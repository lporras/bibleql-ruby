# frozen_string_literal: true

require_relative "lib/bibleql/version"

Gem::Specification.new do |spec|
  spec.name = "bibleql-ruby"
  spec.version = BibleQL::VERSION
  spec.authors = ["Luis Porras"]
  spec.email = ["lporras16@gmail.com"]

  spec.summary = "Ruby client for the BibleQL GraphQL API"
  spec.description = "An idiomatic Ruby client for querying Bible verses, passages, and translations via the BibleQL GraphQL API."
  spec.homepage = "https://github.com/lporras/bibleql-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lporras/bibleql-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/lporras/bibleql-ruby/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
end
