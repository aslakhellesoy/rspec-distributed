module Spec
  module Distributed
    class TransportManager

      def self.inherited(klass)
        @subclasses ||= []
        @subclasses << klass
      end

      def self.subclasses_by_type
        @subclasses_by_type ||= @subclasses.inject({}) do |hash, klass|
          begin
            hash[klass.transport_type] = klass
          rescue NoMethodError => e
            @subclasses.delete(klass)
            raise e
          end
          hash
        end
      end
      
      def self.manager_for(transport_type)
        subclasses_by_type[transport_type]
      end
    end
  end
end
