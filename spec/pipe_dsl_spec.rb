require 'spec_helper'

describe PipeDsl do
  it 'has a version number' do
    expect(PipeDsl::VERSION).not_to be nil
  end

  describe '.definition' do
    it 'makes a new definition' do
      expect(described_class.definition).to be_a(PipeDsl::Definition)
    end
  end

end
