require_relative 'errors'

module Minotaur
  def self.to_ctype(node)
    if node.type == :const
      valid_label_to_type(node.children[1])
    elsif node.type == :send and node.children[0].nil?
      PointerType.new(valid_label_to_type(node.children[1][0..-2]))
    elsif node.type == :send and node.children[1] == :[]
      if node.children[0].type == :const
        GenericType.new(to_ctype(node.children[0]), node.children[2..-1].map(&method(:to_ctype)))
      else
        PointerType.new(
          GenericType.new(
            valid_label_to_type(node.children[0].children[1].to_s[0..-2]),
            node.children[2..-1].map(&method(:to_ctype))))
      end
    else
      raise CTypeError.new("Invalid ast node for c type #{node.inspect}")
    end
  end

  def self.valid_label_to_type(label)
    if label[0..2] == 'Int' || label[0..3] == 'UInt' || ['Size', 'Bool', 'List', 'Dict'].include?(label.to_s)
      Builtin::const_get(label.to_sym)
    else
      BaseType.new(label.to_sym)
    end
  end

  class CType
    def generic?
      false
    end

    def pointer?
      false
    end
  end

  class BaseType < CType
    attr_reader :label, :special_c

    def initialize(label, special_c=nil)
      @label = label
      @special_c = (special_c || label).to_s
    end

    def generic?
      false
    end

    def pointer?
      false
    end

    def ==(other)
      self.class == other.class && @label == other.label && @special_c == other.special_c
    end

    def to_c
      "#{@special_c}"
    end
  end

  class PointerType < CType
    attr_reader :base

    def initialize(base)
      @base = base
    end

    def generic?
      @base.generic?
    end

    def pointer?
      true
    end

    def ==(other)
      self.class == other.class && @base == other.base
    end

    def to_c
      "#{@base.to_c}*"
    end
  end

  class GenericType < CType
    attr_reader :base
    attr_reader :type_args

    def initialize(base, type_args)
      @base = base
      @type_args = type_args
    end

    def generic?
      !@type_args.empty?
    end

    def pointer?
      false
    end

    def ==(other)
      self.class == other.class && @base == other.base && @type_args == other.type_args
    end

    def to_c
      "#{@base.to_c}_#{@type_args.map(&:to_c).join '_'}"
    end
  end
end
