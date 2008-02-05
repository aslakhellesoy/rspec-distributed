module Spec
  module Distributed
    class NoSuchTransportException < ArgumentError; end
    class TransportManager
      class << self
        attr_reader :transport_type 
        def inherited(klass)
          @subclasses ||= []
          @subclasses << klass
        end

        def known_as(type)
          @transport_type = type
        end

        def subclasses_by_type
          @subclasses.inject({}) do |hash, klass|
            begin
              next hash unless klass.transport_type
              hash[klass.transport_type] = klass
            rescue NoMethodError => e
              # munch
            end
            hash
          end
        end
        
        def manager_for(transport_type)
          transport_types = subclasses_by_type.keys
          manager = subclasses_by_type[transport_type]
          if manager.nil?
            raise NoSuchTransportException.new("No known transport_type #{transport_type}. Known transport_types are '#{transport_types.join(',')}'")
          end
          manager
        end
      end

      def initialize(args)
      end
    end
  end
end
