module Spec
  module Distributed
    module MasterHooks
      Hooks.add_master_hook do |job|
        job.add_library 'spec/distributed/hooks/spec_path_hook'
        hostname = `hostname`.chomp
        job.spec_path_transformation = ['/Users/bcotton/projects/trunk/alm', "/Users/spec_slave/projects"]
      end
    end
    module SlaveHooks
      Hooks.add_slave_hook do |job|
        job.spec_path = job.spec_path.gsub(*job.spec_path_transformation)
      end
    end
  end
end
