require File.dirname(__FILE__) + '/../../../../spec_helper'

module Spec
  module Distributed

    module RindaConnection
      attr_accessor :service_ts
    end
    
    describe RindaExampleGroupRunner do
      include TupleArgs

      before do
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

      it "should set the result in the job when run" do
        @job.should_receive(:result=).with(true)
        @transport_manager.should_receive(:publish_result).with(@job)
        runner = RindaExampleGroupRunner.new(@options, @tuple_args)
        runner.publish_result(true)
      end

      
    end
  end
end
