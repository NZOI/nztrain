class ProblemSeries
  class ImportWorker < Base
    def perform
      imports = job.data['operations']

      volumes = job.data['volume_id'] ? [job.data['volume_id'].to_i] : 0...(importer.index.size)
      volumes.each do |vid|
        issues = job.data['volume_id'] && job.data['issue_id'] ? [job.data['issue_id'].to_i] : 0...(importer.volume(vid)[:contests].size)
        issues.each do |num|
          pids = job.data['volume_id'] && job.data['issue_id'] && job.data['problem_ids'] ? job.data['problem_ids'] : 0...(importer.contest(vid, num)[:problems].size)

          importer.process(vid, num) do |index, data, pid, paths|
            next unless pids.include?(pid)

            job.log "Processing problem #{vid}:#{num}:#{pid}"

            problem = (index[:problem_id].nil? ? Problem.new(name: index[:name], owner_id: 0) : Problem.find(index[:problem_id]))
            manager = ProblemImportManager.new(problem, index, data, paths, job, importer, vid, num)

            ## import attributes
            manager.import_attributes(replace: replace?) if imports.include?('attributes')

            ## import statement
            manager.import_statement if imports.include?('statement') and (replace? or not manager.detect_statement?)

            ## import images
            data[:images].values.each do |filename|
              manager.import_image(filename) if imports.include?('images') and (replace? or not manager.detect_image?(filename))
            end

            ## import test cases
            manager.import_test_cases if imports.include?('test_cases') and (replace? or not manager.detect_test_cases?)

            ## test submissions
            manager.clean_submissions_index
            manager.import_model if imports.include?('submissions') and (replace? or not manager.detect_model?)
            manager.import_test_submissions if imports.include?('submissions')

            ## import other attachments (pdf statement)
            manager.import_statement_file if imports.include?('attachments') and (replace? or not manager.detect_statement_file?)
            manager.import_solution_file if imports.include?('attachments') and (replace? or not manager.detect_solution_file?)

          end
        end
      end
    end

    def replace?
      job.data['disposition'] == 'replace'
    end

    class ProblemImportManager
      attr_accessor :problem, :index, :data, :paths, :logobj, :importer, :vid, :num

      def initialize(problem, index, data, paths, job, importer, vid, num)
        self.problem = problem
        self.index = index
        self.data = data
        self.paths = paths
        self.logobj = job
        self.importer = importer
        self.vid = vid
        self.num = num
      end

      def log(message)
        logobj.log(message)
      end

      def automatic_statement_tag
        "<!-- automatic import -->"
      end

      def detect_statement?
        !problem.statement.blank? or problem.statement =~ /\A#{automatic_statement_tag}/
      end

      def import_statement
        problem.statement = "#{automatic_statement_tag}\n\n" + data[:statement]
        if problem.save
          index[:problem_id] = problem.id
          importer.save or log "Error: Import index was not updated for #{data[:name]} with id #{problem.id}. "
        else
          continue = false
          log "Error: statement for #{data[:name]} not saved. "
        end
      end

      def detect_image?(filename)
        Filelink.where(root_type: 'Problem', root_id: problem.id, filepath: filename).any?
      end

      def import_image(filename)
        # create a new file attachment
        ext = File.extname(filename)
        attachment_name = "#{importer.contest(vid, num)[:name]} #{index[:name]} #{File.basename(filename, ext)}".parameterize + ext
        file_attachment = FileAttachment.new(name: attachment_name, owner_id: 0, file_attachment: File.open(File.expand_path(filename, paths[:tmp])))
        if file_attachment.save
          # remove any existing filelink
          filelink = Filelink.find_or_initialize_by(root_type: 'Problem', root_id: problem.id, filepath: filename)
          previous_id = filelink.file_attachment_id
          filelink.file_attachment_id = file_attachment.id
          filelink.save or log "Filelink for #{attachment_name} failed to be created"
          if previous_attachment = FileAttachment.where(id: previous_id).first
            if previous_attachment.filelinks.count == 0 && previous_attachment.owner_id == 0
              previous_attachment.destroy or log "Orphaned file attachment #{previous_attachment.name} failed to be destroyed."
            end
          end
        else
          log "Could not save image #{attachment_name}"
        end
      end

      def detect_test_cases?
        problem.test_cases.any?
      end

      def import_test_cases
        if Problems::FlatCaseImporter.import(problem, paths[:testdata], :extension => '', :merge => false)
          log "Test cases for #{data[:name]} imported."
        else
          log "Test cases for #{data[:name]} was not imported."
        end
      end

      def clean_submissions_index
        removed_tests = []
        index[:tests].reject! do |test|
          test[:submission_id].nil? || !Submission.where(:id => test[:submission_id]).any? # submission is dead
        end
      end

      def detect_model?
        problem.test_submissions.where(classification: Submission::CLASSIFICATION[:model]).any?
      end

      def import_model
        # get solution
        model = index[:tests].select{|test|test[:model]}.first
        if model.nil? && paths[:model]
          submission = Submission.new(user_id: 0, problem: problem, source: File.read(paths[:model]), language: Language.infer(File.extname(paths[:model])), classification: Submission::CLASSIFICATION[:model])
          if submission.save
            submission.judge
            model = {model: true, submission_id: submission.id}
            index[:tests] << model
          else
            log "Model solution for #{data[:name]} not imported."
          end
        end
      end

      def import_test_submissions
        num_add = [(4 - problem.test_submissions.count),0].max
        if num_add > 0 && data[:shortname] && data[:results] && data[:results][:url]
          agent = Mechanize.new
          page = agent.get(data[:results][:url])
          links = page.links_with(:href => /#{data[:shortname]}.cpp$/)
          maxscore = links.map{|link| link.text.to_i }.max || 0
          if maxscore > 0 && maxscore % 10 == 0
            links.select{|link|link.text.to_i == maxscore}.take(4).each do |link|
              sourcepath = URI.join(page.uri, link.uri).to_s
              source = agent.get(sourcepath)
              # check that such a solution doesn't already exist...
              submission = problem.test_submissions.find_or_initialize_by(user_id: 0, source: source.body, classification: Submission::CLASSIFICATION[:solution])
              next if submission.persisted? # skip if already exists
              submission.language = Language.infer('.cpp')
              if submission.save
                submission.judge
                submission_index = {submission_id: submission.id, url: sourcepath}
                index[:tests] << submission_index
              else
                log "A solution for #{data[:name]} not imported."
              end
            end
          end
        end
      end

      def import_attributes(replace: false)
        tl = ml = nil
        if !replace
          tl = problem.time_limit
          ml = problem.memory_limit
        end
        problem.time_limit = tl || data[:time_limit]
        problem.memory_limit = ml || data[:memory_limit]
        problem.save
      end

      def detect_statement_file?
        true
      end

      def import_statement_file
        data[:pages] #
      end

      def detect_solution_file?
      end

      def import_solution_file
        
      end
    end
  end
end
