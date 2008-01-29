module Spec
  module Distributed
    class RemoteJobRunner
      attr_reader :current_job
      
      def initialize(options)
        @options = options
      end

      def run
        prepare
        begin
          select_job
          run_current_job
        end while keep_running?
      end

      def prepare 
        transport_manager.connect(true)
      end

      def select_job
        @current_job = transport_manager.next_job
        transport_manager.write_job(current_job, job_identifier)
      end
      
      def run_current_job
        set_environment
        if run_forked?
          run_forked
        else
          run_non_forked
        end
      ensure
        reset_environment
      end

      def keep_running?
        true
      end

      def run_forked?
        true
      end

      def run_non_forked
        ::Spec::Runner::CommandLine.run(parsed_options)
      end

      def run_forked
        system("spec #{spec_options.join(' ')}")
      end

      def parsed_options
        ::Spec::Runner::OptionParser.parse(spec_options, STDERR, STDOUT)  
      end
      
      def spec_options 
        options =
          [
           "--require", "spec/distributed", 
           "--runner",
           "Spec::Distributed::SlaveExampleGroupRunner:#{transport_type}:#{job_identifier}"
          ]
        
        current_job.libraries.each do |lib|
          options << "--require"
          options << lib
        end
        puts options.inspect
        options
      end

      def transport_type 
        @options.transport_type  
      end

      def job_identifier 
        "#{Process::pid}"
      end

      def transport_manager 
        @transport_manager ||= TransportManager.manager_for(transport_type).new
      end

      def set_environment
        current_job.environment.each do |key, value|
          ENV[key] = value
        end
      end

      def reset_environment
        current_job.environment.each do |key, value|
          ENV.delete key
        end
      end
    end
  end
end
