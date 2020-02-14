import valuetypes
import lines

type
    OpCode* = enum
        opConstant,
        opConstantLong,
        opNull,
        opTrue,
        opFalse,
        opAdd,
        opSubtract,
        opMultiply,
        opDivide,
        opNot,
        opNegate,
        opReturn

    Chunk* = object
        code*: ptr uint8
        count*: int
        capacity*: int
        lines*: Lines
        constants*: ValueArray
