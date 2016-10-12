require 'spec_helper'
require 'pipe_dsl/parameter_object'

describe PipeDsl::Fields do
  describe '.initialize' do
    it { expect(subject).to be_a(Array) }
    it 'adds fields' do
      subject = described_class.new(kk: 'vv')

      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
    it 'yields fields' do
      yielded = false
      subject = described_class.new do |a|
        yielded = true
        a[:kk] = 'vv'
      end

      expect(yielded).to eq true
      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
  end

  describe '.concat' do
    it 'adds fields to the current list' do
      expect(subject).to be_empty
      subject.concat(kk: 'vv', 'kk2' => 'vv2')

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject[1].key).to eq 'kk2'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds array of fields' do
      expect(subject).to be_empty
      subject.concat([
                       Aws::DataPipeline::Types::Field.new(key: 'kk', string_value: 'vv'),
                       Aws::DataPipeline::Types::Field.new(key: 'kk2', string_value: 'vv2'),
      ])

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject[1].key).to eq 'kk2'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds hash with array' do
      expect(subject).to be_empty
      subject.concat(kk: %w(vv vv2))

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject[1].key).to eq 'kk'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it { expect { subject.concat(%w(vv vv2)) }.to raise_error(ArgumentError, 'All entries must be Field') }
    it { expect { subject.concat('vv') }.to raise_error(ArgumentError, 'Must be a Hash, or Array of Field') }
  end

  describe '.as_cli_json' do
    it { expect(subject.concat(kk: 'vv').as_cli_json).to eq('kk' => 'vv') }
    it { expect(subject.concat(kk: %w(vv vv2)).as_cli_json).to eq('kk' => %w(vv vv2)) }
    it { expect(subject.concat(kk: { ref: 'vv' }).as_cli_json).to eq('kk' => { ref: 'vv' }) }
  end

  describe '.field' do
    it 'creates a string value field' do
      subject.field(:kk, 'vv')
      expect(subject.size).to eq 1
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
    end
    it 'creates multiple for an array' do
      subject.field(:kk, %w(vv vv2))

      expect(subject.size).to eq 2
      expect(subject.first).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.string_value).to eq 'vv'
      expect(subject[1]).to be_a(Aws::DataPipeline::Types::Field)
      expect(subject[1].key).to eq 'kk'
      expect(subject[1].string_value).to eq 'vv2'
    end
    it 'adds a field' do
      att = Aws::DataPipeline::Types::Field.new(key: 'kk', string_value: 'vv')
      subject.field(att)
      expect(subject.size).to eq 1
      expect(subject.first).to eq att
    end
    it 'adds a ref via hash' do
      subject.field(:kk, ref: 'vv')
      expect(subject.size).to eq 1
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.ref_value).to eq 'vv'
    end
    it 'adds a ref via object' do
      obj = PipeDsl::PipelineObject.new(id: 'test')
      subject.field(:kk, obj)
      expect(subject.size).to eq 1
      expect(subject.first.key).to eq 'kk'
      expect(subject.first.ref_value).to eq 'test'
    end
    it { expect { subject.field(:kk, Object.new) }.to raise_error(ArgumentError, 'unknown value type') }
  end

end
