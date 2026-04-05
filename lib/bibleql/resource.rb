# frozen_string_literal: true

module BibleQL
  class Resource
    def initialize(attributes = {})
      attributes.each do |key, value|
        setter = "#{key}="
        public_send(setter, value) if respond_to?(setter)
      end
    end

    def to_h
      instance_variables.each_with_object({}) do |ivar, hash|
        key = ivar.to_s.delete_prefix("@").to_sym
        value = instance_variable_get(ivar)
        hash[key] = value.is_a?(Resource) ? value.to_h : value
      end
    end

    def ==(other)
      other.is_a?(self.class) && to_h == other.to_h
    end

    def to_s
      "#<#{self.class.name} #{to_h.map { |k, v| "#{k}=#{v.inspect}" }.join(", ")}>"
    end

    alias inspect to_s
  end
end
