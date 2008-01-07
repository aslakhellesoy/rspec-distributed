module Spec
  module Distributed
    class RindaExampleGroupRunner < ::Spec::Runner::ExampleGroupRunner
      include TupleArgs
      include RindaConnection
      
      def initialize(options, args="")
        super(options)
        process_tuple_args(args)
        yield self if block_given? # for testing
        read_job
      end

      def read_job
        connect(true) unless @service_ts
        tuple = @service_ts.take default_tuple
        @job = tuple[2]

        @options.files << @job.spec_file
        @options.examples << @job.example_group_description
      end

      def load_files(files)
        puts "load_files files = #{files.inspect}"
        super
      end
      
      def run 
        result = super
        @job.result = result
      end

    end
  end
end
