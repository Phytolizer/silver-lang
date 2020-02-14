import objtypes

type
    ValueKind* = enum
        vBool,
        vNull,
        vInt,
        vObj

    Value* = object
        case kind*: ValueKind
        of vBool:
            boolean*: bool
        of vNull: discard
        of vInt:
            integer*: int
        of vObj:
            obj*: ptr Obj

    ValueArray* = object
        values*: ptr Value
        count*: int
        capacity*: int

func boolVal*(value: bool): Value = Value(kind: vBool, boolean: value)
func nullVal*(): Value = Value(kind: vNull)
func intVal*(value: int): Value = Value(kind: vInt, integer: value)
func objVal*(value: pointer): Value = Value(kind: vObj, obj: cast[ptr Obj](value))

func asBool*(value: Value): bool = value.boolean
func asInt*(value: Value): int = value.integer
func asObj*(value: Value): ptr Obj = value.obj

func isBool*(value: Value): bool = value.kind == vBool
func isNull*(value: Value): bool = value.kind == vNull
func isInt*(value: Value): bool = value.kind == vInt
func isObj*(value: Value): bool = value.kind == vObj

func objKind*(value: Value): ObjKind = value.asObj().kind

func isObjKind*(value: Value, kind: ObjKind): bool =
    value.isObj() and value.asObj().kind == kind

func isString*(value: Value): bool = value.isObjKind(objString)

func asString*(value: Value): ptr ObjString = cast[ptr ObjString](value.asObj())
func asCString*(value: Value): ptr char = cast[ptr ObjString](value.asObj()).chars
