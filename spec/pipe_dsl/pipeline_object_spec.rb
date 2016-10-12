require 'spec_helper'

describe PipeDsl::PipelineObject do
  describe '.initialize' do
    it 'creates new'
    it 'creates new from hash'
    it 'creates new from string'
    it 'creates new from default'
  end
  describe '.as_cli_json' do
    it 'returns a hash for cli'
  end
end
