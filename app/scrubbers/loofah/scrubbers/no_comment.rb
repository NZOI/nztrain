module Loofah
  module Scrubbers
    class NoComment < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return CONTINUE unless node.comment?
        node.remove
        STOP
      end
    end
  end
end
