require File.dirname(__FILE__) + '/../../spec_helper.rb'
module Spec
  module Distributed
    describe ExampleGroupValueHolder do
      attr_reader :example_group, :holder
      include OptionsHelper

      before do
        @example_group = mock("example_group")
#        @example_group.should_receive(:spec_path).twice.and_return("spec_path")
        
        @rspec_options = mock("rspec_options")
        @rspec_options.should_receive(:example_groups).and_return([@example_group])
      end

      it "should return the example group when example group has a description" do
        @example_group.should_receive(:description).twice.and_return("description")
        @holder = ExampleGroupValueHolder.new(@example_group)
 
        with_rspec_options(@rspec_options) do
          holder.value.should equal(example_group)
        end
      end

      it "should return the example group when example group has no description (for #187 in rspec)" do
        @example_group.should_receive(:description).twice.and_return("")
        @example_group.should_receive(:name).twice.and_return("MyTestCase")
        @holder = ExampleGroupValueHolder.new(@example_group)

        with_rspec_options(@rspec_options) do
          holder.value.should equal(example_group)
        end
      end
    end
  end
end
