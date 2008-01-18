module Spec
  module Distributed
    class RemoteJobRunner
      attr_reader :current_job
      
      def initialize(options)
        @options = options
      end

      def run
        transport_manager.connect(true)
        begin
          puts "taking job"
          @current_job = transport_manager.next_job
          puts "got job"
          
          transport_manager.write_job(current_job, job_identifier)

          run_non_forked
          #run_forked
        end while keep_running?
      end

      def keep_running?
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
    end
  end
end
