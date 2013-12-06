module Problems
  class FlatCaseImporter < BaseImporter
    # Problems::FlatCaseImporter.import(Problem.new, '/home/ronald/test_cases.zip')
    def import(path, options = {})
      dir.foreach(path) do |entry|
        outputname = case entry
        when /.in\z/; "#{name = entry.chomp('.in')}.out"
        when /.IN\z/; "#{name = entry.chomp('.IN')}.OUT"
        when /.i\z/; "#{name = entry.chomp('.i')}.o"
        when /(.*)\.in((put)?\.(.*))\z/
          name = $~[1] + $~[2]
          "#{$~[1]}.out#{$~[2]}"
        else
          nil
        end
        if outputname && file.exist?(ofile = File.expand_path(outputname, path))
          kase = TestCase.new(:name => name, :input => file.read(File.expand_path(entry, path)), :output => file.read(ofile))
          problem.test_cases << kase
          setopts = {:name => name, :points => 1, :test_cases => [kase]}
          if name =~ /\.(dummy|sample)(\.|\z)/
            setopts.merge(:points => 0, :visibility => :sample)
          end
          problem.test_sets << TestSet.new(setopts)
        end
      end
      problem
    end

    def around_import(path, options = {})
      options.reverse_merge!(:append => false)
      clear! unless options[:append]
      super
    end

    def clear!()
      problem.test_cases.clear
      problem.test_sets.clear
    end
  end
end
