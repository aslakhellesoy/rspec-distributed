module Spec
  module Distributed
    class Hooks
      class << self
        def master_hooks
          @master_hooks ||= []
        end

        def slave_hooks
          @slave_hooks ||= []
        end

        def reset 
          @master_hooks = @slave_hooks = nil
        end

        def add_master_hook(&hook)
          master_hooks << hook
        end

        def add_slave_hook(&hook)
          slave_hooks << hook
        end

        def run_master_hooks(hash)
          run_hooks(master_hooks, hash)
        end

        def run_slave_hooks(hash)
          run_hooks(slave_hooks, hash)
        end

        def run_hooks(hooks, hash)
          hooks.each do |hook|
            hook.call(hash)
          end
          hash
        end
      end
    end
  end
end
