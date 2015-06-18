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
    
    def write(node, parens: false)
      if parens == :maybe
        q = node.c_type.pointer?
      else
        q = parens
      end
      lparen if q
      send :"generate_#{node.kind}", node
      s(')') if q
    end
    
    def s(string)
      @out << string
    end
    
    def generate_attr(node)
      write node.receiver, parens: :maybe
      dot
      write node.attr
    end
    
    def generate_pointer_attr(node)
      write node.receiver, parens: :maybe
      s '->'
      write node.attr
    end
    
  end
end
