import io
import objtypes
import ptr_arithmetic
import valuetypes

from memory import nil

proc allocateObject(size: int, kind: ObjKind): ptr Obj =
    result = cast[ptr Obj](memory.reallocate(nil, 0, size))
    result.kind = kind

proc allocateObj(T: typedesc, kind: ObjKind): ptr T =
    cast[ptr T](allocateObject(sizeof(T), kind))

proc allocateString*(chars: ptr char, length: int): ptr ObjString =
    result = allocateObj(ObjString, objString)
    result.length = length
    result.chars = chars

proc copyString*(chars: ptr char, length: int): ptr ObjString =
    let heapChars = memory.allocate(char, length + 1)
    copyMem(heapChars, chars, length)
    (heapChars + length)[] = '\0'

    return allocateString(heapChars, length)

proc printObject*(self: Value) =
    case self.objKind():
        of objString:
            printf("%s", self.asCString())
