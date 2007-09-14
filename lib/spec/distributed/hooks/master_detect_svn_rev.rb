module Spec
  module Distributed
    module Hooks
      module Master
        # This master hook detects local svn rev. It should be
        # used in conjuction with Spec::Distributed::Hooks::Slave::UpdateSvn
        module DetectSvnRev
          Spec::Distributed::Hooks.add_hook do |slave_opts|
            slave_opts[:master_svn_rev] = `svn info`.match(/Revision: (\d+)/m)[1]
          end
        end
      end
    end
  end
end
