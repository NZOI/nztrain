module XmlUtil
  def self.serialize_id_list builder, name, docs
    builder.tag!(name, 'count' => docs.count) do
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
