require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Job do
      it "should generate a rspec options with the spec file" do
        @job = Job.new(:spec_file => "a/path/to/spec.rb")
        @job.spec_commandline.should match(%r|a/path/to/spec.rb|)
      end

      it "should call Spec::Runner::CommandLine to run the spec" do
        @job = Job.new(:spec_file => "a/path/to/spec.rb")
        Kernel.should_receive(:system).with("spec a/path/to/spec.rb")
        @job.run
      end
    end
  end
end
