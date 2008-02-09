require 'rinda/ring'
require 'rinda/tuplespace'

module Spec
  module Distributed
    class RindaTransportManager < TransportManager
      include TupleArgs
      include RindaConnection

      known_as "rinda"

      def initialize(tuple_args="")
        process_tuple_args(tuple_args)
        @published_count = 0
      end

      # slave protocol
      def next_job
        puts "in next_job tuple = #{default_tuple.inspect}"
        take_job default_tuple
      end
      
      def publish_result(job)
        tuple = result_tuple(job, job.return_path)
        @service_ts.write tuple
      end

      # master protocol
      def publish_job(job, path = return_path)
        job.return_path = path
        marshaled_delegate = MarshaledDelegate.new(job)
        write_job(marshaled_delegate)
        @published_count += 1
      end
      
      def next_result
        take_job result_tuple(nil, return_path)
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


      def return_path
        DRb.uri
      end

      protected
      def take_job(template, wait = nil)
        tuple = @service_ts.take template, wait
        tuple[2]
      end

      def write_job(job)
        tuple = default_tuple
        tuple[2] = job
        @service_ts.write tuple
      end

      def result_tuple(job, path)
        [:rspec_slave, :job_result, job, path]
      end


    end
  end
end
