require File.dirname(__FILE__) + '/../../spec_helper.rb'
module Spec
  module Distributed
    describe ExampleValueHolder do
      include OptionsHelper
      attr_reader :example, :holder
      before do
        @example_group = mock('example_group')
        @example = mock("example")
        @example.should_receive(:class).twice.and_return(@example_group)
        @example.should_receive(:description).twice.and_return("description")

        @example_group.should_receive(:object_id).and_return(7654321)
        @example_group.should_receive(:description_options).and_return({:remote_example_group_object_id => 7654321})
        @example_group.should_receive(:examples).and_return([@example])

        @rspec_options = mock("rspec_options")
        @rspec_options.should_receive(:example_groups).and_return([@example_group])

        @holder = ExampleValueHolder.new(@example)
      end

      it "should return the example" do
        with_rspec_options(@rspec_options) do
          holder.value.should equal(example)
        end
      end
    end
  end
end
