class Language < ActiveRecord::Base
  belongs_to :group, :class_name => LanguageGroup

  def source_filename
    self[:source_filename] || "program"
  end

  def processes
    self[:processes]==0 ? true : self[:processes]
  end

  def exe_filename
    if compiled
      "program#{self.exe_extension}"
    else
       "#{source_filename}#{self.extension}"
    end
  end

  def compile_command parameters = {}
    parameters.assert_valid_keys(:source, :output)
    parameters.fetch(:source)
    parameters.reverse_merge! :source_dir => File.dirname(parameters[:source])
    parameters.reverse_merge! :output => 'a.out'
    parameters.merge! explode_path_to_hash(:compiler, compiler)
    sprintf(compiler_command, parameters)
  end

  # compiles source to output in box
  def compile box, source, output, options = {}
    result = {}
    box.tmpfile([source_filename, self.extension]) do |source_file|
      box.fopen(source_file, 'w') { |f| f.write(source) }
      result['command'] = self.compile_command(:source => source_file, :output => output)
      result.merge!(Hash[%w[output log box meta stat].zip(box.capture5("/bin/bash -c #{result['command'].shellescape}", options.reverse_merge(:processes => true)))])
      result['stat'] = result['stat'].exitstatus
    end
    return result
  end

  def run_command source = exe_filename
    if interpreted
      sprintf(interpreter_command, explode_path_to_hash(:interpreter, interpreter).merge(:source => source))
    else
      "./#{source}"
    end
  end

  def explode_path_to_hash key, path
    elements = path.split(';')
    {key => path}.merge Hash[(0...elements.size).map{|i|"#{key}[#{i}]".to_sym}.zip(elements)]
  end

  def self.submission_options
    latest = LanguageGroup.where(identifier: %w[c++ c python haskell java ruby j]).pluck(:current_language_id)
    old = Language.where(identifier: %w[c++11 c++14 c99 python2]).pluck(:id)
    languages = Language.where(:id => latest).order(:identifier) + Language.where(:id => old).order(:identifier)
    Hash[languages.map{ |language| ["#{language.name}", language.id] }]
  end

  def self.infer(ext)
    case ext
    when *%w[.cpp]
      LanguageGroup.where(identifier: 'c++').first.current_language
    when *%w[.c]
      LanguageGroup.where(identifier: 'c').first.current_language
    when *%w[.py]
      LanguageGroup.where(identifier: 'python').first.current_language
    else
      nil
    end
  end
end
