import bitops
import chunktypes
import lines
import ptr_arithmetic
import value
import valuetypes

from memory import nil


proc initChunk*: Chunk =
    Chunk(code: nil, count: 0, capacity: 0, constants: initValueArray())

proc write*(self: var Chunk, b: uint8, line: int) =
    if self.count >= self.capacity:
        let oldCapacity = self.capacity
        self.capacity = memory.growCapacity(oldCapacity)
        self.code = memory.growArray(self.code, oldCapacity, self.capacity)
    (self.code + self.count)[] = b
    self.count += 1
    let last = self.lines.getLast()
    if last == nil or last.line != line:
        self.lines.push(LineInfo(line: line, offset: self.count - 1, length: 1))
    else:
        last.length += 1

proc addConstant*(self: var Chunk, value: Value): uint =
    self.constants.write(value)
    return (self.constants.count - 1).uint

proc writeConstant*(self: var Chunk, value: Value, line: int) =
    let offset = self.addConstant(value)
    if offset > high(uint8).uint:
        self.write(opConstantLong.uint8, line)
        let hi = (offset.bitand 0xff0000) shr 8
        let mid = (offset.bitand 0xff00) shr 4
        let lo = (offset.bitand 0xff)
        self.write(hi.uint8, line)
        self.write(mid.uint8, line)
        self.write(lo.uint8, line)
    else:
        self.write(opConstant.uint8, line)
        self.write(offset.uint8, line)

func getLine*(self: Chunk, offset: int): int =
    var p = self.lines.lines
    while p - self.lines.lines < self.lines.count * sizeof(LineInfo):
        if p[].contains(offset):
            return p.line
        p += 1
    return -1

proc free*(self: var Chunk) =
    memory.freeArray(self.code, self.capacity)
    self.constants.free()
    self.lines.free()
    self = initChunk()
