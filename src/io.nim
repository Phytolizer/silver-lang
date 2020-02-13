var
    cmdCount* {.importc.}: cint
    cmdLine* {.importc.}: cstringArray

proc printf*(fmt: cstring) {.importc, varargs.}
proc fprintf*(file: File, fmt: cstring) {.nodecl, importc, varargs.}
