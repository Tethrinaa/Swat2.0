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
