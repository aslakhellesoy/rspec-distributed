require 'ostruct'
module Spec
  module Distributed
    class RemoteJobRunnerOptionParser
      class << self
        def parse
          OpenStruct.new(:transport_type => "rinda")
        end
      end
    end
  end
end
