module Spec
  module Distributed
    class ValueHolder
      attr_reader :value
      def initialize(v)
        @value = v
      end
    end
  end
end
