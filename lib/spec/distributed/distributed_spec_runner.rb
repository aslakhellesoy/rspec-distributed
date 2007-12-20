module Spec
  module Distributed
    class DistributedSpecRunner < Spec::Runner::ExampleGroupRunner
      def initialize(options, args="")
        super(options)
        process_args(args)
      end

      def process_args(args)
        manager_class = TransportManager.manager_for(args)
        @transport_manager = manager_class.new
      end

      def run
        @transport_manager.connect_for_publishing
        example_groups.each do |example_group|
          @transport_manager.publish_job(example_group, @options)
        end
        true
      end
      
    end
  end
end
