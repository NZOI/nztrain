class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :problem

  validates :score, :presence => true

  attr_accessible :problem_id, :source, :language

  # scopes (lazy running SQL queries)
  scope :distinct, select("distinct(submissions.id), submissions.*")

  def self.by_user(user_id)
    where("submissions.user_id IN (?)", user_id.to_s.split(','))
  end
  def self.by_problem(problem_id)
    where("submissions.problem_id IN (?)", problem_id.to_s.split(','))
  end

  def judge
    box_path = File.expand_path(Rails.root)+"/bin/box"
    if Config::CONFIG["host_cpu"] == "x86_64"
      box_path += "64"
    end
    working_directory = '/tmp/submission_' + id.to_s + '/'
    if not File.directory? working_directory 
      Dir.mkdir(working_directory)
    end
    Dir.chdir(working_directory)

    source_file = 'program.c'
    exe_file = 'program.exe'
    judge_file = "judge.info"
    eval_file = "eval.sh"
    expected_file = "expect.out"

    # TODO: store compiler info in config file
    compiler = '/usr/bin/gcc'
    if language == 'C++'
      compiler = '/usr/bin/g++'
    end
    if language == 'Haskell'
      source_file = 'program.hs'
      compiler = '/usr/bin/ghc --make'
    end

    File.open(source_file, 'w') { |f| f.write(source) }

    if problem.evaluator_id
      File.open(eval_file, 'w') { |f| f.write(problem.evaluator.source) }
    end

    self.judge_output = "Judging...\n"

    comp_sandbox_opts='-m262144 -w60 -e -i/dev/null'
    comp_output = `#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file} 2>&1`

    if comp_output == ""
      comp_output = "nothing"
    end

    self.judge_output += 'compiling with ' +  "#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file}\n"

    self.judge_output += "compiler output:\n" + comp_output + "\n"

    self.score = 0
    total_points = 0


    # TODO: check compiler output here (compile errors, warnings, etc)
    if FileTest.exist? exe_file
      input_file = problem.input
      output_file = problem.output

      mem_limit = problem.memory_limit * 1024
      stack_limit = 1024 * 4
      time_limit = problem.time_limit
      number = 0

      problem.test_cases.each do |test_case|
        number += 1
        self.judge_output += "Test Case #{number} (#{test_case.points} points):\n"
        total_points += test_case.points

        File.open(input_file, 'w') { |f| f.write(test_case.input) }

        system("#{box_path} -a2 -M#{judge_file} -m#{mem_limit} -k#{stack_limit} " +
               " -t#{time_limit} -o/dev/null -r/dev/null -- #{exe_file}" )

        judge_msg = IO.read(judge_file)

        self.judge_output += judge_msg
        correct = false
        
        if FileTest.exist?(output_file) == false
          self.judge_output += "No output, probably crashed\n"
        elsif judge_msg.include?("status")
          self.judge_output += "Terminated by judge\n"
        else
          expected = test_case.output.split('\n').each{|s| s.strip!}.join('\n').chomp.gsub(/\r/, "")

          #logger.info("writing expected");
          File.open(expected_file, 'w') { |f| f.write(expected) }
          #logger.info("finished writing expected");

          if !problem.evaluator
            if FileTest.exists?(output_file)
               their_output = IO.read(output_file)
            else
               their_output = nil
            end

            actual = their_output.split('\n').each{|s|s.strip!}.join('\n').chomp.gsub(/\r/, "")

            logger.debug "actual output was #{actual}, expected #{expected}"

            if actual == expected
              correct = true
            end
          else
            File.chmod(0700, eval_file)
            run_string = "./#{eval_file} #{input_file} #{output_file} #{expected_file}"
            logger.info "running " + run_string
            correct = system(run_string)
            self.judge_output += "running " + run_string + "\n"
            self.judge_output += "correct is " + correct.to_s + "\n"
            
            if correct == nil
              self.judge_output += "Evaluator packed a sad, sorry :(\n"
            end
          end

          if correct
            logger.info "test case with id " + test_case.id.to_s + " was correct"
            self.score += test_case.points 
            self.judge_output += "Correct!\n"
          else
            logger.info "test case with id " + test_case.id.to_s + " was incorrect"
            self.judge_output += "Incorrect :(\n"
          end

          File.delete(output_file) if FileTest.exists?(output_file)
          File.delete(expected_file) if FileTest.exists?(expected_file)
        end

        self.judge_output += "\n<br />\n"
        # TODO: error checking necessary here?
        # or ruby exceptions takes care of it?
        if FileTest.exists?(input_file)
          File.delete(input_file)
        end
      end

      self.judge_output += "Submission scored #{self.score} points out of #{total_points}\n"

      self.score *= 100
      self.score /= total_points

      if self.score == 100
        self.judge_output += "Congratulations! 100%!\n"
      end

      File.delete(exe_file) if FileTest.exists?(exe_file)

      if problem.evaluator
        File.delete(eval_file)
      end
    else
      self.judge_output += "Program did not compile!\n"
    end

    self.save

    File.delete(source_file) if FileTest.exist? source_file
    File.delete(judge_file) if FileTest.exist? judge_file
    Dir.chdir('/')
    FileUtils.rm_rf(working_directory)
  end
end
