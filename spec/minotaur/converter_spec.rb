require 'parser'
require 'spec_helper'

module Minotaur
  describe '.convert_ast' do
    it 'can convert ints' do
      expect_converted('2', n(:uint, value: 2))
    end

    it 'can convert strings' do
      expect_converted('"Hello"', n(:string, value: 'Hello'))
    end

    it 'can convert top level functions' do
      code = <<-MINOTAUR
          def add929(a: Int32) Int32
            a + 929
          end
      MINOTAUR

      expect_converted(code, n(:function,
        label: :add929,
        args:  [n(:arg, label: :a, c_type: Builtin::Int32)],
        return_type: Builtin::Int32,
        body:  [n(:binary_math, left: n(:ident, label: :a), right: n(:uint, value: 929), op: :+)]))
    end

    it 'can convert classes' do
      code = <<-MINOTAUR
          class A
            a   UInt16
            b   UInt16
            x   UInt16

            def init(a: UInt16)
              @a = a
              @b = 0
              @x = @a
            end
          end
      MINOTAUR

      expect_converted(code, [
        n(:struct, label: :A, fields: [
          n(:type_declaration, label: :a, c_type: Builtin::UInt16),
          n(:type_declaration, label: :b, c_type: Builtin::UInt16),
          n(:type_declaration, label: :x, c_type: Builtin::UInt16)]),
        n(:function, label: :init, args: [
          n(:arg, label: :self, c_type: PointerType.new(BaseType.new(:A))),
          n(:arg, label: :a, c_type: Builtin::UInt16)],
          return_type: Builtin::Void, body: [
            n(:field_assignment, label: :a, value: n(:ident, label: :a)),
            n(:field_assignment, label: :b, value: n(:uint, value: 0)),
            n(:field_assignment, label: :x, value: n(:field, label: :a))])])
    end

    def expect_converted(code, converted)
      ast = Parser::Ruby22.parse(code)
      converted_ast = Minotaur::convert_ast(ast)
      if converted.is_a?(Array)
        converted_ast = converted_ast.children
      else
        converted_ast = converted_ast.children[0]
      end
      expect(converted_ast).to eq converted
    end

    def n(kind, **kwargs)
      Minotaur::n(kind, **kwargs)
    end
  end
end
