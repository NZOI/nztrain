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
      include ActionView::Helpers::JavaScriptHelper
      def initialize
        @direction = :top_down
      end
      def scrub(node)
        return STOP if (node.type == Nokogiri::XML::Node::ELEMENT_NODE) && (['script','noscript','style','textarea','pre','code'].include? node.name)
        if node.name == "text"
          pos = 0
          content = node.content
          # find latex by
          # matching any non-dollar string (except for escaped dollars - \$), surrounded by dollars, subject to:
          # - neither outside dollars are escaped
          # - ending (single) dollar does not precede numerical character
          re = /(?<re>(?<!\\){([^{}]|\\({|})|\g<re>)*(?<!\\)})/ # matches balanced unescaped braces in tex
          tex_content = /([^${}]|(\\(\$|{|}))|#{re})+/ # matches any valid tex content, but avoiding unescaped $ delimiter (which ends the tex expression)
          tex = /(?<!\\)(?<d>\$?)\$#{tex_content}(?<!\\)\$(?![0-9])\g<d>/ # matches tex - including $ and $$ delimiters
          while match = content.match(tex, pos)
            dollars = 1 + match[:d].length
            # make math/tex script for latex
            script = Nokogiri::XML::Element.new "script", node.document
            script.set_attribute 'type', 'math/tex'+(dollars==2?'; mode=display':'')
            latex = match[0][dollars...-dollars]
            script.add_child Nokogiri::XML::Text.new(latex, node.document) # add latex to script tag
            node.add_previous_sibling script # insert script tag above
            # add <noscript> alternative to view javascript
            #lateximage = Nokogiri::XML::Element.new('img', node.document)
            #lateximage.set_attribute('src','/cgi-bin/mathtex.cgi?'+latex) # TODO: mathtex.cgi to be installed
            noscript = Nokogiri::XML::Element.new('noscript', node.document)
            noscript.set_attribute('style','display: block; text-align: center;') if dollars==2
            #noscript.add_child(lateximage)
            noscript.add_child Nokogiri::XML::Text.new(match[0], node.document)
            script.add_next_sibling noscript

            script.add_previous_sibling Nokogiri::XML::Text.new(escape(content[pos...match.begin(0)]), node.document) # insert relevant text above script

            # insert preview before script
            js_preview = Nokogiri::XML::Element.new('script', node.document)
            js_preview.set_attribute 'type', 'text/javascript'
            js_preview.add_child Nokogiri::XML::Text.new("document.write('#{j latex}');", node.document)
            preview = Nokogiri::XML::Element.new('span', node.document)
            preview.set_attribute('class','MathJax_Preview')
            preview.set_attribute('style','display: block; text-align: center;') if dollars==2
            preview.add_child js_preview
            script.add_previous_sibling preview

            pos = match.end(0)
          end
          node.content = escape content[pos..-1] # set remaining text
        end
        return CONTINUE
      end

      private
      def escape content
        content.gsub(/\\\$/,'$')
      end
    end
  end
end

