import io
import ptr_arithmetic
import vm as vm_impl
import vmtypes

proc repl(vm: var VM) =
    var line: array[1024, char]
    while true:
        printf("> ")

        if fgets(addr line[0], sizeof(line).cint, stdin) == 0:
            printf("\n")
            break

        discard vm.interpret(addr line[0])

proc readFile(path: cstring): ptr char =
    let file = fopen(path, "rb")
    if file == nil:
        fprintf(stderr, "Could not open file \"%s\"\n", path)
        quit(74)

    fseek(file, 0, SEEK_END)
    let fileSize = ftell(file)
    fseek(file, 0, SEEK_SET)

    result = cast[ptr char](alloc(fileSize + 1))
    if result == nil:
        fprintf(stderr, "Not enough memory to read \"%s\"\n", path)
        quit(74)
    let bytesRead = fread(result, sizeof(char), fileSize, file)
    if bytesRead < fileSize:
        fprintf(stderr, "Could not read file \"%s\"\n", path)
        quit(74)
    (result + bytesRead)[] = '\0'

    fclose(file)

proc runFile(vm: var VM, file: cstring): int =
    let source = readFile(file)
    let ir = vm.interpret(source)
    dealloc(source)
    if ir == irCompileError:
        return 65
    elif ir == irRuntimeError:
        return 70

when isMainModule:
    var vm = initVM()
    var ret = 0

    if cmdCount == 1:
        repl(vm)
    elif cmdCount == 2:
        ret = runFile(vm, cmdLine[1])
    else:
        fprintf(stderr, "Usage: clox [path]\n")
        ret = 64

    vm.free()
    quit(ret)
