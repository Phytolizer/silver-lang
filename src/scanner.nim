import ptr_arithmetic
import scannertypes
import stringops
import strutils

func initScanner*(source: ptr char): Scanner =
    Scanner(start: source, curr: source, line: 1)

func atEnd(self: Scanner): bool =
    self.curr[] == '\0'

func advance(self: var Scanner): char =
    result = self.curr[]
    self.curr += 1

func peekNext(self: Scanner): char =
    if self.atEnd(): return '\0'
    return (self.curr + 1)[]

func skipWhitespace(self: var Scanner): bool =
    while true:
        let c = self.curr[]
        case c:
            of ' ', '\r', '\t':
                discard self.advance()
            of '\n':
                self.line += 1
                discard self.advance()
            of '/':
                if self.peekNext() == '/':
                    while self.curr[] != '\n' and not self.atEnd():
                        discard self.advance()
                elif self.peekNext() == '*':
                    while true:
                        if self.atEnd(): return false

                        let c = self.curr[]
                        if c == '*' and self.peekNext() == '/':
                            # *
                            discard self.advance()
                            # /
                            discard self.advance()
                            break
                        elif c == '\n':
                            self.line += 1
                        discard self.advance()
                else:
                    return true
            else:
                return true

func checkKeyword(lexeme: ptr char, length: int, start: int, compare: cstring, kind: TokenKind): TokenKind =
    if length - start != compare.len:
        return tkIdentifier
    if strncmp(lexeme + start, compare, length - start) == 0:
        return kind
    return tkIdentifier

func checkKeyword(lexeme: ptr char, length: int, stop: int): TokenKind =
    if length < stop:
        return tkIdentifier
    case stop:
    of 1:
        case lexeme[]:
        of 'a':
            return checkKeyword(lexeme, length, 1, "nd", tkAnd)
        of 'e':
            return checkKeyword(lexeme, length, 1, "lse", tkElse)
        of 'n':
            return checkKeyword(lexeme, length, 1, "ull", tkNull)
        of 'o':
            return checkKeyword(lexeme, length, 1, "r", tkOr)
        of 'w':
            return checkKeyword(lexeme, length, 1, "hile", tkWhile)
        
        # ambiguous
        of 'c', 'f', 'i', 'p', 'r', 's', 't', 'v':
            return checkKeyword(lexeme, length, 2)
        else:
            return tkIdentifier
    of 2:
        if strncmp(lexeme, "ch", 2) == 0:
            return checkKeyword(lexeme, length, 2, "ar", tkChar)
        if strncmp(lexeme, "cl", 2) == 0:
            return checkKeyword(lexeme, length, 2, "ass", tkClass)
        if strncmp(lexeme, "fa", 2) == 0:
            return checkKeyword(lexeme, length, 2, "lse", tkElse)
        if strncmp(lexeme, "fn", 2) == 0:
            return checkKeyword(lexeme, length, 2, "", tkFn)
        if strncmp(lexeme, "fo", 2) == 0:
            return checkKeyword(lexeme, length, 2, "r", tkFor)
        if strncmp(lexeme, "if", 2) == 0:
            return checkKeyword(lexeme, length, 2, "", tkIf)
        if strncmp(lexeme, "in", 2) == 0:
            return checkKeyword(lexeme, length, 2, "t", tkInt)
        if strncmp(lexeme, "pr", 2) == 0:
            return checkKeyword(lexeme, length, 2, "int", tkPrint)
        if strncmp(lexeme, "pt", 2) == 0:
            return checkKeyword(lexeme, length, 2, "r", tkPtr)
        if strncmp(lexeme, "st", 2) == 0:
            return checkKeyword(lexeme, length, 2, "ring", tkString)
        if strncmp(lexeme, "su", 2) == 0:
            return checkKeyword(lexeme, length, 2, "per", tkSuper)
        if strncmp(lexeme, "sw", 2) == 0:
            return checkKeyword(lexeme, length, 2, "itch", tkSwitch)
        if strncmp(lexeme, "th", 2) == 0:
            return checkKeyword(lexeme, length, 2, "is", tkThis)
        if strncmp(lexeme, "tr", 2) == 0:
            return checkKeyword(lexeme, length, 2, "ue", tkTrue)
        if strncmp(lexeme, "va", 2) == 0:
            return checkKeyword(lexeme, length, 2, "r", tkVar)
        if strncmp(lexeme, "vo", 2) == 0:
            return checkKeyword(lexeme, length, 2, "id", tkVoid)
        # ambiguous
        if strncmp(lexeme, "re", 2) == 0:
            return checkKeyword(lexeme, length, 3)
        return tkIdentifier
    of 3:
        if strncmp(lexeme, "ref", 3) == 0:
            return checkKeyword(lexeme, length, 3, "", tkRef)
        if strncmp(lexeme, "ret", 3) == 0:
            return checkKeyword(lexeme, length, 3, "urn", tkReturn)
        return tkIdentifier
    else: 
        return tkIdentifier

