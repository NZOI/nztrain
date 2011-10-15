class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :problem

  validates :score, :presence => true
  def judge
    working_directory = '/tmp/submission_' + id.to_s + '/'
    if not File.directory? working_directory 
      Dir.mkdir(working_directory)
    end
    Dir.chdir(working_directory)

    source_file = 'program.c'
    exe_file = 'program.exe'

    # TODO: store compiler info in config file
    compiler = '/usr/bin/gcc'
    if language == 'C++'
      compiler = '/usr/bin/g++'
    end

    File.open(source_file, 'w') { |f| f.write(source) }

    comp_sandbox_opts='-m262144 -w60 -e -i/dev/null'
    comp_output = `box #{comp_sandbox_opts} -- #{compiler} #{source_file} -o #{exe_file}`

    logger.debug 'compiling with ' +  "box #{comp_sandbox_opts} -- #{compiler} #{source_file} -o #{exe_file}"
    logger.debug 'compiler output: ' + comp_output
    # TODO: check compiler output here (compile errors, warnings, etc)

    input_file = problem.input
    output_file = problem.output

    judge_file = "judge.info"

    mem_limit = problem.memory_limit * 1024
    stack_limit = 1024 * 4
    time_limit = problem.time_limit

    self.score = 0
    total_points = 0

    problem.test_cases.each do |test_case|
      File.open(input_file, 'w') { |f| f.write(test_case.input) }

      system("box -a2 -f -M#{judge_file} -m#{mem_limit} -k#{stack_limit} " +
             " -t#{time_limit} -o/dev/null -r/dev/null -- #{exe_file}" )

      print File.open(judge_file, 'r') { |f| f.read } + "\n"
      their_output = File.open(output_file, 'r') { |f| f.read }

      # TODO: different evaluators.
      actual = their_output.split('\n').each{|s|s.strip!}.join('\n')
      expected = test_case.output.split('\n').each{|s| s.strip!}.join('\n')

      logger.debug "actual output was #{actual}, expected #{expected}"

      self.score += test_case.points if actual == expected
      total_points += test_case.points

      # TODO: error checking necessary here?
      # or ruby exceptions takes care of it?
      File.delete(input_file)
      File.delete(output_file)
    end
    self.score *= 100
    self.score /= total_points

    self.save

    File.delete(source_file)
    File.delete(exe_file)
    File.delete(judge_file)
    Dir.chdir('/')
    Dir.rmdir(working_directory)
  end
end

