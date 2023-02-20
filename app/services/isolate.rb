require 'open3'

class Isolate
  private
  RESOURCE_OPTIONS = { :time => '-t', :wall_time => '-w', :extra_time => '-x', :mem => '-m', :stack => '-k', :processes => '-p', :meta => '-M', :stderr => '-r', :stdin => '-i', :stdout => '-o', :cg => '--cg', :cg_timing => '--cg-timing', :cg_mem => '--cg-mem=', :inherit_fds => '--inherit-fds' } # TODO: :quota
  CONFIG = YAML.load_file(File.expand_path('config/isolate.yml', Rails.root)).symbolize_keys
  META = { 'time' => :to_f, 'time-wall' => :to_f, 'max-rss' => :to_i, 'csw-voluntary' => :to_i, 'csw-forced' => :to_i, 'killed' => :to_i, 'cg-mem' => :to_i, 'exitsig' => :to_i, 'exitcode' => :to_i }

  public
  # Create an isolate box to execute commands within.
  # Pass a block which will be instance_exec-ed, giving access to exec, popen, fopen, ...
  # 
  # Alternatively, the isolate box is passed as an argument to a block with an arity, which is not instance_exec-ed
  def self.box options = {}, &block
    options.reverse_merge!(:cg => has_cgroups?).assert_valid_keys(:cg)
    raise CGroupsUnavailableError if options[:cg] && !has_cgroups?
    isolate = self.new(options)
    yield isolate if block_given?
    true
  rescue LockError => e
    false
  ensure
    isolate.send(:destroy, options) if !isolate.nil?
  end
  
  class LockError < StandardError; end
  class UnlockError < StandardError; end
  class CGroupsUnavailableError < StandardError; end

  # Execute a single command in isolate context
  # 
  # Examples:
  #   Isolate.box { exec("/bin/ls", "/") }
  #   Isolate.box { exec("/bin/ls /") }
  #   Isolate.box do |box|
  #     box.exec "/bin/touch asdf"
  #     box.exec "/bin/ls"
  #   end
  #
  # options
  # :in
  #   specify stdin (filename, symbol, pipe), and optionally flags
  # :out
  #   specify stdout
  # :err
  #   specify stderr
  def exec command, options = {}
    sandbox_command(command, options) do |command, options|
      system(*command, options.reverse_merge(:close_others => true))
    end
  end

  # popen a single command in isolate context
  #
  # Example:
  #   Isolate.box { popen("/bin/ls") {|io| puts io.read} }
  def popen command, mode = "r", options = {}, &block
    options, mode = mode, "r" if mode.is_a? Hash

    sandbox_command(command) do |command, options|
      IO.popen [*command, options], mode, &block
    end
  end

  ['2', '2e', '3'].each do |suffix|
    class_eval <<EOF
      def popen#{suffix} command, options = {}, &block
        sandbox_command(command, options) do |command, options|
          Open3.popen#{suffix} *command, options, &block
        end
      end

      def capture#{suffix} command, options = {}, &block
        stdin_data = options.delete(:stdin_data) || ''
        binmode = options.delete(:binmode)
        opts = options.extract!(:output_limit, :clean_utf8)
        popen#{suffix} command, options do |i, *p, t|
          if binmode
            i.binmode
            p.each(&:binmode)
          end
          count = opts.fetch(:output_limit, nil)
          pipe_reader = p.map { |p| Thread.new { count ? read_pipe_limited(p, count) : p.read } }
          begin
            i.write stdin_data
          rescue Errno::EPIPE
          end
          i.close
          values = pipe_reader.map(&:value)
          values.map!{|v|clean_utf8(v)} if opts.fetch(:clean_utf8, false)
          [*values, t.value]
        end
      end
