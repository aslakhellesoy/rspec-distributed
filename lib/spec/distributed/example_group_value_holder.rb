module Spec
  module Distributed
    class ExampleGroupValueHolder
      def initialize(example_group)
        @object_id = example_group.description_options[:example_group_object_id]
       end

      def value 
        value = rspec_options.example_groups.find do |eg|
          eg.object_id == @object_id
        end
        debugger if value.nil?
        value
      end
    end
  end
end
