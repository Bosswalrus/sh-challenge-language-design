local bytecode = require("bytecode")
local opcode_table = require("interpreter.opcode-table")

--- The virtual machine class encapsulates the entire runtime of SHLang.
--- @class virtual_machine
local virtual_machine = {}
virtual_machine.__index = virtual_machine


--- Creates a new virtual_machine.
--- @param istream input_stream
function virtual_machine.new(istream) -- luacheck: ignore 212/istream
	local vm = setmetatable({
		_pc = 0,
		_sp = 0,
		_bp = 0,
		_argc = 0,
		_inputs = {},
		_pc_stack = {},
		_bp_stack = {},
		_value_stack = {},
		_instruction_memory = virtual_machine._read_file(istream),
	}, virtual_machine)

	istream:close()
	return vm
end

--- Executes SHLang bytecode and returns the result of the final expression.
--- @param inputs number[]
--- @return number
function virtual_machine:execute(inputs)
	self._inputs = inputs
	self:_check_signature()

	while self._pc < #self._instruction_memory do
		local instruction = self:_decode()
		instruction.handler(self, instruction.operand)
	end

	return self._value_stack[self._sp]
end

--- @param idx integer
--- @return number
function virtual_machine:input(idx)
	return self._inputs[idx + 1] or (0/0)
end

--- @param idx integer
--- @return number
function virtual_machine:global(idx)
	return self._value_stack[idx + 1]
end

--- @param idx integer
--- @return number
function virtual_machine:stack(idx)
	return self._value_stack[self._bp + idx + 1]
end

--- @param idx integer
--- @param value number
function virtual_machine:set_stack(idx, value)
	self._value_stack[self._bp + idx + 1] = value
end

--- @param value number
function virtual_machine:push(value)
	self._value_stack[self._sp + 1] = value
	self._sp = self._sp + 1
end

--- @return number
function virtual_machine:pop()
	local val = assert(self._value_stack[self._sp], "stack underflow")
	self._sp = self._sp - 1
	return val
end

--- @param argc integer
function virtual_machine:arg(argc)
	self._argc = argc
end

--- @param operand integer
function virtual_machine:inv(operand)
	table.insert(self._bp_stack, self._bp)
	table.insert(self._pc_stack, self._pc)
	self._pc = self._pc + operand
	self._bp = math.min(self._sp, self._sp - self._argc + 1)
end

function virtual_machine:ret()
	local val = self:pop()
	self._sp = self._bp

	if #self._pc_stack > 0 then
		self._bp = table.remove(self._bp_stack)
		self._pc = table.remove(self._pc_stack)
	end

	self:push(val)
end

--- @param istream input_stream
function virtual_machine._read_file(istream)
	local contents = {}

	while istream:peek() do
		table.insert(contents, istream:get())
	end

	return table.concat(contents)
end

function virtual_machine:_check_signature()
	local sig = self._instruction_memory:sub(self._pc + 1, self._pc + 8)
	assert(sig == "SHLang-1", "bad signature")
	self._pc = self._pc + 8
end

--- @return integer
function virtual_machine:_read_byte()
	local byte = self._instruction_memory:byte(self._pc + 1, self._pc + 1)
	self._pc = self._pc + 1
	return byte
end

--- @return integer
function virtual_machine:_read_word()
	local word = string.unpack("<i4", self._instruction_memory:sub(self._pc + 1, self._pc + 4))
	self._pc = self._pc + 4
	return word
end

--- @return number
function virtual_machine:_read_double()
	local double = string.unpack("<d", self._instruction_memory:sub(self._pc + 1, self._pc + 8))
	self._pc = self._pc + 8
	return double
end

--- @return table
function virtual_machine:_decode()
	local opcode = self:_read_byte()
	local instruction = assert(opcode_table[opcode + 1], "bad opcode")
	local instructionProto = instruction.prototype
	local instructionInfo = { handler = instruction.handler }

	if instructionProto.format == bytecode.formats.ib then
		instructionInfo.operand = self:_read_byte()
	elseif instructionProto.format == bytecode.formats.iw then
		instructionInfo.operand = self:_read_word()
	elseif instructionProto.format == bytecode.formats.id then
		instructionInfo.operand = self:_read_double()
	end

	return instructionInfo
end

return virtual_machine
