module Loofah
  module Scrubbers
    # rewrites all relative links relative to a root (or image src)
    class EscapeWithCustomWhitelist < Loofah::Scrubbers::Escape
      CUSTOM_ALLOWED_ELEMENTS = {
        'object' => [
          # svg objects
          {'data' => /\A\/?(([#{URI::REGEXP::PATTERN::UNRESERVED}]|#{URI::REGEXP::PATTERN::ESCAPED})+\/)*([#{URI::REGEXP::PATTERN::UNRESERVED}]|#{URI::REGEXP::PATTERN::ESCAPED})+\.svg\z/, 'type' => /\Aimage\/svg\+xml\z/}
        ]
      }

      def initialize
        @direction = :top_down
      end

      def scrub(node)
        # Custom whitelist
        if node.type == Nokogiri::XML::Node::ELEMENT_NODE && CUSTOM_ALLOWED_ELEMENTS.has_key?(node.name)
          CUSTOM_ALLOWED_ELEMENTS[node.name].each do |criteria|
            matching = true
            criteria.each do |key, value|
              attr_val = node.has_attribute?(key) ? node.get_attribute(key) : "";
              # does attribute value match regular expression?
              matching &&= (attr_val =~ value);
            end
            if matching
              node.attributes.keys.each do |attr|
                unless criteria.has_key?(attr) || Loofah::HTML5::WhiteList::ACCEPTABLE_ATTRIBUTES.include?(attr)
                  node.remove_attribute(attr)
                end
              end
              return CONTINUE
            end
          end
        end
        # default behaviour
        super(node)
      end
    end
  end
end

