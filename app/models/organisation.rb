class Organisation < ApplicationRecord
  has_one :entity, as: :entity

  def name
    entity.name
  end
end
