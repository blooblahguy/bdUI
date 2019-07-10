memoize = {
  _VERSION     = 'memoize v2.0',
  _DESCRIPTION = 'Memoized functions in Lua',
  _URL         = 'https://github.com/kikito/memoize.lua',
  _LICENSE     = [[
    MIT LICENSE
    Copyright (c) 2018 Enrique García Cota
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}
-- Inspired by http://stackoverflow.com/questions/129877/how-do-i-write-a-generic-memoize-function

-- Lua 5.3 compatibility
local unpack = unpack or table.unpack
local tostring = tostring
local getmetatable = getmetatable
local type = type
local strformat = string.format

-- private stuff

local function is_callable(f)
	local tf = type(f)
	if tf == 'function' then return true end
	if tf == 'table' then
		local mt = getmetatable(f)
		return type(mt) == 'table' and is_callable(mt.__call)
	end
	return false
end

local function cache_get(cache, params)
	local node = cache
	local param
	for i=1, #params do
		param = params[i]

		node = node.children and node.children[param]
		if not node then return nil end

	end
	return node.results
end

local function cache_put(cache, params, results)
	local node = cache
	local param
	for i = 1, #params do
		param = params[i]

		node.children = node.children or {}
		node.children[param] = node.children[param] or {}
		node = node.children[param]

	end
	node.results = results
end

-- public function
-- you can use your own local cache by passing it, otherwise it goes into global cache which is weak
local memoizecache = {}
local currentf = nil
function memoize.memoize(f, cache)
	if not is_callable(f) then
		error(strformat( "Only functions and callable tables are memoizable. Received %s (a %s)", tostring(f), type(f)))
	end

	cache = cache or memoizecache
	currentf = f

	return function (...)
		local params = {...}

		-- don't allow nil values
		for i = 1, #params do
			if params[i] == nil then params[i] = false end
		end

		local results = cache_get(cache, params)
		if not results then
			results = { f(...) }
			cache_put(cache, params, results)
		end

		return unpack(results)
	end
end

-- bdCore modification: this being weak means that empty values will be expunged on collectgarbage
setmetatable(memoizecache, {__mode = "kv"}) -- make it weak
setmetatable(memoize, { __call = function(_, ...) return memoize.memoize(...) end })