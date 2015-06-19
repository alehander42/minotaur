# infer types and annotate
# minotaur ast

module Minotaur
  def self.type_analyze(ast)
    TypeAnalyser.new(ast).analyze
  end

  class TypeAnalyser
    def initialize(ast)
      @ast = ast
      @structs = {}
      @functions = {main: {overloads: [{argc: Builtin::Size, argv: Builtin::CharPtr}], _c_type: [Builtin::Int]}}
      @instances = {}
      @current_function = @functions[:main][:overloads][-1]
    end

    def analyze
      analyze_node(@ast)
      {ast: @ast, functions: @functions, instances: @instances}
      # go through all
      # infer and annotate
    end

    def analyze_node(node)
      send :"analyze_#{node.kind}", node
    end

    def analyze_program(node)
      node.children.each(&method(:analyze_node))
    end

    def analyze_class(node)
      @structs[node.label] = Hash[node.fields.map { |f| [f.label, f.c_type] }]
    end

    def analyze_function(node)
      c_type = GenericInstanceType.new(Builtin::Function, node.args.map(&:c_type) + [node.return_type])

      if @functions.key?(node.label) #overload
        @functions[node.label].overloads << {}
        @current_function = @functions[node.label].overloads[-1]
        current_type = @functions[node.label][:_c_type]
        c_type = VariantType.new(current_type, c_type)
      else
        @functions[node.label] = {_c_type: c_type, overloads: [{}]}
        @current_function = @functions[node.label].overloads[-1]
      end
      node.args.each { |a| @current_function[a.label] = a.c_type }
      node.body.each(&method(:analyze_node))
      node.c_type = c_type
    end

    def analyze_type_declaration(node)
      if @current_function.key?(node.label)
        expect_type(@current_function[node.label], node.decl_type)
      else
        @current_function[node.label] = node.decl_type
      end
      node.c_type = node.decl_type
    end

    # y.z
    # y is not a pointer y.z
    # y is a pointer y->z
    def analyze_attr(node)
      analyze_type(node.receiver)

      analyze_type(node.attr)
      if node.receiver.c_type.pointer?
        s = @structs[node.receiver.c_type.base.label.to_sym]
        kind = :pointer_attr
        p_type = node.receiver.c_type
      else
        s = @structs[node.receiver.c_type.label.to_sym]
        kind = :attr
        p_type = Pointer.new(node.receiver.c_type)
      end
      if s.key?(node.attr)
        node.c_type = s[node.attr]
        node.kind = kind
      else
        f_type = @functions[node.attr][:_c_type]
        expect_type(p_type, f_type.type_args.first)
        node.kind = :call
        node.callee = n(:ident, c_type: f_type, label: node.attr,)
        node.receiver.c_type = p_type
        node.args = [node.receiver]
        node.c_type = f_type.type_args.last
      end
    end

    def analyze_assignment(node)
      analyze_node(node.value)
      if @current_function.key?(node.target)
        assert @current_function[node.target] == node.value.c_type
      else
        @current_function[node.target] = node.value.c_type
      end
      node.c_type = node.value.c_type
    end

    def analyze_int(node)
      node.c_type = Builtin::Int
    end

    def analyze_uint(node)
      node.c_type = Builtin::UInt
    end

    def analyze_str(node)
      node.c_type = Builtin::CString
    end

    def analyze_until(node)
      analyze_while(node)
    end

    def analyze_while(node)
      node.c_type = Builtin::Void
      analyze_node(node.test)
      analyze_seq(node.body)
    end

    def analyze_unless(node)
      analyze_if(node)
    end

    def analyze_if(node)
      analyze_node(node.test)
      analyze_seq(node.body)
      if node.otherwise
        analyze_seq(node.otherwise_body)
      end
      node.c_type = node.otherwise_body[-1].c_type
    end

    def analyze_index(node)
      analyze_node(node.sequence)
      analyze_node(node.index)
      if node.sequence.c_type.base == Builtin::Dict
        expect_type(node.sequence.c_type.type_args[0], node.index.c_type)
        node.c_type = node.sequence.c_type.type_args[1]
      elsif node.sequence.c_type.base == Builtin::List
        expect_type(Builtin::UInt, node.index.c_type)
        node.c_type = node.sequence.c_type.type_args[0]
      else
        raise TypeError.new("#{node.sequence.c_type} doesn't support index")
      end
    end

    def analyze_call(node)
      analyze_node(node.callee)
      analyze_seq(node.args)
      if node.callee.c_type.base == Builtin::Function
        node.callee.c_type.type_args.zip(node.args).each do |t, arg|
          expect_type(t, arg)
        end
      else
        raise TypeError.new("#{node.callee.c_type} doesn't support call")
      end
    end

    def analyze_seq(list)
      list.map(&method(:analyze_node))
    end

    def analyze_ident(node)
      if @current_function.key?(node.label)
        node.c_type = @current_function[node.label]
      elsif @functions.key?(node.label)
        node.c_type = @functions[node.label][:_c_type]
      else
        raise TypeError.new("unknown type for #{node.label}")
      end
    end

    def analyze_binary_math(node)
      analyze_node(node.left)
      analyze_node(node.right)
      expect_type(node.left.c_type, node.right.c_type)
      expect_type_in(node.left.c_type, [Builtin::Int, Builtin::String, Builtin::List])
      node.c_type = node.left.c_type
    end

    def analyze_binary_logic(node)
      analyze_node(node.left)
      analyze_node(node.right)
      expect_type(Builtin::Bool, node.left.c_type)
      expect_type(Builtin::Bool, node.right.c_type)
      node.c_type = Builtin::Bool
    end

    def analyze_list(node)
      analyze_seq(node.items)
      element_type = node.items[0].c_type
      node.items[1..-1].each do |c|
        expect_type(element_type, c.c_type)
      end
      node.c_type = GenericInstanceType.new(Builtin::List, [element_type])
    end

    def expect_type(expected, given)
      if expected == Builtin::UInt
        if Builtin::UINT_TYPES.include?(given)
          return true
        end
      elsif expected == Builtin::Int
        if Builtin::ALL_INT_TYPES.include?(given)
          return true
        end
      else
        if expected == given
          return true
        end
      end
      raise TypeError.new("expected #{expected.to_c} got #{given.to_c}")
    end
  end
end

