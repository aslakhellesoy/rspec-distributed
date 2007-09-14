module Spec
  module Distributed
    module Hooks
      module Slave
        # This slave hook updates svn working copy to a given revision.
        # It should be used in conjuction with Spec::Distributed::Hooks::Master::DetectSvnRev
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

          Spec::Distributed::Hooks.add_hook do |slave_opts|
            UpdateSvn.new.update_wc(slave_opts[:master_svn_rev])
          end
        end
      end
    end
  end
end
