module Loofah
  module Scrubbers
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
          regex = {}
          regex[:re] = /(?<re>(?<!\\){([^{}]|\\({|})|\g<re>)*(?<!\\)})/ # matches balanced unescaped braces in tex
          regex[:tex] = /([^${}]|(\\(\$|{|}))|#{regex[:re]})+/ # matches any valid tex content, but avoiding unescaped $ delimiter (which ends the tex expression)
          regex[:jax] = /(?<!\\)(?<d>\$?)\$#{regex[:tex]}(?<!\\)\$(?![0-9])\g<d>/ # matches tex - including $ and $$ delimiters
          while match = content.match(regex[:jax], pos)
            dollars = 1 + match[:d].length
            tex = match[0][dollars...-dollars]

            fragment = Nokogiri::HTML::DocumentFragment.new node.document
            Nokogiri::HTML::Builder.with(fragment) do |html|
              html.text escape content[pos...match.begin(0)] # text before Jax
              html.span(:class => 'MathJax_Preview', :style => dollars==2?'display: block; text-align: center;':'' ) { # preview before Jax typeset
                html.span(:class => 'js_only') { html.text tex } # preview if javascript exists
                html.noscript {
                  html.text tex # placeholder if javascript doesn't exist, TODO: use mathtex cgi
                }
              }
              html.script(:type => 'math/tex'+(dollars==2?'; mode=display':'')) { html.text tex } # MathJax script
            end

            node.add_previous_sibling fragment

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

