require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe JobRunnerOptionParser do
      REQUIRED_OPTIONS = ['--transport-type', 'rinda']
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
        options.should be_valid
      end

      it "should have forked mode as the default" do
        option = parse(REQUIRED_OPTIONS)
        option.fork.should == true
      end

      it "should parse forked mode" do
        options = parse(['--fork'])
        options.fork.should == true
        options = parse(['--no-fork'])
        options.fork.should == false
      end

      it "should print help to stdout" do
        options = parse(['--help'])
        @out.rewind
        @out.read.should match(/Usage: remote_job_runner \[options\]/m)
      end

      it "should print help when invalid options are given" do
        options = parse([])
        @out.rewind
        @out.read.should match(/Usage: remote_job_runner \[options\]/m)
      end
    end
    
  end
end
