import io
import objects
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
    case self.kind:
    of vBool:
        if self.boolean:
            printf("true")
        else:
            printf("false")
    of vNull:
        printf("null")
    of vInt:
        printf("%d", self.integer)
    of vObj:
        self.printObject()

func isFalsey*(self: Value): bool =
    self.isNull() or (self.isBool() and not self.asBool())

func equals*(self: Value, other: Value): bool =
    if self.kind != other.kind: return false

    case self.kind:
        of vBool:
            return self.asBool() == other.asBool()
        of vNull:
            return true
        of vInt:
            return self.asInt() == other.asInt()
        of vObj:
            return self.asObj() == other.asObj()
