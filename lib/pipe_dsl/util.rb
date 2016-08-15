module PipeDsl
  module Util
    def self.stringify_keys(hsh)
      Hash[hsh.map { |k,v| [k.to_s, v] }]
    end
    def self.array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end
