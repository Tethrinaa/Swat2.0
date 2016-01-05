-- This file is responsible for managing the shops: ABMs and Lab shop

ShopsManager = {}

SHOW_SHOPS_LOGS = SHOW_GAME_SYSTEM_LOGS

ShopsManager.ABM_UNIT_NAME = "game_black_market"

function ShopsManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.abms = {}

    return o
end

function ShopsManager:spawnUnpoweredAbms()
    for _,region in pairs(Locations.abms) do
        local abm = CreateUnitByName("game_black_market", GetCenterInRegion(region), true, nil, nil, DOTA_TEAM_NEUTRALS )
        table.insert(self.abms, abm)
    end
end

function ShopsManager:powerAbms()
    local abm_triggers = Entities:FindByName(nil, "abm_triggers_parent"):GetChildren()
    local locations = Locations.abms

    for i = 1,#locations do
        local position = GetCenterInRegion(locations[i])
        local trigger = abm_triggers[i]

        trigger:Enable() -- Triggers start disabled. Now we want to allow shops
        trigger:SetOrigin(position)

        -- Center the damn thing
        -- (Origin is not the center of the region)
        local center = trigger:GetCenter()
        local newOrigin = Vector(position.x - (center.x - position.x)
                                 , position.y - (center.y - position.y)
                                 , position.z - (center.z - position.z))
        trigger:SetOrigin(newOrigin)
    end

    for _,abm in pairs(self.abms) do
        abm:RemoveAbility("game_black_market_powered_off")
        abm:RemoveModifierByName("modifier_black_market_powered_off")
        abm:AddAbility("game_black_market_powered_on")
        abm:FindAbilityByName("game_black_market_powered_on"):SetLevel(1)
    end
end
