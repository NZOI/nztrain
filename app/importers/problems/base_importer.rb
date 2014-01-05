require 'zip/filesystem'

module Problems
  class BaseImporter

    class ImportError < StandardError; end

    def self.import(problem, path, options = {})
      importer = self.new(problem)
      # redirect to import zip etc if zip path etc
      
      extension = options.fetch(:extension) { File.extname(path) }
      context = case extension
      when '.zip'; :enter_zip
      else; :enter_fs
      end
      importer.send(context, path, options) do |path, options|
        importer.around_import(path, options) do |path, options|
          importer.import(path, options).save
        end
      end
    end

    attr_accessor :problem, :dir, :file

    def initialize(problem)
      self.problem = problem
      self.dir = Dir
      self.file = File
    end

    def around_import(path, options)
      while true
        entries = dir.entries(path) - ['.','..']
        break unless entries.size == 1 and File.expand_path(entries.first, path).try do |candidate|
          file.directory?(candidate) and path = candidate
        end
      end
      yield(path, options)
    end

    def enter_fs(*args)
      yield(*args)
    end

    def enter_zip(path, options = {})
      Zip::File.open(path) do |zfs|
        chfs(zfs.dir, zfs.file) do
          yield '/', options
        end
      end
    end

    def chfs(dir, file)
      self.dir, self.file, cache = dir, file, [self.dir, self.file]
      if block_given?
        result = yield
        self.dir, self.file = cache
      end
      result
    end

    # core function
    def import(path, options)
      raise "Not implemented"
    end

    protected
    def casemap
      @casemap ||= Hash[problem.test_cases.map{ |kase| [kase.name, kase] }]
    end

    def setmap
      @setmap ||= Hash[problem.test_sets.map{ |set| [set.name, set] }]
    end
  end
end
