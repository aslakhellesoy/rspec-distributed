require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe JobRunner do

      attr_reader :runner
      before do
        @job_manager = mock("rinda helper")
        @runner = JobRunner.new(@job_manager)
      end
      
      it "should run specs until nil" do
        @job_manager.should_receive(:connect)
        spec = mock("spec")
        spec.should_receive(:run).twice
        @job_manager.should_receive(:next_job).and_return(spec, spec, nil)
        @job_manager.should_receive(:run)
        runner.start
      end
    end
  end
end
