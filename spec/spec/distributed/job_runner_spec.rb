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
        job = mock("job")
        job.should_receive(:run).twice
        @job_manager.should_receive(:next_job).and_return(job, job, nil)
        @job_manager.should_receive(:run)
        @job_manager.should_receive(:publish_result).twice.with(job)
        runner.start
      end
    end
  end
end
