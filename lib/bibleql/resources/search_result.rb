# frozen_string_literal: true

module BibleQL
  class SearchResult < Resource
    attr_accessor :total_count

    attr_reader :verses

    def verses=(list)
      @verses = (list || []).map do |v|
        v.is_a?(Verse) ? v : Verse.new(v)
      end
    end
  end
end
