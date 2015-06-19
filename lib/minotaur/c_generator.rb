# go through ast
# generate c

module Minotaur
  def self.generate_c(ast)
    CGenerator.new(ast).generate
  end

  class Generator
    def lparen
      @out << '('
    end

    def dot
      @out << '.'
    end

    def nl
      @out << "\n"
    end

    def rparen
      @out << ')'
    end

    def ws
      @out << ' '
    end
  end

  class CGenerator < Generator
    def initialize(ast)
      @ast = ast
      @out = []
    end

    def generate
      write @ast
      @out.join
    end

    def offset(depth)
      @out << '    ' * depth
    end

    def semi
      @out << ';'
    end

    def comma
      @out << ','
    end

    def write(node, depth = 0, parens: false)
      if parens == :maybe
        q = node.c_type.pointer?
      else
        q = parens
      end
      lparen if q
      offset(depth)
      send :"generate_#{node.kind}", node, depth
      s(')') if q
    end

    def s(string)
      @out << string
    end

    def generate_attr(node, depth = 0)
      write node.receiver, parens: :maybe
      dot
      write node.attr
    end

    def generate_pointer_attr(node, depth = 0)
      write node.receiver, parens: :maybe
      s '->'
      write node.attr
    end

    def generate_module(node, depth = 0)
      p node.node_fields
      p node.includes
      generate_includes(node.includes)
      nl
      generate_types(node.types)
      nl
      generate_functions(node.functions)
      nl
    end

    def generate_includes(includes, depth = 0)
      includes.each do |inc|
        if inc.kind == :include
          s "#include<#{inc.lib}>"
        else
          s "#include \"#{inc.file}\""
        end
        nl
      end
    end

    def generate_types(types, depth = 0)
      types.each do |type|
        write type
        nl
      end
    end

    def generate_functions(functions, depth = 0)
      functions.each do |function|
        generate_function function
        nl
      end
    end

    def generate_struct(node, depth = 0)
      s "typedef struct #{node.label} {"
      nl
      node.fields[0...-1].each do |field|
        write field, depth + 1
        comma
        nl
      end
      write node.fields.last, depth + 1
      nl
      s "} #{node.label};"
    end

    def generate_function(node, depth = 0)
      write_ctype node.return_type
      ws
      s node.label
      lparen
      node.args[0...-1].each { |arg| write arg; comma; ws }
      write(node.args.last) if node.args.last
      rparen
      s "{\n"
      node.body[0...-1].each { |child| write child, depth + 1; semi; nl }
      unless node.return_type == Builtin::Void || node.label == :main || node.body.empty?
        offset(depth + 1)
        s 'return '
        write node.body.last
        semi
        nl
      else
        if !node.body.empty?
          write node.body.last, depth + 1
          semi
          nl
        end
      end

      offset(depth)
      s "}\n"
    end

    def generate_field_assignment(node, depth = 0)
      s 'self->'
      s node.label
      s ' = '
      write node.value
    end

    def generate_arg(node, depth = 0)
      write_ctype node.c_type
      ws
      s node.label
    end

    def generate_type_declaration(node, depth = 0)
      write_ctype node.c_type
      ws
      s node.label
    end

    def generate_int(node, depth = 0)
      s node.value.to_s
    end

    def generate_uint(node, depth = 0)
      s node.value.to_s
    end

    def generate_binary_math(node, depth = 0)
      write node.left
      s " #{node.op} "
      write node.right
    end

    def generate_binary_compare(node, depth = 0)
      write node.left
      s " #{node.op} "
      write node.right
    end

    def generate_string(node, depth = 0)
      s "MString_new(\"#{node.value}\")"
    end

    def generate_ident(node, depth = 0)
      s node.label.to_s
    end

    def generate_call(node, depth = 0)
      write node.callee
      lparen
      node.args[0...-1].map { |z| write z; coma; ws }
      write node.args.last unless node.args.empty?
      rparen
    end

    def write_ctype(ctype, depth = 0)
      if ctype.pointer?
        write_ctype ctype.base
        s '*'
      else
        s ctype.to_c
      end
    end

    def generate_null(node, depth = 0)
      s 'NULL'
    end
  end
end
