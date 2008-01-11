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

      def return_path
        DRb.uri
      end
      
      def next_job
        take_job default_tuple
      end

      def next_result
        take_job result_tuple(nil, return_path)
      end

      def result_tuple(job, path)
        [:rspec_slave, :job_result, job, path]
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
        job = create_job(example_group, options)
        tuple = default_tuple
        tuple[2] = job
        @service_ts.write tuple
        @published_count += 1
      end

      def publish_result(job)
        tuple = result_tuple(job, job.return_path)
        @service_ts.write tuple
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

      def create_job(example_group, options)
        # TODO: This only handles one level of nested example groups.
        # Not needed if the bug is fixed (nested example_groups don't have spec_paths)
        path = example_group.spec_path
        path = example_group.superclass.spec_path if path.nil? # rspec bug ????
        spec_path = strip_line_number(path)

        # master (publisher) hooks go here
        Job.new(:spec_file => spec_path,
                :example_group_description => example_group.description,
                :example_group_object_id => example_group.object_id,
                :return_path => return_path)
        # need a return path
      end

      def strip_line_number(spec_path)
        spec_path.gsub(/:\d+\Z/, "")
      end
    end
  end
end
