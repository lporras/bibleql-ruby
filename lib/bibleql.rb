# frozen_string_literal: true

require_relative "bibleql/version"
require_relative "bibleql/configuration"
require_relative "bibleql/errors"
require_relative "bibleql/resource"
require_relative "bibleql/resources/verse"
require_relative "bibleql/resources/passage"
require_relative "bibleql/resources/translation"
require_relative "bibleql/resources/book"
require_relative "bibleql/resources/language"
require_relative "bibleql/resources/localized_book"
require_relative "bibleql/resources/chapter"
require_relative "bibleql/resources/search_result"
require_relative "bibleql/resources/semantic_search_result"
require_relative "bibleql/query_builder"
require_relative "bibleql/client"

module BibleQL
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def client
      Client.new
    end

    def reset!
      @configuration = Configuration.new
    end
  end
end
