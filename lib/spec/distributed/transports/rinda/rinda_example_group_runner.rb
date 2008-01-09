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
        result = super
        publish_result(result)
      end

      def publish_result(result)
        @job.result = result
        @transport_manager.publish_result(@job)
      end
    end
  end
end
