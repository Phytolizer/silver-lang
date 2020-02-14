import common
when DEBUG_LOG_HEAP:
    import io
    import typetraits
    var totalMem = 0

func growCapacity*(capacity: int): int =
    if capacity < 8:
        return 8
    else:
        return capacity * 2

proc reallocate*(arr: pointer, oldSize: int, newSize: int): pointer =
    if newSize == 0:
        if arr != nil:
            when DEBUG_LOG_HEAP:
                totalMem -= oldSize
                fprintf(stderr, "total mem usage: %4d\n", totalMem)
            dealloc(arr)
        return nil
    when DEBUG_LOG_HEAP:
        totalMem += newSize - oldSize
        fprintf(stderr, "total mem usage: %4d\n", totalMem)
    result = realloc(arr, newSize)

proc allocate*(T: typedesc, count: SomeInteger): ptr T =
    cast[ptr T](reallocate(nil, 0, sizeof(T) * count))

proc growArray*[T](arr: ptr T, oldSize: int, newSize: int): ptr T =
    when DEBUG_LOG_HEAP:
        fprintf(stderr, "growing %08x: %4d -> %4d (%2d) %s\n", arr, oldSize *
                sizeof(T), newSize * sizeof(T), newSize, T.name.cstring)
    result = cast[ptr T](reallocate(arr, sizeof(T) * oldSize, sizeof(T) * newSize))
    when DEBUG_LOG_HEAP:
        fprintf(stderr, " => %08x\n", result)

proc freeArray*[T](arr: ptr T, capacity: int) =
    if capacity == 0: return
    when DEBUG_LOG_HEAP:
        fprintf(stderr, "freeing %08x: %4d (%2d) %s\n", arr, capacity * sizeof(
                T), capacity, T.name.cstring)
    discard reallocate(arr, sizeof(T) * capacity, 0)

proc free*(T: typedesc, p: pointer) =
    discard reallocate(p, sizeof(T), 0)
