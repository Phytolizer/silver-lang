var
    cmdCount* {.importc.}: cint
    cmdLine* {.importc.}: cstringArray
    SEEK_SET* {.nodecl, importc.}: cint
    SEEK_END* {.nodecl, importc.}: cint

proc printf*(fmt: cstring) {.nodecl, importc, varargs.}
proc fprintf*(file: File, fmt: cstring) {.nodecl, importc, varargs.}
proc fgets*(buffer: ptr char, size: cint, file: File): cint {.nodecl, importc.}
proc fopen*(path: cstring, mode: cstring): File {.nodecl, importc.}
proc fseek*(file: File, pos: clong, whence: cint) {.nodecl, importc.}
proc ftell*(file: File): csize {.nodecl, importc.}
proc fread*(buffer: ptr char, size: csize, n: csize, file: File): csize {.
        nodecl, importc.}
proc fclose*(file: File) {.nodecl, importc.}
