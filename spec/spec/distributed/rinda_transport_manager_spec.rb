require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'

module Spec
  module Distributed

    shared_examples_for "capturing stdout" do
      before do
        stringio = StringIO.new
        $stdout = stringio
      end

      after do
        $stdout = STDOUT
      end
      
    end
    
    describe RindaTransportManager, "when connecting" do
      it_should_behave_like "capturing stdout"
      
      before do
        @manager = RindaTransportManager.new
      end
      
      it "should look for an existing ring server" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        @service_ts.should_receive(:__drburi)
        Rinda::RingFinger.should_receive(:primary).and_return(@service_ts)
        @manager.connect
      end

      it "should create a ring server if none exists" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        @ring_server = mock("ring server")
        Rinda::RingFinger.should_receive(:primary).and_raise(RuntimeError.new)
        
        Rinda::TupleSpace.should_receive(:new).and_return(@service_ts)
        Rinda::RingServer.should_receive(:new).with(@service_ts)
        
        @manager.connect
      end

    end

    describe RindaTransportManager, "when getting jobs" do
      include TupleArgs
      
      before do
        process_tuple_args(nil)
        
        @manager = RindaTransportManager.new
        class << @manager
          attr_accessor :service_ts
        end
        
        @service_ts = mock("service_ts")
        @manager.service_ts = @service_ts

        tuple = tuples
        tuple[2] = {}
        @service_ts.should_receive(:take).with(tuples).and_return(tuple)
      end
      
      it "should take the next job from the tuplespace" do
        @manager.next_job
      end
      
      it "should return an instant of a job" do
        job = @manager.next_job
        job.should be_kind_of(Job)
      end
    end

    describe RindaTransportManager, "when publishing jobs" do
      include TupleArgs
      it_should_behave_like "capturing stdout"
      
      before do
        @manager = RindaTransportManager.new
        class << @manager
          attr_accessor :service_ts
        end
        
        @service_ts = mock("service_ts")
        @manager.service_ts = @service_ts

        
        @example_group = mock('example group')
        @options = mock('options')
      end

      it "should look for an existing ring server" do
        DRb.should_receive(:start_service)
        DRb.should_receive(:uri)
        @service_ts = mock("service_ts")
        @service_ts.should_receive(:__drburi)
        Rinda::RingFinger.should_receive(:primary).and_return(@service_ts)
        @manager.connect_for_publishing
      end

      it "should send the spec_path of the spec" do
        @example_group = mock('example group')
        @example_group.should_receive(:spec_path).and_return("/a/b/d/d_spec.rb")
        @options = mock('options')

        tuple = tuples
        tuple[2] = {:spec_file => "/a/b/d/d_spec.rb"}
        @service_ts.should_receive(:write).with(tuple)
        @manager.publish_job(@example_group, @options)
      end
    end
    
  end
end
