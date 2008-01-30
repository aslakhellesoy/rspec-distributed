module Spec
  module Distributed
    class MarshaledDelegate
      def initialize(target)
        @target = target
      end

      def marshal_dump
        Marshal.dump(@target)
      end

      def marshal_load(target_string)
        @target = nil
        @dumped_target = target_string
      end

      def method_missing(method, *args)
        target.__send__(method, *args)
      end

      def ==(other)
        target == other
      end

      def target 
        @target ||= load_target
      end

      def load_target
        Marshal.load(@dumped_target)
      end
    end
  end
end
