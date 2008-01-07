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
        @service_ts = mock("tuple space")
      end

      it "should read a job from the tuplespace, and tell options the file and example name" do
        job = mock("job")
        job.should_receive(:spec_file).and_return("/path/to/spec")
        job.should_receive(:example_group_description).and_return("example group description")

        @service_ts.should_receive(:take).with(default_tuple).and_return([nil,nil,job])

        files = []
        examples = []
        @options.should_receive(:files).and_return(files)
        @options.should_receive(:examples).and_return(examples)

        @runner = RindaExampleGroupRunner.new(@options) do |runner|
          runner.service_ts = @service_ts
        end

        files.should == ["/path/to/spec"]
        examples.should == ["example group description"]
      end

      it "should set the result in the job when run" do
      end

      
    end
  end
end
