import valuetypes
import lines

type
    OpCode* = enum
        opConstant,
        opConstantLong,
        opNull,
        opTrue,
        opFalse,
        opEqual,
        opGreater,
        opLess,
        opAdd,
        opSubtract,
        opMultiply,
        opDivide,
        opNot,
        opNegate,
        opPrint,
        opReturn

    Chunk* = object
        code*: ptr uint8
        count*: int
        capacity*: int
        lines*: Lines
        constants*: ValueArray
