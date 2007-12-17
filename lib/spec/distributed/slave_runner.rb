module Spec
  module Distributed
    class SlaveRunner < ::Spec::Runner::ExampleGroupRunner      
      def initialize(options, args=nil)
        super(options)
        process_args(args)
      end

      def process_args(args)
        @url = args
        raise "You must pass the DRb URL: --runner #{self.class}:druby://host1:port1" if @url.nil?
      end

      def run
        @started = true
        puts "Whip me on #{slave_watermark}"
        DRb.start_service(@url, self)
        DRb.thread.join
      end

      # This is called by the master over DRb.
      # The +hook_opts+ argument is a Hash that is
      # populated by master's hook(s)
      def prepare_run(master_files, hook_opts)
        begin
          Hooks.run_hooks(hook_opts)
          load_files(master_files)
          prepare
        rescue => e
          STDERR.puts e.message
          STDERR.puts e.backtrace.join("\n")
          exit(1)
        end
      end

      # This is called by the master over DRb.
      def run_example_group_at(example_group_index, dry_run, reverse, timeout)
        begin
          options = override_options(dry_run, reverse, timeout)
          example_group = example_groups[example_group_index]

          # We'll report locally, but also record what happened so we can send
          # that back to the master
          recorder = RecordingFormatter.new(slave_watermark)
          reporter = Dispatcher.new(recorder, options.reporter)
          options.reporter = reporter

          success = example_group.run
          return success, recorder
        rescue => e
          STDERR.puts e.message
          STDERR.puts e.backtrace.join("\n")
          exit(1)
        ensure
          restore_options
        end
      end
      
      # This is called by the master over DRb.
      def finish_slave
        puts "=" * 70
        finish
      end
      
      def slave_watermark
        @url
      end

      def override_options(dry_run, reverse, timeout)
        @orig_options = rspec_options
        options = rspec_options.dup
        options.dry_run = dry_run
        options.reverse = reverse
        options.timeout = timeout
        
        $rspec_options = options
      end

      def restore_options
        $rspec_options = @orig_options
      end
    end

    class Dispatcher
      def initialize(*children)
        @children = children
      end

      def method_missing(method, *args)
        @children.each{|child| child.__send__(method, *args)}
      end
    end
  end
end
