require File.dirname(__FILE__) + '/../../../../spec_helper'

module Spec
  module Distributed
    describe RindaConnection do
      it_should_behave_like "capturing stdout"
      
      it "should look for an existing ring server" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        Rinda::RingFinger.should_receive(:primary).twice.and_return(@service_ts)
        connect
      end

      it "should force a lookup if the primary is nil (locally created tuplespace)" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        Rinda::RingFinger.should_receive(:primary).twice.and_return(nil)
        finger = mock("finger")
        finger.should_receive(:lookup_ring_any).and_return(@service_ts)
        Rinda::RingFinger.should_receive(:finger).and_return(finger)
        connect
      end

      it "should create a ring server if none exists" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        @ring_server = mock("ring server")
        Rinda::RingFinger.should_receive(:primary).and_raise(RuntimeError.new)
        
        Rinda::TupleSpace.should_receive(:new).and_return(@service_ts)
        Rinda::RingServer.should_receive(:new).with(@service_ts)
        connect(true)
      end

    end

  end
end

