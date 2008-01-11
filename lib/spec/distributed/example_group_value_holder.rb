module Spec
  module Distributed
    class ExampleGroupValueHolder
      def initialize(example_group)
        @object_id = example_group.description_options[:remote_example_group_object_id]
       end

      def value 
        rspec_options.example_groups.find do |eg|
          eg.object_id == @object_id
        end
      end
    end
  end
end
