import memory
import ptr_arithmetic

type
    LineInfo* = object
        line*: int
        offset*: int
        length*: int
    
    Lines* = object
        lines*: ptr LineInfo
        count*: int
        capacity: int

func initLineInfo*(line: int, offset: int, length: int): LineInfo =
    LineInfo(line: line, offset: offset, length: length)
    
func contains*(self: LineInfo, offset: int): bool =
    self.offset <= offset and offset - self.offset < self.length

func initLines*: Lines =
    Lines(lines: nil, count: 0, capacity: 0)

proc push*(self: var Lines, info: LineInfo) =
    if self.count >= self.capacity:
        let oldCapacity = self.capacity
        self.capacity = memory.growCapacity(oldCapacity)
        self.lines = memory.growArray(self.lines, oldCapacity, self.capacity)
    (self.lines + self.count)[] = info
    self.count += 1

func getLast*(self: Lines): ptr LineInfo =
    if self.count == 0:
        return nil
    else:
        return self.lines + self.count - 1
