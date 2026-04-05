# frozen_string_literal: true

require "faraday"
require "json"

module BibleQL
  class Client
    def initialize(api_key: nil, default_translation: nil, api_url: nil, timeout: nil)
      config = BibleQL.configuration
      @api_key = api_key || config.api_key
      @default_translation = default_translation || config.default_translation
      @api_url = api_url || config.api_url
      @timeout = timeout || config.timeout

      raise ConfigurationError, "api_key is required. Set it via BibleQL.configure or pass it to Client.new" unless @api_key

      @connection = Faraday.new(url: @api_url) do |f|
        f.options.timeout = @timeout
        f.options.open_timeout = @timeout
        f.headers["Content-Type"] = "application/json"
        f.headers["Authorization"] = "Bearer #{@api_key}"
      end
    end

    def translations
      data = execute(QueryBuilder.translations, "translations")
      data["translations"].map { |t| Translation.new(map_translation(t)) }
    end

    def translation(identifier)
      data = execute(QueryBuilder.translation(identifier), "translation")
      Translation.new(map_translation(data["translation"]))
    end

    def books
      data = execute(QueryBuilder.books, "books")
      data["books"].map { |b| Book.new(map_book(b)) }
    end

    def languages
      data = execute(QueryBuilder.languages, "languages")
      data["languages"].map { |l| Language.new(map_language(l)) }
    end

    def passage(reference, translation: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.passage(reference, translation: t), "passage")
      Passage.new(map_passage(data["passage"]))
    end

    def chapter(book, chapter_num, translation: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.chapter(book, chapter_num, translation: t), "chapter")
      data["chapter"].map { |v| Verse.new(map_verse(v)) }
    end

    def verse(book, chapter_num, verse_num, translation: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.verse(book, chapter_num, verse_num, translation: t), "verse")
      Verse.new(map_verse(data["verse"]))
    end

    def random_verse(translation: nil, testament: nil, books: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.random_verse(translation: t, testament: testament, books: books), "randomVerse")
      Verse.new(map_verse(data["randomVerse"]))
    end

    def search(query_text, translation: nil, limit: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.search(query_text, translation: t, limit: limit), "search")
      data["search"].map { |v| Verse.new(map_verse(v)) }
    end

    def verse_of_the_day(translation: nil, date: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.verse_of_the_day(translation: t, date: date), "verseOfTheDay")
      Passage.new(map_passage(data["verseOfTheDay"]))
    end

    def bible_index(translation: nil)
      t = translation || @default_translation
      data = execute(QueryBuilder.bible_index(translation: t), "bibleIndex")
      data["bibleIndex"].map { |b| LocalizedBook.new(map_localized_book(b)) }
    end

    private

    def execute(query_hash, _query_name)
      response = @connection.post do |req|
        req.body = JSON.generate(query: query_hash[:query], variables: query_hash[:variables])
      end

      handle_http_errors(response)

      body = JSON.parse(response.body)

      handle_graphql_errors(body["errors"]) if body["errors"] && !body["errors"].empty?

      body["data"]
    rescue Faraday::TimeoutError => e
      raise TimeoutError, "Request timed out: #{e.message}"
    rescue Faraday::ConnectionFailed, Faraday::Error => e
      raise ConnectionError, "Connection failed: #{e.message}"
    end

    def handle_http_errors(response)
      return if response.status >= 200 && response.status < 300

      message = "HTTP #{response.status}"
      case response.status
      when 401
        raise AuthenticationError.new(message, status: response.status, body: response.body)
      when 429
        raise RateLimitError.new(message, status: response.status, body: response.body)
      when 500..599
        raise ServerError.new(message, status: response.status, body: response.body)
      else
        raise APIError.new(message, status: response.status, body: response.body)
      end
    end

    def handle_graphql_errors(errors)
      messages = errors.map { |e| e["message"] }
      full_message = messages.join("; ")

      raise NotFoundError.new(full_message, errors: errors) if messages.any? { |m| m.downcase.include?("not found") }

      raise QueryError.new(full_message, errors: errors)
    end

    def map_verse(data)
      {
        book_id: data["bookId"],
        book_name: data["bookName"],
        chapter: data["chapter"],
        verse: data["verse"],
        text: data["text"]
      }
    end

    def map_passage(data)
      {
        reference: data["reference"],
        translation_id: data["translationId"],
        translation_name: data["translationName"],
        translation_note: data["translationNote"],
        text: data["text"],
        verses: (data["verses"] || []).map { |v| map_verse(v) }
      }
    end

    def map_translation(data)
      result = {
        identifier: data["identifier"],
        name: data["name"],
        language: data["language"],
        note: data["note"]
      }
      result[:books] = data["books"].map { |b| map_localized_book(b) } if data["books"]
      result
    end

    def map_book(data)
      {
        book_id: data["bookId"],
        name: data["name"],
        testament: data["testament"],
        position: data["position"]
      }
    end

    def map_language(data)
      {
        code: data["code"],
        translation_count: data["translationCount"],
        translations: (data["translations"] || []).map { |t| map_translation(t) }
      }
    end

    def map_localized_book(data)
      result = {
        book_id: data["bookId"],
        name: data["name"],
        testament: data["testament"],
        position: data["position"],
        chapter_count: data["chapterCount"]
      }
      result[:chapters] = data["chapters"].map { |c| map_chapter(c) } if data["chapters"]
      result
    end

    def map_chapter(data)
      result = {
        number: data["number"],
        verse_count: data["verseCount"]
      }
      result[:verses] = data["verses"].map { |v| map_verse(v) } if data["verses"]
      result
    end
  end
end
