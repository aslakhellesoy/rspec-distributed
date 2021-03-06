require File.dirname(__FILE__) + '/../../../../spec_helper'
require 'stringio'

module Spec
  module Distributed
    describe RindaTransportManager do
      include TupleArgs
      
      before do
        process_tuple_args(nil)
        @manager = RindaTransportManager.new
        class << @manager
          attr_accessor :service_ts
        end
        @service_ts = mock("service_ts")
        @manager.service_ts = @service_ts
      end

      it "should initialize the default tuple" do
        RindaTransportManager.new.default_tuple.should == default_tuple
      end

      it "should initialize the default_tuple base on arguments" do
        process_tuple_args("mine,yours")
        RindaTransportManager.new("mine,yours").default_tuple.should == default_tuple
      end

      describe "when getting jobs" do
        before do
          tuple = default_tuple
          tuple[2] = Job.new
          @service_ts.should_receive(:take).with(default_tuple, nil).and_return(tuple)
        end
        
        it "should take the next job from the tuplespace" do
          @manager.next_job
        end
        
        it "should return an instant of a job" do
          job = @manager.next_job
          job.should be_kind_of(Job)
        end
      end

      describe "when publishing jobs" do
        before do
          @example_group = mock('example group')
          @options = mock('options')
          @job = mock("job")
          @tuple = default_tuple
          @tuple[2] = @job
        end

        it "should set the return path on the job, and write the job" do
          DRb.should_receive(:uri).and_return("druby://")
          @service_ts.should_receive(:write) do |t|
            t[2].should == @tuple[2]
          end
          @job.should_receive(:return_path=)
          @manager.publish_job(@job)
        end
        
        it "should set the return path on the job, to the given value" do
          @service_ts.should_receive(:write) do |t|
            t[2].should == @tuple[2]
          end
          @job.should_receive(:return_path=).with("return_path")
          @manager.publish_job(@job, "return_path")
        end

      end
      
      describe "when publishing results" do
        it "should write the job into the tuple space as a result" do
          job = mock("job with result")
          job.should_receive(:return_path).and_return("druby://localhost:12345/")
          @service_ts.should_receive(:write).with([:rspec_slave, :job_result, job, "druby://localhost:12345/"])
          
          @manager.publish_result(job)
        end
      end

      describe "when collecting results" do
        before do
          example_group = mock("example_group")
          @service_ts.stub!(:write)
          job = OpenStruct.new
          DRb.should_receive(:uri).any_number_of_times.and_return("druby://localhost:12345/")
          3.times do
            @manager.publish_job(job)
          end
        end

        it "should collect the number of results published" do
          job = mock("job")
          @service_ts.should_receive(:take).with([:rspec_slave, :job_result, nil, "druby://localhost:12345/"], nil).exactly(3).times.and_return([:rspec_slave, :job_result, job, "druby://localhost:12345/"])

          count = 0
          @manager.collect_results do |job|
            count += 1
          end
          count.should == 3
        end
      end

    end
  end
end
