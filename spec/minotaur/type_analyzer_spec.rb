require 'spec_helper'

module Minotaur
  describe '.type_analyze' do
    it 'can infer types from assignments' do
      expect_analyzed_type(
        n(:assignment, target: :a, value: n(:int, value: 0)),
        a: Builtin::Int)
    end

    it 'can infer types for elements of lists' do
      expect_analyzed_type(
        n(:assignment, target: :a, value: n(:index,
            sequence: n(:list, items: [n(:int, value: 0)]),
            index: n(:uint, value: 0))),
        a: Builtin::Int)
    end

    def expect_analyzed_type(minotaur_ast, **expected)
      typed_data = Minotaur::type_analyze(n(:program, children: [minotaur_ast]))
      f_data = typed_data[:functions][:main][:overloads][-1]
      expected.each do |attr, type|
        expect(f_data[attr]).to eq type
      end
    end

    def n(kind, **kwargs)
      Minotaur::n(kind, **kwargs)
    end
  end
end
