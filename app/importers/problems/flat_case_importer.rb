module Problems
  class FlatCaseImporter < BaseImporter
    def import(path, options = {})
      dir.foreach(path) do |entry|
        setname = nil
        outputname = case entry
        when /.in\z/ then "#{name = entry.chomp(".in")}.out"
        when /.IN\z/ then "#{name = entry.chomp(".IN")}.OUT"
        when /.i\z/ then "#{name = entry.chomp(".i")}.o"
        when /(.*)\.in((put)?\.(.*))\z/
          n1, n2 = $~[1, 2]
          name = n1 + n2
          # for COCI compatibility
          if /\.(dummy|sample)(\.|\z)/.match?(n1)
            setname = n1
          elsif n2 =~ /\A(\.[[:digit:]]+)[[:alpha:]]+\z/
            setname = n1 + $~[1]
          end
          "#{n1}.out#{n2}"
        end
        setname ||= name
        if outputname && file.exist?(ofile = File.expand_path(outputname, path))
          caseopts = {input: file.read(File.expand_path(entry, path)), output: file.read(ofile)}
          if casemap.has_key?(name)
            casemap[name].assign_attributes(caseopts)
          else
            caseopts[:sample] = true if /\.(dummy|sample)(\.|\z)/.match?(name)
            casemap[name] = problem.test_cases.build(caseopts.merge(name: name))
            unless setmap.has_key?(setname)
              setopts = {name: setname, points: 1}
              if /\.(dummy|sample)(\.|\z)/.match?(setname)
                setopts[:points] = 0
                setopts[:prerequisite] = true
              end
              setmap[setname] = problem.test_sets.build(setopts)
            end
            setmap[setname].test_case_relations.build(test_case: casemap[name])
          end
        end
      end
      problem
    end
  end
end
