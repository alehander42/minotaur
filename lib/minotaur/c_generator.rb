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
      '    ' * depth
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
      node.fields.each do |field|
        generate field, depth + 1
      end
      s "} #{node.label};"
    end
  end
end
