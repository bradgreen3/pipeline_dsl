require 'spec_helper'

describe PipeDsl::PipelineObject do
  subject { described_class.new('test') }

  describe '.initialize' do
    it 'creates new from string' do
      expect(subject.id).to eq 'test'
      expect(subject.name).to eq 'test'
      expect(subject.fields.first.string_value).to eq 'test'
    end
    it 'creates new default' do
      obj = described_class.new('Default')
      expect(obj.id).to eq 'Default'
      expect(obj.name).to eq 'Default'
      expect(obj.fields.size).to eq 0
    end
    it 'creates new from hash' do
      obj = described_class.new(id: 'thing', type: 'CSV')
      expect(obj.id).to eq 'thing'
      expect(obj.name).to eq 'thing'
      expect(obj.fields.first.string_value).to eq 'CSV'
    end
    it 'creates new from object' do
      obj = described_class.new(subject)
      expect(obj.id).to eq 'test'
      expect(obj.name).to eq 'test'
      expect(obj.fields.first.string_value).to eq 'test'
    end
    it 'creates new as descendant, setting type' do
      obj = PipeDsl::Csv.new('thing')
      expect(obj.id).to eq 'thing'
      expect(obj.name).to eq 'thing'
      expect(obj.fields.first.string_value).to eq 'CSV'
    end
    it 'raises error on unknown' do
      expect { described_class.new(Set.new) }.to raise_error(ArgumentError, "type must be string, symbol, hash or object")
    end
    it 'raises error on empty' do
      expect { described_class.new }.to raise_error(ArgumentError, 'id must be specified')
    end
  end

  describe '.as_cli_json' do
    it 'returns a hash for cli' do
      obj = described_class.new('test') do |f|
        f['thing'] = 'Test'
      end
      expect(obj.as_cli_json).to eq(
        id: 'test',
        name: 'test',
        type: 'test',
        thing: 'Test'
      )
    end
  end

  describe '.symbol_name' do
    it 'name of class as symbol' do
      expect(PipeDsl::Schedule.symbol_name).to eq :schedule
      expect(PipeDsl::Csv.symbol_name).to eq :csv
    end
  end

  describe '.type_name' do
    it 'name of class as type string' do
      expect(PipeDsl::Schedule.type_name).to eq 'Schedule'
      expect(PipeDsl::Csv.type_name).to eq 'CSV'
    end
  end

  describe '.class_factory' do
    it 'gets one' do
      expect(described_class.class_factory(:schedule)).to eq PipeDsl::Schedule
      expect(described_class.class_factory(:csv)).to eq PipeDsl::Csv
    end
    it 'refuses to make non-descendant' do
      expect { described_class.class_factory(:unknown) }.to raise_error(ArgumentError, 'Name is not a pipeline object')
      expect { described_class.class_factory(:attributes) }.to raise_error(ArgumentError, 'Name is not a pipeline object')
    end
  end

end
