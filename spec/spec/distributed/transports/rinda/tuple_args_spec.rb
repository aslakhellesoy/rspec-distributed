require File.dirname(__FILE__) + '/../../../../spec_helper.rb'

module Spec
  module Distributed
    describe TupleArgs do

      def runner(args)
        Class.new do
          include TupleArgs
          def initialize(options=nil, args=nil)
            process_tuple_args(args)
          end
        end.new("", args)
      end

      it "should create the default tuplespace when no args are given" do
        runner(nil).default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil]
      end

      it "should add one element to the tuple when one argument is given" do
        runner("One").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, "One"]
      end

      it "should add two elements to the tuple when two arguments are given" do
        runner("One,Two").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, "One", "Two"]
      end

      it "should turn wildcards to 'nil' in the tuplespace" do
        runner("*").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, nil]
        runner("One,*").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, "One", nil]
        runner("*,Two").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, nil, "Two"]
        runner("*,*").default_tuple.should ==  [:rspec_slave, :RindaSlaveRunner, nil, nil, nil]
      end
    end
  end
end
