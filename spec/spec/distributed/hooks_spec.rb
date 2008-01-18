require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe Hooks do

      after do
        Hooks.reset
      end
        
      it "should register and run hooks" do
        Hooks.add_master_hook do |slave_opts|
          slave_opts[:foo] = :bar
        end
        Hooks.add_slave_hook do |slave_opts|
          slave_opts[:snip] = :snap
        end
        hash = Hooks.run_master_hooks({})
        hash.should == {:foo => :bar}
        
        hash = Hooks.run_slave_hooks({})
        hash.should == {:snip => :snap}
      end
    end
  end
end
