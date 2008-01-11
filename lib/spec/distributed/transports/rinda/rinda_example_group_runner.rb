module Spec
  module Distributed
    class RindaExampleGroupRunner < ::Spec::Runner::ExampleGroupRunner
      include TupleArgs
      include RindaConnection

      def initialize(options, args="")
        super(options)
        @transport_manager = RindaTransportManager.new(args)
        read_job
      end

      def read_job
        @transport_manager.connect(true)
        @job = @transport_manager.next_job

        @options.files << @job.spec_file
        @options.examples << @job.example_group_description
      end

      def load_files(files)
        puts "load_files files = #{files.inspect}"
        super
      end
      
      def run
        @result = super
      end

      def prepare
        @recording_reporter = RecordingReporter.new # need a watermark?
        @options.reporter = Dispatcher.new(@recording_reporter, reporter)
        example_groups.each do |eg|
          eg.description_options[:remote_example_group_object_id] = @job.example_group_object_id
        end
        super
      end

      def finish 
        super
        publish_result
      end

      def publish_result
        @job.result = @result
        @job.reporter = @recording_reporter
        @transport_manager.publish_result(@job)
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
