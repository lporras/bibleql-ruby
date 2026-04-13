# frozen_string_literal: true

RSpec.describe BibleQL::QueryBuilder do
  describe ".translations" do
    it "returns a query hash" do
      result = described_class.translations
      expect(result[:query]).to include("translations")
      expect(result[:variables]).to eq({})
    end
  end

  describe ".translation" do
    it "includes the identifier variable" do
      result = described_class.translation("eng-web")
      expect(result[:query]).to include("$identifier: String!")
      expect(result[:variables]).to eq(identifier: "eng-web")
    end
  end

  describe ".passage" do
    it "includes reference and translation variables" do
      result = described_class.passage("John 3:16", translation: "eng-web")
      expect(result[:query]).to include("$reference: String!")
      expect(result[:variables]).to eq(reference: "John 3:16", translation: "eng-web")
    end
  end

  describe ".chapter" do
    it "includes book and chapter variables" do
      result = described_class.chapter("MAT", 5, translation: "eng-web")
      expect(result[:variables]).to eq(book: "MAT", chapter: 5, translation: "eng-web")
    end
  end

  describe ".verse" do
    it "includes book, chapter, and verse variables" do
      result = described_class.verse("MAT", 5, 3, translation: "eng-web")
      expect(result[:variables]).to eq(book: "MAT", chapter: 5, verse: 3, translation: "eng-web")
    end
  end

  describe ".random_verse" do
    it "compacts nil values" do
      result = described_class.random_verse(translation: "eng-web")
      expect(result[:variables]).to eq(translation: "eng-web")
    end

    it "includes testament when provided" do
      result = described_class.random_verse(translation: "eng-web", testament: "NT")
      expect(result[:variables]).to eq(translation: "eng-web", testament: "NT")
    end
  end

  describe ".search" do
    it "includes query and translation variables" do
      result = described_class.search("love", translation: "eng-web", limit: 10)
      expect(result[:variables]).to eq(query: "love", translation: "eng-web", limit: 10)
    end
  end

  describe ".semantic_search" do
    it "includes query and translation variables" do
      result = described_class.semantic_search("love and forgiveness", translation: "eng-web", limit: 10)
      expect(result[:query]).to include("semanticSearch")
      expect(result[:variables]).to eq(query: "love and forgiveness", translation: "eng-web", limit: 10)
    end

    it "compacts nil limit" do
      result = described_class.semantic_search("hope", translation: "eng-web")
      expect(result[:variables]).to eq(query: "hope", translation: "eng-web")
    end
  end

  describe ".verse_of_the_day" do
    it "includes translation variable" do
      result = described_class.verse_of_the_day(translation: "eng-web")
      expect(result[:variables]).to eq(translation: "eng-web")
    end

    it "includes date when provided" do
      result = described_class.verse_of_the_day(translation: "eng-web", date: "2026-01-01")
      expect(result[:variables]).to eq(translation: "eng-web", date: "2026-01-01")
    end
  end

  describe ".bible_index" do
    it "includes translation variable" do
      result = described_class.bible_index(translation: "eng-web")
      expect(result[:variables]).to eq(translation: "eng-web")
    end
  end
end
