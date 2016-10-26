require 'spec_helper'
require 'pipe_dsl/util'

describe PipeDsl::Util do
  describe '.stringify_keys' do
    it "string keys" do
      expect(described_class.stringify_keys(a: 1, 'b' => 2, 3 => 'c')).to eq('a' => 1, 'b' => 2, '3' => 'c')
    end
  end
  describe '.array_wrap' do
    it { expect(described_class.array_wrap([1, 2, 3])).to eq [1, 2, 3] }
    it { expect(described_class.array_wrap(1)).to eq [1] }
    it { expect(described_class.array_wrap(a: 1, b: 2)).to eq([{ a: 1, b: 2 }]) }
  end
  describe '.unescape_string_value' do
    it { expect(described_class.unescape_string_value('%{foo}')).to eq '#{foo}' }
  end
  describe '.camelize' do
    it { expect(described_class.camelize('foo_bar')).to eq 'FooBar' }
  end
  describe '.demodulize' do
    it { expect(described_class.demodulize('Foo::Bar')).to eq 'Bar' }
  end
  describe '.descendants' do
    before(:all) do
      module PipeDsl
        module Test
          class A; end
          class B < A; end
          class C < B; end
          class D < A; end
          class E; end
        end
      end
    end
    it { expect(described_class.descendants(PipeDsl::Test::A)).to match_array [PipeDsl::Test::B, PipeDsl::Test::C, PipeDsl::Test::D] }
  end
  describe '.underscore' do
    it { expect(described_class.underscore('FooBar')).to eq 'foo_bar' }
    it { expect(described_class.underscore('FooBar::Baz')).to eq 'foo_bar/baz' }
    it { expect(described_class.underscore('foo_barBaz')).to eq 'foo_bar_baz' }
  end
end
