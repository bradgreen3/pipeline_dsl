module PipeDsl
  module Util
    def self.stringify_keys(hsh)
      Hash[hsh.map { |k,v| [k.to_s, v] }]
    end
  end
end
