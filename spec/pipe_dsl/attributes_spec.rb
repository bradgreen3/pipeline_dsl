require 'spec_helper'

describe PipeDsl::Attributes do
  describe '.initialize' do
    it 'creates new'
  end
  describe '.as_cli_json' do
    it 'returns hash for cli serialization'
  end
  describe '.concat' do
    it 'adds attributes to the current list'
  end
  describe '.ref' do
    it 'creates a ref attribute'
  end
  describe '.attribute' do
    it 'creates a string value attribute'
  end
end
