class Entity < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true

  def definite_article
    if entity_type == "Organisation"
      "the" # change to settable
    else
      nil
    end
  end
end
