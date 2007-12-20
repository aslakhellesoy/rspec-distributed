module Spec
  module Distributed
    class NoSuchTransportException < ArgumentError; end
    class TransportManager

      def self.inherited(klass)
        @subclasses ||= []
        @subclasses << klass
      end

      def self.subclasses_by_type
        @subclasses.inject({}) do |hash, klass|
          begin
            hash[klass.transport_type] = klass
          rescue NoMethodError => e
            # munch
          end
          hash
        end
      end
      
      def self.manager_for(transport_type)
        transport_types = subclasses_by_type.keys
        manager = subclasses_by_type[transport_type]
        if manager.nil?
          raise NoSuchTransportException.new("No known transport_type #{transport_type}. Known transport_types are #{transport_types.join(' ' )}")
        end
        manager
      end
    end
  end
end
