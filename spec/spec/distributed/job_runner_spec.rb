require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe JobRunner do
      attr_reader :transport_manager, :job_runner
      before do
        @transport_manager = mock("transport_manager")
        @options = mock("options")
        @options.stub!(:transport_manager).and_return(transport_manager)
        @job_runner = JobRunner.new(@options)
      end
      
      describe "before reading jobs" do
        it "should connect to the transport" do
          transport_manager.should_receive(:connect)
          job_runner.prepare
        end
      end

      describe "when reading jobs" do
        it "should read the next job from the transport_manager" do
          transport_manager.should_receive(:next_job)
          job_runner.next_job
        end
      end

      describe "when reading and running jobs" do
        it "should read the next job from the transport_manager" do
          job = mock("job")
          job.should_receive(:run)
          transport_manager.should_receive(:next_job).and_return(job)
          job_runner.next_job
          job_runner.run_job
        end
      end

      describe "when publishing results" do
        it "should publish the job" do
          job = mock("job")
          transport_manager.should_receive(:next_job).and_return(job)
          job_runner.next_job
          transport_manager.should_receive(:publish_result).with(job)
          job_runner.publish_result
        end
      end
    end
  end
end
