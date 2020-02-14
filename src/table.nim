import objtypes
import options
import ptr_arithmetic
import tabletypes
import valuetypes

from memory import nil

proc initTable*: Table =
    result.entries = nil
    result.count = 0
    result.capacity = 0

proc free*(self: var Table) =
    memory.freeArray(self.entries, self.capacity)
    self = initTable()

proc findEntry(entries: ptr Entry, capacity: int,
        key: ptr ObjString): ptr Entry =
    var index = key.hash mod capacity.uint32
    while true:
        let entry = entries + index

        var tombstone: ptr Entry = nil

        if entry.key == nil:
            if entry.value.isNull():
                if tombstone == nil:
                    return entry
                else:
                    return tombstone
            else:
                if tombstone == nil:
                    tombstone = entry
        elif entry.key == key:
            return entry

        index = (index + 1) mod capacity.uint32

proc adjustCapacity(self: var Table, capacity: int) =
    let entries = memory.allocate(Entry, capacity)
    for i in 0..<capacity:
        (entries + i)[].key = nil
        (entries + i)[].value = nullVal()

    self.count = 0
    for i in 0..<self.capacity:
        let entry = self.entries + i
        if entry.key == nil: continue

        let dest = findEntry(entries, capacity, entry.key)
        dest.key = entry.key
        dest.value = entry.value
        self.count += 1

    memory.freeArray(self.entries, self.capacity)
    self.entries = entries
    self.capacity = capacity

proc put*(self: var Table, key: ptr ObjString, value: Value): bool =
    if (self.count + 1).float64 > self.capacity.float64 * TABLE_MAX_LOAD:
        let capacity = memory.growCapacity(self.capacity)
        self.adjustCapacity(capacity)

    let entry = findEntry(self.entries, self.capacity, key)

    result = entry.key == nil
    if result and entry.value.isNull():
        self.count += 1

    entry.key = key
    entry.value = value

proc putAll*(fr: Table, to: var Table) =
    for i in 0..<fr.capacity:
        let entry = fr.entries + i
        if entry.key != nil:
            discard to.put(entry.key, entry.value)

proc get*(self: Table, key: ptr ObjString): Option[Value] =
    if self.count == 0: return none(Value)

    let entry = findEntry(self.entries, self.capacity, key)
    if entry.key == nil: return none(Value)

    return some(entry.value)

proc remove*(self: var Table, key: ptr ObjString): bool =
    if self.count == 0: return false

    let entry = findEntry(self.entries, self.capacity, key)
    if entry.key == nil: return false

    entry.key = nil
    entry.value = boolVal(true)

    return true
