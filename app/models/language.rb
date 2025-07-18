class Language < ApplicationRecord
  belongs_to :group, class_name: LanguageGroup

  def source_filename
    self[:source_filename] || "program"
  end

  def processes
    self[:processes] == 0 ? true : self[:processes]
  end

  def exe_filename
    if compiled
      "program#{exe_extension}"
    else
      "#{source_filename}#{extension}"
    end
  end

  def compile_command parameters = {}
    parameters.assert_valid_keys(:source, :output)
    parameters.fetch(:source)
    parameters.reverse_merge! source_dir: File.dirname(parameters[:source])
    parameters.reverse_merge! output: "a.out"
    parameters.merge! explode_path_to_hash(:compiler, compiler)
    sprintf(compiler_command, parameters)
  end

  # compiles source to output in box
  def compile box, source, output, options = {}
    result = {}
    box.tmpfile([source_filename, extension]) do |source_file|
      box.fopen(source_file, "w") { |f| f.write(source) }
      result["command"] = compile_command(source: source_file, output: output)
      result.merge!(Hash[%w[output log box meta stat].zip(box.capture5("/bin/bash -c #{result["command"].shellescape}", options.reverse_merge(processes: true)))])
      result["stat"] = result["stat"].exitstatus
    end
    result
  end

  def run_command source = exe_filename
    if interpreted
      sprintf(interpreter_command, explode_path_to_hash(:interpreter, interpreter).merge(source: source))
    else
      "./#{source}"
    end
  end

  def explode_path_to_hash key, path
    elements = path.split(";")
    {key => path}.merge Hash[(0...elements.size).map { |i| "#{key}[#{i}]".to_sym }.zip(elements)]
  end

  # for validating submissions
  def self.submission_options
    grouped_submission_options.values.reduce(:merge)
  end

  # for the selection dropdown
  def self.grouped_submission_options
    current = ["c++", "c", "python", "csharp", "java", "javascript", "haskell", "ruby"] # language group identifiers, order is preserved
    other = ["c++14", "c99", "pypy3"] # language identifiers, ordered by language name
    current_langs = LanguageGroup.where(identifier: current).preload(:current_language).map(&:current_language)
    current_options = current_langs.sort_by { |lang| current.index(lang.group.identifier) }.map { |lang| [lang.name, lang.id] }
    other_options = Language.where(identifier: other).order(:name).pluck(:name, :id)
    {"Current" => Hash[current_options],
     "Other" => Hash[other_options]}
  end

  def self.infer(ext)
    case ext
    when ".cpp"
      LanguageGroup.where(identifier: "c++").first.current_language
    when ".c"
      LanguageGroup.where(identifier: "c").first.current_language
    when ".py"
      LanguageGroup.where(identifier: "python").first.current_language
    end
  end
end
