# CLAUDE.md — BibleQL Ruby Gem

## What is this project?

`bibleql-ruby` is a Ruby client gem for the BibleQL GraphQL API. It lets Ruby developers query Bible verses, passages, and translations without writing GraphQL directly.

- **Gem name**: `bibleql-ruby` (require as `bibleql`)
- **Top-level module**: `BibleQL` (capital Q, capital L)
- **HTTP client**: Faraday (~> 2.0)
- **Production API**: `https://bibleql-rails.onrender.com/graphql` (configurable, may change when domain is purchased)
- **Auth**: `Authorization: Bearer <api_key>` header on every request. API key is required.
- **Source GraphQL API**: lives at `/Users/lporras/apps/lporras/bibleql` — check there for schema changes

## Commands

```bash
bundle exec rspec          # run all tests (49 specs)
bundle exec rspec spec/bibleql/client_spec.rb  # run specific spec file
bundle exec rubocop        # lint check
bundle exec rubocop -A     # auto-fix lint issues
bundle exec rake           # runs both rspec + rubocop (default task)
```

## Architecture

```
lib/bibleql.rb                  # Entry point: BibleQL.configure, .client, .reset!
lib/bibleql/version.rb          # BibleQL::VERSION
lib/bibleql/configuration.rb    # Holds api_key, api_url, default_translation, timeout
lib/bibleql/errors.rb           # Error hierarchy (see below)
lib/bibleql/resource.rb         # Base class: to_h, ==, inspect for all resources
lib/bibleql/resources/*.rb      # Data objects: Verse, Passage, Translation, Book, Language, LocalizedBook, Chapter, SearchResult
lib/bibleql/query_builder.rb    # Module with class methods returning {query:, variables:} hashes
lib/bibleql/client.rb           # Main class: 11 public methods, each calls QueryBuilder -> execute -> map to resources
```

### Data flow for a client method

1. **Client public method** (e.g. `#passage`) resolves translation, calls `QueryBuilder.passage(...)`.
2. **QueryBuilder** returns `{ query: "...", variables: { ... } }` with hardcoded GraphQL string.
3. **Client#execute** POSTs to API via Faraday, parses JSON, checks for HTTP/GraphQL errors.
4. **Client#map_*  methods** convert camelCase JSON keys to snake_case hashes.
5. **Resource constructor** receives the hash, sets attributes via `attr_accessor`.

### Error hierarchy

```
BibleQL::Error < StandardError
  ├── ConfigurationError        # missing api_key
  ├── ConnectionError           # network failures
  │   └── TimeoutError          # request timeout
  ├── APIError (status, body)   # generic HTTP error
  │   ├── AuthenticationError   # 401
  │   ├── RateLimitError        # 429
  │   └── ServerError           # 5xx
  └── QueryError (errors array) # GraphQL errors in response
      └── NotFoundError         # "not found" in error message
```

### Naming conventions

- **GraphQL fields**: camelCase (e.g. `bookId`, `translationName`, `verseCount`)
- **Ruby attributes**: snake_case (e.g. `book_id`, `translation_name`, `verse_count`)
- **Mapping**: done in `Client#map_*` private methods (e.g. `map_verse`, `map_passage`)

## How to add a new API query

1. **Check the GraphQL schema** at `/Users/lporras/apps/lporras/bibleql/app/graphql/types/query_type.rb` for the query name, arguments, and return type.
2. **Add a method to `QueryBuilder`** (`lib/bibleql/query_builder.rb`): return `{ query: "...", variables: { ... } }`. Use camelCase in the GraphQL string.
3. **Add a public method to `Client`** (`lib/bibleql/client.rb`): call the QueryBuilder, execute, map response to resource objects. Add a `map_*` private method if the response has a new shape.
4. **Add/update Resource** if needed (`lib/bibleql/resources/`): create a new class extending `Resource` with `attr_accessor` for each field. For nested objects, define a custom setter (see `Passage#verses=`).
5. **Register the resource** in `lib/bibleql.rb` with `require_relative`.
6. **Write tests**:
   - `spec/bibleql/query_builder_spec.rb` — verify variables and query string.
   - `spec/bibleql/client_spec.rb` — stub with `stub_graphql_success(...)` helper, assert return types.
   - `spec/bibleql/resources/*_spec.rb` — if new resource, test construction and nested wrapping.

## How to add a new Resource

1. Create `lib/bibleql/resources/my_thing.rb`:
   ```ruby
   module BibleQL
     class MyThing < Resource
       attr_accessor :field_one, :field_two
     end
   end
   ```
2. For nested resources, define a custom setter:
   ```ruby
   attr_reader :items
   def items=(list)
     @items = (list || []).map { |i| i.is_a?(Item) ? i : Item.new(i) }
   end
   ```
3. Add `require_relative "bibleql/resources/my_thing"` to `lib/bibleql.rb`.

## Testing patterns

- **WebMock** blocks all real HTTP. Specs use three helpers in `client_spec.rb`:
  - `stub_graphql_success(data_hash)` — 200 with `{"data": ...}`
  - `stub_graphql_errors(errors_array)` — 200 with `{"data": null, "errors": [...]}`
  - `stub_graphql_http_error(status)` — non-200 HTTP response
- **BibleQL.reset!** is called `before(:each)` in `spec_helper.rb`.
- Client specs must pass `api_key: "test_key"` to `Client.new`.
- Use `expect_with :rspec` syntax only (no `should`).

## Style

- `frozen_string_literal: true` on every Ruby file.
- Double quotes for strings (enforced by rubocop).
- No documentation cops (Style/Documentation is disabled).
- `query_builder.rb` is exempt from MethodLength (GraphQL strings are long).
- Specs are exempt from BlockLength and LineLength.
