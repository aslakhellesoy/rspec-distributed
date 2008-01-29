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

          relative_path = rel_path(Dir.pwd, spec_path)

          Job.new(:spec_path => relative_path,
                  :example_group_description => example_group.description,
                  :example_group_object_id => example_group.object_id,
                  :return_path => return_path)
        end
        
        def strip_line_number(spec_path)
          spec_path.gsub(/:\d+.*\Z/, "")
        end

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
        
        # path transformation
        # The master may want to set a path transformation in a few scenarios:
        # A. The master wants the slave to load the spec from the master's
        #    directory, most likely over network. The master will
        #    specify a transformation resulting in:
        #      /absolute/path/to/where/the/specs/are ->
        #      /network/path/to/where/the/specs/are
        #    This is a substitution of s/absolute/network/ where the
        #    rest of the path remains the same. e.g. If a user's home
        #    directory were exported over NFS, then the master would transform
        #    the spec_path from /Users/john/project/spec ->
        #    /net/johns_machine/Users/john/project/spec 
        #
        # B. The master wants the slave to load libraries relative to
        #    some known CWD, therefore wants the slave to run in a
        #    specific CWD.
        # B1. The master wants the slave to run in a known CWD.
        # B1.1 This may be the CWD the remote_runner was started in (because
        #     those starting the master/slave know this)
        # B1.2 or some other CWD that the master suggests (e.g. run in
        #    branch dir vs. the trunk)
        #     
        # B2. The master wants the slave to run in a CWD that is on
        #     the masters machine, thus the path would be would be
        #     similar to A.
        #
        # How to deal with win/unix path transformations?
      end
      
      def initialize(args={})
        super
        self.libraries ||= []
        self.environment ||= {}
      end

      def add_library(library_path)
        self.libraries << library_path
      end

      def add_environment(key, value)
        environment[key] = value
      end
    end
  end
end
