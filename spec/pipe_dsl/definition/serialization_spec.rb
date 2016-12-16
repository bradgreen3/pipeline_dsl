require 'spec_helper'

describe PipeDsl::Definition do

  describe '.from_cli_json' do
    it 'decodes json' do
      expect(described_class).to receive(:from_cli_hash).with("foo" => "bar")

      described_class.from_cli_json('{"foo": "bar"}')
    end
  end

  describe '.from_cli_hash' do
    it 'parses objects' do
      out = described_class.from_cli_hash(
        'objects' => [
          { id: 'first', name: 'firstname' }
        ]
      )
      expect(out.pipeline_objects.size).to eq 1
    end
    it 'parses parameters' do
      out = described_class.from_cli_hash(
        'parameters' => [
          { id: 'first', name: 'firstname' }
        ]
      )
      expect(out.parameter_objects.size).to eq 1
    end
    it 'parses values' do
      out = described_class.from_cli_hash(
        'values' => {
          'foo' => 'bar'
        }
      )
      expect(out.parameter_values.size).to eq 1
    end
    it 'parses all' do
      out = described_class.from_cli_hash(
        'objects' => [
          { id: 'first', name: 'firstname' }
        ],
        'parameters' => [
          { id: 'first', name: 'firstname' }
        ],
        'values' => {
          'foo' => 'bar'
        }
      )
      expect(out.pipeline_objects.size).to eq 1
      expect(out.parameter_objects.size).to eq 1
      expect(out.parameter_values.size).to eq 1
    end
  end

  describe '.as_cli_json' do
    it 'generates object hashes' do
      subject.pipeline_object('Test')
      expect(subject.as_cli_json).to eq({
                                          objects: [
                                            { type: 'Test', name: 'Test', id: 'Test' }
                                          ],
                                          parameters: [],
                                          values: {}
      })
    end
    it 'generates parameter hashes' do
      subject.parameter_object('Test')
      expect(subject.as_cli_json).to eq({
                                          objects: [],
                                          parameters: [
                                            {id: 'Test' }
                                          ],
                                          values: {}
      })
    end
    it 'generates value hashes' do
      subject.parameter_value('Test', 'value')
      expect(subject.as_cli_json).to eq({
                                          objects: [],
                                          parameters: [],
                                          values: { 'Test' => 'value' }
      })
    end
  end

  describe '.to_cli_json' do
    it 'generates a json string' do
      expect(subject).to receive(:as_cli_json).and_return(foo: 'bar')
      subject.to_cli_json
    end
  end

end
