module Problems
  class TestCaseExporter < BaseExporter
    # Problems::TestCaseExporter.export(Problem.find(1), '/home/ronald/sample/sample.zip')
    def export(path, options = {})
      inpath = File.expand_path('inputs', path)
      outpath = File.expand_path('outputs', path)
      dir.mkdir(inpath)
      dir.mkdir(outpath)
      # export the test cases
      problem.test_cases.each do |kase|
        file.open(File.expand_path(kase.name + '.txt', inpath), 'w') do |f|
          f.write kase.input
          tempfiles << f
        end
        file.open(File.expand_path(kase.name + '.txt', outpath), 'w') do |f|
          f.write kase.output
          tempfiles << f
        end
      end
      # export the test sets
      file.open(File.expand_path('specification.yaml', path), 'w') do |f|
        f.puts 'test_sets:'
        problem.test_sets.each do |set|
          f.puts "  #{escape_key(set.name)}:"
          f.puts "    points: #{set.points}"
          f.puts "    visibility: #{set.visibility}" if set.visibility != 2
          f.puts "    test_cases: [#{set.test_cases.map{ |kase| escape_key(kase.name) }.join(",")}]"
          tempfiles << f
        end
      end
      path
    end

    def around_export(path, options)
      super
    end

    private
    def escape_key(string)
      return string if string =~ /\A[[:alpha:]][[:alnum:]]*\z/
      return "\"#{string.gsub(/(\\|")/,'\\\1')}\"" if string =~ /\A[[:graph:][:blank:]]+\z/
      string.gsub(/[^[:graph:][:blank:]]/,"").gsub(/(\\|")/,'\\\1')
    end
  end
end

