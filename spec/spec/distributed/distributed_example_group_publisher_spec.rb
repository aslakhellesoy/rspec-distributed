require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe DistributedExampleGroupPublisher do
      before do
        @options = mock("options")
        @example_group = mock("example_group")
        @transport_manager = mock("transport manager")
        
        @runner = DistributedExampleGroupPublisher.new(@options, "rinda")
        class << @runner
          attr_writer :transport_manager
        end
        @runner.transport_manager = @transport_manager
      end

      it "should complain if no transport type is given" do
        lambda {DistributedExampleGroupPublisher.new(@options)}.should raise_error(NoSuchTransportException)
      end

      it "should complain if no known transport type is given" do
        lambda {DistributedExampleGroupPublisher.new(@options, "bogus transport")}.should raise_error(NoSuchTransportException)
      end

      it "should find and create the TransportManager" do
        RindaTransportManager.should_receive(:new)
        @runner = DistributedExampleGroupPublisher.new(@options, RindaTransportManager.transport_type)
      end

      it "should tell the transport manager to publish each example, and wait for results" do
        # ick, all from overriding #prepare and calling super
        reporter = mock("reporter")
        reporter.should_receive(:start)
        @options.should_receive(:reporter).any_number_of_times.and_return(reporter)
        @options.should_receive(:number_of_examples).and_return(2)
        @options.should_receive(:reverse).and_return(false)
        reporter.should_receive(:end)
        reporter.should_receive(:dump)
        # /ick
        @options.should_receive(:example_groups).and_return([@example_group, @example_group])
        @transport_manager.should_receive(:connect).with(false)
        @transport_manager.should_receive(:publish_job).twice.with(@example_group, @options)
        @transport_manager.should_receive(:collect_results).and_return(true)
        @runner.run.should == true
      end
      
    end
  end
end
