require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe SlaveExampleGroupRunner do

      before do
        @options = mock("options")
        @example_group = mock("example_group")
        @transport_manager = mock("transport manager")
      end

      it "should complain if no transport type is given" do
        lambda {SlaveExampleGroupRunner.new(@options)}.should raise_error(NoSuchTransportException)
      end

      it "should complain if no known transport type is given" do
        lambda {SlaveExampleGroupRunner.new(@options, "bogus transport")}.should raise_error(NoSuchTransportException)
      end

      describe "when fetching jobs" do
        before do
          @job = mock("job")          
          @runner_and_tuple_args = "rinda:mine,mine"
          RindaTransportManager.should_receive(:new).with("mine,mine").and_return(@transport_manager)

          @transport_manager.should_receive(:connect)
          @transport_manager.should_receive(:next_job).and_return(@job)

          @runner = SlaveExampleGroupRunner.new(@options, @runner_and_tuple_args)
        end

        describe "setting options" do
          it "should run hooks and add files to options" do

            @job.should_receive(:spec_path).and_return("/path/to/spec")
            @job.should_receive(:example_group_description).and_return("example group description")
            
            @job.should_receive(:[]=).any_number_of_times.with(:foo, :bar)
            Hooks.add_slave_hook do |job|
              job[:foo] = :bar
            end
            
            @files = []
            @examples = []
            @options.should_receive(:files).and_return(@files)
            @options.should_receive(:examples).and_return(@examples)

            @runner.set_options
            @files.should == ["/path/to/spec"]
            @examples.should == ["example group description"]
          end
          
          after do
            Hooks.reset
          end
        end

        describe "when preparing" do
          it "should, on prepare, create a dispatcher, with a recording formatter, and set it on options" do
            recording_reporter = mock("recording_reporter")
            RecordingReporter.should_receive(:new).and_return(recording_reporter)
            dispatching_reporter = mock("dispatcher")
            Dispatcher.should_receive(:new).with(recording_reporter, anything()).and_return(dispatching_reporter)

            @options.should_receive(:reporter).and_return(dispatching_reporter)

            example_group = mock("example_group")
            # spec this correctly (remove the twice)
            example_group.should_receive(:description_options).twice.and_return({}) 
            # 
            @options.should_receive(:example_groups).and_return([example_group])
            @job.should_receive(:example_group_object_id)
            
            @options.should_receive(:reporter=).with(dispatching_reporter)
            @runner.send :prepare
          end

          it "should set the result on the job when publishing results" do
            recording_reporter = mock("recording_reporter")
            # ick
            @runner.instance_variable_set(:@result, true)
            @runner.instance_variable_set(:@recording_reporter, recording_reporter)

            @job.should_receive(:result=).with(true)
            @job.should_receive(:reporter=).with(recording_reporter)
            
            @transport_manager.should_receive(:publish_result).with(@job)
            @runner.send :publish_result
          end
        end

      end
    end
    
    describe Dispatcher do
      it "should dispatch each method send to all children" do
        child1 = mock("child1")
        child2 = mock("child2")
        [child1, child2].each do |child|
          child.should_receive(:foo)
          child.should_receive(:bar).with(true)
        end
        dispatcher = Dispatcher.new(child1, child2)
        dispatcher.foo
        dispatcher.bar(true)
      end
    end
 
  end
end
