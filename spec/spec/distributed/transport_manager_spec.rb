require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe TransportManager do

# this passed under autotest, but fails under 'rake spec'      
      it "should force subclasses to implement #transport_type" do
        Class.new(TransportManager)
        lambda { TransportManager.manager_for("foo") }.should raise_error(NoSuchTransportException, /No known transport_type/)
      end

      it "should map distribution methods to classes" do
        Class.new(TransportManager) do
          def self.transport_type
            "foo"
          end
        end
        TransportManager.manager_for("rinda").should == RindaTransportManager
      end
    end
  end
end
