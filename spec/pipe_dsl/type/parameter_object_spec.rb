require 'spec_helper'

describe PipeDsl::ParameterObject do
  describe '.initialize' do
    it 'creates new from string' do
      obj = described_class.new('test')
      expect(obj.id).to eq('test')
    end
    it 'creates new from hash' do
      obj = described_class.new(id: 'test', type: 'String')
      expect(obj.id).to eq('test')
      expect(obj.attributes.first.key).to eq('type')
    end
    it 'creates new from object' do
      obj = described_class.new(id: 'test', type: 'String')
      obj2 = described_class.new(obj)
      expect(obj2.id).to eq('test')
      expect(obj2.attributes.first.key).to eq('type')
    end
    it 'calls block' do
      obj = described_class.new('test') do |d|
        expect(d).to be_a(PipeDsl::Attributes)
        d['type'] = 'String'
      end
      expect(obj.id).to eq('test')
      expect(obj.attributes.first.key).to eq('type')
    end
    it 'throws on unknown' do
      expect { described_class.new(Set.new) }.to raise_error(ArgumentError, 'id must be string, symbol, hash or object')
    end
  end

  describe '.as_cli_json' do
    it 'returns a hash for cli' do
      obj = described_class.new(id: 'test', string_value: 'val', type: 'String')

      expect(obj.as_cli_json).to eq(
        id: 'test',
        string_value: 'val',
        type: 'String'
      )
    end
  end

end
