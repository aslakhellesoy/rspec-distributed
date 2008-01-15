module Spec
  module Distributed
    class SlaveExampleGroupRunner < ::Spec::Runner::ExampleGroupRunner

      def initialize(options, args="")
        super(options)
        process_args(args)
        read_job
      end

      def process_args(args)
        (transport_manager, tuple_args) = *split_args(args)
        manager_class = TransportManager.manager_for(transport_manager)
        @transport_manager = manager_class.new(tuple_args)
      end
      
      def split_args(args)
        args.split(/:/)
      end

      def read_job
        # what is true to the transport_manager?
        transport_manager.connect(true)
        @job = transport_manager.next_job
        @options.files << job.spec_file
        @options.examples << job.example_group_description
      end

      def load_files(files)
        puts "load_files files = #{files.inspect}"
        super
      end
      
      def run
        @result = super
      end

      protected
      attr_reader :transport_manager, :job

      # do not call 'super' for either prepare or finish.
      # is resets the bookkeeping on the master
      def prepare
        @recording_reporter = RecordingReporter.new # need a watermark?
        @options.reporter = Dispatcher.new(@recording_reporter, reporter)
        example_groups.each do |eg|
          next unless eg.description_options
          eg.description_options[:remote_example_group_object_id] = job.example_group_object_id
        end
      end

      def finish
        publish_result
      end

      def publish_result
        job.result = @result
        job.reporter = @recording_reporter
        transport_manager.publish_result(job)
      end
    end

    class Dispatcher
      def initialize(*children)
        @children = children
      end

      def method_missing(method, *args)
        @children.each{|child| child.__send__(method, *args)}
      end
    end

  end
end
