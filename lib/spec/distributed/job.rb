module Spec
  module Distributed

    # Stuff we're going to want:
    # - in process or out
    # - path to spec file
    # - Load path
    # - CWD
    # - enviroment variables
    # - return path
    # - DRb location of formatters IO?
    class Job
      attr_reader :spec_file
      attr_reader :return_path
      attr_reader :example_group_description,
      :example_group_object_id
      attr_accessor :result, :reporter
      
      def initialize(args={})
        @args = args
        @spec_file = @args[:spec_file]
        @example_group_description = @args[:example_group_description]
        @return_path = @args[:return_path]
        @example_group_object_id = @args[:example_group_object_id]
        @reporter = @args[:reporter]
      end

      def spec_commandline
        command_line = "spec"
        command_line << " -e '#{@example_group_description}'" if @example_group_description
        command_line << " #{spec_file}"
        command_line
      end

    end
  end
end
