require 'spec_helper'

describe PipeDsl::ParameterObject do
  describe '.initialize' do
    it 'creates new from string'
    it 'creates new from hash'
    it 'creates new from object'
    it 'calls block'
    it 'throws on unknown'
  end
  describe '.as_cli_json' do
    it 'returns a hash for cli'
  end
end
