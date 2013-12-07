module Problems
  class FlatCaseImporter < BaseImporter
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
          caseopts = {:input => file.read(File.expand_path(entry, path)), :output => file.read(ofile)}
          if casemap.has_key?(name)
            casemap[name].update_attributes(caseopts)
          else
            kase = TestCase.new(caseopts.merge(:name => name))
            problem.test_cases << kase
            setopts = {:name => name, :points => 1, :test_cases => [kase]}
            if name =~ /\.(dummy|sample)(\.|\z)/
              setopts.merge(:points => 0, :visibility => :sample)
            end
            problem.test_sets << TestSet.new(setopts)
            casemap[name] = kase
          end
        end
      end
      problem
    end

    def around_import(path, options = {})
      options.reverse_merge!(:merge => false)
      clear! unless options[:merge]
      super
    end

    def clear!()
      problem.test_cases.clear
      problem.test_sets.clear
    end
  end
end
