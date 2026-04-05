# frozen_string_literal: true

RSpec.describe BibleQL::Verse do
  subject(:verse) do
    described_class.new(
      book_id: "JHN",
      book_name: "John",
      chapter: 3,
      verse: 16,
      text: "For God so loved the world..."
    )
  end

  it "has accessible attributes" do
    expect(verse.book_id).to eq("JHN")
    expect(verse.book_name).to eq("John")
    expect(verse.chapter).to eq(3)
    expect(verse.verse).to eq(16)
    expect(verse.text).to eq("For God so loved the world...")
  end

  it "converts to hash" do
    expect(verse.to_h).to eq(
      book_id: "JHN",
      book_name: "John",
      chapter: 3,
      verse: 16,
      text: "For God so loved the world..."
    )
  end

  it "supports equality" do
    other = described_class.new(book_id: "JHN", book_name: "John", chapter: 3, verse: 16,
                                text: "For God so loved the world...")
    expect(verse).to eq(other)
  end

  it "has a string representation" do
    expect(verse.to_s).to include("BibleQL::Verse")
    expect(verse.to_s).to include("JHN")
  end
end
