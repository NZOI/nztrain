module Problems
  class TestCaseImporter < BaseImporter
    def import(path, options = {})
      if file.directory?(path)
        assert_files(path)
        import_files()
      else
        specimport(path, options)
      end

      problem
    end

    protected
    # not a directory, import .yaml file only
    def specimport(path, options = {})
      if options[:inline]
        @read_spec = path
      else
        self.specfile = path
      end
      specdata = load_spec()
      import_specification(specdata)

      problem
    end

    def import_specification(spec)
      import_spec_cases(spec['test_cases'] || {})
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
      specdata = load_spec()
      import_cases(indir, outdir)
      import_specification(specdata)
    end

    def load_spec
      Psych.safe_load(read_spec) || {}
    rescue Psych::SyntaxError => e
      raise ImportError, "YAML parse error: " + e.message
    end

    def read_spec
      @read_spec ||= file.read(specfile)
    end

    attr_accessor :outdir, :indir, :specfile

    def assert_files(path)
      # we expect an inputs and outputs
      self.outdir = File.expand_path('outputs', path)
      self.indir = File.expand_path('inputs', path)
      self.specfile = File.expand_path('specification.yaml', path)
      missing = []
      missing << "specification.yaml file" unless file.exist?(specfile)
      # following checks may not work so well with winzip, and these directories are not strictly required...
      # make directory so we can foreach it later
      dir.mkdir(indir) unless file.exist?(indir)
      #missing << "inputs directory" unless file.exist?(indir)
      #missing << "outputs directory" unless file.exist?(outdir)
      raise ImportError, "Was the right importer selected? Missing #{missing.join(', ')}" unless missing.empty?
    end

    def import_cases(indir, outdir)
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
          import_case(name, file.read(File.expand_path(entry, indir)), file.read(ofile))
        end
      end
    end

    def import_case(name, input, output)
      parameters = {:input => input, :output => output}
      if casemap.keys.include?(name)
        casemap[name].assign_attributes(parameters)
      else
        casemap[name] = problem.test_cases.build(parameters.merge(name: name))
      end
    end

    def import_spec_cases(casedata)
      casedata.each do |name, attributes|
        if !attributes.has_key?('input') || !attributes.has_key?('output')
          raise ImportError, "Incomplete test case in specification"
        elsif attributes['input'].class != String
          raise ImportError, "Test Case \"#{name}\" input not a string"
        elsif attributes['output'].class != String
          raise ImportError, "Test Case \"#{name}\" output not a string"
        end
        import_case(name, attributes['input'], attributes['output'])
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
          raise ImportError, "Undefined test case referenced by test set" unless cases.map{ |name| casemap[name] }.select{ |kayse| kayse.nil? }.empty?
          setmap[name].test_cases = cases.map{ |name| casemap[name] }
        end
      end
    end
  end
end
