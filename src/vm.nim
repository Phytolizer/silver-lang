import io
import chunktypes
import common
import debug
import ptr_arithmetic
import value
import valuetypes
import vmtypes

from memory import nil

func resetStack(vm: var VM) =
    vm.stackTop = vm.stack
    
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
    vm.stackTop -= 1
    return vm.stackTop[]

func initVM*: VM =
    result = VM()
    result.resetStack()

proc free*(vm: var VM) =
    if vm.chunk != nil:
        dealloc(vm.chunk)

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

template binaryOp(vm: var VM, op: untyped) =
    block:
        let b = vm.pop()
        let a = vm.pop()
        vm.push(op(a, b))

proc run*(vm: var VM): InterpretResult =
    while true:
        if DEBUG_TRACE_EXECUTION:
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
            of opAdd.uint8:
                vm.binaryOp(`+`)
            of opSubtract.uint8:
                vm.binaryOp(`-`)
            of opMultiply.uint8:
                vm.binaryOp(`*`)
            of opDivide.uint8:
                vm.binaryOp(`/`)
            of opNegate.uint8:
                vm.push(-vm.pop())
            of opReturn.uint8:
                vm.pop().print()
                printf("\n")
                return irOk
            else:
                discard

proc interpret*(vm: var VM, source: ptr char): InterpretResult =
    discard
