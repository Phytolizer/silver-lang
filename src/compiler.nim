import io
import scanner
import scannertypes

proc compile*(source: ptr char) =
    var scanner = initScanner(source)
    var line = -1
    while true:
        let token = scanner.scanToken()
        if token.line != line:
            printf("%4d ", token.line)
            line = token.line
        else:
            printf("   | ")
        printf("%2d '%.*s'\n", token.kind, token.length, token.start)

        if token.kind == tkEof: break