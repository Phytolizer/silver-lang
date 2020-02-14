import io
import chunktypes
import chunk
import common
import compiler
import helpers
import objects
import objtypes
import ptr_arithmetic
import value
import valuetypes
import vmtypes

when DEBUG_TRACE_EXECUTION:
    import debug

from memory import nil

func resetStack(vm: var VM) =
    vm.stackTop = vm.stack

template runtimeError(vm: var VM, fmt: cstring, args: varargs[untyped]) =
    appendToCall(fprintf(stderr, fmt), args)
    fprintf(stderr, "\n\n")

    let instruction = vm.ip - vm.chunk.code
    let line = vm.chunk[].getLine(instruction)
    fprintf(stderr, "[line %d] in script\n", line)

    vm.resetStack()

proc push(vm: var VM, value: Value) =
    if vm.count >= vm.capacity:
        let oldCapacity = vm.capacity
        vm.capacity = memory.growCapacity(oldCapacity)
        vm.stack = memory.growArray(vm.stack, oldCapacity, vm.capacity)
        if vm.stackTop == nil:
            vm.stackTop = vm.stack
    vm.stackTop[] = value
    vm.stackTop += 1

proc pop(vm: var VM): Value =
    if vm.stackTop == vm.stack:
        return nullVal()
    vm.stackTop -= 1
    return vm.stackTop[]

func peek(vm: var VM, distance: int): Value =
    (vm.stackTop - distance - 1)[]

proc initVM* =
    vmtypes.vm = VM()
    vmtypes.vm.resetStack()
    vmtypes.vm.objects = nil

proc freeObjects*(vm: var VM) =
    var obj = vm.objects
    while obj != nil:
        let next = obj.next
        obj.free()
        obj = next

proc free*(vm: var VM) =
    if vm.chunk != nil:
        vm.chunk[].free()
    vm.freeObjects()

func readByte(vm: var VM): uint8 =
    result = vm.ip[]
    vm.ip += 1

func readConstant(vm: var VM): Value =
    return (vm.chunk.constants.values + vm.readByte())[]

func readConstantLong(vm: var VM): Value =
    let hi = vm.readByte()
    let mid = vm.readByte()
    let lo = vm.readByte()
    let constant = (hi.uint shl 8) + (mid.uint shl 4) + lo.uint
    return (vm.chunk.constants.values + constant)[]

template binaryOp[T](vm: var VM, valueType: proc(x: T): Value, op: untyped) =
    block:
        if not (vm.peek(0).isInt() and vm.peek(1).isInt()):
            vm.runtimeError("Operands must be numbers")
            return irRuntimeError
        let b = vm.pop().asInt()
        let a = vm.pop().asInt()
        vm.push(valueType(op(a, b)))

proc concatenate(vm: var VM) =
    let b = vm.pop().asString()
    let a = vm.pop().asString()

    let length = a.length + b.length
    let chars = memory.allocate(char, length + 1)
    copyMem(chars, a.chars, a.length)
    copyMem(chars + a.length, b.chars, b.length)
    (chars + length)[] = '\0'

    let res = takeString(chars, length)
    vm.push(objVal(res))

proc run*(vm: var VM): InterpretResult =
    while true:
        when DEBUG_TRACE_EXECUTION:
            printf("          ", vm.stack, vm.stackTop)
            var slot = vm.stack
            while slot < vm.stackTop:
                printf("[ ")
                slot[].print()
                printf(" ]")
                slot += 1
            printf("\n")
            discard disassembleInstruction(vm.chunk[], vm.ip - vm.chunk.code)
        let instruction = vm.readByte()
        case instruction:
            of opConstant.uint8:
                let constant = vm.readConstant()
                vm.push(constant)
            of opConstantLong.uint8:
                let constant = vm.readConstantLong()
                vm.push(constant)
            of opNull.uint8:
                vm.push(nullVal())
            of opTrue.uint8:
                vm.push(boolVal(true))
            of opFalse.uint8:
                vm.push(boolVal(false))
            of opEqual.uint8:
                let b = vm.pop()
                let a = vm.pop()
                vm.push(boolVal(a.equals(b)))
            of opGreater.uint8:
                vm.binaryOp(boolVal, `>`)
            of opLess.uint8:
                vm.binaryOp(boolVal, `<`)
            of opAdd.uint8:
                if vm.peek(0).isString() and vm.peek(1).isString():
                    vm.concatenate()
                elif vm.peek(0).isInt() and vm.peek(1).isInt():
                    let b = vm.pop().asInt()
                    let a = vm.pop().asInt()
                    vm.push(intVal(a + b))
                else:
                    vm.runtimeError("Operands must be two numbers or two strings")
                    return irRuntimeError
            of opSubtract.uint8:
                vm.binaryOp(intVal, `-`)
            of opMultiply.uint8:
                vm.binaryOp(intVal, `*`)
            of opDivide.uint8:
                vm.binaryOp(intVal, `div`)
            of opNot.uint8:
                vm.push(boolVal(vm.pop().isFalsey()))
            of opNegate.uint8:
                if not vm.peek(0).isInt():
                    vm.runtimeError("Operand must be a number")
                    return irRuntimeError
                vm.push(intVal(vm.pop().asInt()))
            of opReturn.uint8:
                vm.pop().print()
                printf("\n")
                return irOk
            else:
                discard

proc interpret*(vm: var VM, source: ptr char): InterpretResult =
    var c = initChunk()

    if not compile(source, addr c):
        c.free()
        return irCompileError

    vm.chunk = addr c
    vm.ip = c.code

    result = vm.run()
    c.free()
    vm.chunk = nil
    vm.ip = nil
