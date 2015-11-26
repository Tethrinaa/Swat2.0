-- Collection of some generic util functions
--

-- Rounds the passed double to the nearest integer
function Round(x)
    return math.floor(x + 0.5)
end

-- Returns a vector with values of 0,maxSize in both the x and y directions
-- This differs from RandomVector(size) which returns a Vector in a random direction and random amplitude of the supplied size
-- Ex: RandomSizedVector(10) -> Vector(0, 10, 0), Vector (0, 1, 0), Vector(-3, -2, 0)...etc
function RandomSizedVector(maxSize)
    return Vector(RandomInt(-1 * maxSize, maxSize), RandomInt(-1 * maxSize, maxSize), 0)
end

-- Will randomize the passed in list
function RandomizeList(list)
    for i = 1,#list do
        local randNum = RandomInt(1,#list)
        local temp = list[randNum]
        list[randNum] = list[i]
        list[i] = temp
    end
end

function ShallowPrintTable(t)
	if t and type(t) == "table" then
		for k,v in pairs(t) do
			print(k,v)
		end
	end
end

function PrintEntityFunctions(t, all)

	local mt = getmetatable(t)
	if not mt then
		print("Object has no metatable.")
		return
	end

	print("**********************Object methods**********************")	
	mt = mt.__index
	if mt and mt ~= t then
		ShallowPrintTable(mt)
		if all then
			PrintEntityFunctions(mt)
		end
	end
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
    return x % (p + p) >= p
end

function bit(p)
    return 2 ^ (p - 1)  -- 1-based indexing
end

function round(n)
  return math.floor((math.floor(n*2) + 1)/2)
end
