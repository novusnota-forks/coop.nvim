--- Table utilities.
---
--- Terminology:
---
--- - A list is a table with integer keys starting from 1.
--- - A packed list is a list with a field `n` that holds the number of elements in the list.
local M = {}

-- ADR: List functions accept a length parameter to avoid problems with nils.

--- Packs a vararg expression into a table.
---
---@param ... ...
---@return table packed_list
M.pack = function(...)
	-- selene: allow(mixed_table)
	return { n = select("#", ...), ... }
end

--- Unpacks a packed list.
---
---@param packed table a packed list
---@return ... unpacked list
M.unpack_packed = function(packed)
	return unpack(packed, 1, packed.n)
end

--- Shifts elements of a list to the left.
---
---@param t table The list to shift.
---@param len number The size of t.
---@return table list
M.shift_left = function(t, len)
	if len == 0 then
		return t
	end

	local first = t[1]
	for i = 1, len - 1 do
		t[i] = t[i + 1]
	end
	t[len] = first

	return t
end

--- Shifts elements of a list to the right.
---
---@param t table The list to shift.
---@param len number The size of t.
---@return table list
M.shift_right = function(t, len)
	if len == 0 then
		return t
	end

	local last = t[len]
	for i = len, 2, -1 do
		t[i] = t[i - 1]
	end
	t[1] = last
	return t
end

return M
