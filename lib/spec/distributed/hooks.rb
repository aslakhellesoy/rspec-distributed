module Spec
  module Distributed
    class Hooks
      class << self
        def hooks
          @hooks ||= []
        end
      
        def add_hook(&hook)
          hooks << hook
        end
      
        def run_hooks(hash)
          hooks.each do |hook|
            hook.call(hash)
          end
          hash
        end
      end
    end
  end
end