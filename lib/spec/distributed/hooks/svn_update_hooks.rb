module Spec
  module Distributed
    module MasterHooks
      # This master hook detects local svn rev. 
      module DetectSvnRev
        Spec::Distributed::Hooks.add_master_hook do |job|
          job.add_library 'spec/distributed/hooks/svn_update_hooks'
          job.master_svn_rev = `svn info`.match(/Revision: (\d+)/m)[1]
        end
      end
    end
    
    module SlaveHooks
      # This slave hook updates svn working copy to a given revision.
      #
      # It's smart enough to walk up the directory tree and update from the root.
      class UpdateSvn
        def update_wc(svn_rev)
          Dir.chdir(top_svn_dir) do
            local_rev = `svn info`.match(/^Revision: (\d+)$/n)[1]
            if(local_rev.to_i != svn_rev.to_i)
              system("svn up -r#{svn_rev}")
            end
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

        Spec::Distributed::Hooks.add_slave_hook do |job|
          UpdateSvn.new.update_wc(job.master_svn_rev)
        end
      end
    end

  end
end
