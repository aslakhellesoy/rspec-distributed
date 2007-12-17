require File.dirname(__FILE__) + '/../../spec_helper.rb'
module Spec
  module Distributed
    describe ValueHolder do
      it "should be constructed with a value" do
        ValueHolder.new("a")
      end

      it "should return the held value" do
        ValueHolder.new("a").value.should == "a"
      end
    end
  end
end
