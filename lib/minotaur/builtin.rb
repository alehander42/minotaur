require_relative 'c_type'

module Minotaur
  module Builtin
    Int 	= BaseType.new(:Int,    'int')
    Int8 	= BaseType.new(:Int8,   'int8_t')
    Int16 	= BaseType.new(:Int16,  'int16_t')
    Int32 	= BaseType.new(:Int32,  'int32_t')
    Int64 	= BaseType.new(:Int64,  'int64_t')
    UInt 	= BaseType.new(:UInt,   'unsigned int')
    UInt8 	= BaseType.new(:UInt8,  'uint8_t')
    UInt16 	= BaseType.new(:UInt16, 'uint16_t')
    UInt32 	= BaseType.new(:UInt32, 'uint32_t')
    UInt64 	= BaseType.new(:UInt64, 'uint64_t')
    Size    = BaseType.new(:Size,   'size_t')
    UIntPtr = BaseType.new(:UIntPtr,'uintptr_t')
    List    = BaseType.new(:List,   'MList')
    Dict    = BaseType.new(:Dict,   'MDict')
    Bool    = BaseType.new(:Bool,   'bool')
    Float   = BaseType.new(:Float,  'float')
    Char    = BaseType.new(:Char,   'char')
  end
end
