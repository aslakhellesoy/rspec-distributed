# this needs to become a rake task, or a bin with options parsing etc
require 'rubygems'
require 'spec'
dir = File.dirname(__FILE__)
distributed_path = File.expand_path("#{dir}/lib")
$LOAD_PATH.unshift distributed_path unless $LOAD_PATH.include?(distributed_path)

require 'spec/distributed'
#Spec::Distributed::JobRunner.new(Spec::Distributed::RindaTransportManager.new).start

#include Spec::Distributed::RindaConnection
#connect(true)
begin
  ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(["--runner", "Spec::Distributed::RindaExampleGroupRunner"], STDERR, STDOUT))
end while true
