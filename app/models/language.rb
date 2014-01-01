class Language < ActiveRecord::Base
  belongs_to :group, :class_name => LanguageGroup

  def compile_command parameters = {}
    parameters.assert_valid_keys(:source, :output)
    parameters.fetch(:source)
    parameters.reverse_merge! :output => 'a.out'
    parameters.merge! :compiler => compiler
    sprintf("%{compiler} #{flags}", parameters)
  end

  # compiles source to output in box
  def compile box, source, output, options = {}
    result = {}
    box.tmpfile(["program", self.extension]) do |source_file|
      box.fopen(source_file, 'w') { |f| f.write(source) }
      result['command'] = self.compile_command(:source => source_file, :output => output)
      result.merge!(Hash[%w[output log box meta stat].zip(box.capture5(result['command'], options.reverse_merge(:processes => true)))])
      result['stat'] = result['stat'].exitstatus
    end
    return result
  end

  def self.submission_options
    languages = Language.where(:id => LanguageGroup.where(identifier: %w[c++ c python haskell]).select(:current_language_id)).order(:identifier)
    Hash[(languages + [Language.find_by(identifier: 'c++03')]).map{ |language| ["#{language.group.name} (#{language.name})", language.id] }]
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
