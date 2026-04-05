# frozen_string_literal: true

module BibleQL
  class LocalizedBook < Resource
    attr_accessor :book_id, :name, :testament, :position, :chapter_count

    attr_reader :chapters

    def chapters=(list)
      @chapters = (list || []).map do |c|
        c.is_a?(Chapter) ? c : Chapter.new(c)
      end
    end
  end
end
