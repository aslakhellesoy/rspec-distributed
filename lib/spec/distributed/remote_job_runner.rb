require 'systemu'

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
          select_and_assign_job
          run_assigned_job
          check_job_status
        end while keep_running?
      end

      def prepare 
        transport_manager.connect(true)
      end

      def select_and_assign_job
        @current_job = transport_manager.assign_next_job_to(slave_identifier)
      end
      
      def run_assigned_job
        set_environment
        if run_forked?
          run_forked
        else
          run_non_forked
        end
      ensure
        reset_environment
      end

      def check_job_status
        if job = transport_manager.take_assigned_job(slave_identifier, 0)
          job.success = false
          job.fatal_failure = true
          job.slave_stdout = @stdout
          job.slave_stderr = @stderr
          job.slave_status = @status
          transport_manager.publish_result(job)
        end
      end

      def keep_running?
        true
      end

      def run_forked?
        @options.fork
      end

      def run_non_forked
        ::Spec::Runner::CommandLine.run(parsed_options)
      end

      def run_forked
        @status, @stdout, @stderr = systemu("spec #{spec_options.join(' ')}")
        puts @status
        puts @stdout
        puts @stderr
      end

      def parsed_options
        ::Spec::Runner::OptionParser.parse(spec_options, STDERR, STDOUT)  
      end
      
      def spec_options 
        options =
          [
           "--require", "spec/distributed", 
           "--runner",
           "Spec::Distributed::SlaveExampleGroupRunner:#{transport_type}:#{slave_identifier}"
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

      def slave_identifier 
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
