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
        transport_type && transport_manager
      end

      def transport_manager
        @transport_manager ||= create_transport_manager
      end

      protected
      def create_transport_manager
        begin
          type, options = parse_transport_manager_options
          @transport_manager = TransportManager.manager_for(type).new(options)
        rescue NoSuchTransportException => e
          nil
        end
      end

      def parse_transport_manager_options
        start = transport_type.index(':')
        if start
          type = transport_type[0...start]
          options = start ? transport_type[start +1..-1] : ""
        else
          type = transport_type
          options = ""
        end
        return type, options
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

