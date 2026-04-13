# frozen_string_literal: true

module BibleQL
  class SemanticSearchResult < Resource
    attr_accessor :similarity

    attr_reader :verse

    def verse=(data)
      @verse = data.is_a?(Verse) ? data : Verse.new(data || {})
    end
  end
end