func checkKeyword(lexeme: ptr char, length: int): TokenKind =
    checkKeyword(lexeme, length, 1)

func identifierType(self: Scanner): TokenKind =
    checkKeyword(self.start, self.curr - self.start)

func match(self: var Scanner, c: char): bool =
    if self.curr[] != c: return false

    self.curr += 1
    return true

func makeToken(self: Scanner, kind: TokenKind): Token =
    result.kind = kind
    result.start = self.start
    result.length = self.curr - self.start
    result.line = self.line

func errorToken(self: Scanner, message: cstring): Token =
    result.kind = tkInvalid
    result.start = cast[ptr char](message)
    result.length = message.len
    result.line = self.line

func string(self: var Scanner): Token =
    while self.curr[] != '"' and not self.atEnd():
        if self.curr[] == '\n':
            self.line += 1
        discard self.advance()

    if self.atEnd(): return self.errorToken("Unterminated string")

    discard self.advance()
    return self.makeToken(tkStringLiteral)

func identifier(self: var Scanner): Token =
    while self.curr[].isAlphaNumeric() or self.curr[] == '_':
        discard self.advance()
    
    return self.makeToken(self.identifierType())

func number(self: var Scanner): Token =
    while self.curr[].isDigit():
        discard self.advance()
    return self.makeToken(tkIntegerLiteral)

func scanToken*(self: var Scanner): Token =
    if not self.skipWhitespace():
        return self.errorToken("Unterminated comment")

    self.start = self.curr

    if self.atEnd(): return self.makeToken(tkEof)

    let c = self.advance()

    # Character classes
    if c.isAlphaAscii() or c == '_':
        return self.identifier()
    if c.isDigit():
        return self.number()

    # Specific character
    case c:
        # Single-character tokens
        of '(': return self.makeToken(tkParenLeft)
        of ')': return self.makeToken(tkParenRight)
        of '{': return self.makeToken(tkBraceLeft)
        of '}': return self.makeToken(tkBraceRight)
        of '[': return self.makeToken(tkBracketLeft)
        of ']': return self.makeToken(tkBracketRight)
        of ';': return self.makeToken(tkSemicolon)
        of ',': return self.makeToken(tkComma)
        of '.': return self.makeToken(tkDot)
        of '+': return self.makeToken(tkPlus)
        of '/': return self.makeToken(tkSlash)
        of '*': return self.makeToken(tkStar)

        # Two-character tokens
        of '!':
            if self.match('='):
                return self.makeToken(tkBangEqual)
            else:
                return self.makeToken(tkBang)
        of '=':
            if self.match('='):
                return self.makeToken(tkEqualEqual)
            else:
                return self.makeToken(tkEqual)
        of '<':
            if self.match('='):
                return self.makeToken(tkLessEqual)
            else:
                return self.makeToken(tkLess)
        of '>':
            if self.match('='):
                return self.makeToken(tkGreaterEqual)
            else:
                return self.makeToken(tkGreater)
        of '-':
            if self.match('>'):
                return self.makeToken(tkArrow)
            else:
                return self.makeToken(tkMinus)

        # More complicated literals
        of '"':
            return self.string()
        else: discard

    return self.errorToken("Unexpected character")
