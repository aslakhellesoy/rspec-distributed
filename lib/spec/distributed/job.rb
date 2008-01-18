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

    # OpenStruct is a bug waiting to happen...
    class Job < OpenStruct
      class << self
        def create_job(example_group, options, return_path)
          path = example_group.spec_path
          spec_path = strip_line_number(path)

          # master (publisher) hooks go here
          Job.new(:spec_file => spec_path,
                  :example_group_description => example_group.description,
                  :example_group_object_id => example_group.object_id,
                  :return_path => return_path)
        end

        def strip_line_number(spec_path)
          spec_path.gsub(/:\d+.*\Z/, "")
        end
      end
      
      def initialize(args={})
        super
      end

      def add_library(library_path)
        self.libraries ||= []
        self.libraries << library_path
      end

      
    end
  end
end
