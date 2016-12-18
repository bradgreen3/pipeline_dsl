require 'spec_helper'

describe PipeDsl::ComponentDefinition do
  describe '.symbol_name' do
    it 'gets symbol for object' do
      expect(PipeDsl::MysqlRedshiftCopy.symbol_name).to eq :mysql_redshift_copy
    end
  end
  describe '.class_factory' do
    it 'gets class for string' do
      expect(described_class.class_factory('mysql_redshift_copy')).to eq PipeDsl::MysqlRedshiftCopy
    end
    it 'refuses unless is a descendent' do
      expect { described_class.class_factory('unknown') }.to raise_error(ArgumentError, 'Name is not a component')
      expect { described_class.class_factory('csv') }.to raise_error(ArgumentError, 'Name is not a component')
    end
  end
end
