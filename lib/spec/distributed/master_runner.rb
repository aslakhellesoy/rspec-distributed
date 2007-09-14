require 'thread'
require 'spec/distributed/slave_runner'

module Spec
  module Distributed
    class MasterRunner < ::Spec::Runner::BehaviourRunner      
      def initialize(options, args="")
        super(options)
        process_args(args)
      end

      def process_args(args)
        @slave_urls = args.split(",")
        raise "You must pass the DRb URLs: --runner #{self.class}:druby://host1:port1,drb://host2:port2" if @slave_urls.empty?
      end
      
      def run(paths, exit_when_done)
        @master_paths = paths
        super(paths, exit_when_done)
      end
      
      def run_behaviours
        DRb.start_service
        behaviour_reports = Queue.new
        index_queue = Queue.new
        @behaviours.length.times {|index| index_queue << index}

        # The master can do some prep work before starting slaves.
        # It can also send some values (typically related to its prep work)
        # to the slaves.
        #
        # A typical example is to detect local svn rev and send it to the slaves.
        slave_opts = Hooks.run_hooks({})
        @threads = slave_runners.map do |slave_runner|
          Thread.new do
            slave_runner.prepare_run(@master_paths, slave_opts)
            drb_error = nil
            while !index_queue.empty?
              begin
                i = index_queue.pop
                behaviour = @behaviours[i]
                behaviour_report = slave_runner.run_behaviour_at(i, @options.dry_run, @options.reverse, @options.timeout)
                behaviour_reports << behaviour_report
              rescue DRb::DRbConnError => e
                # Maybe the slave is down. Put the index back and die
                index_queue << i
                drb_error = e
                break
              end
            end
            
            unless drb_error
              slave_runner.report_end
              slave_runner.report_dump
            end
          end
        end

        return unless @threads.length > 0
        
        # Add a last thread for the reporter
        @threads << Thread.new do
          @behaviours.length.times do
            behaviour_reports.pop.replay(@options.reporter)
          end
        end

        @threads.each do |t| 
          t.join
        end
      end

      def slave_runners
        @slave_urls.map { |slave_url| DRbObject.new_with_uri(slave_url) }
      end
    end
  end
end
