require 'rinda/ring'
require 'rinda/tuplespace'

module Spec
  module Distributed
    class RindaTransportManager < TransportManager
      include TupleArgs
      include RindaConnection

      def self.transport_type
        "rinda"
      end

      def initialize(tuple_args="")
        process_tuple_args(tuple_args)
        @published_count = 0
      end
      
      def next_job
        take_job default_tuple
      end

      def next_result
        take_job result_tuple
      end

      def result_tuple
        [:rspec_slave, :job_result, nil]
      end

      def take_job(template)
        begin
          tuple = @service_ts.take template
        rescue Exception => e
          puts "caught Exception #{e}"
          retry
        end
        tuple[2]
      end

      def publish_job(example_group, options)
        tuple = default_tuple
        tuple[2] = create_job(example_group, options)
        @service_ts.write tuple
        @published_count += 1
      end

      def publish_result(job)
        tuple = result_tuple
        tuple[2] = job
        @service_ts.write tuple
      end

      def collect_results
        # read all result tuples, untill we have enough or timeout
        # collect the results and return them
        result = true
        while @published_count > 0
          puts "Taking next result #{@published_count}"
          job = next_result
          result = result & job.result
          @published_count -= 1
        end
        result
      end

      def create_job(example_group, options)
        path = example_group.spec_path
        path = example_group.superclass.spec_path if path.nil?
        spec_path = strip_line_number(path)
        Job.new(:spec_file => spec_path,
                :example_group_description => example_group.description,
                :return_path => @service_ts)
      end

      def strip_line_number(spec_path)
        spec_path.gsub(/:\d+\Z/, "")
      end
    end
  end
end
