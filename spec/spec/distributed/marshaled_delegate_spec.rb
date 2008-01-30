require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Distributed
    describe MarshaledDelegate do
      attr_reader :target, :delegate
      before do
        class Foo
          def foo; "foo"; end
          def bar; "bar"; end
          def marshal_dump; $dump_called = true; end
          def marshal_load(o); $load_called = true; end
        end
        @target = Foo.new
        @delegate = MarshaledDelegate.new(target)
      end
      
      it "should delegate methods to the target" do
        delegate.foo.should == "foo"
        delegate.bar.should == "bar"
      end

      it "should provide ==" do
        delegate.should == @target
      end

      it "should implement custom marshal_dump and marshal_load" do
        delegate.should respond_to(:marshal_dump)
        delegate.should respond_to(:marshal_load)
      end
      
      it "should marshall the delegate on dump" do
        $dump_called = false
        Marshal.dump(delegate)
        $dump_called.should == true
      end

      it "should not un-marshal the target on unload" do
        $dump_called = false
        $load_called = false
        dump = Marshal.dump(delegate)
        Marshal.load(dump)
        $dump_called.should == true
        $load_called.should == false
      end

      it "should call load when accessing the target" do
        $load_called = false
        dump = Marshal.dump(delegate)
        d = Marshal.load(dump)
        d.foo.should == "foo"
        $load_called.should == true
      end
      
    end
  end
end
