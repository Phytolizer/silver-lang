import valuetypes
import lines

type
    OpCode* = enum
        opConstant,
        opConstantLong,
        opNegate,
        opAdd,
        opSubtract,
        opMultiply,
        opDivide,
        opReturn

    Chunk* = object
        code*: ptr uint8
        count*: int
        capacity*: int
        lines*: Lines
        constants*: ValueArray
