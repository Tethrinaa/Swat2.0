package.path = package.path .. ";../?.lua"
--print(package.path)
require("util/Queue")

queue = Queue:new()

-- Test as queue
queue:push_last(1)
queue:push_last(2)
queue:push_last(3)
print("size: 3 == " .. queue:getSize())
print("1 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("2 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("3 == " .. queue:peek_first() .. " == " .. queue:pop_first())

-- Test as stack
queue:push_first(4)
queue:push_first(5)
queue:push_first(6)
print("size: 3 == " .. queue:getSize())
print("4 == " .. queue:peek_last() .. " == " .. queue:pop_last())
print("5 == " .. queue:peek_last() .. " == " .. queue:pop_last())
print("6 == " .. queue:peek_last() .. " == " .. queue:pop_last())

-- Test as mixed
queue:push_first(3)
queue:push_last(4)
queue:push_first(2)
queue:push_last(5)
queue:push_first(1)
queue:push_last(6)
print("size: 6 == " .. queue:getSize())
print("1 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("2 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("3 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("4 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("5 == " .. queue:peek_first() .. " == " .. queue:pop_first())
print("6 == " .. queue:peek_first() .. " == " .. queue:pop_first())
