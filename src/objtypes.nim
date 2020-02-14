from memory import nil

type
    ObjKind* = enum
        objString

    Obj* = object
        kind*: ObjKind
        next*: ptr Obj

    ObjString* = object
        obj*: Obj
        length*: int
        chars*: ptr char
        hash*: uint32

proc free*(self: var ptr Obj) =
    case self.kind:
        of objString:
            let str = cast[ptr ObjString](self)
            memory.freeArray(str.chars, str.length + 1)
            memory.free(ObjString, self)
