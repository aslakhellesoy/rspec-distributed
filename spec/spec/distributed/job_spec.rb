require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Job do

      it "should construct a job with the spec_file and example_group description, example_group object id and return path" do
        @example_group = mock('example group')
        @example_group.should_receive(:spec_path).and_return("/a/b/d/d_spec.rb:12345")
        @example_group.should_receive(:description).and_return("example group description")
        @example_group.should_receive(:object_id).and_return(54321)
        
        Job.should_receive(:new).with(:spec_file => "/a/b/d/d_spec.rb",
                                      :example_group_description => "example group description",
                                      :example_group_object_id => 54321,
                                      :return_path => "return_path")
        Job.create_job(@example_group, mock("options"), "return_path")
      end

      
      it "should store the remote example_group object id" do
        Job.new(:example_group_object_id => 1).example_group_object_id.should == 1
      end

      it "should store the remote example_group object id" do
        Job.new(:reporter => "reporter").reporter.should == "reporter"
      end

      it "should store additional libraries" do
        job = Job.new
        job.add_library "a"
        job.add_library "b"
        job.libraries.should == ["a", "b"]
      end

    end
  end
end
