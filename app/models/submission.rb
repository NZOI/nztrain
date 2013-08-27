class Submission < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  belongs_to :user
  belongs_to :problem
  
  validates :source, :presence => true

  sifter :for_contestant do |u_id|
    (user_id == u_id) & (problem_id >> Problem.select(:id).joins(:contest_relations).where{ contest_relations.sift(:is_active) & (contest_relations.user_id == u_id) })
  end

  after_save do
    if self.score_changed? # only update if score changed
      self.contests.select("contest_relations.id, contests.finalized_at").find_each do |record|
        # only update contest score if contest not yet sealed
        if record.finalized_at.nil? # are results finalized?
          ContestScore.find_or_initialize_by_contest_relation_id_and_problem_id(record.id,self.problem_id).recalculate_and_save
        end
      end
    end
  end

  def contests
    # check if this submission's problem belongs to a contest that the user is competing in
    @_mycontests ||= Contest.joins(:contest_relations, :problems).where(:contest_relations => {:user_id => user_id}, :problems => {:id => self.problem_id}).where("contest_relations.started_at <= ? AND contest_relations.finish_at > ?", self.created_at, self.created_at)
  end

  # scopes (lazy running SQL queries)
  scope :distinct, select("distinct(submissions.id), submissions.*")

  def self.by_user(user_id)
    where("submissions.user_id IN (?)", user_id.to_s.split(','))
  end

  def self.by_problem(problem_id)
    where("submissions.problem_id IN (?)", problem_id.to_s.split(','))
  end

  def source_file=(file)
    self.source = IO.read(file.path)
  end

  before_save do
    if source_was.nil?
      problem = Problem.find(self.problem_id)
      self.input = problem.input
      self.output = problem.output
    end
    true
  end

  def judge
    box_path = File.expand_path(Rails.root)+"/bin/box"
    if RbConfig::CONFIG["host_cpu"] == "x86_64"
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


    if problem.evaluator_id
      File.open(eval_file, 'w') { |f| f.write(problem.evaluator.source.gsub /\r\n?/, "\n") } # gsub added to normalize line endings (otherwise script might not run properly)
    end

    self.judge_output = "Judging...\n"

    self.debug_output = "Judging...\n"
    # TODO: store compiler info in config file
    if language != 'Python'
      File.open(source_file, 'w') { |f| f.write(source) }
      compiler = '/usr/bin/gcc'
      if language == 'C++'
        compiler = '/usr/bin/g++'
      end
      if language == 'Haskell'
        source_file = 'program.hs'
        compiler = '/usr/bin/ghc --make'
      end


      comp_sandbox_opts='-m262144 -w60 -e -i/dev/null'
      comp_output = `#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file} 2>&1`

      if comp_output == ""
        comp_output = "nothing"
      end

      self.judge_output += '<i>compiling with ' +  "#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file}</i>\n"

      self.judge_output += "<i><b style=\"color:black\">compiler output:</b></i>\n<pre>" + comp_output.gsub("\n", "<br />") + "</pre>\n"
    else
      self.judge_output += "<i>interpreted language, not compiling</i>\n"
      File.open(exe_file, 'w') { |f| f.write(source) }
    end

    self.score = 0
    total_points = 0


    # TODO: check compiler output here (compile errors, warnings, etc)
    if FileTest.exist? exe_file
      exec_string = exe_file
      if language == 'Python'
        exec_string = '/usr/bin/python ' + exe_file
      end
      input_file = self.input
      output_file = self.output
      input_stream = "/dev/null"
      output_stream = "/dev/null"
      if input_file.nil?
        input_file = "data.in"
        input_stream = "#{input_file}"
      end
      if output_file.nil?
        output_file = "data.out"
        output_stream = "#{output_file}"
      end

      mem_limit = problem.memory_limit * 1024
      stack_limit = 1024 * 4
      time_limit = problem.time_limit

      problem.test_sets.each_with_index do |test_set,number|
        self.judge_output += "Test Set #{1+number} (#{test_set.points} points):\n"
        # print table headers
        self.judge_output += "<table border = \"1\"><tr> <th style=\"width:6%\">Test Case</th> <th style=\"width:44%\">Message</th> <th style=\"width:10%\">Memory/kb</th> "
        self.judge_output += "<th style=\"width:15%\">Time/s</th> <th style=\"width:25%\">Result</th> </tr>"

        total_points += test_set.points
        numcorrect = 0
        test_set.test_cases.each_with_index do |test_case,case_number|
          #self.judge_output += "Test Case #{1+case_number}:\n"
          self.judge_output += "<tr style=\"text-align:center\"><td>#{1+case_number}</td>"

          File.open(input_file, 'w') { |f| f.write(test_case.input) }
          system_string = "#{box_path} -a2 -M#{judge_file} -m#{mem_limit} -k#{stack_limit} " +
                 " -t#{time_limit} -w#{[time_limit*2,30].max} -o#{output_stream} -r/dev/null -- #{exec_string} < #{input_stream}"
          system(system_string)
          self.debug_output += system_string + "\n"

          program_output = system(system_string)

          judge_msg = IO.read(judge_file) # judge message received here, after running the submission
          
          # ==judge message output in cells== #
          judge_msg_hash = Hash[judge_msg.each_line.map { |line| line.chomp.split(":", 2) }]
          # table cells [Test Case] ([Message][Memory Used][Time Taken]) [Result]
          self.judge_output += "<td>" + ((judge_msg_hash["message"]==nil) ? ("") : (judge_msg_hash["message"])) + "</td>"
          self.judge_output += "<td>" + judge_msg_hash["mem"] + "</td>"
          self.judge_output += "<td>" + judge_msg_hash["time-wall"] + "</td>"
          # ==end of judge message processing== #
          
          self.judge_output += "<td style=\"color:FireBrick\">" # start of cell in Results column
          correct = false
        
          if FileTest.exist?(output_file) == false
            self.judge_output += "No output file - ensure output was to the correct file\n"
          elsif IO.read(output_file) == ""
            self.judge_output += "Empty output\n"
          elsif judge_msg.include?("status")
            self.judge_output += "Terminated by judge\n"
          else
            expected = test_case.output.split('\n').each{|s| s.strip!}.join('\n').chomp.gsub(/\r/, "")

            #logger.debug("writing expected");
            File.open(expected_file, 'w') { |f| f.write(expected) }
            #logger.debug("finished writing expected");

            if !problem.evaluator
              if FileTest.exists?(output_file)
                 their_output = IO.read(output_file)
              else
                 their_output = nil
              end

              actual = their_output.split('\n').each{|s|s.strip!}.join('\n').chomp.gsub(/\r/, "")

              self.debug_output +=  "actual output was #{actual}, expected #{expected}\n"

              if actual == expected
                correct = true
              end
            else
              File.chmod(0700, eval_file)
              run_string = "./#{eval_file} #{input_file} #{output_file} #{expected_file}"
              logger.debug "running " + run_string
              correct = system(run_string)
            
              if correct == nil
                self.judge_output += "Evaluator packed a sad, sorry :(\n"
              end
            end

            if correct
              numcorrect += 1
              logger.debug "test case with id " + test_case.id.to_s + " was correct"
              #self.score += test_case.points 
              self.judge_output += "<b><green style=\"color:Green\">" + "Correct!\n" + "</green></b>"
            else
              logger.debug "test case with id " + test_case.id.to_s + " was incorrect"
              self.judge_output += "Incorrect :(\n"
            end

            File.delete(output_file) if FileTest.exists?(output_file)
            File.delete(expected_file) if FileTest.exists?(expected_file)
          end

          self.judge_output += "</td></tr>" # end of table row

          if FileTest.exists?(input_file)
            File.delete(input_file)
          end
          # TODO: error checking necessary here?
          # or ruby exceptions takes care of it?

        end

        self.judge_output += "</table>"
        if numcorrect == test_set.test_cases.size
          self.judge_output += "Test Set #{1+number} result: Correct (+#{test_set.points} points)\n"
          self.score += test_set.points
        else
          self.judge_output += "Test Set #{1+number} result: Incorrect (+0 points)\n"
        end
        self.judge_output += "\n<br />\n"
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
