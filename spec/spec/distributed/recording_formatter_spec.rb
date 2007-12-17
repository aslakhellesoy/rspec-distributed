require File.dirname(__FILE__) + '/../../spec_helper.rb'
module Spec
  module Distributed
    describe RecordingFormatter do
      attr_reader :recorder, :target
      before do
        @recorder = RecordingFormatter.new("Watermark")
        @target = mock("target reporter")
      end

      it "should replay a simple method call with no parameters" do
        target.should_receive(:simple_method_call)
        
        recorder.simple_method_call
        recorder.replay(target)
      end

      it "should replay a method call with parameters" do
        target.should_receive(:simple_method_call).with("parameter")
        recorder.simple_method_call("parameter")
        recorder.replay(target)
      end
    end
  end
end
