import objtypes
import valuetypes

type
    Entry* = object
        key*: ptr ObjString
        value*: Value

    Table* = object
        entries*: ptr Entry
        count*: int
        capacity*: int

const TABLE_MAX_LOAD* = 0.75