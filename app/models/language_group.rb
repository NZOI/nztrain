class LanguageGroup < ActiveRecord::Base
  has_many :languages, foreign_key: :group_id
  belongs_to :current_language, class_name: Language
end
