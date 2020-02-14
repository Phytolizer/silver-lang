proc strncmp*(s1: ptr char, s2: cstring, n: csize): cint {.nodecl, importc.}
proc strtol*(s: ptr char, endptr: ptr ptr char, base: cint): clong {.nodecl, importc.}
proc memcmp*(a: pointer, b: pointer, length: SomeInteger): cint {.nodecl, importc.}