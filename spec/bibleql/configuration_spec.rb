# frozen_string_literal: true

RSpec.describe BibleQL::Configuration do
  subject(:config) { described_class.new }

  it "has default api_url" do
    expect(config.api_url).to eq("https://bibleql-rails.onrender.com/graphql")
  end

  it "has default translation" do
    expect(config.default_translation).to eq("eng-web")
  end

  it "has default timeout" do
    expect(config.timeout).to eq(30)
  end

  it "has nil api_key by default" do
    expect(config.api_key).to be_nil
  end

  it "allows setting values" do
    config.api_key = "my_key"
    config.api_url = "https://custom.api"
    config.default_translation = "spa-bes"
    config.timeout = 60

    expect(config.api_key).to eq("my_key")
    expect(config.api_url).to eq("https://custom.api")
    expect(config.default_translation).to eq("spa-bes")
    expect(config.timeout).to eq(60)
  end
end
