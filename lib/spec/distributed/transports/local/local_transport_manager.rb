module Spec
  module Distributed
    class LocalTransportManager < TransportManager
      known_as "local"

      attr_reader :jobs, :results
      def initialize(options="")
        @jobs = []
        @results = {}
        @published_count = 0
      end

      def connect(start)
      end

      def next_job
        job = jobs.pop
        while job.nil?
          sleep 1
          job = jobs.pop
        end 
      end

      def publish_job(job, path = return_path)
        job.return_path = path
        jobs.push job
      end

      def return_path 
        object_id
      end

      def publish_result(job)
        results[job.return_path] ||= []
        results[job.return_path].push job
        @published_count += 1
      end

      def collect_results
        result = true
        while @published_count > 0
          puts "Taking next result #{@published_count}"
          job = next_result
          @published_count -= 1
          yield job
        end
        result
      end

      def next_result 
        results[return_path].pop
      end
      
    end
  end
end
