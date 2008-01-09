module Spec
  module Distributed
    module RindaConnection

      def connect(start_if_not_found = false)
        return if @service_ts
        DRb.start_service unless DRb.thread
        @url = DRb.uri.to_s
        @service_ts = if start_if_not_found
          find_or_start_ring_server
        else
          find_ring_server
        end
        puts "Located Ring server: #{@service_ts.instance_of?(DRb::DRbObject) ? @service_ts.__drburi : 'locally'}"
#        start_notifier
      end

#      def run 
#        DRb.thread.join
#      end
#      
      def find_or_start_ring_server
        begin
          find_ring_server
        rescue RuntimeError
          start_ring_server
        end
      end

      def find_ring_server
        puts "Looking for Ring server..."
        Rinda::RingFinger.finger.lookup_ring_any unless @service_ts = Rinda::RingFinger.primary
        Rinda::RingFinger.primary
      end

      def start_ring_server
        puts "No Ring server found, starting my own."
        @service_ts = Rinda::TupleSpace.new
        @ring_server = Rinda::RingServer.new(@service_ts)
        @service_ts
      end

      # might be good for out-out-bound messaging
      def start_notifier
        Thread.start do
          notifier = @service_ts.notify 'write', default_tuple
          notifier.each do |_, t|
            puts "Write event: #{t.inspect}"
          end
        end
      end

    end
  end
end
