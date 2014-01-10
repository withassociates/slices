require 'spec_helper'

describe Slices::GeneratorMacros do
  subject do
    Module.new do
      extend Slices::GeneratorMacros

      generator :test do
        @test_generator_called = true
        "ohai"
      end

      def self.test_generator_called?
        @test_generator_called
      end
    end
  end

  describe ".generator" do
    it "defines a generator method" do
      subject.test.should == "ohai"
    end
  end

  describe ".generators" do
    it "returns a catalogue of generators" do
      subject.generators.should == [:test]
    end
  end

  describe ".generate!" do
    it "runs all generators" do
      subject.generate!
      subject.test_generator_called?.should be_true
    end
  end
end
