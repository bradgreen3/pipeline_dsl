require 'spec_helper'

describe PipeDsl::ParameterValue do
  describe '.initialize' do
    it 'creates new from parameters' do
      obj = described_class.new('id', 'val')
      expect(obj.id).to eq 'id'
      expect(obj.string_value).to eq 'val'
    end
    it 'creates new from string' do
      obj = described_class.new('id')
      expect(obj.id).to eq 'id'
      expect(obj.string_value).to be_nil
    end
    it 'creates new from array' do
      obj = described_class.new(['id', 'val'])
      expect(obj.id).to eq 'id'
      expect(obj.string_value).to eq 'val'
    end
    it 'creates new from hash' do
      obj = described_class.new(id: 'id', string_value: 'val')
      expect(obj.id).to eq 'id'
      expect(obj.string_value).to eq 'val'
    end
    it 'creates new from object' do
      obj = described_class.new('id', 'val')
      obj2 = described_class.new(obj)

      expect(obj2.id).to eq 'id'
      expect(obj2.string_value).to eq 'val'
    end
    it 'calls block' do
      obj = described_class.new('id') do |v|
        v.string_value = 'val'
      end
      expect(obj.id).to eq 'id'
      expect(obj.string_value).to eq 'val'
    end
    it 'throws on unknown' do
      expect { described_class.new(Set.new) }.to raise_error(ArgumentError, 'parameter must be string, symbol, hash or object')
    end
  end
  describe '.as_cli_json' do
    it 'returns array for cli serialization' do
      obj = described_class.new('id', 'val')
      expect(obj.as_cli_json).to eq(%w(id val))
    end
  end
end
