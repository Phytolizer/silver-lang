import chunktypes
import objtypes
import tabletypes
import valuetypes

const STACK_MAX* = 256

type
    VM* = object
        chunk*: ptr Chunk
        ip*: ptr uint8
        stack*: ptr Value
        stackTop*: ptr Value
        count*: int
        capacity*: int
        strings*: Table

        objects*: ptr Obj
    
    InterpretResult* = enum
        irOk,
        irCompileError,
        irRuntimeError

var vm*: VM
