import chunktypes
import objtypes
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
        objects*: ptr Obj
    
    InterpretResult* = enum
        irOk,
        irCompileError,
        irRuntimeError

var vm*: VM
