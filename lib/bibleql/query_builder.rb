# frozen_string_literal: true

module BibleQL
  module QueryBuilder
    module_function

    def translations
      {
        query: <<~GQL,
          query {
            translations {
              identifier
              name
              language
              note
            }
          }
        GQL
        variables: {}
      }
    end

    def translation(identifier)
      {
        query: <<~GQL,
          query($identifier: String!) {
            translation(identifier: $identifier) {
              identifier
              name
              language
              note
              books {
                bookId
                name
                testament
                position
                chapterCount
              }
            }
          }
        GQL
        variables: { identifier: identifier }
      }
    end

    def books
      {
        query: <<~GQL,
          query {
            books {
              bookId
              name
              testament
              position
            }
          }
        GQL
        variables: {}
      }
    end

    def languages
      {
        query: <<~GQL,
          query {
            languages {
              code
              translationCount
              translations {
                identifier
                name
                language
                note
              }
            }
          }
        GQL
        variables: {}
      }
    end

    def passage(reference, translation:)
      {
        query: <<~GQL,
          query($reference: String!, $translation: String) {
            passage(reference: $reference, translation: $translation) {
              reference
              translationId
              translationName
              translationNote
              text
              verses {
                bookId
                bookName
                chapter
                verse
                text
              }
            }
          }
        GQL
        variables: { reference: reference, translation: translation }
      }
    end

    def chapter(book, chapter, translation:)
      {
        query: <<~GQL,
          query($book: String!, $chapter: Int!, $translation: String) {
            chapter(book: $book, chapter: $chapter, translation: $translation) {
              bookId
              bookName
              chapter
              verse
              text
            }
          }
        GQL
        variables: { book: book, chapter: chapter, translation: translation }
      }
    end

    def verse(book, chapter, verse, translation:)
      {
        query: <<~GQL,
          query($book: String!, $chapter: Int!, $verse: Int!, $translation: String) {
            verse(book: $book, chapter: $chapter, verse: $verse, translation: $translation) {
              bookId
              bookName
              chapter
              verse
              text
            }
          }
        GQL
        variables: { book: book, chapter: chapter, verse: verse, translation: translation }
      }
    end

    def random_verse(translation:, testament: nil, books: nil)
      {
        query: <<~GQL,
          query($translation: String, $testament: String, $books: String) {
            randomVerse(translation: $translation, testament: $testament, books: $books) {
              bookId
              bookName
              chapter
              verse
              text
            }
          }
        GQL
        variables: { translation: translation, testament: testament, books: books }.compact
      }
    end

    def search(query_text, translation:, limit: nil)
      {
        query: <<~GQL,
          query($query: String!, $translation: String, $limit: Int) {
            search(query: $query, translation: $translation, limit: $limit) {
              bookId
              bookName
              chapter
              verse
              text
            }
          }
        GQL
        variables: { query: query_text, translation: translation, limit: limit }.compact
      }
    end

    def verse_of_the_day(translation:, date: nil)
      {
        query: <<~GQL,
          query($translation: String, $date: ISO8601Date) {
            verseOfTheDay(translation: $translation, date: $date) {
              reference
              translationId
              translationName
              translationNote
              text
              verses {
                bookId
                bookName
                chapter
                verse
                text
              }
            }
          }
        GQL
        variables: { translation: translation, date: date }.compact
      }
    end

    def bible_index(translation:)
      {
        query: <<~GQL,
          query($translation: String) {
            bibleIndex(translation: $translation) {
              bookId
              name
              testament
              position
              chapterCount
              chapters {
                number
                verseCount
              }
            }
          }
        GQL
        variables: { translation: translation }
      }
    end
  end
end
