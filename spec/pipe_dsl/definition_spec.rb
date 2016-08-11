require 'spec_helper'
require 'pry'

describe PipeDsl::Definition do

  describe 'integration' do
    it 'json roundtrip' do
      str = File.read(File.join($SPEC_ROOT,'samples','table_copy.json'));
      parsed = JSON.parse(str)
      parsed_objects = parsed['objects'].sort_by { |v| v['id'] }

      definition = described_class.from_cli_json(str).as_cli_json
      #run through json to stringify keys
      definition = JSON.parse(JSON.dump(definition))
      objects = definition['objects'].sort_by { |v| v['id'] }

      expect(parsed_objects).to match_array(objects)
    end
  end

  describe '.initialize' do
    it 'sets args' do
      dsl = described_class.new(
        pipeline_objects: [
          { 'id' => 'first', 'name' => 'first', 'type' => 'Test' }
        ],
        parameter_objects: [
          { 'id' => 'second' }
        ],
        parameter_values: [
          { 'id' => 'third', 'string_value' => 'third value' }
        ]
      ) do |dsl|
        expect(dsl).to be_a(described_class)
      end

      expect(dsl.pipeline_objects.size).to eq 1
      expect(dsl.pipeline_objects.first.id).to eq 'first'
      expect(dsl.parameter_objects.size).to eq 1
      expect(dsl.parameter_objects.first.id).to eq 'second'
      expect(dsl.parameter_values.size).to eq 1
      expect(dsl.parameter_values.first.id).to eq 'third'
      expect(dsl.parameter_values.first.string_value).to eq 'third value'
    end
  end

  describe '.from_cli_json' do
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

  describe '.concat' do
    it 'merges a definition'
  end

  describe '.pipeline_object' do
    it 'adds a new object'
    it 'adds a new hash'
    it 'adds a new params'
  end

  describe '.parameter_object' do
    it 'adds a new object'
    it 'adds a new hash'
    it 'adds a new params'
  end

  describe '.parameter_value' do
    it 'adds a new object'
    it 'adds a new hash'
    it 'adds a new params'
  end

end
