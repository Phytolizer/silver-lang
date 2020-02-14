import io
import objtypes
import ptr_arithmetic
import valuetypes
import vmtypes

from memory import nil

proc allocateObject(size: int, kind: ObjKind): ptr Obj =
    result = cast[ptr Obj](memory.reallocate(nil, 0, size))
    result.kind = kind
    result.next = vm.objects

proc allocateObj(T: typedesc, kind: ObjKind): ptr T =
    cast[ptr T](allocateObject(sizeof(T), kind))

proc allocateString*(chars: ptr char, length: int,
        hash: uint32): ptr ObjString =
    result = allocateObj(ObjString, objString)
    result.length = length
    result.chars = chars
    result.hash = hash

func hashString(key: ptr char, length: int): uint32 =
    result = 2166136261'u32

    for i in 0..<length:
        result = result xor (key + i)[].uint32
        result *= 16777619

proc copyString*(chars: ptr char, length: int): ptr ObjString =
    let hash = hashString(chars, length)

    let heapChars = memory.allocate(char, length + 1)
    copyMem(heapChars, chars, length)
    (heapChars + length)[] = '\0'

    return allocateString(heapChars, length, hash)

proc takeString*(chars: ptr char, length: int): ptr ObjString =
    let hash = hashString(chars, length)
    allocateString(chars, length, hash)

proc printObject*(self: Value) =
    case self.objKind():
        of objString:
            printf("%s", self.asCString())
