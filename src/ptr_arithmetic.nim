func `+`*[T](a: ptr T, b: SomeInteger): ptr T =
    cast[ptr T](cast[int](a) + cast[int](b) * sizeof(T))

func `+=`*[T](a: var ptr T, b: SomeInteger) =
    a = a + b

func `-`*[T](a: ptr T, b: ptr T): int =
    cast[int](a) - cast[int](b)

func `-`*[T](a: ptr T, b: SomeInteger): ptr T =
    cast[ptr T](cast[int](a) - cast[int](b) * sizeof(T))

func `-=`*[T](a: var ptr T, b: SomeInteger) =
    a = a - b
