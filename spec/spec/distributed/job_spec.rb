require File.dirname(__FILE__) + '/../../spec_helper'
module Spec
  module Distributed
    describe Job do

      describe "factory method" do
        it "should construct a job with a relative spec_path, example_group description, example_group object id and return path" do
          @example_group = mock('example group')
          @example_group.should_receive(:spec_path).and_return("/a/b/c/d/d_spec.rb:12345")
          @example_group.should_receive(:description).and_return("example group description")
          @example_group.should_receive(:object_id).and_return(54321)

          Dir.should_receive(:pwd).and_return("/a/b/c")
          
          job = Job.create_job(@example_group, mock("options"), "return_path")
          
          job.spec_path.should == "d/d_spec.rb"
          job.example_group_description.should == "example group description"
          job.example_group_object_id.should == 54321
          job.return_path.should == "return_path"
        end
      end
      
      it "should store the remote example_group object id" do
        Job.new(:example_group_object_id => 1).example_group_object_id.should == 1
      end


      it "should store additional libraries" do
        job = Job.new
        job.add_library "a"
        job.add_library "b"
        job.libraries.should include("a")
        job.libraries.should include("b")
      end

      it "should store additional hook libraries" do
        job = Job.new
        job.add_hook_library "a"
        job.add_hook_library "b"
        job.hook_libraries.should include("a")
        job.hook_libraries.should include("b")
      end

      it "should store environment pairs" do
        job = Job.new
        job.add_environment("A", "A")
        job.add_environment("B", "B")
        job.environment.should == {"A" => "A", "B" => "B"}
      end

      describe "when creating the spec command line" do
        attr_reader :job
        before do
          @job = Job.new
        end
        it "should start with spec" do
          job.command_line.should match(/\Aspec.*/)
        end

        it "should conatin spec_distributed" do
          job.command_line.should match(/--require 'spec\/distributed'/)
        end

        it "should contain any libraries" do
          job.add_library("my_custom1")
          job.add_library("my_custom2")
          job.command_line.should match(/--require 'my_custom1'/)
          job.command_line.should match(/--require 'my_custom2'/)
        end

        it "should contain the slave runner" do
          job.command_line.should match(/--runner Spec::Distributed::SlaveExampleGroupRunner/)
        end

        it "should pass a tmpfilename to the slave runner" do
          job.temp_filename = "filename"
          job.command_line.should match(/--runner Spec::Distributed::SlaveExampleGroupRunner:filename/)
        end

        it "should contain the spec file" do
          job.spec_path = 'spec_spec.rb'
          job.command_line.should match(/spec_spec.rb\Z/)
        end

        it "should contain the example group name" do
          job.example_group_description = "example_group_description"
          job.command_line.should match(/-e "example_group_description"/)
        end
      end

      describe "when running the job" do
        attr_reader :job
        before do
          @job = Job.new
          class << job
            undef_method :command_line
          end
        end
        
        after do
          Hooks.reset
        end

        it "should run hooks" do
          job.should_receive(:[]=).with(:foo, :bar)
          Hooks.add_slave_hook do |job|
            job[:foo] = :bar
          end
          
          job.command_line = "echo $FOO"
          job.run
        end

        it "should load the spec libraries" do
          job.add_hook_library('uri')
          job.command_line = "echo $FOO"
          job.run
          lambda { Module.const_get('URI') }.should_not raise_error(NameError)
        end

        it "should catch and return all exceptions" do
          job.add_hook_library('no_such')
          job.command_line = "echo $FOO"
          job.run
          job.fatal_failure.should == true
          job.exception.should be_instance_of(LoadError)
        end

        it "should create a tmpfile for the reporter" do
          file = mock("temp file")
          file.should_receive(:path).and_return('/tmp/foo.1.1')
          Tempfile.should_receive(:new).and_return(file)
          job.setup_temp_filename
          job.temp_filename.should == '/tmp/foo.1.1'
        end

        it "should capture stdout" do
          job.command_line = "echo 'hello'"
          job.fork_command
          job.status.success?.should be_true
          job.stdout.should == "hello\n"
        end

        it "should capture stderr" do
          job.command_line = "cat notfound"
          job.fork_command
          job.status.success?.should be_false
          job.stderr.should match(/No such file or directory/)
        end

        it "should read the contents of report file" do
          job.setup_temp_filename
          job.command_line =  %Q!ruby -e 'File.open("#{job.temp_filename}", "w") { |f| f.write Marshal.dump("hello") }'!
          job.fork_command
          job.collect_reporter
          job.reporter.should == "hello"
        end

        it "should mark the job as having a fatal error if no reporter was written" do
          job.command_line = "echo 'hello'"
          job.run
          job.fatal_failure.should == true
        end

        it "should set environment vars" do
          job.add_environment("FOO", "BAR")
          job.command_line = "echo $FOO"
          job.run
          job.stdout.should == "BAR\n"
        end

        it "should set and environment var for the example group object id" do
          job.example_group_object_id = 12345
          job.command_line = "echo $REMOTE_EXAMPLE_GROUP_OBJECT_ID"
          job.run
          job.stdout.should == "12345\n"
        end
        
      end

    end
  end
end
