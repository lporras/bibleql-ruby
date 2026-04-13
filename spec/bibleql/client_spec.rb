# frozen_string_literal: true

RSpec.describe BibleQL::Client do
  let(:api_url) { "https://bibleql-rails.onrender.com/graphql" }
  let(:client) { described_class.new(api_key: "test_key") }

  def stub_graphql_success(data)
    body = { "data" => data }
    stub_request(:post, api_url)
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end

  def stub_graphql_errors(errors)
    body = { "data" => nil, "errors" => errors }
    stub_request(:post, api_url)
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end

  def stub_graphql_http_error(status)
    stub_request(:post, api_url)
      .to_return(status: status, body: "error", headers: { "Content-Type" => "text/plain" })
  end

  describe "#translations" do
    it "returns an array of Translation objects" do
      stub_graphql_success("translations" => [
                             { "identifier" => "eng-web", "name" => "World English Bible", "language" => "eng", "note" => nil }
                           ])

      result = client.translations
      expect(result).to all(be_a(BibleQL::Translation))
      expect(result.first.identifier).to eq("eng-web")
    end
  end

  describe "#translation" do
    it "returns a Translation object with books" do
      stub_graphql_success("translation" => {
                             "identifier" => "eng-web", "name" => "World English Bible", "language" => "eng", "note" => nil,
                             "books" => [{ "bookId" => "GEN", "name" => "Genesis", "testament" => "OT", "position" => 1, "chapterCount" => 50 }]
                           })

      result = client.translation("eng-web")
      expect(result).to be_a(BibleQL::Translation)
      expect(result.books.first).to be_a(BibleQL::LocalizedBook)
    end
  end

  describe "#books" do
    it "returns an array of Book objects" do
      stub_graphql_success("books" => [
                             { "bookId" => "GEN", "name" => "Genesis", "testament" => "OT", "position" => 1 }
                           ])

      result = client.books
      expect(result).to all(be_a(BibleQL::Book))
      expect(result.first.name).to eq("Genesis")
    end
  end

  describe "#languages" do
    it "returns an array of Language objects" do
      stub_graphql_success("languages" => [
                             { "code" => "eng", "translationCount" => 5, "translations" => [
                               { "identifier" => "eng-web", "name" => "World English Bible", "language" => "eng", "note" => nil }
                             ] }
                           ])

      result = client.languages
      expect(result).to all(be_a(BibleQL::Language))
      expect(result.first.translations.first).to be_a(BibleQL::Translation)
    end
  end

  describe "#passage" do
    it "returns a Passage object" do
      stub_graphql_success("passage" => {
                             "reference" => "John 3:16", "translationId" => "eng-web", "translationName" => "World English Bible",
                             "translationNote" => nil, "text" => "For God so loved...",
                             "verses" => [{ "bookId" => "JHN", "bookName" => "John", "chapter" => 3, "verse" => 16, "text" => "For God so loved..." }]
                           })

      result = client.passage("John 3:16")
      expect(result).to be_a(BibleQL::Passage)
      expect(result.reference).to eq("John 3:16")
      expect(result.verses.first).to be_a(BibleQL::Verse)
    end

    it "uses the provided translation" do
      stub = stub_graphql_success("passage" => {
                                    "reference" => "Juan 3:16", "translationId" => "spa-bes", "translationName" => "Biblia en Español",
                                    "translationNote" => nil, "text" => "Porque de tal manera...",
                                    "verses" => [{ "bookId" => "JHN", "bookName" => "Juan", "chapter" => 3, "verse" => 16, "text" => "Porque de tal manera..." }]
                                  })

      result = client.passage("Juan 3:16", translation: "spa-bes")
      expect(result.translation_id).to eq("spa-bes")
      expect(stub).to have_been_requested
    end
  end

  describe "#chapter" do
    it "returns an array of Verse objects" do
      stub_graphql_success("chapter" => [
                             { "bookId" => "MAT", "bookName" => "Matthew", "chapter" => 5, "verse" => 1, "text" => "Seeing the multitudes..." },
                             { "bookId" => "MAT", "bookName" => "Matthew", "chapter" => 5, "verse" => 2, "text" => "He opened his mouth..." }
                           ])

      result = client.chapter("MAT", 5)
      expect(result).to all(be_a(BibleQL::Verse))
      expect(result.length).to eq(2)
    end
  end

  describe "#verse" do
    it "returns a Verse object" do
      stub_graphql_success("verse" => {
                             "bookId" => "MAT", "bookName" => "Matthew", "chapter" => 5, "verse" => 3, "text" => "Blessed are the poor..."
                           })

      result = client.verse("MAT", 5, 3)
      expect(result).to be_a(BibleQL::Verse)
      expect(result.text).to eq("Blessed are the poor...")
    end
  end

  describe "#random_verse" do
    it "returns a Verse object" do
      stub_graphql_success("randomVerse" => {
                             "bookId" => "PSA", "bookName" => "Psalms", "chapter" => 23, "verse" => 1, "text" => "The LORD is my shepherd..."
                           })

      result = client.random_verse
      expect(result).to be_a(BibleQL::Verse)
    end
  end

  describe "#search" do
    it "returns an array of Verse objects" do
      stub_graphql_success("search" => [
                             { "bookId" => "JHN", "bookName" => "John", "chapter" => 3, "verse" => 16, "text" => "For God so loved..." }
                           ])

      result = client.search("love", limit: 10)
      expect(result).to all(be_a(BibleQL::Verse))
    end
  end

  describe "#semantic_search" do
    it "returns an array of SemanticSearchResult objects" do
      stub_graphql_success("semanticSearch" => [
                             { "verse" => { "bookId" => "JHN", "bookName" => "John", "chapter" => 3, "verse" => 16,
                                            "text" => "For God so loved..." },
                               "similarity" => 0.95 }
                           ])

      result = client.semantic_search("love and forgiveness", limit: 5)
      expect(result).to all(be_a(BibleQL::SemanticSearchResult))
      expect(result.first.similarity).to eq(0.95)
      expect(result.first.verse).to be_a(BibleQL::Verse)
      expect(result.first.verse.book_id).to eq("JHN")
      expect(result.first.verse.text).to eq("For God so loved...")
    end

    it "uses the provided translation" do
      stub = stub_graphql_success("semanticSearch" => [
                                    { "verse" => { "bookId" => "JHN", "bookName" => "Juan", "chapter" => 3, "verse" => 16,
                                                   "text" => "Porque de tal manera..." },
                                      "similarity" => 0.92 }
                                  ])

      result = client.semantic_search("amor y perdon", translation: "spa-rv1909")
      expect(result.first.verse.book_name).to eq("Juan")
      expect(stub).to have_been_requested
    end
  end

  describe "#verse_of_the_day" do
    it "returns a Passage object" do
      stub_graphql_success("verseOfTheDay" => {
                             "reference" => "Psalm 23:1", "translationId" => "eng-web", "translationName" => "World English Bible",
                             "translationNote" => nil, "text" => "The LORD is my shepherd...",
                             "verses" => [{ "bookId" => "PSA", "bookName" => "Psalms", "chapter" => 23, "verse" => 1, "text" => "The LORD is my shepherd..." }]
                           })

      result = client.verse_of_the_day
      expect(result).to be_a(BibleQL::Passage)
    end
  end

  describe "#bible_index" do
    it "returns an array of LocalizedBook objects" do
      stub_graphql_success("bibleIndex" => [
                             { "bookId" => "GEN", "name" => "Genesis", "testament" => "OT", "position" => 1, "chapterCount" => 50,
                               "chapters" => [{ "number" => 1, "verseCount" => 31 }] }
                           ])

      result = client.bible_index
      expect(result).to all(be_a(BibleQL::LocalizedBook))
      expect(result.first.chapters.first).to be_a(BibleQL::Chapter)
    end
  end

  describe "error handling" do
    it "raises ConfigurationError when api_key is missing" do
      BibleQL.reset!
      expect { described_class.new }.to raise_error(BibleQL::ConfigurationError, /api_key is required/)
    end

    it "raises AuthenticationError on 401" do
      stub_graphql_http_error(401)
      expect { client.translations }.to raise_error(BibleQL::AuthenticationError)
    end

    it "raises RateLimitError on 429" do
      stub_graphql_http_error(429)
      expect { client.translations }.to raise_error(BibleQL::RateLimitError)
    end

    it "raises ServerError on 500" do
      stub_graphql_http_error(500)
      expect { client.translations }.to raise_error(BibleQL::ServerError)
    end

    it "raises QueryError on GraphQL errors" do
      stub_graphql_errors([{ "message" => "Something went wrong" }])
      expect { client.translations }.to raise_error(BibleQL::QueryError, "Something went wrong")
    end

    it "raises NotFoundError when error contains 'not found'" do
      stub_graphql_errors([{ "message" => "Translation not found" }])
      expect { client.translations }.to raise_error(BibleQL::NotFoundError)
    end

    it "raises ConnectionError on timeout" do
      stub_request(:post, api_url).to_timeout
      expect { client.translations }.to raise_error(BibleQL::ConnectionError)
    end

    it "raises ConnectionError on connection failure" do
      stub_request(:post, api_url).to_raise(Faraday::ConnectionFailed.new("connection refused"))
      expect { client.translations }.to raise_error(BibleQL::ConnectionError)
    end
  end
end
