require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe JobRunnerOptionParser do
      before(:each) do
        @out = StringIO.new
        @err = StringIO.new
        @parser = JobRunnerOptionParser.new(@err, @out)
      end

      def parse(args)
        @parser.parse(args)
        @parser.options
      end

      it "should parse transport manager" do
        options = parse(['--transport-type', 'rinda'])
        options.transport_type.should == "rinda"
      end

      it "should have forked mode as the default" do
        option = parse([])
        option.fork.should == true
      end

      it "should parse forked mode" do
        options = parse(['--fork'])
        options.fork.should == true
        options = parse(['--no-fork'])
        options.fork.should == false
      end
      
    end
  end
end
