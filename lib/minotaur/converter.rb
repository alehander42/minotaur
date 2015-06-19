# converts from parser's s-expr representation to
# minotaur's ast representation

require 'parser'
require_relative 'ast'
require_relative 'c_type'

module Minotaur

  OPERATORS = {
    :+  =>  :binary_math,
    :-  =>  :binary_math,
    :*  =>  :binary_math,
    :/  =>  :binary_math,
    :>  =>  :binary_compare,
    :<  =>  :binary_compare,
    :>= =>  :binary_compare,
    :<= =>  :binary_compare
  }

  def self.convert_ast(ast)
    Converter.new.convert(ast)
  end

  class Converter
    def convert(ast)
      n(:program, children: convert_body(ast))
    end

    def convert_node(node)
      send :"convert_#{node.type}", node
    end

    def convert_body(node)
      if node.type == :begin
        convert_begin(node)
      else
        [convert_node(node)]
      end.flatten
    end

    def convert_begin(node)
      node.children.map(&method(:convert_node))
    end

    def convert_class(node)
      b = node.children[2].type == :begin ? node.children[2].children : [node.children[2]]
      m = b.find_index { |c| c.type == :def } || b.length
      fields, methods = b[0..m - 1], b[m..-1]
      [n(:struct,
        label: node.children[0].children[1],
        fields: fields.map(&method(:convert_field)))] +
      methods.map { |m| convert_def(m, klass: node.children[0]) }
    end

    def convert_field(node)
      p node
      n(:type_declaration,
        label: node.children[1],
        c_type: to_ctype(node.children[2]))
    end

    def convert_int(node)
      kind = node.children.first >= 0 ? :uint : :int
      n(kind, value: node.children.first)
    end

    def convert_str(node)
      n(:string, value: node.children.first)
    end

    # def label(arg: Arg) Result
    #  2; end
    def convert_def(node, klass: nil)
      label = node.children.first
      self_args = klass ? [n(:arg, label: :self, c_type: PointerType.new(to_ctype(klass)))] : []
      args = node.children[1].children.map { |arg| n(:arg, label: arg.children.first, c_type: to_ctype(arg.children[1])) }
      body = node.children[2].type == :begin ? node.children[2].children : [node.children[2]]
      if node.loc.line == body[0].loc.line
        return_type, body = to_ctype(body[0]), convert_seq(body[1..-1])
      else
        return_type, body = Builtin::Void, convert_seq(body)
      end
      n(:function, label: label, args: self_args + args, return_type: return_type, body: body)
    end

    def convert_seq(nodes)
      nodes.map(&method(:convert_node))
    end

    def convert_send(node)
      # a 2
      # a UInt
      if node.type == :send && node.children.first.nil?
        arg = convert_node(node.children[2])
        if arg.kind == :type
          n(:type_declaration, label: node.children[1], c_type: arg.c_type)
        else
          n(:call, callee: n(:ident, label: node.children[1]),
             args: [arg] + node.children[3..-1].map(&method(:convert_node)))
        end
      # e.a 2
      else
        if node.children.count == 2
          n(:attr, receiver: node.children.first.first, attr: node.children[1])
        elsif OPERATORS.key?(node.children[1])
          n(OPERATORS[node.children[1]],
                        left: convert_node(node.children[0]),
                        right: convert_node(node.children[2]),
                        op: node.children[1])
        else
          n(:call, callee: n(:ident, label: node.children[1]),
             args: ([node.children[0]] + node.children[2..-1]).map(&method(:convert_node)))
        end
      end
    end

    def convert_and(node)
      n(:binary_logic,
            left: convert_node(node.children[0]),
            right: convert_node(node.children[1]),
            op: :and)
    end

    def convert_or(node)
      n(:binary_logic,
            left: convert_node(node.children[0]),
            right: convert_node(node.children[1]),
            op: :or)
    end

    def convert_ivasgn(node)
      n(:field_assignment,
        label: node.children.first[1..-1].to_sym,
        value: convert_node(node.children.last))
    end

    def convert_lvar(node)
      n(:ident, label: node.children.first)
    end

    def convert_ivar(node)
      n(:field, label: node.children.first[1..-1].to_sym)
    end

    def convert_nil(node)
      n(:null)
    end

    def n(kind, **kwargs)
      Minotaur::n(kind, **kwargs)
    end

    def to_ctype(node)
      Minotaur::to_ctype(node)
    end
  end
end


