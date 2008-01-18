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

      it "should call the spec command line with the correct runner and transport type" do
        @transport_manager = mock("transport_manager")
        @transport_manager.should_receive(:connect).with(true)
        @transport_manager_class = mock("transport_manager_class")
        @transport_manager_class.should_receive(:new).and_return(@transport_manager)
        TransportManager.should_receive(:manager_for).and_return(@transport_manager_class)
        
        job = mock("job")
        job.should_receive(:libraries).exactly(3).times.and_return([])
        spec_options = mock('spec_options')
        ::Spec::Runner::OptionParser.should_receive(:parse).exactly(3).times.with(["--require", "spec/distributed", "--runner", "Spec::Distributed::SlaveExampleGroupRunner:rinda:hello"], STDERR, STDOUT).and_return(spec_options)

        transport_manager.should_receive(:next_job).exactly(3).times.and_return(job)
        transport_manager.should_receive(:write_job).exactly(3).times
        runner.should_receive(:keep_running?).exactly(3).times.and_return(true, true, false)
        ::Spec::Runner::CommandLine.should_receive(:run).exactly(3).times.with(spec_options)
        runner.run
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
      
    end
  end
end
