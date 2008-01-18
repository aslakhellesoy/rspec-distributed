require 'spec'
require 'spec/mocks'

module Spec
  module Example
    module ExampleGroupMethods
      def describe_with_nested_example_group_spec_path(*args, &example_group_block)
        args << {} unless Hash === args.last
        if example_group_block
          args.last[:spec_path] = eval("caller(0)[1]", example_group_block) unless args.last[:spec_path]
        else
          args.last[:spec_path] = caller(0)[1] unless args.last[:spec_path]
        end
        describe_without_nested_example_group_spec_path(*args, &example_group_block)
      end

      alias describe_without_nested_example_group_spec_path describe
      alias describe describe_with_nested_example_group_spec_path
    end
  end
end


require 'spec/distributed/version'
require 'spec/distributed/hooks'
require 'spec/distributed/value_holder'
require 'spec/distributed/example_group_value_holder'
require 'spec/distributed/example_value_holder'
require 'spec/distributed/recording_reporter'
require 'spec/distributed/remote_job_runner_option_parser'
require 'spec/distributed/remote_job_runner'
require 'spec/distributed/job'
require 'spec/distributed/transport_manager'
require 'spec/distributed/transports'
require 'spec/distributed/master_example_group_runner'
require 'spec/distributed/slave_example_group_runner'
