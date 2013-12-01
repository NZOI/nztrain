class Language < ActiveRecord::Base
  #attr_accessible :compiler, :is_interpreted, :name

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
end
