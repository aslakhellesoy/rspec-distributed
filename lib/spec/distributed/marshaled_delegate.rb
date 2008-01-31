module Spec
  module Distributed
    class MarshaledDelegate
      def initialize(target)
        @target = target
      end

      def marshal_dump
        @dumped_target || Marshal.dump(@target)
      end

      def marshal_load(target_string)
        @dumped_target = target_string
      ensure
        @target = nil
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
      ensure
        @dumped_target = nil
      end
    end
  end
end
