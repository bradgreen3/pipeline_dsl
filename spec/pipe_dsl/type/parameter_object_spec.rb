require 'spec_helper'

describe PipeDsl::ParameterObject do
  describe '.initialize' do
    it 'creates new'
    it 'creates new from object'
    it 'creates new from hash'
    it 'creates new from string'
  end
  describe '.as_cli_json' do
    it 'returns a hash for cli'
  end
end
