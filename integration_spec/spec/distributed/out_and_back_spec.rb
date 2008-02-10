require File.dirname(__FILE__) + '/../../spec_helper'
describe "Running a spec job" do
  # start the job runner, possibly on a thread
  before(:all) do
    @thread = Thread.new do
      
    end
  end
  
  # Use the Spec CommandLine to start a job with the master runner
  # ensure something happened, not sure what 
end
