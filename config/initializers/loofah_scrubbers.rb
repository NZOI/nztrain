module Loofah
  module Scrubbers
    class NoForm < Scrubber
      def initialize
        @direction = :top_down
      end
      def scrub(node)
        return CONTINUE unless (node.type == Nokogiri::XML::Node::ELEMENT_NODE) && (['form','input','select','textarea'].include? node.name)
        node.add_next_sibling Nokogiri::XML::Text.new(node.to_s, node.document)
        node.remove
        return STOP
      end
    end
    class MathJax < Scrubber
      def initialize
        @direction = :top_down
      end
      def scrub(node)
        if node.name == "text"
          pos = 0
          content = node.content
          # find latex by
          # matching any non-dollar string (except for escaped dollars - \$), surrounded by dollars, subject to:
          # - neither outside dollars are escaped
          # - ending dollar does not precede numerical character
          while match = content.match(/(?<!\\)\$([^$]|(\\$))+(?<!\\)\$(?![0-9])/, pos)
            # make math/tex script for latex
            script = Nokogiri::XML::Element.new "script", node.document
            script.set_attribute 'type', 'math/tex'
            script.add_child Nokogiri::XML::Text.new(match[0][1...-1], node.document) # add latex to script tag
            node.add_previous_sibling script # insert script tag above
            
            script.add_previous_sibling Nokogiri::XML::Text.new(content[pos...match.begin(0)], node.document) # insert relevant text above script

            # TODO: add <noscript> alternative

            pos = match.end(0)
          end
          node.content = content[pos..-1] # set remaining text
        end
        return CONTINUE
      end
    end
  end
end

