type
    ValueKind* = enum
        vBool,
        vNull,
        vInt

    Value* = object
        case kind*: ValueKind
        of vBool:
            boolean*: bool
        of vInt:
            integer*: int
        of vNull: discard

    ValueArray* = object
        values*: ptr Value
        count*: int
        capacity*: int

func boolVal*(value: bool): Value = Value(kind: vBool, boolean: value)
func nullVal*(): Value = Value(kind: vNull)
func intVal*(value: int): Value = Value(kind: vInt, integer: value)

func asBool*(value: Value): bool = value.boolean
func asInt*(value: Value): int = value.integer

func isBool*(value: Value): bool = value.kind == vBool
func isNull*(value: Value): bool = value.kind == vNull
func isInt*(value: Value): bool = value.kind == vInt
