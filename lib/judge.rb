class Judge
  SourceFileName = "program.source"
  ExeFileName = "program.exe"
  JudgeFileName = "judge.info"
  EvalFileName = "eval.sh"
  ExpectedFileName = "expect.out"
  CompileSandboxOptions ='-m262144 -w60 -e -i/dev/null'
  StackLimitBytes = 1024 * 4

  def compile!
    File.open(SourceFileName, 'w') { |f| f.write(program.source)
    language = program.language
    compiler = language.compiler

    comp_output = `#{self.box_path} #{CompileSandboxOptions} -- #{compiler} #{SourceFileName} -O2 -lm -o #{ExeFileName} 2>&1`
    
    if not comp_output
      comp_output = "No output."
    end

    is_error = not FileTest.exist? exe_file
    self.have_compiled = not is_error

    self.judge_output.append({
      :key => "Compiler Output",
      :value => comp_output,
      :is_error => is_error})

    return is_error
  end

  def setup_judging(program)
    self.have_compiled = false
    self.judge_output = []
    self.program = program
    self.box_path = File.expand_path(Rails.root)+"/bin/box"
    if RbConfig::CONFIG["host_cpu"] == "x86_64"
      self.box_path += "64"
    end
    self.working_directory = '/tmp/submission_' + id.to_s + '/'
    if not File.directory? working_directory
      Dir.mkdir(self.working_directory)
    end
    Dir.chdir(self.working_directory)

    if not program.language.is_interpreted
      return self.compile!
    else
      File.open(exe_file, 'w') { |f| f.write(source) }
      self.have_compiled = true
      return true
    end
  end

  def append_error_to_output(error)
    self.judge_output.append({
      :key => "Internal Error"
      :value => error
      :is_error => true})
  end

  def judge_test_case(test_case)
    File.open(input_file, 'w') { |f| f.write(test_case.input) }
    memory_limit = self.program.problem.memory_limit * 1024
    time_limit = self.program.problem.time_limit

    system_string = "#{self.box_path} -a2 -M#{JudgeFileName} -m#{memory_limit} -k#{StackLimitBytes} " +
      " -t#{time_limit} -w#{[time_limit*2,30].max} -o#{output_stream} -r/dev/null -- #{exec_string} < #{input_stream}"
  end

  def judge(program)
    if not self.have_compiled
      append_error_to_output("Attempted to judge before compilation.")
      return false
    end

    test_case_results = {}
    program.problem.test_cases.each do |test_case|
      test_case_results[test_case] = self.judge_test_case(test_case)
    end
  end

