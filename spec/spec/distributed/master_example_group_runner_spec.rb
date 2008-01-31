require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe MasterExampleGroupRunner do
      class MasterExampleGroupRunner
        attr_writer :transport_manager
      end
      
      before do
        @options = mock("options")
        @example_group = mock("example_group")
        @transport_manager = mock("transport manager")
      end

      it "should complain if no transport type is given" do
        lambda {MasterExampleGroupRunner.new(@options)}.should raise_error(NoSuchTransportException)
      end

      it "should complain if no known transport type is given" do
        lambda {MasterExampleGroupRunner.new(@options, "bogus transport")}.should raise_error(NoSuchTransportException)
      end

      it "should find and create the TransportManager" do
        @runner_and_tuple_args = "rinda:mine,mine"
        RindaTransportManager.should_receive(:new).with("mine,mine").and_return(@transport_manager)
        @runner = MasterExampleGroupRunner.new(@options, @runner_and_tuple_args)
      end

      describe "runner lifecycle:" do
        before do
          @runner = MasterExampleGroupRunner.new(@options, "rinda")
          @runner.transport_manager = @transport_manager
        end

        describe "when preparing" do
          it "should connect to the transport manager" do
            @transport_manager.should_receive(:connect)
            @runner.send(:connect)
          end
        end

        describe "when returning example_groups" do
          it "should filter out example groups with no spec_path" do
            eg1 = mock("eg with spec_path")
            eg1.should_receive(:spec_path).and_return("/a/happy/path")
            eg2 = mock("eg without spec_path")
            eg2.should_receive(:spec_path).and_return(nil)

            @options.should_receive(:example_groups).and_return([eg1, eg2])
            @runner.send(:example_groups).should == [eg1]
          end
        end

        describe "when publishing example_groups" do
          it "should send each example_group to the transport_manager" do
            @runner.should_receive(:example_groups).and_return([@example_group, @example_group])
            @transport_manager.should_receive(:return_path).twice.and_return("return_path")
            job = {}
            Hooks.add_master_hook do |job|
              job[:foo] = :bar
            end
            Job.should_receive(:create_job).twice.with(@example_group, @options, "return_path").and_return(job)
            @transport_manager.should_receive(:publish_job).twice
            @runner.send(:publish_example_groups)
            job[:foo].should == :bar
          end
        end

        describe "when collecting results" do
          it "should replay the reporter" do
            job1 = mock("job1")
            job2 = mock("job2")
            reporter = mock("reporter")
            @options.should_receive(:reporter).any_number_of_times.and_return(reporter)


            recording_reporter = mock("recording_reporter")
            recording_reporter.should_receive(:replay).twice
            [job1, job2].each do |job|
              job.should_receive(:result).and_return(true)
              job.should_receive(:slave_exception).and_return(nil)
              job.should_receive(:reporter).and_return(recording_reporter)
            end
            @transport_manager.should_receive(:collect_results).and_yield(job1).and_yield(job2)
            @runner.send(:collect_results)
          end

          it "should collect jobs with exceptions raised by the slave" do
            job = mock("job with exception")
            job.should_receive(:result).and_return(:false)
            job.should_receive(:slave_exception).and_return(NoMethodError.new("No Method"))
            
            @transport_manager.should_receive(:collect_results).and_yield(job)
            @runner.send(:collect_results)
            @runner.send(:jobs_with_exceptions).length.should == 1
          end
        end
      end
    end
  end
end
