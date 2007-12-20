require 'rinda/ring'
require 'rinda/tuplespace'

module Spec
  module Distributed
    class RindaTransportManager < TransportManager
      include TupleArgs

      def self.transport_type
        "rinda"
      end

      def initialize
        process_tuple_args(nil)
      end
      
      def connect
        DRb.start_service
        @url = DRb.uri.to_s
        find_or_start_ring_server

        start_notifier
      end

      def connect_for_publishing
        DRb.start_service
        @url = DRb.uri.to_s
        find_ring_server
      end

      def run 
        DRb.thread.join
      end
      
      def find_or_start_ring_server
        begin
          find_ring_server
        rescue RuntimeError
          start_ring_server
        end
      end

      def find_ring_server
        puts "Looking for Ring server..."
        @service_ts = Rinda::RingFinger.primary
        puts "Located Ring server at #{@service_ts.__drburi}"
      end

      def start_ring_server
        puts "No Ring server found, starting my own."
        @service_ts = Rinda::TupleSpace.new
        @ring_server = Rinda::RingServer.new(@service_ts)
      end
      
      # might be good for out-out-bound messaging
      def start_notifier
        Thread.start do
          notifier = @service_ts.notify 'write', tuples
          notifier.each do |_, t|
            puts "Write event: #{t.inspect}"
          end
        end
      end

      def next_job
        begin
          tuple = @service_ts.take tuples
        rescue Exception => e
          puts "caught Exception #{e}"
          retry
        end
        Job.new(tuple[2])
      end

      def publish_job(example_group, options)
        tuple = tuples
        spec_path = strip_line_number(example_group.spec_path)
        tuple[2] = {:spec_file => spec_path}
        @service_ts.write tuple
      end

      def strip_line_number(spec_path)
        spec_path.gsub(/:\d+\Z/, "")
      end
    end
  end
end
