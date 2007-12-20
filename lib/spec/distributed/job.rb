module Spec
  module Distributed

    # Stuff we're going to want:
    # - in process or out
    # - path to spec file
    # - Load path
    # - CWD
    # - enviroment variables
    # - DRb location of formatters IO?
    class Job
      attr_reader :spec_file
      
      def initialize(args)
        @args = args
        @spec_file = @args[:spec_file]
      end

      def spec_commandline
        spec_file
      end

      def run
        Kernel.system("spec #{spec_file}")
      end
    end
  end
end
