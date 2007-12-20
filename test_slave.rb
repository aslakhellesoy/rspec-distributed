# this needs to become a rake task, or a bin with options parsing etc
require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/lib/spec/distributed'

Spec::Distributed::JobRunner.new(Spec::Distributed::RindaTransportManager.new).start
