# infer types and annotate
# minotaur ast

module Minotaur
  def self.type_analyse(ast)
    TypeAnalyser.new(ast).analyse
  end

  class TypeAnalyser
  	def initialize(ast)
  	  @ast = ast
  	end

  	def analyze
  	  # go through all
  	  # infer and annotate
  	end
  end
end
