# frozen_string_literal: true

module BibleQL
  class Passage < Resource
    attr_accessor :reference, :translation_id, :translation_name, :translation_note, :text

    attr_reader :verses

    def verses=(list)
      @verses = (list || []).map do |v|
        v.is_a?(Verse) ? v : Verse.new(v)
      end
    end
  end
end
