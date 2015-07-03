module PipeDsl
  module Utils
    #left wins merge! (merge! is right-wins)
    # @see File activesupport/lib/active_support/core_ext/hash/reverse_merge.rb
    def self.defaults_merge!(hash, other_hash)
      # right wins if there is no left
      hash.merge!(other_hash) { |key,left,right| left }
    end
  end
end
