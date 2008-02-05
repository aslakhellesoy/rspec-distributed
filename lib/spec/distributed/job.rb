require 'tempfile'
require 'systemu'

module Spec
  module Distributed
    # OpenStruct is a bug waiting to happen...
    # btw, don't add instance variables, OpenStruct has it's own
    # marshal_dump etc
    class Job < OpenStruct
      class << self
        def create_job(example_group, options, return_path)
          path = example_group.spec_path
          spec_path = strip_line_number(path)

          relative_path = rel_path(Dir.pwd, spec_path)

          Job.new(:spec_path => relative_path,
                  :example_group_description => example_group.description,
                  :example_group_object_id => example_group.object_id,
                  :return_path => return_path)
        end
        
        def strip_line_number(spec_path)
          spec_path.gsub(/:\d+.*\Z/, "")
        end

        # push this into File
        # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/20586
        def rel_path(a, b)
          # Should work in in win and *nix
          sep = File::Separator

          # Get rid of /path//to/./here problems
          a = (File::expand_path a).split(sep)
          b = (File::expand_path b).split(sep)

          # Windows?
          raise "can't switch drives" if a[0] =~ /^\w\:$/ and a[0] != b[0]

          # If one of the paths starts with /, the split array
          # will have an empty first element (if a path is solely
          # /, it will be empty)
          a.shift unless a.empty? or not a[0].empty?
          b.shift unless b.empty? or not b[0].empty?

          # If a & b are empty, a[0] == b[0] == nil
          while a[0] == b[0] and not a.empty? and not b.empty?
            a.shift
            b.shift
          end

          parent = ".." + sep
          (parent * a.size) + b.join(sep)
        end
      end

      def initialize(args={})
        super
        self.libraries ||= []
        self.hook_libraries ||= []
        self.environment ||= {}

        add_library("spec/distributed")
      end

      def add_library(library_path)
        self.libraries << library_path
      end

      def add_hook_library(library_path)
        self.hook_libraries << library_path
      end

      def add_environment(key, value)
        environment[key] = value
      end

      def command_line
        command_string = "spec"
        libraries.each do |lib|
          command_string << " --require '#{lib}'"
        end
        command_string << " --runner Spec::Distributed::SlaveExampleGroupRunner:#{temp_filename}"
        # TODO: escape the EG descriptions for quote chars
        command_string << " -e \"#{example_group_description}\""
        command_string << " #{spec_path}"
        command_string
      end

      def run
        begin
          run_hooks
          setup_environment
          setup_temp_filename
          fork_command
          collect_reporter
        rescue Exception => e
          self.fatal_failure = true
          self.exception = e
        end
      ensure
        temp_file.delete if temp_file
        self.temp_file = nil
      end

      def run_hooks
        hook_libraries.each { |lib| require lib } 
        Hooks.run_slave_hooks(self)
      end

      def setup_environment
        if example_group_object_id
          add_environment('REMOTE_EXAMPLE_GROUP_OBJECT_ID', example_group_object_id)
        end
      end

      def setup_temp_filename
        self.temp_file = Tempfile.new('job')
        self.temp_filename = temp_file.path
      end

      def fork_command
        self.status, self.stdout, self.stderr = systemu command_line, 'env' => environment
      end

      def collect_reporter
        if File.stat(temp_file.path).size > 0
          temp_file.open
          self.reporter = Marshal.load(temp_file)
        else
          self.fatal_failure = true
        end
      end
      
    end
  end
end