EOF
  end

  # like capture3, but isolate overrides stderr, so capture3 returns [stdout_and_stderr, box-stderr, status]
  # capture5 returns [stdout, stderr, box-stderr, meta, status]
  # meta is the key-value list of information isolate outputs related to resource usage, signals and how the program exited
  def capture5 command, options = {}, &block
    # if isolate adds functionality to close file descriptors box_inside before execve, these files can be converted to pipes without security implications
    opts = options.slice(:output_limit, :clean_utf8)
    metafile = Tempfile.new('metafile')
    logfile = tmpfile
    options.reverse_merge!(:stderr => logfile, :meta => metafile.path)
    stdout, boxlog, status = capture3(command, options, &block)
    metafile.open
    meta = self.class.parse_meta(metafile.read)
    count = opts.fetch(:output_limit, nil)
    stderr = File.open(expand_path(logfile)) { |f| count ? read_pipe_limited(f, count) : f.read }
    stderr = clean_utf8(stderr) if opts.fetch(:clean_utf8, false)
    return stdout, stderr, boxlog, meta, status
  ensure
    metafile.close! unless metafile.nil?
    FileUtils.remove(expand_path(logfile)) unless logfile.nil?
  end

  # Identical to File.open, except that the filename is automatically appended to the box path
  #
  # Example:
  #   Isolate.box do |box|
  #     box.fopen("test","w") { |f| f.write("hello world\n") }
  #     box.exec("/bin/cat test")
  #   end
  def fopen filename, mode = "r", options = {}, &block
    File.open(expand_path(filename), mode, options, &block)
  end

  def tmpfile basename = 'tmpfile'
    basename = Array(basename) + ['']
    tmpname = 'tmp/' + basename.join
    prng = Random.new
    int = prng.rand(100)
    while File.exist?(fullname = expand_path(tmpname))
      int += prng.rand(11..100)
      tmpname = 'tmp/' + basename[0] + int.to_s + basename[1]
    end
    FileUtils.mkdir_p(File.dirname(fullname))
    FileUtils.touch(fullname)

    if block_given?
      begin
        yield tmpname
      ensure
        FileUtils.remove(fullname)
      end
    else
      return tmpname
    end
  end

  def exist? filename
    File.exist?(expand_path(filename))
  end

  # cleans the box directory of any files by re-initializing
  def clean!
    system "isolate -b#{@box_id} --cleanup #{"--cg" if has_cgroup?}", :out => '/dev/null'
    system "isolate -b#{@box_id} --init #{"--cg" if has_cgroup?}", :out => '/dev/null'
    init_boxdir()
  end

  def expand_path filename
    File.expand_path(filename,"/var/local/lib/isolate/#{@box_id}/box")
  end

  def clean_utf8 string
    return clean_utf8(string[0]), *string.drop(1) if string.is_a?(Array)
    string.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace)
  end

  def read_pipe_limited(pipe, count)
    string = (pipe.read(count) || "")
    [string, File.open(File::NULL, "w") { |nul| string.bytesize + IO.copy_stream(pipe, nul) }]
  end

  protected

  def initialize(options = {})
    @has_cgroup = !!options[:cg]
    @box_id = Kernel.send(:`, "isolock --lock -- #{"--cg" if has_cgroup?}").to_i
    raise LockError unless $?.success?
    init_boxdir()
    @box_id
  end

  def init_boxdir
    FileUtils.mkdir(expand_path('tmp')) # make tmp directory in box
  end

  def destroy(options = {})
    return if @box_id.nil?
    system "isolock --free -- #{@box_id} #{"--cg" if has_cgroup?}", :out => '/dev/null'
    raise UnlockError unless $?.success?
  end

  def has_cgroup?
    @has_cgroup
  end

  def extract_resource(options)
    options.extract!(*RESOURCE_OPTIONS.keys).select{|k,v|v}
  end

  def sandbox_command command, options = {}
    boxcmd = ["isolate","-b#{@box_id}"] + directory_bindings(options.extract!(:noexec)) + sandbox_options(extract_resource(options)) + environment + ["--run","--"]
    yield boxcmd + process_command(command), options
  end

  def sandbox_options options = {}
    if has_cgroup?
      options[:cg] = "" unless options.delete(:cg) == false
      options[:cg_timing] = "" unless options.delete(:cg_timing) == false || !options.has_key?(:cg)
      unless options.delete(:cg_mem) == false || !options.has_key?(:cg) || !options.has_key?(:mem)
        # mem (virtual address space) includes shared library memory which causes problems with the .so libraries python loads
        options[:cg_mem] = options[:mem]
        options.delete(:mem) # control group memory excludes address memory that references library memory shared with other applications
      end
    elsif !!options[:cg]
      raise CGroupsUnavailableError
    end

    options[:processes] = 1 if options[:processes] == false
    options[:processes] = "" if options[:processes] == true
    options[:inherit_fds] = "" if options.delete(:inherit_fds) == true
    options.map{ |k,v| "#{RESOURCE_OPTIONS[k]}#{v}" }
  end

  def directory_bindings options = {}
    options.reverse_merge!({:noexec => false}).assert_valid_keys(:noexec)
    {
      'bin' => [], # core executables
      'dev' => ['dev'], # device files
      'lib' => [], # core libraries
      'lib64' => [], # 64-bit libraries
      'usr' => [], # general binaries, includes and libraries
      'opt' => [], # for ghc from ppa:hvr/ghc
      'etc' => [],
      #'etc/alternatives' => [], # required for many symbolic links to work
      #'etc/j' => [], # required for J to work (load profile)
    }.map do |dir, opt|
      fullpath = File.expand_path(dir, isolate_root)
      boxpath = File.expand_path(dir, "/")
      opt << 'noexec' if options[:noexec]
      binding = opt.unshift(fullpath).join(':')
      next "--dir=#{boxpath}=" unless File.exist?(fullpath)
      "--dir=#{boxpath}=#{binding}"
    end.compact
  end

  # returns root if debootstrap enabled
  def isolate_root
    CONFIG[:root]
  end

  def environment
    Shellwords.split(`cat #{isolate_root}/etc/environment`).map do |pair|
      "--env=#{pair}"
    end + ["--env=HOME=/box"]
  end

  def process_command command
    if command.is_a? String
      command = Shellwords.split(command)
    elsif command.is_a? Array
      command
    else
      raise ArgumentError
    end
  end

  def pipe_to_string(num = 1)
    pipes = 1.upto(num).map do
      IO.pipe
    end
    readers = pipes.map(&:first).map{ |r| Thread.new { r.read; r.close } }
    ws = pipes.map(&:last)
    result = yield *ws
    ws.each(&:close)
    readers.map(&:value)+Array(result)
  end

  class << self
    def parse_meta raw
      Hash[raw.split("\n").map{|kv|kv.strip.split(':',2)}.map{|k,v|[k,v.send(META.fetch(k,:to_s))]}].reverse_merge!('status' => 'OK')
    end

    def has_cgroups?
      !!CONFIG[:cgroups]
    end
  end
end
