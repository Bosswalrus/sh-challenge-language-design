local bytecode = require("bytecode")

local function op_add(vm) local b = vm:pop() vm:push(vm:pop() + b) end
local function op_sub(vm) local b = vm:pop() vm:push(vm:pop() - b) end
local function op_mul(vm) local b = vm:pop() vm:push(vm:pop() * b) end
local function op_div(vm) local b = vm:pop() vm:push(vm:pop() / b) end
local function op_rem(vm) local b = vm:pop() vm:push(vm:pop() % b) end
local function op_exp(vm) local b = vm:pop() vm:push(vm:pop() ^ b) end
local function op_neg(vm) vm:push(-vm:pop()) end
local function op_imm(vm, operand) vm:push(operand) end
local function op_cpy(vm, operand) vm:push(vm:stack(operand)) end
local function op_rep(vm, operand) vm:set_stack(operand, vm:pop()) end
local function op_gbl(vm, operand) vm:push(vm:global(operand)) end
local function op_inp(vm) vm:push(vm:input(vm:pop())) end
local function op_arg(vm, operand) vm:arg(operand) end
local function op_inv(vm, operand) vm:inv(operand) end
local function op_ret(vm) vm:ret() end

local opcode_table = {
	{ handler = op_add, prototype = bytecode.instructions.add },
	{ handler = op_sub, prototype = bytecode.instructions.sub },
	{ handler = op_mul, prototype = bytecode.instructions.mul },
	{ handler = op_div, prototype = bytecode.instructions.div },
	{ handler = op_rem, prototype = bytecode.instructions.rem },
	{ handler = op_exp, prototype = bytecode.instructions.exp },
	{ handler = op_neg, prototype = bytecode.instructions.neg },
	{ handler = op_imm, prototype = bytecode.instructions.imm },
	{ handler = op_cpy, prototype = bytecode.instructions.cpy },
	{ handler = op_rep, prototype = bytecode.instructions.rep },
	{ handler = op_gbl, prototype = bytecode.instructions.gbl },
	{ handler = op_inp, prototype = bytecode.instructions.inp },
	{ handler = op_arg, prototype = bytecode.instructions.arg },
	{ handler = op_inv, prototype = bytecode.instructions.inv },
	{ handler = op_ret, prototype = bytecode.instructions.ret }
}

return opcode_table
