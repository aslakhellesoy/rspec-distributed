module Spec
  module Distributed
    class Options
      attr_accessor :transport_type,
                    :fork,
                    :argv
      def initialize(error_stream, out_stream)
        @error_stream, @out_stream = error_stream, out_stream
        self.fork = true
      end

      def valid?
        transport_type_valid?
      end

      def transport_type_valid?
        begin
          TransportManager.manager_for(transport_type)
        rescue NoSuchTransportException => e
          false
        end
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
        :transport_type => ["-t", "--transport-type TYPE", "The transport type. Arguments to the transport manager",
                            "are appended to the transport type. e.g. rinda:1,2"],
        :fork => ["--[no-]fork", "To force forking, or not, of jobs. Defaults to true"],
        :help => ["-h", "--help", "You're looking at it"]
      }

      def initialize(err, out)
        super()
        @error_stream = err
        @out_stream = out

        @options = Options.new(@error_stream, @out_stream)
        self.banner = "Usage: remote_job_runner [options]"
        self.separator ""
        on(*OPTIONS[:transport_type]) {|transport_type| @options.transport_type = transport_type }
        on(*OPTIONS[:fork]) {|fork_mode| @options.fork = fork_mode } 
        on(*OPTIONS[:help]) {parse_help}
      end

      def parse(argv)
        super
        parse_help unless @options.valid?
      end
      
      def parse_help
        @out_stream.puts self
        exit if stdout?
      end

      protected
      def stdout?
        @out_stream == $stdout
      end

      def stderr?
        @error_stream == $stderr
      end

    end
  end
end

