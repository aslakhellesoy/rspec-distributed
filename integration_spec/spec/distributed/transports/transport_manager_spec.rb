require File.dirname(__FILE__) + '/../../../spec_helper'
module Spec
  module Distributed
    module Transports
      Struct.new("StubExampleGroup", :description, :spec_path, :return_path)
      
      shared_examples_for "All Transport Managers" do
        attr_reader :manager, :example_group
        before(:all) do
          @example_group = Struct::StubExampleGroup.new("Description", "path", nil)
          @manager = TransportManager.manager_for(transport_type).new(transport_args)
          manager.connect(true)
        end

        it "should put and get results" do
          result_count = 0
          job = Job.create_job(example_group, nil, manager.return_path)

          2.times do
            manager.publish_job(job)
            manager.next_job
            manager.publish_result(job)
          end

          manager.collect_results do |result|
            result.should == job
            result_count += 1
          end
          result_count.should == 2
        end
        
      end

      describe LocalTransportManager do
        def transport_type; "local"; end
        def transport_args; ""; end
        it_should_behave_like "All Transport Managers"
      end

      describe RindaTransportManager do
        def transport_type; "rinda"; end
        def transport_args; ""; end
        it_should_behave_like "All Transport Managers"
      end

    end
  end
end
