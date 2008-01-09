module Spec
  module Distributed
    class DistributedExampleGroupPublisher < Spec::Runner::ExampleGroupRunner
      def initialize(options, args="")
        super(options)
        process_args(args)
        @transport_manager = @manager_class.new
      end

      def process_args(args)
        @manager_class = TransportManager.manager_for(args)
      end

      def run
        prepare
        success = true
        example_groups.each do |example_group|
          transport_manager.publish_job(example_group, @options)
        end
        success = transport_manager.collect_results # timeout?
        success
      ensure
        finish
      end

      protected
      attr_reader :transport_manager
      
      def prepare
        super
        transport_manager.connect(false)
      end
      
    end
  end
end
