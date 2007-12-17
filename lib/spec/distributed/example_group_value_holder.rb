module Spec
  module Distributed
    class ExampleGroupValueHolder
      def initialize(example_group)
        @description = example_group.description 
        @description = @description == "" ? example_group.name : @description # waiting on #187 in rspec
#        @spec_path = example_group.spec_path
       end

      def value 
        rspec_options.example_groups.find do |eg|
          eg.description == @description || eg.name == @description # &&
#            eg.spec_path == @spec_path
        end
      end
    end
  end
end
