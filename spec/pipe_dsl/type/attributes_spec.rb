require 'spec_helper'

describe PipeDsl::Attributes do
  describe '.initialize' do
    it { expect(subject).to be_a(Array) }
    it 'adds attributes' do
      subject = described_class.new(kk: 'vv')

      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
    it 'yields attributes' do
      yielded = false
      subject = described_class.new do |a|
        yielded = true
        a[:kk] = 'vv'
      end

      expect(yielded).to eq true
      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
  end

  describe '.concat' do
    it 'adds attributes to the current list' do
      expect(subject).to be_empty
      subject.concat(kk: 'vv', 'kk2' => 'vv2')

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject[1].key).to eq 'kk2'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds array of attributes' do
      expect(subject).to be_empty
      subject.concat([
                       Aws::DataPipeline::Types::ParameterAttribute.new(key: 'kk', string_value: 'vv'),
                       Aws::DataPipeline::Types::ParameterAttribute.new(key: 'kk2', string_value: 'vv2'),
      ])

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject[1].key).to eq 'kk2'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds hash with array' do
      expect(subject).to be_empty
      subject.concat(kk: %w(vv vv2))

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject[1].key).to eq 'kk'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it { expect { subject.concat(%w(vv vv2)) }.to raise_error(ArgumentError, 'All entries must be Attribute') }
    it { expect { subject.concat('vv') }.to raise_error(ArgumentError, 'Must be a Hash, or Array of Attribute') }
  end

  describe '.as_cli_json' do
    it { expect(subject.concat(kk: 'vv').as_cli_json).to eq(kk: 'vv') }
    it { expect(subject.concat(kk: %w(vv vv2)).as_cli_json).to eq(kk: %w(vv vv2)) }
  end

  describe '.attribute' do
    it 'creates a string value attribute' do
      subject.attribute(:kk, 'vv')
      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
    it 'creates multiple for an array' do
      subject.attribute(:kk, %w(vv vv2))

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::ParameterAttribute)
      expect(subject[1].key).to eq 'kk'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds an attribute' do
      att = Aws::DataPipeline::Types::ParameterAttribute.new(key: 'kk', string_value: 'vv')
      subject.attribute(att)
      expect(subject.size).to eq 1
      expect(subject.first).to eq att
    end
    it { expect { subject.attribute(:kk, Object.new) }.to raise_error(ArgumentError, 'unknown value type') }
  end

end
