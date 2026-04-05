# frozen_string_literal: true

RSpec.describe BibleQL::Passage do
  subject(:passage) do
    described_class.new(
      reference: "John 3:16",
      translation_id: "eng-web",
      translation_name: "World English Bible",
      translation_note: nil,
      text: "For God so loved the world...",
      verses: [
        { book_id: "JHN", book_name: "John", chapter: 3, verse: 16, text: "For God so loved the world..." }
      ]
    )
  end

  it "has accessible attributes" do
    expect(passage.reference).to eq("John 3:16")
    expect(passage.translation_id).to eq("eng-web")
    expect(passage.text).to eq("For God so loved the world...")
  end

  it "wraps verses as Verse objects" do
    expect(passage.verses).to all(be_a(BibleQL::Verse))
    expect(passage.verses.first.book_id).to eq("JHN")
  end

  it "handles nil verses" do
    p = described_class.new(reference: "test", verses: nil)
    expect(p.verses).to eq([])
  end
end
