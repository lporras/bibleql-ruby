# frozen_string_literal: true

RSpec.describe BibleQL do
  it "has a version number" do
    expect(BibleQL::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure do |config|
        config.api_key = "test_key"
      end

      expect(described_class.configuration.api_key).to eq("test_key")
    end
  end

  describe ".client" do
    it "returns a Client instance" do
      described_class.configure { |c| c.api_key = "test_key" }
      expect(described_class.client).to be_a(BibleQL::Client)
    end
  end

  describe ".reset!" do
    it "resets configuration to defaults" do
      described_class.configure { |c| c.api_key = "test_key" }
      described_class.reset!

      expect(described_class.configuration.api_key).to be_nil
    end
  end
end
