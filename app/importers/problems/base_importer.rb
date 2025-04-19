require "zip/filesystem"

module Problems
  class BaseImporter
    class ImportError < StandardError; end

    def self.import(problem, path, options = {})
      importer = new(problem)
      # redirect to import zip etc if zip path etc

      extension = options.fetch(:extension) { File.extname(path) }
      context = case extension
      when ".zip" then :enter_zip
      else; :enter_fs
      end
      importer.send(context, path, options) do |path, options|
        importer.around_import(path, options) do |path, options|
          importer.import(path, options)
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
      options.reverse_merge!(merge: false, inline: false)

      problem.with_lock do
        clear! unless options[:merge]

        path = drill(path) unless options[:inline]
        yield(path, options)

        problem.save
        casemap.each_value(&:save)
        setmap.each_value(&:save)
        true # completed
      end
    end

    def clear!
      problem.test_cases.clear
      problem.test_sets.clear
    end

    def drill(path)
      if file.directory?(path)
        while true
          entries = dir.entries(path) - [".", ".."]
          break unless (entries.size == 1) && File.expand_path(entries.first, path).try do |candidate|
            file.directory?(candidate) && (path = candidate)
          end
        end
      end
      path
    end

    def enter_fs(*args)
      yield(*args)
    end

    def enter_zip(path, options = {})
      Zip::File.open(path) do |zfs|
        chfs(zfs.dir, zfs.file) do
          yield "/", options
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
      @casemap ||= Hash[problem.test_cases.map { |kase| [kase.name, kase] }]
    end

    def setmap
      @setmap ||= Hash[problem.test_sets.map { |set| [set.name, set] }]
    end
  end
end
