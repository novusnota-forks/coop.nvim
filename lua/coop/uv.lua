--- This module provides task function versions of vim.uv functions.
local M = {}

local coop = require("coop")
local functional_utils = require("coop.functional-utils")
local shift_cb = functional_utils.shift_parameters

--- Wraps the callback param with `vim.schedule_wrap`.
---
--- This is useful for Libuv functions to ensure that their continuations can run `vim.api` functions without problems.
---
---@param f function
---@param cb_pos? number the position of the callback parameter
---@return function
local schedule_cb = function(f, cb_pos)
	cb_pos = cb_pos or 1

	return function(cb, ...)
		local pack = require("coop.table-utils").pack
		local unpack = require("coop.table-utils").unpack_packed
		local safe_insert = require("coop.table-utils").safe_insert
		local args = pack(...)
		safe_insert(args, cb_pos, args.n, vim.schedule_wrap(cb))
		args.n = args.n + 1
		f(unpack(args))
	end
end

local wrap = function(f, cb_pos)
	return coop.cb_to_tf(schedule_cb(f, cb_pos))
end

M.timer_start = coop.cb_to_tf(schedule_cb(shift_cb(vim.uv.timer_start)))
M.fs_open = wrap(vim.uv.fs_open, 4)
M.fs_close = wrap(vim.uv.fs_close, 2)
M.fs_fstat = wrap(vim.uv.fs_fstat, 2)
M.fs_opendir = wrap(vim.uv.fs_opendir, 2)
M.fs_readdir = wrap(vim.uv.fs_readdir, 2)
M.fs_closedir = wrap(vim.uv.fs_closedir, 2)

--- Sleeps for a number of milliseconds.
---
---@async
---@param ms number The number of milliseconds to sleep.
M.sleep = function(ms)
	local timer = vim.uv.new_timer()
	M.timer_start(timer, ms, 0)
	timer:stop()
	timer:close()
end

return M
