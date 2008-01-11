require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Job do
      it "should generate rspec command line with the spec file" do
        @job = Job.new(:spec_file => "a/path/to/spec.rb")
        @job.spec_commandline.should match(%r|a/path/to/spec.rb|)
      end

      it "should specify the example group, if given the description" do
        @job = Job.new(:spec_file => "a/spec.rb")
        @job.spec_commandline.should_not match(/-e/)

        @job = Job.new(:spec_file => "a/spec.rb",
                       :example_group_description => "my example group")
        @job.spec_commandline.should match(/-e 'my example group'/)
      end
      
      it "should store the remote example_group object id" do
        Job.new(:example_group_object_id => 1).example_group_object_id.should == 1
      end

      it "should store the remote example_group object id" do
        Job.new(:reporter => "reporter").reporter.should == "reporter"
      end

    end
  end
end
