type
    Scanner* = object
        start*: ptr char
        curr*: ptr char
        line*: int

    TokenKind* = enum
        tkInvalid,

        # Grouping
        # ()
        tkParenLeft, tkParenRight,
        # {}
        tkBraceLeft, tkBraceRight,
        # []
        tkBracketLeft, tkBracketRight,

        # Punctuation
        #  ,       .       -        +
        tkComma, tkDot, tkMinus, tkPlus,
        #    ;          /       *
        tkSemicolon, tkSlash, tkStar,
        #  ->
        tkArrow,

        # Boolean operations
        #  !         !=
        tkBang, tkBangEqual,
        #  =         ==
        tkEqual, tkEqualEqual,
        #   >            >=
        tkGreater, tkGreaterEqual,
        #  <         <=
        tkLess, tkLessEqual,
        tkAnd, tkOr,
        tkTrue, tkFalse,

        # Keywords
        tkClass, tkSuper, tkThis, tkPrint,
        tkReturn, tkVar, tkFn, tkNull,
        # Type keywords
        tkInt, tkChar, tkString, tkVoid,
        # Type modifiers
        tkRef, tkPtr,
        # Control flow
        tkIf, tkElse, tkFor, tkWhile, tkSwitch,

        # Tokens with arbitrary lexemes
        # [a-zA-Z_]\w*     ".*?"            \d+
        tkIdentifier, tkStringLiteral, tkIntegerLiteral,

        tkEof

    Token* = object
        kind*: TokenKind
        start*: ptr char
        length*: int
        line*: int
