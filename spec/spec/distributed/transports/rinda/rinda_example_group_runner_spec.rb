require File.dirname(__FILE__) + '/../../../../spec_helper'

module Spec
  module Distributed
    describe RindaExampleGroupRunner do
      include TupleArgs

      before do
        # all this stuff has to happen at creation time, 
        # because there is no hook before load_files
        @options = mock("options")
        @job = mock("job")
        @job.should_receive(:spec_file).and_return("/path/to/spec")
        @job.should_receive(:example_group_description).and_return("example group description")

        @files = []
        @examples = []
        @options.should_receive(:files).and_return(@files)
        @options.should_receive(:examples).and_return(@examples)

        @tuple_args = "mine,mine"
        @transport_manager = mock("transport_manager")
        RindaTransportManager.should_receive(:new).with(@tuple_args).and_return(@transport_manager)
        @transport_manager.should_receive(:connect).with(true)
        @transport_manager.should_receive(:next_job).and_return(@job)
      end

      it "should read a job from the tuplespace, and tell options the file and example name" do
        @runner = RindaExampleGroupRunner.new(@options, @tuple_args)
        
        @files.should == ["/path/to/spec"]
        @examples.should == ["example group description"]
      end

      describe RindaExampleGroupRunner, "when preparing" do

        before do
        end

        it "should, on prepare, create a dispatcher, with a recording formatter, and set it on options" do
          recording_reporter = mock("recording_reporter")
          RecordingReporter.should_receive(:new).and_return(recording_reporter)
          dispatching_reporter = mock("dispatcher")
          Dispatcher.should_receive(:new).with(recording_reporter, anything()).and_return(dispatching_reporter)
          dispatching_reporter.should_receive(:start).with(0)

          @options.should_receive(:reporter).twice.and_return(dispatching_reporter)
          @options.should_receive(:number_of_examples).and_return(0)
          @options.should_receive(:reverse).and_return(false)
          runner = RindaExampleGroupRunner.new(@options, @tuple_args)

          example_group = mock("example_group")
          example_group.should_receive(:description_options).and_return({})
          @options.should_receive(:example_groups).and_return([example_group])
          @job.should_receive(:example_group_object_id)
          
          @options.should_receive(:reporter=).with(dispatching_reporter)
          runner.send(:prepare)
        end

        it "should set the result on the job when publishing results" do
          recording_reporter = mock("recording_reporter")
          runner = RindaExampleGroupRunner.new(@options, @tuple_args)
          # ick
          runner.instance_variable_set(:@result, true)
          runner.instance_variable_set(:@recording_reporter, recording_reporter)

          @job.should_receive(:result=).with(true)
          @job.should_receive(:reporter=).with(recording_reporter)
          
          @transport_manager.should_receive(:publish_result).with(@job)
          runner.publish_result
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
