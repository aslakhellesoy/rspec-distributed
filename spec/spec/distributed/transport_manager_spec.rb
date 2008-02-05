require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe TransportManager do

      it "should force subclasses to implement #transport_type" do
        Class.new(TransportManager)
        lambda { TransportManager.manager_for("unknown") }.should raise_error(NoSuchTransportException, /No known transport_type/)
      end

      it "should map distribution methods to classes" do
        c = Class.new(TransportManager) do
          known_as "foo"
        end
        TransportManager.manager_for("foo").should == c
        TransportManager.manager_for("rinda").should == RindaTransportManager
      end
    end
  end
end
