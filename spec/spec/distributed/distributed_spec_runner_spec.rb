require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe DistributedSpecRunner do
      before do
        @options = mock("options")
        @example_group = mock("example_group")
        @transport_manager = mock("transport manager")
        
#        c = Class.new(TransportManager) do
#          def self.transport_type
#            "spec_transport"
#          end
#        end
#        c.should_receive(:new).and_return(@transport_manager)

        @runner = DistributedSpecRunner.new(@options, "rinda")
        class << @runner
          attr_writer :transport_manager
        end
        @runner.transport_manager = @transport_manager
      end

      it "should complain if no transport type is given" do
        lambda {DistributedSpecRunner.new(@options)}.should raise_error(NoSuchTransportException)
      end

      it "should complain if no known transport type is given" do
        lambda {DistributedSpecRunner.new(@options, "bogus transport")}.should raise_error(NoSuchTransportException)
      end

      it "should find and create the TransportManager" do
        RindaTransportManager.should_receive(:new)
        @runner = DistributedSpecRunner.new(@options, RindaTransportManager.transport_type)
      end

      it "should tell the transport manager to publish each example" do
        @options.should_receive(:example_groups).and_return([@example_group, @example_group])
        @transport_manager.should_receive(:connect_for_publishing)
        @transport_manager.should_receive(:publish_job).twice.with(@example_group, @options)
        @runner.run
      end
      
    end
  end
end
