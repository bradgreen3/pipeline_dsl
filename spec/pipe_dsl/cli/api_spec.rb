require 'spec_helper'
require 'pipe_dsl/cli/base'

describe PipeDsl::CLI::Api do

  let(:sdk) { Aws::DataPipeline::Client.new(stub_responses: true) }
  before(:each) do
    described_class.any_instance.stub(:client).and_return(sdk)
  end

end
