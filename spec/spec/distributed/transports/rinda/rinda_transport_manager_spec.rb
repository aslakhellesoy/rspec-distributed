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

      describe "when getting jobs" do
        before do
          tuple = default_tuple
          tuple[2] = Job.new
          @service_ts.should_receive(:take).with(default_tuple).and_return(tuple)
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
        end

        it "should send the Job to run" do
          @example_group = mock('example group')
          @example_group.should_receive(:spec_path).and_return("/a/b/d/d_spec.rb:12345")
          @example_group.should_receive(:description).and_return("example group description")
          @options = mock('options')

          tuple = default_tuple
          tuple[2] = Job.new(:spec_file => "/a/b/d/d_spec.rb",
                             :example_group_description => "example group description")
          @service_ts.should_receive(:write) do |t|
            t[2].spec_commandline.should == tuple[2].spec_commandline
          end
          @manager.publish_job(@example_group, @options)
        end

        it "should construct a job with the spec_file and example_group description and return path" do
          @example_group = mock('example group')
          @example_group.should_receive(:spec_path).and_return("/a/b/d/d_spec.rb:12345")
          @example_group.should_receive(:description).and_return("example group description")
          Job.should_receive(:new).with(:spec_file => "/a/b/d/d_spec.rb",
                                        :example_group_description => "example group description",
                                        :return_path => @service_ts)
          @manager.create_job(@example_group, mock("options"))
        end
      end
      
      describe "when publishing results" do
        it "should write the job into the tuple space as a result" do
          job = mock("job with result")
          @service_ts.should_receive(:write).with([:rspec_slave, :job_result, job])
          @manager.publish_result(job)
        end
      end
    end

    describe RindaTransportManager, "when collecting results" do
      before do
        @manager = RindaTransportManager.new
      end
    end
  end
end
