require 'zip/zip'
require 'csv'

class ZippedTestCasesController < ApplicationController
  # POST /test_cases/bulk_upload
  def upload
    @problem = Problem.find(params[:problem_id])
    authorize! :update, @problem
    if params[:test_cases_zip].nil?
      redirect_to(edit_problem_path(@problem), :alert => 'No zip file uploaded')
      return
    end

    if params[:upload] && params[:upload] == 'replace'
      @problem.test_sets.clear
    end

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

    # file spec file (the one which is nearest to root, ties broken by lexicographical order
    specdepth = -1
    specfile = nil
    rootdir = nil
    filecountatdepth = []
    rootcandidate = nil
    files_in_zip.each_key do |filename|
      if rootcandidate.nil?
        rootcandidate = filename.split('/')[0...-1]
      else
        filename.split('/').zip(rootcandidate).each_with_index do |part,index|
          if part[0].nil? || part[0]!=part[1]
            rootcandidate = rootcandidate.take(index)
            break
          end
        end
      end
      depth = filename.count("/") - filename[-1..-1].count("/")
      if filename.match(/\A.*spec(ification)?(\.txt|\.nfo|\.csv)?\z/)
        if specdepth>depth || specdepth == -1
          specfile = filename
          specdepth = depth
          rootdir = filename.match(/\A.*\//).to_s # greedily get directory part
        end
      end
    end

    if rootdir.nil? # find root directory - whichever directory first splits into 2
      specdepth = rootcandidate.length
      rootdir = rootcandidate.join('/')
      rootdir += '/' if !rootdir.empty?
    end

    testsets = {}
    if specfile # get hash of points for test sets by name
      CSV.parse(files_in_zip[specfile]) do |row|
        if row.size >= 2
          next if testsets[row[0]] # already have test set by that name
          testset = TestSet.new()
          testset.name = row[0]
          testset.problem = @problem
          testset.points = row[1].to_i
          testset.save
          testsets[row[0]] = testset
        end
      end
    end
    # now make test cases
    testcases = []
    files_in_zip.each_key do |filename|
      match = filename.match(/\A(#{rootdir}(([^\/]*)\/(.*\/)?)?([^\/]*))(\.in|\.i)(\.([0-9]*)[^\/]*)?\z/) # any (input file)/dir which is an immediate child of the root directory
      if match
        testsetname = match[3] || ""
        testcasename = "#{match[5]}#{match[7]}"
        testsetname = "#{match[5]}#{match[8].nil? || "#{match[5]}".match(/(\.dummy)/) ? "" : ".#{match[8]}"}" if testsetname.nil? || testsetname.empty?
        if testsets[testsetname].nil? # if we don't have a test set of required name
          dummy = testsetname.match(/(\.dummy)/) # test set without points
          testsets[testsetname] = TestSet.new( :name => testsetname, :points => !dummy, :problem => @problem )
          testsets[testsetname].save
        end
        testcase = TestCase.new()
        testcase.name = testcasename
        testcase.input = files_in_zip[filename]
        testcase.output = ""
        testcaseoutputroot = filename.gsub(/(\.in|\.i)\z/,"")
        ['.out','.o','.ans'].each do |suffix|
          outputcandidate = "#{match[1]}#{suffix}#{match[7]}"
          if !files_in_zip[outputcandidate].nil?
            testcase.output = files_in_zip[outputcandidate]
            break
          end
        end
        testcase.test_set = testsets[testsetname]
        testcase.save
        testcases.push(testcase)
      end
    end
    respond_to do |format|
      if testcases.size + testsets.size > 0
        format.html { redirect_to(edit_problem_path(@problem), :notice => 'Successfully uploaded ' + testcases.size.to_s + ' test cases in ' + testsets.size.to_s + ' test sets') }
        # what would we want to return if we were looking for an xml response?
        # thinking command line interfacing utilities in the future :)
        #format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { redirect_to(edit_problem_path(@problem), :alert => 'No test cases or test sets detected.') }
        #format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end
  def download
    @problem = Problem.find(params[:problem_id])
    authorize! :inspect, @problem
    name = @problem.title.gsub(/[\W]/,"")
    name = "testcases" if name.empty?
    filename = name + ".zip"
    t = Tempfile.new("zip-testcases-#{@problem.id}-#{current_user.id}-#{Time.now}")
    spec = ""
    Zip::ZipOutputStream.open(t.path) do |z|
      @problem.test_sets.each_with_index do |test_set,index|
        spec += CSV.generate_line([test_set.name,test_set.points]) + "\n"

        setname = test_set.name
        setname = index.to_s if setname.empty?
        z.put_next_entry(name + '/' + setname + '/')
        test_set.test_cases.each_with_index do |test_case,index|
          casename = test_case.name
          casename = index.to_s if casename.empty?
          z.put_next_entry(name + '/' + setname + '/' + casename + '.in')
          z.print test_case.input
          z.print "\n" if test_case.input[-2..-1] != "\n\n" # ensures empty line at end of file
          z.put_next_entry(name + '/' + setname + '/' + casename + '.out')
          z.print test_case.output
          z.print "\n" if test_case.input[-2..-1] != "\n\n" # ensures empty line at end of file
        end
      end
      z.put_next_entry(name + '/' + 'spec.txt')
      z.print spec + "\n"
    end
    send_file t.path, :type => 'application/zip',
                             :disposition => 'attachment',
                             :filename => filename
    t.close
  end
end

