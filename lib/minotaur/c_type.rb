require_relative 'errors'

module Minotaur
  def self.to_ctype(node)
    if node.type == :sym
      TypeArg.new(node.children[0])
    elsif node.type == :const
      valid_label_to_type(node.children[1])
    elsif node.type == :array
      to_generic(
        Builtin::List,
        node.children)
    elsif node.type == :hash
      to_generic(
        Builtin::Dict,
        node.children[0].children)
    elsif node.type == :send and node.children[0].nil?
      PointerType.new(valid_label_to_type(node.children[1][0..-2]))
    elsif node.type == :send and node.children[1] == :[]
      if node.children[0].type == :const
        to_generic(
          valid_label_to_type(node.children[0].children[1]),
          node.children[2..-1])
      else
        PointerType.new(
          to_generic(
            valid_label_to_type(node.children[0].children[1].to_s[0..-2]),
            node.children[2..-1]))
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

  def self.to_generic(base, node_args)
    s = node_args.select { |n| n.type == :sym }.map { |n| n.children[0] }
    if s.length > 0
      GenericType.new(base, s, node_args.map(&method(:to_ctype)))
    else
      GenericInstanceType.new(base, node_args.map(&method(:to_ctype)))
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

  class GenericInstanceType < CType
    attr_reader :base
    attr_reader :type_args

    def initialize(base, type_args)
      @base = base
      @type_args = type_args
    end

    def generic?
      false
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

  class GenericType < CType
    attr_reader :label
    attr_reader :type_labels
    attr_reader :type_args

    def initialize(label, type_labels, type_args)
      @label = label
      @type_labels = type_labels
      @type_args = type_args
    end

    def generic?
      !@type_labels.empty?
    end

    def pointer?
      false
    end

    def ==(other)
      self.class == other.class && @label == other.label && @type_labels.count == other.type_labels.count &&
      @type_args.select { |t| !t.is_a?(TypeArg) } == other.type_args.select { |t| !t.is_a?(TypeArg) }
    end

    def to_c
      "M#{@label}"
    end
  end

  class TypeArg < CType
    attr_reader :label

    def initialize(label)
      @label = label.to_sym
      @instance = nil
    end

    def generic?
      true
    end

    def pointer?
      false
    end

    def ==(other)
      self.class == other.class && @label == other.label
    end

    def to_c
      "#{:@label}"
    end
  end
end
