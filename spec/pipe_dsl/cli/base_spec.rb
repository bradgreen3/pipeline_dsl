require 'spec_helper'
require 'pipe_dsl/cli/base'

describe PipeDsl::CLI::Base do

  describe '.version' do
    it 'gets version' do
      str = capture(:stdout) do
        described_class.start(%w(version))
      end
      expect(str.strip).to eq "PipeDsl #{PipeDsl::VERSION}"
    end
    it 'gets ruby and gem version too' do
      str = capture(:stdout) do
        described_class.start(%w(version -v))
      end
      expect(str.strip).to eq "PipeDsl #{PipeDsl::VERSION}\nruby: #{RUBY_VERSION} thor: #{Thor::VERSION}"
    end
  end

  describe 'subcommands' do

  end

end
