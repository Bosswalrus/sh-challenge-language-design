--- Keeps track of accessible identifiers and their parents.
--- @class symbol_table
local symbol_table = {}
symbol_table.__index = symbol_table

--- A symbol keeps track of a node shared between identical names and a reference to the previous symbol.
--- @class symbol
--- @field node abstract_node
--- @field previous symbol | nil

--- Creates a symbol_table.
--- @return symbol_table
function symbol_table.new()
	return setmetatable({ _symbols = {}, _previous = nil }, symbol_table)
end

--- Opens a new scope.
function symbol_table:open_scope()
	local st = symbol_table.new()
	st._symbols = self._symbols
	st._previous = self._previous
	self._symbols = {}
	self._previous = st
end

--- Closes the current scope.
function symbol_table:close_scope()
	assert(self._previous, "symbol_table::close_scope(): no parent scope!")
	self._symbols, self._previous = self._previous._symbols, self._previous._previous
end

--- Creates a new symbol.
--- @param name string
--- @param node abstract_node
--- @return symbol
function symbol_table:bind_symbol(name, node)
	local symbol = { node = node, previous = self._previous and self._previous[name] or nil }
	self._symbols[name] = symbol
	return symbol
end

--- Returns the symbol by the given name.
--- @param name string
--- @param depth integer | nil
--- @return symbol
function symbol_table:symbol(name, depth)
	local symbol = self._symbols[name]
	depth = depth or math.huge

	if not symbol and self._previous and depth > 0 then
		return self._previous:symbol(name, depth - 1)
	end

	return symbol
end

return symbol_table
