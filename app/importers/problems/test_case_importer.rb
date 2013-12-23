module Problems
  class TestCaseImporter < BaseImporter
    def import(path, options = {})
      assert_files(path)
      import_files()

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

    protected
    def import_specification(spec)
      import_sets(spec['test_sets'] || {})
      import_prerequisites(spec['prerequisites']) if spec.has_key?('prerequisites')
      import_samples(spec['samples']) if spec.has_key?('samples')
    end

    def import_prerequisites(set_names)
      problem.test_sets.each do |set|
        set.assign_attributes(:prerequisite => set_names.include?(set.name))
      end
    end

    def import_samples(case_names)
      problem.test_cases.each do |kayse|
        kayse.assign_attributes(:sample => case_names.include?(kayse.name))
      end
    end

    def import_files
      import_cases(indir, outdir)
      import_specification(Psych.safe_load(file.read(specfile)))
    end

    attr_accessor :outdir, :indir, :specfile
    def assert_files(path)
      # we expect an inputs and outputs
      self.outdir = File.expand_path('outputs', path)
      self.indir = File.expand_path('inputs', path)
      self.specfile = File.expand_path('specification.yaml', path)
      raise "Missing specification.yaml file or inputs or outputs directory" unless file.exist?(specfile) && file.exist?(outdir) && file.exist?(indir)
    end

    def import_cases(indir, outdir)
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
            casemap[name].assign_attributes(parameters)
          else
            casemap[name] = problem.test_cases.build(parameters.merge(:name => name))
          end
        end
      end
    end

    def import_sets(setdata)
      setdata.each do |name, attributes|
        setopts = {}
        setopts[:points] = attributes.fetch('points', 1)
        if setmap.has_key?(name)
          setmap[name].assign_attributes(setopts)
        else
          setmap[name] = problem.test_sets.build(setopts.merge(:name => name))
        end
        cases = attributes['test_cases'] || []
        if cases.is_a?(Array)
          raise "Undefined test case referenced by test set" unless cases.map{ |name| casemap[name] }.select{ |kayse| kayse.nil? }.empty?
          setmap[name].test_cases = cases.map{ |name| casemap[name] }
        end
      end
    end
  end
end
