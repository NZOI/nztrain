class Language < ActiveRecord::Base
  #attr_accessible :compiler, :is_interpreted, :name

  def compile_command parameters = {}
    parameters.assert_valid_keys(:source, :output)
    parameters.fetch(:source)
    parameters.reverse_merge! :output => 'a.out'
    parameters.merge! :compiler => compiler
    sprintf("%{compiler} #{flags} %{source}", parameters)
  end
end
