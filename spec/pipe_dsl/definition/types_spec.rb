require 'spec_helper'

describe PipeDsl::Definition do

  #TODO: way to test included stuff?

  describe '.pipeline_object' do
    it 'adds a new object' do
      subject.pipeline_object('Test')
      expect(subject.pipeline_objects.size).to eq(1)
    end
    it 'adds a new object and calls block' do
      subject.pipeline_object('Test') do |p|
        expect(p).to be_a(PipeDsl::Fields)
      end
      expect(subject.pipeline_objects.size).to eq(1)
    end
  end

  describe '.parameter_object' do
    it 'adds a new object' do
      subject.parameter_object('Test')
      expect(subject.parameter_objects.size).to eq(1)
    end
    it 'adds a new object and calls block' do
      subject.parameter_object('Test') do |p|
        expect(p).to be_a(PipeDsl::Attributes)
      end
      expect(subject.parameter_objects.size).to eq(1)
    end
  end

  describe '.parameter_value' do
    it 'adds a new object' do
      subject.parameter_value('test', 'me')
      expect(subject.parameter_values.size).to eq(1)
    end
    it 'adds a new object and calls block' do
      subject.parameter_value('test', 'me') do |p|
        expect(p).to be_a(PipeDsl::ParameterValue)
      end
      expect(subject.parameter_values.size).to eq(1)
    end
  end

  describe '.component' do
    # TODO: need a good way to mock this for a shorter test
    it 'adds a component'
    it 'adds a component and calls block'
  end

  #TODO: best way to test registered methods?

end
