require 'spec_helper'

describe PipeDsl::ParameterValue do
  describe '.initialize' do
    it 'creates new from object'
    it 'creates new from hash'
    it 'creates new from array'
    it 'creates new from string'
  end
  describe '.as_cli_json' do
    it 'returns hash for cli serialization'
  end
end
