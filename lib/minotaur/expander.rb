# analyse overloaded and generic functions
# generate normal c function nodes

module Minotaur
  def self.expand_ast(ast)
    Expander.new(ast).expand
  end

  class Expander
  	def initialize(ast)
  	  @ast = ast
  	end

  	def expand
  	  # go through generic functions and core
  	  # select what is used and generate
  	end
  end
end
