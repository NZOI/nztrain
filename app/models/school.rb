class School < ApplicationRecord
  has_many :users, dependent: :nullify

  has_many :synonyms, class_name: "School", as: :synonym
  belongs_to :synonym, class_name: "School"
end
