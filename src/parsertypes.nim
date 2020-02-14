import scannertypes

type
    Parser* = object
        current*: Token
        previous*: Token
        hadError*: bool
        panicMode*: bool

    Precedence* = enum
        prNone,
        prAssignment,
        prOr,
        prAnd,
        prEquality,
        prComparison,
        prTerm,
        prFactor,
        prUnary,
        prCall,
        prPrimary
    
    ParseFn = proc(p: var Parser, s: var Scanner)
    
    ParseRule* = object
        prefix*: ParseFn
        infix*: ParseFn
        precedence*: Precedence
