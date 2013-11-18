class Judge
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
      if program.language.interpreted
        File.open(File.expand_path(ExeFileName, tmpdir)) { |f| f.write(program.source) }
      else
        result['compile'] = compile!(ExeFileName) # possible caching
      end

      run_command = "./#{ExeFileName}"
      run_command = program.language.compile_command(:source => ExeFileName) if program.language.interpreted

      # test cases
      result['test_cases'] = {}
      problem.test_cases.each do |test_case|
        FileUtils.copy(File.expand_path(ExeFileName, tmpdir), box.expand_path(ExeFileName))
        result['test_cases'][test_case.id] = judge_test_case(test_case, run_command) unless result['test_cases'].has_key?(test_case.id)
      end

      # test sets
      result['test_sets'] = {}
      problem.test_sets.each do |test_set|
        result['test_sets'][test_set.id] = grade_test_set(test_set, result['test_cases'])
      end

      result.merge!(grade_program(result['test_sets']))
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
      resource_limits = { :mem => 262144, :wall_time => 60, :processes => true }
      result['output'], result['box'], status = box.capture3(compile_command, resource_limits.reverse_merge(:meta => metafile, :stderr => '/dev/null'))
      result['output'] = "No output." if result['output'].empty?
      result['stat'] = status.to_i
      result['meta'] = File.open(metafile) { |f| Isolate.parse_meta(f.read) }
    end
    FileUtils.copy(box.expand_path(output), File.expand_path(output, tmpdir)) if result['stat']
    return result
  ensure
    box.clean!
  end

  def judge_test_case(test_case, run_command)
    result = run_test_case(test_case, run_command)
    result['evaluator'] = evaluate_output(test_case, result['output'], problem.evaluator)
    result
  end

  def run_test_case(test_case, run_command)
    result = {}
    box.fopen(program.input,"w") { |f| f.write(test_case.input) } unless program.input.nil?
    metafile = File.expand_path("case#{test_case.id}.meta", tmpdir)
    resource_limits = { :mem => problem.memory_limit*1024, :time => problem.time_limit, :wall_time => problem.time_limit*3+5 }
    run_opts = resource_limits.reverse_merge(:processes => false, :meta => metafile, :stderr => '/dev/null', :stdin_data => test_case.input)
    result['output'], result['box'], status = box.capture3(run_command, run_opts)
    result['stat'] = status.to_i
    result['meta'] = File.open(metafile) { |f| Isolate.parse_meta(f.read) }
    box.fopen(program.output) { |f| result['output'] = f.read } unless program.output.nil?
    return result
  ensure
    box.clean!
  end

  def evaluate_output(test_case, output, evaluator)
    expected = conditioned_output(test_case.output)
    actual = conditioned_output(output)
    if evaluator.nil?
      {'evaluation' => (actual == expected ? 1 : 0), 'meta' => {'status' => 'OK'}}
    else
      result = {}
      box.fopen(EvalFileName,"w") do |file|
        file.chmod(0700)
        file.write(problem.evaluator.source.gsub(/\r\n?/, "\n"))
      end
      metafile = File.expand_path("eval#{test_case.id}.meta", tmpdir)
      resource_limits = { :mem => 262144, :time => problem.time_limit, :wall_time => problem.time_limit*3+30 }
      box.fopen("actual","w") { |f| f.write(actual) } # DEPRECATED
      box.fopen("input","w") { |f| f.write(test_case.input) } # DEPRECATED
      box.fopen("expected","w") { |f| f.write(expected) } # DEPRECATED
      deprecated_args = "input actual expected" # DEPRECATED
      eval_output = nil
      str_to_pipes(test_case.input, expected) do |input_stream, output_stream|
        run_opts = resource_limits.reverse_merge(:processes => true, :meta => metafile, 3 => input_stream, 4 => output_stream, :stdin_data => actual)
        #run_opts = resource_limits.reverse_merge(:processes => true, :meta => metafile)
        #### TODO: Fix interpreter directive not working through isolate
        output, result['box'], status = box.capture3("./#{EvalFileName} #{deprecated_args}", run_opts )
        eval_output = output.strip.split(nil,2)
        result['stat'] = status.to_i
      end
      result['meta'] = File.open(metafile) { |f| Isolate.parse_meta(f.read) }
      if eval_output.empty? # DEPRECATED
        result['evaluation'] = 0 if result['stat'] == 1 && result['meta']['status'] == 'RE' && result['meta']['exitcode'] == 1 # DEPRECATED
        result['evaluation'] = 1 if result['stat'] == 0 # DEPRECATED
      else
        result['evaluation'] = eval_output[0].to_f
        result['message'] = eval_output[1]
        result.delete('evaluation') if result['meta']['status'] != 'OK'
      end
      result
    end
  ensure
    box.clean!
  end

  def grade_test_set test_set, evaluated_test_cases
    result = {}
    pending, error, sig = false, false, false
    evaluations = test_set.test_case_relations.map do |relation|
      id = relation.test_case_id
      next pending = true unless evaluated_test_cases.has_key?(id)
      test = evaluated_test_cases[id]
      break error = true if test['stat'] == 2 || !test['evaluator'].has_key?('evaluation')
      sig = true if test['stat'] != 0
      test['evaluator'].fetch('evaluation', 0)
    end

    result['status'] = 0
    result['status'] = 1 if pending
    result['status'] = 2 if error
    if result['status'] == 0
      # test set = min case score
      result['evaluation'] = evaluations.min
      result['evaluation'] = 0 if sig # any signal/runtime error/timeout fails the test set
    end
    result
  end

  def grade_program(graded_sets)
    test_sets = problem.test_sets
    sets = graded_sets.values_at(*test_sets.map(&:id))
    result = {}
    result['status'] = [*sets.map{ |s| s['status'] }, (sets.compact.count<sets.count) ? 1 : 0].max
    if result['status'] == 0
      denominator = test_sets.map(&:points).inject(&:+)
      numerator = test_sets.map{ |s| (graded_sets[s.id]['evaluation'] * s.points).floor }.inject(&:+)
      result['evaluation'] = numerator/denominator
      result['score'] = (result['evaluation']*100).floor
    end
    result
  end

  # Utility methods
  def str_to_pipes(*strings)
    pipes = strings.map do |str|
      r, w = IO.pipe
      Thread.new { w.write(str); w.close } # to avoid full pipe deadlocks
      r
    end
    result = yield *pipes
    pipes.each(&:close)
    result
  end

  def conditioned_output output
    output.split("\n").map{|s|s.rstrip.chomp}.join("\n").chomp << "\n"
  end
  
end
