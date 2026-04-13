# frozen_string_literal: true

RSpec.describe BibleQL::SemanticSearchResult do
  subject(:result) do
    described_class.new(
      similarity: 0.95,
      verse: { book_id: "JHN", book_name: "John", chapter: 3, verse: 16, text: "For God so loved the world..." }
    )
  end

  it "has accessible attributes" do
    expect(result.similarity).to eq(0.95)
  end

  it "wraps verse as a Verse object" do
    expect(result.verse).to be_a(BibleQL::Verse)
    expect(result.verse.book_id).to eq("JHN")
    expect(result.verse.book_name).to eq("John")
    expect(result.verse.chapter).to eq(3)
    expect(result.verse.verse).to eq(16)
    expect(result.verse.text).to eq("For God so loved the world...")
  end

  it "handles nil verse" do
    r = described_class.new(similarity: 0.5, verse: nil)
    expect(r.verse).to be_a(BibleQL::Verse)
  end
end
