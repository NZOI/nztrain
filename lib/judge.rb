class Judge
  SourceFileName = "program.source"
  ExeFileName = "program.exe"
  JudgeFileName = "judge.info"
  EvalFileName = "eval.sh"
  ExpectedFileName = "expect.out"
  CompileSandboxOptions ='-m262144 -w60 -e -i/dev/null'
  StackLimitBytes = 1024 * 4

  attr_accessor :program

  def initialize(program)
    self.program = program
  end

  def judge
    result = {}
    setup_judging do
      result[:compile] = compile!(ExeFileName) unless program.language.interpreted

      run_command = "./#{ExeFileName}"
      run_command = program.language.compile_command(:source => ExeFileName) if program.language.interpreted

      result[:test_cases] = {}
      problem.test_cases.each do |test_case|
        FileUtils.copy(File.expand_path(ExeFileName, tmpdir), box.expand_path(ExeFileName))
        result[:test_cases][test_case.id] = judge_test_case(test_case, run_command) unless result[:test_cases].has_key?(test_case.id)
      end

      # test sets
    end
    result
  end

  private
  attr_accessor :problem, :box, :tmpdir
  def setup_judging
    self.problem = program.problem
    Dir.mktmpdir do |tmpdir|
      self.tmpdir = tmpdir
      Isolate.box do |box|
        self.box = box
        yield
      end
    end
  end

  def compile! output
    result = {}
    box.tmpfile(["program", program.language.extension]) do |source_file|
      box.fopen(source_file, 'w') { |f| f.write(program.source) }
      compile_command = program.language.compile_command(:source => source_file, :output => output)
      metafile = File.expand_path("compile.meta", tmpdir)
      box.popen3(compile_command, :mem => 262144, :wall_time => 60, :processes => true, :meta => metafile ) do |stdin, stdout, stderr|
        result[:output] = stdout.read || "No output."
        result[:box] = stderr.read
      end
      result[:meta] = File.open(metafile) { |f| Isolate.parse_meta(f.read) }
    end

    if box.exist?(output)
      FileUtils.copy(box.expand_path(output), File.expand_path(output, tmpdir)) # copy output file to directory
      result[:success] = true
    else
      result[:success] = false
    end

    return result
  ensure
    box.clean!
  end

  def judge_test_case(test_case, run_command)
    result = {}
    box.fopen(program.input,"w") { |f| f.write(test_case.input) } unless program.input.nil?
    metafile = File.expand_path("case#{test_case.id}.meta", tmpdir)
    box.popen3(run_command, :mem => problem.memory_limit*1024, :time => problem.time_limit, :wall_time => 60, :processes => true, :meta => metafile ) do |stdin, stdout, stderr, wait_thr|
      stdin.write(test_case.input) if program.input.nil?
      stdin.close
      result[:output] = stdout.read if program.output.nil?
      result[:box] = stderr.read
    end
    result[:meta] = File.open(metafile) { |f| Isolate.parse_meta(f.read) }
    box.fopen(program.output) { |f| result[:output] = f.read } unless program.output.nil?

    # TODO: evaluator
    return result
  ensure
    box.clean!
  end


#  def compile_old!
#    File.open(SourceFileName, 'w') { |f| f.write(program.source) }
#    language = program.language
#    compiler = language.compiler
#
#    comp_output = `#{self.box_path} #{CompileSandboxOptions} -- #{compiler} #{SourceFileName} -O2 -lm -o #{ExeFileName} 2>&1`
#    
#    if not comp_output
#      comp_output = "No output."
#    end
#
#    is_error = not FileTest.exist? exe_file
#    self.have_compiled = not is_error
#
#    self.judge_output.append({
#      :key => "Compiler Output",
#      :value => comp_output,
#      :is_error => is_error})
#
#    return is_error
#  end
#
#  def setup_judging(program)
#    self.have_compiled = false
#    self.judge_output = []
#    self.program = program
#    self.box_path = File.expand_path(Rails.root)+"/bin/box"
#    if RbConfig::CONFIG["host_cpu"] == "x86_64"
#      self.box_path += "64"
#    end
#    self.working_directory = '/tmp/submission_' + id.to_s + '/'
#    if not File.directory? working_directory
#      Dir.mkdir(self.working_directory)
#    end
#    Dir.chdir(self.working_directory)
#
#    if not program.language.interpreted
#      return self.compile!
#    else
#      File.open(exe_file, 'w') { |f| f.write(source) }
#      self.have_compiled = true
#      return true
#    end
#  end
#
#  def append_error_to_output(error)
#    self.judge_output.append({
#      :key => "Internal Error"
#      :value => error
#      :is_error => true})
#  end
#
#  def judge_test_case(test_case)
#    File.open(input_file, 'w') { |f| f.write(test_case.input) }
#    memory_limit = self.program.problem.memory_limit * 1024
#    time_limit = self.program.problem.time_limit
#
#    system_string = "#{self.box_path} -a2 -M#{JudgeFileName} -m#{memory_limit} -k#{StackLimitBytes} " +
#      " -t#{time_limit} -w#{[time_limit*2,30].max} -o#{output_stream} -r/dev/null -- #{exec_string} < #{input_stream}"
#  end
#
#  def judge(program)
#    if not self.have_compiled
#      append_error_to_output("Attempted to judge before compilation.")
#      return false
#    end
#
#    test_case_results = {}
#    program.problem.test_cases.each do |test_case|
#      test_case_results[test_case] = self.judge_test_case(test_case)
#    end
#  end
end
