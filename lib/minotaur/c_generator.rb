# go through ast
# generate c

module Minotaur
  def self.generate_c(ast)
    CGenerator.new(ast).generate
  end

  class CGenerator
    def initialize(ast)
      @ast = ast
    end

    def generate
    end
  end
end
