module Minotaur
  class CType
    attr_reader :base
    attr_reader :type_args

    def initialize(sexp_node)
      if sexp_node.type == :const
        @base = sexp_node.children[2]
        @type_args = []
      elsif sexp_node.type == :index
        @base = sexp_node.children[0].children[2]
        @type_args = sexp_node.children[1].children.map { |c| self.class.new(c) }
      end
    end

    def generic?
      !@type_args.empty?
    end

    def to_c
      "magic"
    end
  end
end
