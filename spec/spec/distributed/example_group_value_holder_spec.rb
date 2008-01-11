require File.dirname(__FILE__) + '/../../spec_helper.rb'
module Spec
  module Distributed
    describe ExampleGroupValueHolder do
      attr_reader :example_group, :holder
      include OptionsHelper

      before do
        @example_group = mock("example_group")
        @example_group.should_receive(:object_id).twice.and_return(654321)
        @example_group.should_receive(:description_options).and_return({:remote_example_group_object_id => 654321})
        
        @rspec_options = mock("rspec_options")
        @rspec_options.should_receive(:example_groups).and_return([@example_group])
      end

      it "should return the example group when example group has a description" do
        @holder = ExampleGroupValueHolder.new(@example_group)
 
        with_rspec_options(@rspec_options) do
          holder.value.should equal(example_group)
        end
      end

    end
  end
end
