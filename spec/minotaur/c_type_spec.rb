require 'parser/ruby22'
require 'spec_helper'

module Minotaur
  describe '.to_ctype' do
    it 'should recognize base types' do
      expect_base('X', 'X')
      expect_base('Int16', 'int16_t')
    end

    it 'should recognize pointer to base types' do
      expect_pointer('X!', 'X*', base: BaseType.new(:X))
      expect_pointer('Int32!', 'int32_t*', base: Builtin::Int32)
    end

    it 'should recognize generic types' do
      expect_generic('List[Int16]', 'MList_int16_t', base: Builtin::List, type_args: [Builtin::Int16])
    end

    it 'should recognize pointer to generic types' do
      expect_pointer('Dict![Int16, Int32]', 'MDict_int16_t_int32_t*',
                     base: GenericType.new(Builtin::Dict, [Builtin::Int16, Builtin::Int32]))
    end

    def to_type(code)
      Minotaur::to_ctype(Parser::Ruby22.parse(code))
    end

    def expect_base(code, label)
      c_type = to_type(code)
      expect(c_type.class).to be BaseType
      expect(c_type.to_c).to eq label
    end

    def expect_pointer(code, c, base:, type_args: nil)
      c_type = to_type(code)
      expect(c_type.class).to be PointerType
      expect(c_type.to_c).to eq c
      expect(c_type.base).to eq base
      if type_args
        expect(c_type.base.type_args).to eq type_args
      end
    end

    def expect_generic(code, c, base:, type_args:)
      c_type = to_type(code)
      expect(c_type.class).to be GenericType
      expect(c_type.to_c).to eq c
      expect(c_type.base).to eq base
      expect(c_type.type_args).to eq type_args
    end
  end
end
