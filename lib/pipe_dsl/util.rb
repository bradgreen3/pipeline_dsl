module PipeDsl

  #generic utilities, mostly cribbed from ActiveSupport
  module Util

    #convert hash keys to strings
    # @param [Hash] hsh input
    # @return [Hash] string keyed hash
    def self.stringify_keys(hsh)
      Hash[hsh.map { |k, v| [k.to_s, v] }]
    end

    #wrap an object in an array if not already an array
    # @param [Object] object
    # @return [Array] array of objects
    def self.array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end

    #to allow use of '#{}' replacements in the definition output, but not conflict with ruby
    # interpolation, allow %{} instead
    # @param [String] input
    # @return [String] unescaped output
    def self.unescape_string_value(str)
      str.to_s.gsub('%{'.freeze, '#{'.freeze)
    end

    #camel-case a downcased string
    # @param [Object] term
    # @return [String] inflected string
    def self.camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/, &:capitalize)
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      string.gsub!('/'.freeze, '::'.freeze)
      string
    end

    #remove all but the last part of a namespace
    # @param [String] path
    # @return [String] inflected string
    def self.demodulize(path)
      path = path.to_s
      if (i = path.rindex('::'.freeze))
        path[(i + 2)..-1]
      else
        path
      end
    end

    #get all descendants of a class
    # @param [Class] klass
    # @return [Array] classes that descend
    def self.descendants(klass)
      ObjectSpace.each_object(klass.singleton_class).select { |k| k < klass }
    end

    #convert camel to underscore/snake
    # @param [String] camel_cased_word
    # @return [String] snake_case word
    def self.underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub('::'.freeze, '/'.freeze)
      # word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'.freeze }#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
      word.tr!("-".freeze, "_".freeze)
      word.downcase!
      word
    end

  end
end
