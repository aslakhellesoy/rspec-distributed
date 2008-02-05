require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe SlaveExampleGroupRunner do

      attr_reader :options
      before do
        @options = mock("options")
        @example_group = mock("example_group")
      end

      it "should complain if no report file is given" do
        lambda {SlaveExampleGroupRunner.new(@options)}.should raise_error(ArgumentError, /requires a temp filename/)
      end


      describe "when preparing" do
        attr_reader :runner
        before do
          @runner = SlaveExampleGroupRunner.new(@options, "/tmpfile")
        end

        after do
          ENV.delete 'REMOTE_EXAMPLE_GROUP_OBJECT_ID'
        end

        it "should replace the reporter with a dispatcher, wrapping the real reporter and the recording_reporter" do
          recording_reporter = mock("recording_reporter")
          RecordingReporter.should_receive(:new).and_return(recording_reporter)
          dispatching_reporter = mock("dispatcher")
          Dispatcher.should_receive(:new).with(recording_reporter, anything()).and_return(dispatching_reporter)

          @options.should_receive(:reporter=).with(dispatching_reporter)
          @options.should_receive(:reporter)
          runner.send :insert_recording_reporter
        end

        it "should add the example_group_object_id to the example_groups with description options" do
          example_group = mock 'example_group'
          description_options = {}
          example_group.should_receive(:description_options).twice.and_return(description_options)
          ENV['REMOTE_EXAMPLE_GROUP_OBJECT_ID'] = '12345'
          @options.should_receive(:example_groups).and_return([example_group])
          runner.send :link_example_groups
          description_options[:example_group_object_id].should == 12345
        end

        it "should add the remote_example_group_object_id to the example_groups with description options" do
          example_group = mock 'example_group'
          example_group.should_receive(:description_options).and_return(nil)
          @options.should_receive(:example_groups).and_return([example_group])
          runner.send :link_example_groups
        end

      end

      describe "when finishing" do
        attr_reader :runner, :tempfile
        before do
          @tempfile = Tempfile.new('slave_spec')
          @runner = SlaveExampleGroupRunner.new(@options, tempfile.path)
        end

        it "should marshal the recording_reporter to the given tempfile" do
          class << runner
            attr_accessor :recording_reporter
          end
          runner.recording_reporter = ["recording_reporter"]
          runner.send :publish_result
          tempfile.open
          Marshal.load(tempfile).should == ["recording_reporter"]
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
