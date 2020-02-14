type
    ObjKind* = enum
        objString

    Obj* = object
        kind*: ObjKind

    ObjString* = object
        obj*: Obj
        length*: int
        chars*: ptr char
