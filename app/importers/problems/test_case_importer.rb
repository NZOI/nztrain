module Problems
  class TestCaseImporter < BaseImporter
    def import(path, options = {})
      # we expect an inputs and outputs
      outdir = File.expand_path('outputs', path)
      indir = File.expand_path('inputs', path)
      specfile = File.expand_path('specification.yaml', path)
      raise "Missing specification.yaml file or inputs or outputs directory" unless file.exist?(specfile) && file.exist?(outdir) && file.exist?(indir)
      casemap = Hash[problem.test_cases.select([:id, :name]).map{ |kase| [kase.name, kase] }]
      initialcases = casemap.keys
      dir.foreach(indir) do |entry|
        ext = File.extname(entry)
        name = File.basename(entry, ext)
        ext = case ext
        when '.in'; '.out'
        when '.IN'; '.OUT'
        when '.i'; '.o'
        else; ext
        end
        if file.exist?(ofile = File.expand_path("#{name}#{ext}", outdir))
          parameters = {:input => file.read(File.expand_path(entry, indir)), :output => file.read(ofile)}
          if initialcases.include?(name)
            casemap[name].update_attributes(parameters)
          else
            kase = TestCase.new(parameters.merge(:name => name))
            problem.test_cases << kase
            casemap[name] = kase
          end
        end
      end

      setmap = Hash[problem.test_sets.select([:id, :name]).map{ |set| [set.name, set] }]
      data = Psych.safe_load(file.read(specfile))
      raise "Missing test set yaml map" unless data.has_key?('test_sets')
      data['test_sets'].each do |name, attributes|
        setopts = {}
        setopts[:points] = attributes.fetch('points', 1)
        setopts[:visibility] = attributes.fetch('visibility', 2)
        cases = attributes['test_cases'] || []
        if cases.is_a?(Array)
          setopts[:test_cases] = cases.map{ |name| casemap[name] }
          raise "Undefined test case referenced by test set" unless setopts[:test_cases].select{ |kase| kase.nil? }.empty?
        end
        if setmap.has_key?(name)
          setmap[name].update_attributes(setopts)
        else
          problem.test_sets << TestSet.new(setopts.merge(:name => name))
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
