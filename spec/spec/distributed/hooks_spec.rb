require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Hooks do
      before(:each) do
#        options = mock('options', :null_object => true)
#        @r = MasterRunner.new(options, "foo")
      end

      it "should register and run hooks" do
        Hooks.add_hook do |slave_opts|
          slave_opts[:foo] = :bar
        end
        Hooks.add_hook do |slave_opts|
          slave_opts[:snip] = :snap
        end
        hash = Hooks.run_hooks({})
        hash.should == {:foo => :bar, :snip => :snap}
      end
    end
  end
end
