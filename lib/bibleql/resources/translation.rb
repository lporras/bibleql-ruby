# frozen_string_literal: true

module BibleQL
  class Translation < Resource
    attr_accessor :identifier, :name, :language, :note

    attr_reader :books

    def books=(list)
      @books = (list || []).map do |b|
        b.is_a?(LocalizedBook) ? b : LocalizedBook.new(b)
      end
    end
  end
end
