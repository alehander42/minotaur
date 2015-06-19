# analyse overloaded and generic functions
# generate normal c function nodes

module Minotaur
  def self.expand_ast(typed_data)
    Expander.new(**typed_data).expand
  end

  class Expander
  	def initialize(ast:, functions:, instances:)
  	  @ast = ast
      @functions = functions
      @instances = instances
  	end

  	def expand
  	  # go through generic functions and core
  	  # select what is used and generate
  	end
  end
end
