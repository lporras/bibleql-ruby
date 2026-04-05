# frozen_string_literal: true

RSpec.describe BibleQL::Translation do
  subject(:translation) do
    described_class.new(
      identifier: "eng-web",
      name: "World English Bible",
      language: "eng",
      note: "Public domain",
      books: [
        { book_id: "GEN", name: "Genesis", testament: "OT", position: 1, chapter_count: 50 }
      ]
    )
  end

  it "has accessible attributes" do
    expect(translation.identifier).to eq("eng-web")
    expect(translation.name).to eq("World English Bible")
    expect(translation.language).to eq("eng")
    expect(translation.note).to eq("Public domain")
  end

  it "wraps books as LocalizedBook objects" do
    expect(translation.books).to all(be_a(BibleQL::LocalizedBook))
    expect(translation.books.first.book_id).to eq("GEN")
  end
end
