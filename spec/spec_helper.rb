dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
lib_path = File.expand_path("#{dir}/../../rspec/lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'spec'
require 'spec/distributed'

module Spec
  module Distributed
    module OptionsHelper
      def with_rspec_options(options)
        begin
          orig_options = $rspec_options
          $rspec_options = options
          yield
        ensure
          $rspec_options = orig_options
        end
      end
    end
  end
end


