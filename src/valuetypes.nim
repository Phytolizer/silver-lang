type
    Value* = int64

    ValueArray* = object
        values*: ptr Value
        count*: int
        capacity*: int
