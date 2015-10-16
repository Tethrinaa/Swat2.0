package.path = package.path .. ";../../?.lua"
print(package.path)
require("internal/util")
require("game/objectives/RadiationManager")

radMan = RadiationManager:new()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:addRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)
radMan:removeRadResistPlayer()
print("radResistPlayers: " .. radMan.radResistPlayers .. " | radiationResistance: " .. radMan.radiationResistance)

print("\n\n")
for i = 0, 5 do
    radMan.radResistPlayers = i
    print("applyRadiationResistance(90.0) [ " .. i .. " players ]" .. radMan:getNukeRadiationResistance(90.0))
end

print("\n\n")
radMan.radiationLevel = -5
radMan.radFragments = 40
radMan.radResistPlayers = 0
radMan.hazmatContainers = 0
radMan:updateRadLevel()
print("2 == " .. radMan.radiationLevel)
radMan.radiationLevel = -5
radMan.radFragments = 60
radMan.radResistPlayers = 0
radMan.hazmatContainers = 0
radMan:updateRadLevel()
print("3 == " .. radMan.radiationLevel)
radMan.radiationLevel = -5
radMan.radFragments = 0
radMan.radResistPlayers = 0
radMan.hazmatContainers = 0
radMan:updateRadLevel()
print("-1 == " .. radMan.radiationLevel)
radMan.radiationLevel = -5
radMan.radFragments = 1
radMan.radResistPlayers = 1
radMan.hazmatContainers = 0
radMan:updateRadLevel()
print("0 == " .. radMan.radiationLevel)
radMan.radiationLevel = -5
radMan.radFragments = 0
radMan.radResistPlayers = 1
radMan.hazmatContainers = 1
radMan:updateRadLevel()
print("0 == " .. radMan.radiationLevel)

radMan:spawnInitialRadFragments()
