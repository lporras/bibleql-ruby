# frozen_string_literal: true

module BibleQL
  class Verse < Resource
    attr_accessor :book_id, :book_name, :chapter, :verse, :text
  end
end
