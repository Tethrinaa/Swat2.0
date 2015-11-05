-- Basic data structure for a Queue in Lua
-- Supports acting as both a Stack (push_last, pop_last) and a proper Queue  (push_last, pop_first)

Queue = {}

function Queue:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

    self.first = 0
    self.last = -1

    return o
end

function Queue:push_first (value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

function Queue:push_last (value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function Queue:peek_first ()
    return self[self.first]
end

function Queue:peek_last (value)
    return self[self.last]
end

function Queue:getSize()
    return self.last - self.first + 1
end

function Queue:pop_first ()
	local first = self.first
	if first > self.last then error("queue is empty") end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1
	return value
end

function Queue:pop_last ()
	local last = self.last
	if self.first > last then error("queue is empty") end
	local value = self[last]
	self[last] = nil         -- to allow garbage collection
	self.last = last - 1
	return value
end
