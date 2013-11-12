class Isolate
  RESOURCE_OPTIONS = { :time => '-t', :wall_time => '-w', :mem => '-m', :stack => '-k' }
  CONFIG = YAML.load_file(File.expand_path('config/isolate.yml', Rails.root))

  # Create an isolate box to execute commands within.
  # Pass a block which will be instance_exec-ed, giving access to system, popen, fopen, ...
  # 
  # Alternatively, the isolate box is passed as an argument to a block with an arity, which is not instance_exec-ed
  def self.box &block
    isolate = self.new
    if block.arity == 0
      isolate.instance_exec &block
    else
      yield isolate
    end if block_given?
    true
  rescue LockError => e
    false
  ensure
    isolate.send :destroy
  end
  
  class LockError < StandardError; end
  class UnlockError < StandardError; end

  # Execute a single command in isolate context
  # 
  # Examples:
  #   Isolate.box { system("/bin/ls", "/") }
  #   Isolate.box { system("/bin/ls /") }
  #   Isolate.box do |box|
  #     box.system "/bin/touch asdf"
  #     box.system "/bin/ls"
  #   end
  #
  # options
  # :in
  #   specify stdin (filename, symbol, pipe), and optionally flags
  # :out
  #   specify stdout
  # :err
  #   specify stderr
  def system *command
    options = command.extract_options!
    options.assert_valid_keys(:in, :out, :err, *RESOURCE_OPTIONS.keys)
    if command.size == 1 && command[0].is_a?(String)
      command = Shellwords.split(command[0])
    end
    super(*self.class.send(:sandbox_command, @box_id, command, options.extract!(*RESOURCE_OPTIONS.keys).select{|k,v|v}), options)
  end

  # popen a single command in isolate context
  #
  # Example:
  #   Isolate.box { popen("/bin/ls") {|io| puts io.read} }
  def popen command, mode = "r", options = {}, &block
    options.assert_valid_keys(*RESOURCE_OPTIONS.keys)
    if command.is_a? String
      command = Shellwords.split(command)
    elsif !command.is_a? Array
      raise ArgumentError
    end
    IO.popen self.class.send(:sandbox_command, @box_id, command, options), mode, &block
  end

  # Example:
  #   Isolate.box { puts `/bin/ls /` }
  def `(command)
    r, w = IO.pipe
    system(command, {:out => w})
    w.close
    output = r.read
    r.close
    output
  end

  # Identical to File.open, except that the filename is automatically appended to the box path
  #
  # Example:
  #   Isolate.box do
  #     fopen("test","w") { |f| f.write("hello world\n") }
  #     system("/bin/cat test")
  #   end
  def fopen filename, mode = "r", options = {}, &block
    File.open(self.class.send(:file_expand, @box_id, filename), mode, options, &block)
  end

  protected

  def initialize
    response = Kernel.send :`, "isolock --lock"
    if $?.success?
      @box_id = response.to_i
    else
      raise LockError
    end
  end

  def destroy
    return if @box_id.nil?
    Kernel.system "isolock --free #{@box_id}"
    raise UnlockError unless $?.success?
  end

  class << self
    private
    def sandbox_command box_id, command, options = {}
      ["isolate","-b#{box_id}"] + options.map{ |k,v| "#{RESOURCE_OPTIONS[k]}#{v}" } + directory_bindings + environment + ["--run","--"] + command
    end

    def file_expand box_id, filename
      File.expand_path(filename,"/tmp/box/#{box_id}/box")
    end

    def directory_bindings
      %w{bin dev lib lib64 usr}.map do |dir|
        fullpath = File.expand_path(dir, isolate_root)
        next nil unless File.exist?(fullpath)
        "--dir=#{File.expand_path(dir, "/")}=#{fullpath}"
      end.compact
    end

    # returns root if debootstrap enabled
    def isolate_root
      CONFIG['root']
    end

    def environment
      Shellwords.split(`cat #{isolate_root}/etc/environment`).map do |pair|
        "--env=#{pair}"
      end
    end
  end
end
