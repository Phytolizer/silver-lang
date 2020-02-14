func growCapacity*(capacity: int): int =
    if capacity < 8:
        return 8
    else:
        return capacity * 2

proc reallocate(arr: pointer, oldSize: int, newSize: int): pointer =
    if newSize == 0:
        if arr != nil:
            dealloc(arr)
        return nil
    realloc(arr, newSize)

proc growArray*[T](arr: ptr T, oldSize: int, newSize: int): ptr T =
    return cast[ptr T](reallocate(arr, sizeof(T) * oldSize, sizeof(T) * newSize))

proc freeArray*[T](arr: ptr T, capacity: int) =
    if capacity == 0: return
    discard reallocate(arr, sizeof(T) * capacity, 0)
