require 'csv'
require 'zip'

class ZippedTestCasesController < ApplicationController
  # POST /test_cases/bulk_upload
  def upload
    @problem = Problem.find(params[:problem_id])
    permitted_to! :update, @problem
    if params[:test_cases_zip].nil?
      redirect_to(edit_problem_path(@problem), :alert => 'No zip file uploaded')
      return
    end

    if params[:upload] && params[:upload] == 'replace'
      @problem.test_sets.clear
    end

    result = Problems::TestCaseImporter.import(@problem, params[:test_cases_zip].path, :extension => '.zip', :append => params[:upload] == 'add')

    respond_to do |format|
      if result
        format.html { redirect_to(edit_problem_path(@problem), :notice => "Successfully uploaded. New counts for the problem are: # Test Sets: #{ @problem.test_sets.count }, # Test Cases: #{ @problem.test_cases.count }") }
      else
        format.html { redirect_to(edit_problem_path(@problem), :alert => 'No test cases or test sets detected.') }
      end
    end
  end

  def download
    @problem = Problem.find(params[:problem_id])
    permitted_to! :inspect, @problem
    name = @problem.title.gsub(/[\W]/,"")
    name = "testcases" if name.empty?
    filename = name + ".zip"

    dir = Dir.mktmpdir("zip-testcases-#{@problem.id}-#{current_user.id}-#{Time.now}")
    zipfile = Problems::TestCaseExporter.export(@problem, File.expand_path(filename, dir))

    send_file zipfile, :type => 'application/zip', :disposition => 'attachment', :filename => filename
  end
end

