class Importers::ContestSeriesController < ApplicationController
  before_filter do
    raise Pundit::NotAuthorizedError unless current_user.is_superadmin?
    raise ActiveRecord::RecordNotFound if importer.nil?
  end

  def series
    params[:series]
  end

  def index
    @index = importer.index
  end

  def update_index
    if importer.update
      redirect_to index_path, :notice => "The series index has been updated."
    else
      redirect_to index_path, :alert => "The series index failed to update."
    end
  end

  def download
    if params[:vid] && params[:cid] && importer.download(params[:vid], params[:cid])
      redirect_to index_path, :notice => "The contest data was downloaded"
    else
      redirect_to index_path, :alert => "The contest could not be downloaded"
    end
  end

  def reindex
    if params[:vid] && params[:cid] && importer.process(params[:vid], params[:cid])
      redirect_to index_path, :notice => "The contest data was reindexed"
    else
      redirect_to index_path, :alert => "The contest could not be reindexed"
    end
  end

  def update
    contest = importer.contest(params[:vid], params[:cid]) or raise ActiveRecord::RecordNotFound
    importer.set_problem_set_id(params[:vid], params[:cid], params[:contest][:problem_set_id]) if params[:contest] && params[:contest][:problem_set_id]
    if params[:problems] && params[:problems].is_a?(Hash)
      params[:problems].each do |pid, id|
        importer.set_problem_id(params[:vid], params[:cid], pid, id)
      end
    end
    redirect_to index_path, :notice => "Contest import ids updated"
  end

  def import
    if params[:vid].nil?
      vids = 0...(importer.index.size)
    end
    raise ActiveRecord::RecordNotFound if vids.nil? && params[:vid].nil?
    vids ||= [params[:vid].to_i]

    errors = []
    trackactual = 0
    trackexpected = 0
    vids.each do |vid|
      cids = params[:cid].nil? ? (0...(importer.contests(vid).size)) : [params[:cid].to_i]
      cids.each do |cid|
        trackexpected+=1 if params[:pid]
        importer.process(vid, cid) do |problem_index, data, pid, paths|
          next if params[:pid] && params[:pid].to_i != pid
          trackactual+=1 if params[:pid]
          continue = true
          ## import statement
          if %w[all statement].include?(params[:filter])
            problem = (problem_index[:problem_id].nil? ? Problem.new(name: problem_index[:name]) : Problem.find(problem_index[:problem_id]))
            problem.statement = data[:statement]
            if problem.save
              problem_index[:problem_id] = problem.id
              importer.save or errors.push "Error: Import index was not updated for #{data[:name]} with id #{problem.id}. "
            else
              continue = false
              errors.push "Error: statement for #{data[:name]} not saved. "
            end
          end
          ## import images
          if continue && %w[all images].include?(params[:filter])
            problem ||= Problem.find(problem_index[:problem_id])
            data[:images].values.each do |filename|
              # create a new file attachment
              ext = File.extname(filename)
              attachment_name = "#{importer.contest(vid,cid)[:name]} #{problem_index[:name]} #{File.basename(filename, ext)}".parameterize + ext
              file_attachment = FileAttachment.new(name: attachment_name, owner_id: 0, file_attachment: File.open(File.expand_path(filename, paths[:tmp])))
              if file_attachment.save
                # remove any existing filelink
                filelink = Filelink.find_or_initialize_by(root_type: 'Problem', root_id: problem.id, filepath: filename)
                previous_id = filelink.file_attachment_id
                filelink.file_attachment_id = file_attachment.id
                filelink.save or errors.push "Filelink for #{attachment_name} failed to be created"
                if previous_attachment = FileAttachment.where(id: previous_id).first
                  if previous_attachment.filelinks.count == 0 && previous_attachment.owner_id == 0
                    previous_attachment.destroy or errors.push "Orphaned file attachment #{previous_attachment.name} failed to be destroyed."
                  end
                end
              else
                errors.push "Could not save image #{attachment_name}"
              end
            end
          end
          ## import tests
          if continue && %w[all tests].include?(params[:filter])
            problem ||= Problem.find(problem_index[:problem_id])
            unless Problems::FlatCaseImporter.import(problem, paths[:testdata], :extension => '', :merge => false)
              errors.push "Test cases for #{data[:name]} was not imported."
            end
          end
          ## test submissions
          if continue && %w[all submissions].include?(params[:filter])
            problem ||= Problem.find(problem_index[:problem_id])

            removed_tests = []
            problem_index[:tests].reject! do |test|
              test[:submission_id].nil? || !Submission.where(:id => test[:submission_id]).any? # submission is dead
            end

            # get solution
            model = problem_index[:tests].select{|test|test[:model]}.first
            if model.nil? && paths[:model]
              submission = Submission.new(user_id: 0, problem: problem, source: File.read(paths[:model]), language: Language.infer(File.extname(paths[:model])), classification: Submission::CLASSIFICATION[:model])
              if submission.save
                submission.judge
                model = {model: true, submission_id: submission.id}
                problem_index[:tests] << model
              else
                errors.push "Model solution for #{data[:name]} not imported."
              end
            end

            # more test submissions...
            num_add = [(4 - problem.test_submissions.count),0].max
            if num_add > 0 && data[:shortname] && data[:results] && data[:results][:url]
              agent = Mechanize.new
              page = agent.get(data[:results][:url])
              links = page.links_with(:href => /#{data[:shortname]}.cpp$/)
              maxscore = links.map{|link| link.text.to_i }.max || 0
              if maxscore > 0 && maxscore % 10 == 0
                links.select{|link|link.text.to_i == maxscore}.take(num_add).each do |link|
                  sourcepath = URI.join(page.uri, link.uri).to_s
                  source = agent.get(sourcepath)
                  submission = Submission.new(user_id: 0, problem: problem, source: source.body, language: Language.infer('.cpp'), classification: Submission::CLASSIFICATION[:solution])
                  if submission.save
                    submission.judge
                    model = {submission_id: submission.id, url: sourcepath}
                    problem_index[:tests] << model
                  else
                    errors.push "A solution for #{data[:name]} not imported."
                  end
                end
              end
            end
          end
          ## import pdf statement
          #if continue && %w[all tests].include?(params[:filter])
          #  problem ||= Problem.find(problem_index[:problem_id])
          #  unless Problems::FlatCaseImporter.import(problem, testdatadir, :extension => '', :merge => false)
          #    errors.push "Test cases for #{data[:name]} was not imported."
          #  end
          #end
        end
      end
    end
    errors.push "#{trackexpected - trackactual} problems missed. " if trackactual < trackexpected
    message = {notice: 'Problems imported. '}
    message = {alert: errors.join} unless errors.empty?
    redirect_to index_path, message
  end

  helper_method :series, :importer, :index_path

  protected
  IMPORTERS = {"COCI" => Problems::COCI::Importer}
  def importer
    @importer ||= begin
      nil if !IMPORTERS.keys.include?(series.to_s)
      IMPORTERS[series].new
    end
  end
  def index_path
    importers_contest_series_path(series)
  end
end

