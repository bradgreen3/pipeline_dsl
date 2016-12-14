require 'spec_helper'

describe PipeDsl::Definition do

  describe 'integration' do
    it 'json roundtrip' do
      str = File.read(File.join($SPEC_ROOT, 'samples', 'table_copy.json'))
      parsed = JSON.parse(str)
      parsed_objects = parsed['objects']

      definition = described_class.from_cli_json(str).as_cli_json
      #run through json to stringify keys
      definition = JSON.parse(JSON.dump(definition))
      objects = definition['objects']

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
      ) do |d|
        expect(d).to be_a(described_class)
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

  describe '.find' do
    let(:defn) do
      described_class.new(
        pipeline_objects: [
          { 'id' => 'first', 'name' => 'first', 'type' => 'Test' }
        ],
        parameter_objects: [
          { 'id' => 'second' }
        ],
        parameter_values: [
          { 'id' => 'third', 'string_value' => 'third value' }
        ]
      )
    end
    it 'finds an ID in the list' do
      first = defn.find('first')
      expect(first.name).to eq('first')
      expect(first.fields.first.string_value).to eq('Test')
    end
  end

  describe '.define' do
    it 'yields for dsl' do
      subject.define do |d|
        expect(d).to eq(subject)
      end
    end
  end

  describe '.concat' do
    let(:defn) do
      described_class.new(
        pipeline_objects: [
          { 'id' => 'first', 'name' => 'first', 'type' => 'Test' }
        ],
        parameter_objects: [
          { 'id' => 'second' }
        ],
        parameter_values: [
          { 'id' => 'third', 'string_value' => 'third value' }
        ]
      )
    end

    it 'merges a definition' do
      expect(subject.pipeline_objects.map(&:id)).to eq([])
      expect(subject.parameter_objects.map(&:id)).to eq([])
      expect(subject.parameter_values.map(&:id)).to eq([])

      subject.concat(defn)

      expect(subject.pipeline_objects.map(&:id)).to eq(%w(first))
      expect(subject.parameter_objects.map(&:id)).to eq(%w(second))
      expect(subject.parameter_values.map(&:id)).to eq(%w(third))
    end
  end

  xdescribe '.merge' do
    let(:defn) do
      described_class.new(
        pipeline_objects: [
          { 'id' => 'first', 'name' => 'first', 'type' => 'Test' }
        ],
        parameter_objects: [
          { 'id' => 'second' }
        ],
        parameter_values: [
          { 'id' => 'third', 'string_value' => 'third value' }
        ]
      )
    end

    it 'merges a definition' do
      expect(subject.pipeline_objects.map(&:id)).to eq([])
      expect(subject.parameter_objects.map(&:id)).to eq([])
      expect(subject.parameter_values.map(&:id)).to eq([])

      out = subject.merge(defn)

      expect(out).to_not eq(subject)
      expect(out).to_not eq(defn)

      expect(out.pipeline_objects.map(&:id)).to eq(%w(first))
      expect(out.parameter_objects.map(&:id)).to eq(%w(second))
      expect(out.parameter_values.map(&:id)).to eq(%w(third))

      #leaves subject alone
      expect(subject.pipeline_objects.map(&:id)).to eq([])
      expect(subject.parameter_objects.map(&:id)).to eq([])
      expect(subject.parameter_values.map(&:id)).to eq([])

    end
  end

  describe '.<<' do
    let(:defn) do
      described_class.new(
        pipeline_objects: [
          { 'id' => 'first', 'name' => 'first', 'type' => 'Test' }
        ],
        parameter_objects: [
          { 'id' => 'second' }
        ],
        parameter_values: [
          { 'id' => 'third', 'string_value' => 'third value' }
        ]
      )
    end

    it 'adds an object' do
      po = PipeDsl::PipelineObject.new('Test')
      subject << po

      expect(subject.pipeline_objects.size).to eq 1
      expect(subject.pipeline_objects.first.id).to eq 'Test'
    end
    it 'adds a parameter' do
      po = PipeDsl::ParameterObject.new('Test')
      subject << po

      expect(subject.parameter_objects.size).to eq 1
      expect(subject.parameter_objects.first.id).to eq 'Test'
    end
    it 'adds a value' do
      v = PipeDsl::ParameterValue.new('Test')
      subject << v

      expect(subject.parameter_values.size).to eq 1
      expect(subject.parameter_values.first.id).to eq 'Test'

    end
    it 'concats a whole definition' do
      subject << defn
      expect(subject.pipeline_objects.map(&:id)).to eq(%w(first))
      expect(subject.parameter_objects.map(&:id)).to eq(%w(second))
      expect(subject.parameter_values.map(&:id)).to eq(%w(third))
    end
  end

  xdescribe '.dup' do
    it 'deeply duplicates'
  end

end
