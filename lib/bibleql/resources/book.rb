# frozen_string_literal: true

module BibleQL
  class Book < Resource
    attr_accessor :book_id, :name, :testament, :position
  end
end
