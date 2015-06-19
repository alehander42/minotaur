require 'spec_helper'

module Minotaur
  describe '.expand_as' do
    it 'can expand generic functions' do
      expect_expanded(
        # def x(z: {k: :v}) Int16
        #   -2
        # end
        # {instances: {Dict: [[UInt, ]]}}
        n(:function,
          label: :x,
          args:  [n(:arg, label: :z, c_type: Builtin::Dict)],
          return_type: Builtin::Int16,
          body: [n(:int, value: -2)]),
        {Dict: [[Builtin::UInt, Builtin::String]]},
        [n(:function,
          label: :x_0,
          args: [n(:arg, label: z, c_type: GenericInstanceType.new(Builtin::Dict, [Builtin::UInt, Builtin::Int]))],
          return_type: Builtin::Int16,
          body: [n(:int, value: -2)])])
    end

    def expect_expanded(minotaur_ast, instances, expanded)
      wtf = Minotaur::expand_ast({
        ast: n(:program, children: [minotaur_ast]),
        functions: {x: {overloads: [{z: Builtin::Dict}], c_type: GenericInstanceType.new(Builtin::Function, Builtin::Dict, Builtin::Int16)}},
        instances: instances})
      expect(wtf.children).to eq expanded
    end
  end
end

