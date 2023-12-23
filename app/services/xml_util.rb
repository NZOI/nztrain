module XmlUtil
  def self.serialize_list builder, name, docs
    array_type = ActiveSupport::XmlMini::TYPE_NAMES['Array']
    builder.tag!(name, 'count' => docs.count, 'type' => array_type) do
      docs.each do |doc| yield doc end
    end
  end

  def self.serialize_id_list builder, name, docs
    array_type = ActiveSupport::XmlMini::TYPE_NAMES['Array']

    XmlUtil.serialize_list builder, name, docs do |doc|
      XmlUtil.tag builder, 'id', doc.id
    end
  end

  # Wrapper around ActiveSupport's to_tag method as the original is pretty long
  def self.tag builder, name, value
    ActiveSupport::XmlMini.to_tag(name, value, {:builder => builder})
  end
end
