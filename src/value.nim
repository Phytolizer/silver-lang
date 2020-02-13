import io
import valuetypes
import ptr_arithmetic

from memory import nil


func initValueArray*: ValueArray =
    ValueArray(values: nil, count: 0, capacity: 0)

proc write*(self: var ValueArray, value: Value) =
    if self.count >= self.capacity:
        let oldCapacity = self.capacity
        self.capacity = memory.growCapacity(oldCapacity)
        self.values = memory.growArray(self.values, oldCapacity, self.capacity)
    (self.values + self.count)[] = value
    self.count += 1

proc free*(self: var ValueArray) =
    memory.freeArray(self.values, self.capacity)
    self = initValueArray()

proc print*(self: Value) =
    printf("%g", self)
