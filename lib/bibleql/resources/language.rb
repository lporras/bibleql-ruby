# frozen_string_literal: true

module BibleQL
  class Language < Resource
    attr_accessor :code, :translation_count

    attr_reader :translations

    def translations=(list)
      @translations = (list || []).map do |t|
        t.is_a?(Translation) ? t : Translation.new(t)
      end
    end
  end
end
