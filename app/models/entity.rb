class Entity < ApplicationRecord
  belongs_to :entity, polymorphic: true

  def definite_article
    if entity_type == "Organisation"
      "the" # change to settable
    end
  end
end
