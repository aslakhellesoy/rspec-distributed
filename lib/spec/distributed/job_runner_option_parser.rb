module Spec
  module Distributed
    class Options
      attr_accessor :transport_type,
                    :fork
      def initialize(error_stream, out_stream)
        @error_stream, @out_stream = error_stream, out_stream
        self.fork = true
      end
    end
    
    class JobRunnerOptionParser < ::OptionParser
      class << self
        def parse(args, err, out)
          parser = new(err, out)
          parser.parse(args)
          parser.options
        end
      end

      attr_reader :options
      OPTIONS = {
        :transport_type => ["-t", "--transport-type TYPE[:TRANSPORT_OPTIONS]", "The transport type. Arguments to the transport manager",
                            "are appended to the transport type. e.g. rinda:1,2"],
        :fork => ["--[no-]fork", "To force forking, or not of jobs. Defaults to true"],
      }

      def initialize(err, out)
        super
        @error_stream = err
        @out_stream = out

        @options = Options.new(@error_stream, @out_stream)
        self.banner = "Usage: remote_job_runner [options]"
        self.separator ""
        on(*OPTIONS[:transport_type]) {|transport_type| @options.transport_type = transport_type }
        on(*OPTIONS[:fork]) {|fork_mode| @options.fork = fork_mode }
      end
    end
  end
end

