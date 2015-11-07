package.path = package.path .. ";../?.lua"
require("util/Utils")

print("Round() Tests")
print("1 == " .. Round(1.2))
print("1 == " .. Round(1.499))
print("1 == " .. Round(0.5))
print("1 == " .. Round(0.999))
