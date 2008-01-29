require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Job do

      it "should construct a job with a relative spec_path, example_group description, example_group object id and return path" do
        @example_group = mock('example group')
        @example_group.should_receive(:spec_path).and_return("/a/b/c/d/d_spec.rb:12345")
        @example_group.should_receive(:description).and_return("example group description")
        @example_group.should_receive(:object_id).and_return(54321)

        Dir.should_receive(:pwd).and_return("/a/b/c")
        
        job = Job.create_job(@example_group, mock("options"), "return_path")
        
        job.spec_path.should == "d/d_spec.rb"
        job.example_group_description.should == "example group description"
        job.example_group_object_id.should == 54321
        job.return_path.should == "return_path"
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

      it "should store environment pairs" do
        job = Job.new
        job.add_environment("A", "A")
        job.add_environment("B", "B")
        job.environment.should == {"A" => "A", "B" => "B"}
      end

    end
  end
end
