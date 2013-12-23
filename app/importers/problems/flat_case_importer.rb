module Problems
  class FlatCaseImporter < BaseImporter
    def import(path, options = {})
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
            casemap[name].assign_attributes(caseopts)
          else
            caseopts.merge!(:sample => true) if name =~ /\.(dummy|sample)(\.|\z)/
            casemap[name] = problem.test_cases.build(caseopts.merge(:name => name))
            unless setmap.has_key?(setname)
              setopts = {:name => setname, :points => 1}
              setopts.merge!(:points => 0, :prerequisite => true) if setname =~ /\.(dummy|sample)(\.|\z)/
              setmap[setname] = problem.test_sets.build(setopts)
            end
            setmap[setname].test_case_relations.build(test_case: casemap[name])
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
