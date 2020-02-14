import chunktypes
import chunk
import common
import parsertypes
import parser
import scanner
import scannertypes
import stringops
import valuetypes

when DEBUG_PRINT_CODE:
    import debug

proc binary*(self: var Parser, s: var Scanner)
proc literal*(self: var Parser, s: var Scanner)
proc grouping*(self: var Parser, s: var Scanner)
proc expression*(self: var Parser, s: var Scanner)
proc number*(self: var Parser, s: var Scanner)
proc unary*(self: var Parser, s: var Scanner)

var RULES = [
    # invalid
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # (
    ParseRule(prefix: grouping, infix: nil, precedence: prNone),
    # )
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # {
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # }
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # [
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # ]
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # ,
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # .
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # -
    ParseRule(prefix: unary, infix: binary, precedence: prTerm),
    # +
    ParseRule(prefix: nil, infix: binary, precedence: prTerm),
    # ;
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # /
    ParseRule(prefix: nil, infix: binary, precedence: prFactor),
    # *
    ParseRule(prefix: nil, infix: binary, precedence: prFactor),
    # ->
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # !
    ParseRule(prefix: unary, infix: nil, precedence: prNone),
    # !=
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # =
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # ==
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # >
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # >=
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # <
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # <=
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # and
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # or
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # true
    ParseRule(prefix: literal, infix: nil, precedence: prNone),
    # false
    ParseRule(prefix: literal, infix: nil, precedence: prNone),
    # class
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # super
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # this
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # print
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # return
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # var
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # fn
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # null
    ParseRule(prefix: literal, infix: nil, precedence: prNone),
    # int
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # char
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # string
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # void
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # ref
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # ptr
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # if
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # else
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # for
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # while
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # switch
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # identifier
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # "string literal"
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
    # 9999
    ParseRule(prefix: number, infix: nil, precedence: prNone),
    # eof
    ParseRule(prefix: nil, infix: nil, precedence: prNone),
]

proc getParseRule*(kind: TokenKind): ptr ParseRule =
    RULES[kind.uint].addr

var compilingChunk: ptr Chunk

proc currentChunk(): ptr Chunk =
    compilingChunk

proc emitByte*(self: var Parser, b: uint8) =
    currentChunk()[].write(b, self.previous.line)

proc emitReturn(self: var Parser) =
    self.emitByte(opReturn.uint8)

proc emitConstant(self: var Parser, value: Value) =
    currentChunk()[].writeConstant(value, self.previous.line)

proc endCompile(self: var Parser) =
    self.emitReturn()
    when DEBUG_PRINT_CODE:
        currentChunk()[].disassemble("code")

proc parsePrecedence*(self: var Parser, s: var Scanner, precedence: Precedence)

proc compile*(source: ptr char, c: ptr Chunk): bool =
    var scanner = initScanner(source)
    var parser = initParser()
    compilingChunk = c
    parser.advance(scanner)
    if parser.current.kind == tkEof:
        endCompile(parser)
        return true
    parser.expression(scanner)

    parser.consume(scanner, tkEof, "Expected end of expression")
    endCompile(parser)
    return not parser.hadError

proc binary*(self: var Parser, s: var Scanner) =
    let operatorKind = self.previous.kind

    let rule = getParseRule(operatorKind)
    self.parsePrecedence(s, Precedence(rule.precedence.uint + 1))

    case operatorKind:
        of tkPlus:
            self.emitByte(opAdd.uint8)
        of tkMinus:
            self.emitByte(opSubtract.uint8)
        of tkStar:
            self.emitByte(opMultiply.uint8)
        of tkSlash:
            self.emitByte(opDivide.uint8)
        else:
            return

proc literal*(self: var Parser, s: var Scanner) =
    case self.previous.kind:
        of tkFalse:
            self.emitByte(opFalse.uint8)
        of tkNull:
            self.emitByte(opNull.uint8)
        of tkTrue:
            self.emitByte(opTrue.uint8)
        else: return

proc grouping*(self: var Parser, s: var Scanner) =
    self.expression(s)
    self.consume(s, tkParenRight, "Expected ')' after expression")

proc expression*(self: var Parser, s: var Scanner) =
    self.parsePrecedence(s, prAssignment)

proc number*(self: var Parser, s: var Scanner) =
    let value = strtol(self.previous.start, nil, 10)
    self.emitConstant(intVal(value))

proc unary*(self: var Parser, s: var Scanner) =
    let operatorKind = self.previous.kind

    self.parsePrecedence(s, prUnary)

    case operatorKind:
        of tkBang:
            self.emitByte(opNot.uint8)
        of tkMinus:
            self.emitByte(opNegate.uint8)
        else: return

proc parsePrecedence*(self: var Parser, s: var Scanner,
        precedence: Precedence) =
    self.advance(s)
    let prefixRule = getParseRule(self.previous.kind).prefix
    if prefixRule == nil:
        self.error("Expected expression")
        return

    prefixRule(self, s)

    while precedence <= getParseRule(self.current.kind).precedence:
        self.advance(s)
        let infixRule = getParseRule(self.previous.kind).infix
        infixRule(self, s)
