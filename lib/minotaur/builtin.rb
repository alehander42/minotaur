require_relative 'c_type'

module Minotaur
  module Builtin
    args = [:arg0, :arg1, :arg2, :arg3, :arg4, :arg5, :arg6, :arg7]
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
    UIntPt  = BaseType.new(:UIntPtr,'uintptr_t')
    Void    = BaseType.new(:Void,   'void')
    List    = GenericType.new(:List, [:t], [TypeArg.new(:t)])
    Dict    = GenericType.new(:Dict, [:k, :v], [TypeArg.new(:k), TypeArg.new(:v)])
    Bool    = BaseType.new(:Bool,   'bool')
    Float   = BaseType.new(:Float,  'float')
    Char    = BaseType.new(:Char,   'char')
    Function = GenericType.new(:Function,
        args,
        args.map { |arg| TypeArg.new(arg) })
    String  = BaseType.new(:String, 'MString')

    CharPtr = PointerType.new(Char)
    UIntPtr = PointerType.new(UInt)
    VoidPtr = PointerType.new(Void)

    INT_TYPES = [Int, Int8, Int16, Int32, Int64]
    UINT_TYPES = [UInt, Size, UInt8, UInt16, UIntPt, UInt32, UInt64]
    ALL_INT_TYPES = INT_TYPES + UINT_TYPES
  end
end
