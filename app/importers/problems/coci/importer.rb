module Problems
  module COCI
    class Importer
      include Problems::COCI::Index

      # find all the problems in the contest
      def process(vid, cid)
        return false unless downloaded?(vid, cid)
        issue = self.issue(vid, cid) or return false
        Dir.mktmpdir do |tmpdir|
          pdfpath = File.expand_path("tasks.pdf", tmpdir)
          FileUtils.copy(File.expand_path(issue[:tasks][:local], DATAPATH), pdfpath)

          importer = PDFImporter.new(pdfpath)
          problems = importer.extract
          if problems.size == 0 # try find the task list in the results webpage
            agent = Mechanize.new
            page = agent.get(issue[:results][:url])

            acronyms = page.root.xpath(".//acronym[@title]")
            problemlist = acronyms.map { |ac| ac.get_attribute(:title).titleize }

            problems = importer.extract(problemlist.map { |name| {name: name} })
          end

          issue[:problems] ||= []

          # extract zipped test data
          testpath = File.expand_path("testdata.zip", tmpdir)
          FileUtils.copy(File.expand_path(issue[:testdata][:local], DATAPATH), testpath)

          Zip::File.open(testpath) do |zfs|
            candidate_zips = []
            zfs.dir.foreach("/") do |entry|
              candidate_zips << entry
            end

            solutiondir = File.expand_path("solutions", tmpdir)
            FileUtils.mkdir_p(solutiondir)
            if issue[:solutions] && issue[:solutions][:local]
              # extract solution data
              solutionpath = File.expand_path("solutions.zip", tmpdir)
              FileUtils.copy(File.expand_path(issue[:solutions][:local], DATAPATH), solutionpath)
              Zip::File.open(solutionpath) do |zf|
                zf.each do |entry|
                  entry.extract(File.expand_path(entry.to_s, solutiondir))
                end
              end
            end

            # determine the problems we need
            problems.each do |problem_data|
              existing = issue[:problems].map { |p| p[:name] }
              pid = existing.index(problem_data[:name]) || existing.size
              merge_problem!(issue[:problems][pid] ||= {}, problem_data)

              # find zip dir for test data
              simplename = problem_data[:name].mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, "").downcase.to_s.strip.split(" ")[0]
              zipdirs = candidate_zips.select { |entry| entry =~ /\A#{simplename}/ }
              zipdir = (zipdirs.select { |entry| entry == simplename } + zipdirs)[0]

              problem_data[:shortname] = zipdir || simplename

              testdatadir = File.expand_path("testdata-#{pid}", tmpdir)
              FileUtils.mkdir_p(testdatadir)
              if zipdir.nil? # got a weird directory structure
                if candidate_zips.any?
                  candidate_zips.each do |zdir|
                    zfs.dir.foreach(zdir.to_s) do |edir|
                      if /\A#{simplename}/.match?(edir)
                        zfs.dir.foreach("#{zdir}/#{edir}") do |entry|
                          entryname = entry.to_s
                          if zdir =~ /examples/ && !(entryname =~ /dummy/)
                            entryname = "test.dummy.#{entryname}"
                          end
                          zfs.extract("#{zdir}/#{edir}/#{entry}", File.expand_path(entryname, testdatadir))
                        end
                      end
                    end
                  end
                else # no directory index in zipfile
                  zfs.entries.each do |entry|
                    match = entry.name.match(/\A#{simplename}\/(.*)$/)
                    if match
                      zfs.extract(entry.name, File.expand_path(match[1], testdatadir))
                    end
                  end
                end
              else
                zfs.dir.foreach(zipdir) do |entry|
                  zfs.extract("#{zipdir}/#{entry}", File.expand_path(entry.to_s, testdatadir))
                end
              end
              # make sure the test submission array is present
              issue[:problems][pid][:tests] ||= []

              paths = {tmp: tmpdir, testdata: testdatadir}

              # check if there is a model solution
              %w[.cpp .c].each do |ext|
                mfile = File.expand_path(problem_data[:shortname] + ext, solutiondir)
                paths[:model] = mfile if File.exist?(mfile)
              end

              problem_data[:results] = issue[:results]

              # why bother splitting the solution pdf file?
              if issue[:solutions] && issue[:solutions][:local]
                possible_solution = File.expand_path("solutions.pdf", solutiondir)
                paths[:solution] = possible_solution if File.exist?(possible_solution)
                problem_data[:solution] = {file_attachment_id: issue[:solutions][:file_attachment_id]}
              end

              # create a new pdf file of the task with only the relevant pages
              if problem_data[:pages]
                paths[:statement] = File.expand_path("#{problem_data[:shortname]}-statement.pdf", tmpdir)
                Prawn::Document.generate paths[:statement], skip_page_creation: true do |pdf|
                  problem_data[:pages].each do |pg|
                    pdf.start_new_page(template: pdfpath, template_page: pg)
                  end
                end
              end

              yield(issue[:problems][pid], problem_data, pid, paths) if block_given?
            end
          end
        end
        save
        true
      end

      def merge_problem! problem, updated
        problem.merge!(updated.slice(:name, :points))
        problem[:images] = updated[:images].values
      end

      def upload_statement(problem, data)
      end
    end
  end
end
