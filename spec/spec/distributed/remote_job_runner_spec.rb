require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe RemoteJobRunner do
      attr_reader :transport_manager, :runner
      before do
        @options = mock('remote job runner options')
        @options.should_receive(:transport_type).any_number_of_times.and_return("rinda")
        @runner = RemoteJobRunner.new(@options)
      end

      describe "when running" do
        before do
          @transport_manager = mock("transport_manager")
          @transport_manager.should_receive(:connect).with(true)
          @transport_manager_class = mock("transport_manager_class")
          @transport_manager_class.should_receive(:new).and_return(@transport_manager)
          TransportManager.should_receive(:manager_for).with("rinda").and_return(@transport_manager_class)
        end

        it "should get the correct transport_manager and call connect" do
          @runner.prepare
        end

        it "should call the spec command line with the correct runner and transport type" do
          @options.should_receive(:fork).and_return(false)
          job = mock("job")
          job.should_receive(:libraries).times.and_return([])
          job.stub!(:environment).and_return({})
          spec_options = mock('spec_options')
          ::Spec::Runner::OptionParser.should_receive(:parse).with(["--require", "spec/distributed", "--runner", "Spec::Distributed::SlaveExampleGroupRunner:rinda:#{Process::pid}"], STDERR, STDOUT).and_return(spec_options)

          transport_manager.should_receive(:assign_next_job_to).and_return(job)
          transport_manager.should_receive(:take_assigned_job).and_return(nil)
          runner.should_receive(:keep_running?).and_return(false)
          ::Spec::Runner::CommandLine.should_receive(:run).with(spec_options)
          runner.run
        end
      end

      it "should add any required libraries to the command line" do
        job = mock("job with libraries")
        job.should_receive(:libraries).and_return("lib_a", "lib_b")
        class << runner
          attr_accessor :current_job
        end
        runner.current_job = job

        runner.spec_options.should include("lib_a")
        runner.spec_options.should include("lib_b")
      end

      it "should set any env vars, and unset them after the run" do
        @options.should_receive(:fork).and_return(true)
        
        job = mock("job with environment variables")
        job.should_receive(:environment).twice.and_return({"A" => "A", "B" => "B"})

        class << runner
          attr_accessor :current_job
          def run_forked 
            ENV["A"].should == "A"
            ENV["B"].should == "B"
          end
        end
        runner.current_job = job
        runner.run_assigned_job
        ENV["A"].should be_nil
        ENV["B"].should be_nil
      end
      
    end
  end
end
