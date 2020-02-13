import chunk
import chunktypes
import debug
import io
import vm as vm_impl

when isMainModule:
    var vm = initVM()
    var c = initChunk()

    c.writeConstant(1.2, 123)

    c.write(opReturn.uint8, 1000)
    c.disassemble("test chunk")
    printf("%d\n", vm.interpret(addr c))

    c.free()
    vm.free()
    quit(0)
