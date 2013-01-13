require 'timeout'

class AiContestGame < ActiveRecord::Base
  belongs_to :ai_contest
  belongs_to :ai_submission_1, :class_name => :AiSubmission
  belongs_to :ai_submission_2, :class_name => :AiSubmission
  

  def getSubmissionExe(box_path, submission)
    name = "program_" + submission.id.to_s
    source_file = name + ".c"
    exe_file = name + ".exe"
    source = submission.source
    language = submission.language
    if language != 'Python'
      File.open(source_file, 'w') { |f| f.write(source) }
      compiler = '/usr/bin/gcc'
      if language == 'C++'
        compiler = '/usr/bin/g++'
      end
      if language == 'Haskell'
        source_file = name + '.hs'
        compiler = '/usr/bin/ghc --make'
      end

      comp_sandbox_opts='-m262144 -w60 -e -i/dev/null'
      comp_output = `#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file} 2>&1`

      if comp_output == ""
        comp_output = "nothing"
      end

      self.judge_output += 'compiling with ' +  "#{box_path} #{comp_sandbox_opts} -- #{compiler} #{source_file} -O2 -lm -o #{exe_file}\n"

      self.judge_output += "compiler output:\n" + comp_output + "\n"
    else
      self.judge_output += "interpreted language, not compiling\n"
      File.open(exe_file, 'w') { |f| f.write(source) }
    end

    exe_file
  end

  def getExeString(box_path, judge_file, mem_limit, stack_limit, time_limit, exe_file, language)
    if language == "Python"
      exec = '/usr/bin/python ' + exe_file
    else
      exec = exe_file
    end
    exec_string = "\"#{box_path} -a2 -M#{judge_file} -m#{mem_limit} -k#{stack_limit} " +
                 " -t#{time_limit} -w#{[time_limit*2,30].max} -r/dev/null -- #{exec}\""

    exec_string
  end

  def judge
    self.judge_output = ""
    begin
      Timeout.timeout(60) do
        box_path = File.expand_path(Rails.root)+"/bin/box"
        mem_limit = 100*1024
        stack_limit = 4*1024
        time_limit = 5

        if RbConfig::CONFIG["host_cpu"] == "x86_64"
          box_path += "64"
        end
        working_directory = '/tmp/game_' + id.to_s + '/'
        if not File.directory? working_directory 
          Dir.mkdir(working_directory)
        end
        Dir.chdir(working_directory)

        judge_file = "eval.sh"
        score_file = "scores.txt"
        record_file = "record.txt"

        contestant_1 = getSubmissionExe(box_path, ai_submission_1)
        contestant_2 = getSubmissionExe(box_path, ai_submission_2)

        File.open(judge_file, 'w') { |f| f.write(ai_contest.judge.gsub /\r\n?/, "\n") } # gsub added to normalize line endings (otherwise script might not run properly)

        if !((FileTest.exist? contestant_1) and (FileTest.exist? contestant_2))
          self.judge_output += "One of the submissions did not compile\n"
          return
        end

        contestant_1_string = getExeString(box_path, "log1.out", mem_limit, stack_limit, time_limit, contestant_1, ai_submission_1.language)
        contestant_2_string = getExeString(box_path, "log2.out", mem_limit, stack_limit, time_limit, contestant_2, ai_submission_2.language)

        File.chmod(0700, judge_file)
        system_string = "./#{judge_file} #{self.iteration} #{score_file} #{contestant_1_string} #{contestant_2_string} > #{record_file}"
        system(system_string)
        # store record in db
        # get scores to put in db
        self.record = IO.read(record_file)
        self.score_1, self.score_2 = IO.read(score_file).split(" ").map{|x|x.to_i}

        self.save

        Dir.chdir('/')
        FileUtils.rm_rf(working_directory)
      end
    rescue Exception
      self.judge_output = "Exception raised!"
    end
  end
end
