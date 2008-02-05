module Spec
  module Distributed
    class JobRunner
      def initialize(options)
        @options = options
      end

      def run
        prepare
        begin
          next_job
          run_job
          publish_result
        end while keep_running?
      end

      def prepare
        #transport_manager.start_local_server_if_required_or_somesuch
        transport_manager.connect(true)
      end

      def next_job
        @job = transport_manager.next_job
      end

      def run_job
        @job.run # options?
      end

      def publish_result
        Marshal.dump(@job) # safety check for now. Don't need any
                           # remote references
        transport_manager.publish_result(@job)
      end

      def keep_running?
        true
      end
      
      protected
      def transport_manager 
        @options.transport_manager
      end
    end
  end
end
