import chunk
import chunktypes
import debug
import io
import vm as vm_impl

when isMainModule:
    var vm = initVM()
    var c = initChunk()

    c.writeConstant(1.2, 123)
    c.writeConstant(3.4, 123)
    c.write(opAdd.uint8, 123)
    c.writeConstant(5.6, 123)
    c.write(opDivide.uint8, 123)
    c.write(opNegate.uint8, 123)

    c.write(opReturn.uint8, 1000)
    c.disassemble("test chunk")
    printf("%d\n", vm.interpret(addr c))

    c.free()
    vm.free()
    quit(0)
