
module Spec
  module Distributed
    class JobRunner
      attr_reader :transport_manager
      
      def initialize(transport_manager)
        @transport_manager = transport_manager
      end

      def start 
        transport_manager.connect
        start_jobs
        transport_manager.run
      end

      def start_jobs
        # how to manager other threads with DRb.thread?
        @t = Thread.new do
          while job = transport_manager.next_job
            job.run
          end
          # then what?
        end
      end
      
    end
  end
end
