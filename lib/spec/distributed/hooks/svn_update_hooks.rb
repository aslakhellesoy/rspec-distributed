module Spec
  module Distributed
    # This slave hook updates svn working copy to a given revision.
    # It's smart enough to walk up the directory tree and update from the root.
    class UpdateSvn
      def update_wc(svn_rev, diff)
        Dir.chdir(top_svn_dir) do
          revert
          update svn_rev
          patch diff if diff
        end
      end

      def patch(diff)
        IO.popen("patch -p0", "w+") do |patch|
          patch.puts diff
          patch.close_write
          patch.readlines
        end
      end

      def local_diff
        Dir.chdir(top_svn_dir) do
          `svn diff`
        end
      end

      def local_revision
        `svn info`.match(/Revision: (\d+)/m)[1]  
      end

      def revert
        `svn revert -R .`
      end

      def update(svn_rev)
        local_rev = `svn info`.match(/^Revision: (\d+)$/n)[1]
        if(local_rev.to_i != svn_rev.to_i)
          system("svn up -r#{svn_rev}")
        end
      end

      def top_svn_dir
        dir = '.'
        loop do
          up = File.join(dir, '..')
          if File.directory?(File.join(up, '.svn'))
            dir = up
          else
            break
          end
        end
        dir
      end
    end


    module MasterHooks
      # This master hook detects local svn rev. and diffs
      # make sure your new files are 'svn add'ed
      module DetectSvnRev
        Spec::Distributed::Hooks.add_master_hook do |job|
          job.add_library 'spec/distributed/hooks/svn_update_hooks'
          
          svn = UpdateSvn.new
          job.master_svn_rev = svn.local_revision
          job.master_svn_diff = svn.local_diff
        end
      end
    end
    
    module SlaveHooks
      Spec::Distributed::Hooks.add_slave_hook do |job|
        UpdateSvn.new.update_wc(job.master_svn_rev, job.master_svn_diff)
      end
    end
  end

end
