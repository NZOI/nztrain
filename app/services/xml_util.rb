module XmlUtil
  def self.serialize_id_list builder, name, docs
    array_type = ActiveSupport::XmlMini::TYPE_NAMES['Array']

    builder.tag!(name, 'count' => docs.count, 'type' => array_type) do
      docs.each do |doc|
        ActiveSupport::XmlMini.to_tag(
          'id',
          doc.id,
          {:builder => builder},
        )
      end
    end
  end
end
