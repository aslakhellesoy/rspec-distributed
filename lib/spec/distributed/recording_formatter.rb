module Spec
  module Distributed
    # This is used as a reporter and just records method invocations. It is then
    # sent back to the master and all the invocations are replayed there on the master's
    # *real* reporter. Nifty, eh?
    class RecordingFormatter
      def initialize(watermark)
        @watermark = watermark
        @invocations = []
      end

      def method_missing(method, *args)
        marshallable_args = args.map {|arg| pack_arg(arg)}
#        if method.to_s == 'add_example_group'
#          # Watermark each example group description so the final report says where it ran
#          marshallable_args[0].description << " (#{@watermark})" 
#        end
        @invocations << [method, *marshallable_args]
      end
    
      def pack_arg(o)
        if Spec::Example::ExampleGroupMethods === o
          ExampleGroupValueHolder.new(o)
        elsif  Spec::Example::ExampleGroupMethods === o.class
          ExampleValueHolder.new(o)
        else
          ValueHolder.new(o)
        end
      end

      def replay(target)
        @invocations.each do |method, *args|
          unpacked_args = args.map { |arg| arg.value }
          target.__send__(method, *unpacked_args)
        end
      end
    end
  end
end
module Spec
  module Distributed
    # This is used as a reporter and just records method invocations. It is then
    # sent back to the master and all the invocations are replayed there on the master's
    # *real* reporter. Nifty, eh?
    class RecordingFormatter
      def initialize(watermark)
        @watermark = watermark
        @invocations = []
      end

      def method_missing(method, *args)
        marshallable_args = args.map {|arg| pack_arg(arg)}
#        if method.to_s == 'add_example_group'
#          # Watermark each example group description so the final report says where it ran
#          marshallable_args[0].description << " (#{@watermark})" 
#        end
        @invocations << [method, *marshallable_args]
      end
    
      def pack_arg(o)
        if Spec::Example::ExampleGroupMethods === o
          ExampleGroupValueHolder.new(o)
        elsif  Spec::Example::ExampleGroupMethods === o.class
          ExampleValueHolder.new(o)
        else
          ValueHolder.new(o)
        end
      end

      def replay(target)
        @invocations.each do |method, *args|
          unpacked_args = args.map { |arg| arg.value }
          target.__send__(method, *unpacked_args)
        end
      end
    end
  end
end
