import io
import parsertypes
import scanner
import scannertypes

func initParser*: Parser =
    result.hadError = false
    result.panicMode = false

proc errorAt(self: var Parser, token: Token, message: ptr char) =
    if self.panicMode:
        return
    self.panicMode = true

    fprintf(stderr, "[line %d] Error", token.line)

    if token.kind == tkEof:
        fprintf(stderr, " at end")
    elif token.kind != tkInvalid:
        fprintf(stderr, " at '%.*s'", token.length, token.start)

    fprintf(stderr, ": %s\n", message)
    self.hadError = true

proc error*(self: var Parser, message: cstring) =
    self.errorAt(self.previous, cast[ptr char](message))

proc errorAtCurrent(self: var Parser, message: ptr char) =
    self.errorAt(self.current, message)

proc advance*(self: var Parser, s: var Scanner) =
    self.previous = self.current

    while true:
        self.current = s.scanToken()
        if self.current.kind != tkInvalid: break

        self.errorAtCurrent(self.current.start)

proc consume*(self: var Parser, s: var Scanner, kind: TokenKind,
        message: cstring) =
    if self.current.kind == kind:
        self.advance(s)
        return

    self.errorAtCurrent(cast[ptr char](message))

proc check(self: var Parser, kind: TokenKind): bool =
    self.current.kind == kind

proc match*(self: var Parser, s: var Scanner, kind: TokenKind): bool =
    if not self.check(kind): return false
    self.advance(s)
    return true
