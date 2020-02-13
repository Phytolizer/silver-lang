type
    Value* = float64

    ValueArray* = object
        values*: ptr Value
        count*: int
        capacity*: int
