import macros

macro appendToCall*(call: untyped, args: untyped): untyped =
    result = call
    for child in args.children:
        result.add(child)
