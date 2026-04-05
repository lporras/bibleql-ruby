# frozen_string_literal: true

module BibleQL
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ConnectionError < Error; end

  class TimeoutError < ConnectionError; end

  class APIError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body = body
      super(message)
    end
  end

  class AuthenticationError < APIError; end

  class RateLimitError < APIError; end

  class ServerError < APIError; end

  class QueryError < Error
    attr_reader :errors

    def initialize(message = nil, errors: [])
      @errors = errors
      super(message)
    end
  end

  class NotFoundError < QueryError; end
end
