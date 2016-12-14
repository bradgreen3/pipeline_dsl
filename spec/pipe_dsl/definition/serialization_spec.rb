require 'spec_helper'

describe PipeDsl::Definition do

  describe '.from_cli_json' do
    it 'decodes json'
  end

  describe '.from_cli_hash' do
    it 'parses objects'
    it 'parses parameters'
    it 'parses values'
  end

  describe '.as_cli_json' do
    it 'generates object hashes'
    it 'generates parameter hashes'
    it 'generates value hashes'
  end

  describe '.to_cli_json' do
    it 'generates a json string'
  end

end
