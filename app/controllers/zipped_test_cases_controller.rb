require 'zip/zip'

class ZippedTestCasesController < ApplicationController
  # POST /test_cases/bulk_upload
  def upload
    @problem = Problem.find(params[:problem_id])

    valid_zip = false

    files_in_zip = Hash.new

    new_test_cases = []

    Zip::ZipInputStream.open(params[:test_cases_zip].path) do |zip|
      while entry = zip.get_next_entry
        if entry.file?
          files_in_zip[entry.name] = entry.get_input_stream.read
        end
      end
    end

    [["in", "out"], ["in", "ans"], ["i", "o"]].each do |replacement|
      file_counts = Hash.new(0)
      files_in_zip.each_key do |filename|
        other_filename = filename.gsub replacement[0], replacement[1]
        if filename != other_filename
          file_counts[filename] += 1
          file_counts[other_filename] += 1
        end
      end
      worked = true
      files_in_zip.each_key do |filename|
        worked = false if file_counts[filename] != 1
      end
      if worked
        valid_zip = true
        files_in_zip.each do |filename, contents|
          other_filename = filename.gsub replacement[0], replacement[1]
          logger.debug "input: #{contents} output: #{files_in_zip[other_filename]}"
          if filename != other_filename
            new_test_cases.push(TestCase.create(:input => contents,
                                                :output => files_in_zip[other_filename],
                                                :problem => @problem,
                                                :points => 1))
          end
        end
      end
    end

    respond_to do |format|
      if valid_zip
        format.html { redirect_to(edit_problem_path(@problem), :notice => 'Successfully uploaded ' + new_test_cases.size.to_s + ' test cases') }
        # what would we want to return if we were looking for an xml response?
        # thinking command line interfacing utilities in the future :)
        #format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { redirect_to(edit_problem_path(@problem), :alert => 'Unable to process bulk upload.') }
        #format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end
end

