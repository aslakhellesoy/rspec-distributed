module Spec
  module Distributed
    module MasterHooks
      Hooks.add_master_hook do |job|
        job.add_library 'spec/distributed/hooks/spec_path_hook'
        hostname = `hostname`.chomp
        job.spec_file_transformation = ['/Users', "/net/#{hostname}"]
      end
    end
    module SlaveHooks
      Hooks.add_slave_hook do |job|
        job.spec_file = job.spec_file.gsub(*job.spec_file_transformation)
      end
    end
  end
end
