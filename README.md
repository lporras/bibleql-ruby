# BibleQL Ruby

An idiomatic Ruby client for the [BibleQL](https://bibleql-rails.onrender.com) GraphQL API. Query Bible verses, passages, and translations across ~43 translations without writing GraphQL.

## Installation

Add to your Gemfile:

```ruby
gem "bibleql-ruby"
```

Then run `bundle install`, or install directly:

```
gem install bibleql-ruby
```

## Configuration

```ruby
require "bibleql"

BibleQL.configure do |config|
  config.api_key = "bql_live_..."             # required - your BibleQL API key
  config.default_translation = "spa-bes"      # optional, defaults to "eng-web"
  config.api_url = "https://custom-host.com/graphql"  # optional, defaults to production
  config.timeout = 60                         # optional, defaults to 30 seconds
end
```

## Usage

```ruby
client = BibleQL.client
# or with per-instance config:
client = BibleQL::Client.new(api_key: "bql_live_...", default_translation: "spa-bes")
```

### Passages

```ruby
passage = client.passage("John 3:16")
passage.reference       # => "John 3:16"
passage.text            # => "For God so loved the world..."
passage.verses          # => [#<BibleQL::Verse ...>]
passage.translation_id  # => "eng-web"

# With a specific translation
client.passage("Juan 3:16", translation: "spa-bes")
```

### Verses

```ruby
verse = client.verse("MAT", 5, 3)
verse.book_name  # => "Matthew"
verse.chapter    # => 5
verse.verse      # => 3
verse.text       # => "Blessed are the poor in spirit..."
```

### Chapters

```ruby
verses = client.chapter("MAT", 5)
# => [#<BibleQL::Verse ...>, ...]
```

### Random Verse

```ruby
client.random_verse
client.random_verse(testament: "NT")
client.random_verse(books: "PSA")
```

### Search

Full-text search across verses.

```ruby
results = client.search("love", limit: 5)
results.each do |verse|
  verse.book_name  # => "Genesis"
  verse.chapter    # => 22
  verse.verse      # => 2
  verse.text       # => "He said, \"Now take your son, your only son, Isaac, whom you love..."
end

# With a specific translation
results = client.search("amor", translation: "spa-bes", limit: 10)
```

### Verse of the Day

```ruby
passage = client.verse_of_the_day
passage = client.verse_of_the_day(date: "2026-01-01")
```

### Translations

```ruby
translations = client.translations
# => [#<BibleQL::Translation identifier="eng-web" ...>, ...]

translation = client.translation("eng-web")
translation.name   # => "World English Bible"
translation.books  # => [#<BibleQL::LocalizedBook ...>, ...]
```

### Languages

```ruby
languages = client.languages
languages.first.code              # => "eng"
languages.first.translation_count # => 5
languages.first.translations      # => [#<BibleQL::Translation ...>, ...]
```

### Books

```ruby
books = client.books
# => [#<BibleQL::Book book_id="GEN" name="Genesis" ...>, ...]
```

### Bible Index

```ruby
index = client.bible_index
# => [#<BibleQL::LocalizedBook ...>, ...]
index.first.chapters  # => [#<BibleQL::Chapter number=1 verse_count=31>, ...]
```

## Error Handling

```ruby
begin
  client.passage("Invalid Reference")
rescue BibleQL::NotFoundError => e
  puts "Not found: #{e.message}"
rescue BibleQL::AuthenticationError
  puts "Invalid API key"
rescue BibleQL::RateLimitError
  puts "Too many requests"
rescue BibleQL::ServerError
  puts "Server error"
rescue BibleQL::TimeoutError
  puts "Request timed out"
rescue BibleQL::ConnectionError
  puts "Connection failed"
rescue BibleQL::QueryError => e
  puts "GraphQL error: #{e.message}"
  puts e.errors  # raw error array from GraphQL
end
```

## Development

```bash
bundle install
bundle exec rspec      # run tests
bundle exec rubocop    # run linter
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
