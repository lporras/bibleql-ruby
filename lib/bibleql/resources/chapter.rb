# frozen_string_literal: true

module BibleQL
  class Chapter < Resource
    attr_accessor :number, :verse_count

    attr_reader :verses

    def verses=(list)
      @verses = (list || []).map do |v|
        v.is_a?(Verse) ? v : Verse.new(v)
      end
    end
  end
end
