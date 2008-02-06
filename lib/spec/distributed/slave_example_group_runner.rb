module Spec
  module Distributed
    class SlaveExampleGroupRunner < ::Spec::Runner::ExampleGroupRunner
      attr_reader :report_dump_filename
      def initialize(options, args="")
        super(options)
        if args.empty?
          raise ArgumentError.new("SlaveExampleGroupRunner requires a temp filename for dumping the RecordingReporter")
        end
        @report_dump_filename = args
      end

      protected
      # do not call 'super' for either prepare or finish.
      # is resets the bookkeeping on the master
      def prepare
        insert_recording_reporter
        link_example_groups
      end

      def finish
        publish_result
      end

      def publish_result
        File.open(report_dump_filename, "w") do |file|
          delegate = MarshaledDelegate.new(@recording_reporter)
          Marshal.dump(delegate, file)
        end
      end

      def insert_recording_reporter
        @recording_reporter = RecordingReporter.new # TODO: need a watermark?
        @options.reporter = Dispatcher.new(@recording_reporter, reporter)
      end

      def link_example_groups
        example_groups.each do |eg|
          next unless eg.description_options
          eg.description_options[:example_group_object_id] = ENV['REMOTE_EXAMPLE_GROUP_OBJECT_ID'].to_i
        end
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
