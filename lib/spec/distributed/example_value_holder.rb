module Spec
  module Distributed
    class ExampleValueHolder
      def initialize(example)
        @description = example.description
        @example_group_value_holder = ExampleGroupValueHolder.new(example.class)
      end

      def value 
        example_group = @example_group_value_holder.value
        if @description =~ /:all/
          example_group.new(@description)
        else
          example_group.examples.find do |e|
            e.description == @description
          end
        end
      end
    end
  end
end
