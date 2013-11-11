class Isolate

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
    options.assert_valid_keys(:in, :out, :err)
    if command.size == 1 && command[0].is_a?(String)
      command = Shellwords.split(command[0])
    end
    super(*isolate_sandbox(command), options)
  end

  # popen a single command in isolate context
  #
  # Example:
  #   Isolate.box { popen("/bin/ls") {|io| puts io.read} }
  def popen command, mode = "r", &block
    if command.is_a? String
      command = Shellwords.split(command)
    elsif !command.is_a? Array
      raise ArgumentError
    end
    IO.popen isolate_sandbox(command), mode, &block
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
    File.open(isolate_expand(filename), mode, options, &block)
  end

  protected

  def initialize
    response = Kernel.send :`, 'isolock'
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

  private
  def isolate_sandbox command
    ["isolate","-b#{@box_id}","--run","--"] + command
  end

  def isolate_expand filename
    File.expand_path(filename,"/tmp/box/#{@box_id}/box")
  end
end
