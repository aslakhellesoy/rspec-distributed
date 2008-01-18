module Spec
  module Distributed
    class MasterExampleGroupRunner < Spec::Runner::ExampleGroupRunner
      def initialize(options, args="")
        super(options)
        process_args(args)
      end

      def process_args(args)
        (transport_manager, tuple_args) = *split_args(args)
        manager_class = TransportManager.manager_for(transport_manager)
        @transport_manager = manager_class.new(tuple_args)
      end

      def split_args(args)
        args.split(/:/)
      end

      def run
        prepare
        publish_example_groups
        collect_results
      ensure
        finish
      end

      protected
      attr_reader :transport_manager
      
      def connect
        transport_manager.connect
      end

      def prepare 
        super
        connect
      end

      def example_groups
        @options.example_groups.reject do |eg|
          eg.spec_path.nil?
        end
      end

      def publish_example_groups
        example_groups.each do |example_group|
          job = Job.create_job(example_group, @options, transport_manager.return_path)
          Hooks.run_master_hooks(job)
          transport_manager.publish_job(job)
        end
      end
      
      def collect_results
        success = true
        transport_manager.collect_results do |job|
          success = success & job.result
          job.reporter.replay(reporter)
        end
      end
      
    end
  end
end
