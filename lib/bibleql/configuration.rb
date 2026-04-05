# frozen_string_literal: true

module BibleQL
  class Configuration
    attr_accessor :api_key, :api_url, :default_translation, :timeout

    DEFAULT_API_URL = "https://bibleql-rails.onrender.com/graphql"
    DEFAULT_TRANSLATION = "eng-web"
    DEFAULT_TIMEOUT = 30

    def initialize
      @api_key = nil
      @api_url = DEFAULT_API_URL
      @default_translation = DEFAULT_TRANSLATION
      @timeout = DEFAULT_TIMEOUT
    end
  end
end
