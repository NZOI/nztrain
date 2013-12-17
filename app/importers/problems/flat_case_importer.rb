module Problems
  class FlatCaseImporter < BaseImporter
    def import(path, options = {})
      setmap = {}
      dir.foreach(path) do |entry|
        setname = nil
        outputname = case entry
        when /.in\z/; "#{name = entry.chomp('.in')}.out"
        when /.IN\z/; "#{name = entry.chomp('.IN')}.OUT"
        when /.i\z/; "#{name = entry.chomp('.i')}.o"
        when /(.*)\.in((put)?\.(.*))\z/
          n1, n2 = $~[1,2]
          name = n1 + n2
          # for COCI compatibility
          if n1 =~ /\.(dummy|sample)(\.|\z)/
            setname = n1
          elsif n2 =~ /\A(\.[[:digit:]]+)[[:alpha:]]+\z/
            setname = n1 + $~[1]
          end
          "#{n1}.out#{n2}"
        else
          nil
        end
        setname ||= name
        if outputname && file.exist?(ofile = File.expand_path(outputname, path))
          caseopts = {:input => file.read(File.expand_path(entry, path)), :output => file.read(ofile)}
          if casemap.has_key?(name)
            casemap[name].update_attributes(caseopts)
          else
            kase = TestCase.new(caseopts.merge(:name => name))
            problem.test_cases << kase
            if setmap.has_key?(setname)
              set = setmap[setname]
            else
              setopts = {:name => setname, :points => 1}
              if setname =~ /\.(dummy|sample)(\.|\z)/
                setopts.merge!(:points => 0, :visibility => :sample)
              end
              set = setmap[setname] = TestSet.new(setopts)
              problem.test_sets << set
            end
            set.test_cases << kase
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
