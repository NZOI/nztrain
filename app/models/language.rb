class Language < ActiveRecord::Base
  #attr_accessible :compiler, :is_interpreted, :name

  def compile file, output
    "#{compiler} #{sprintf(flags, :output => output)} #{file}"
  end
end
