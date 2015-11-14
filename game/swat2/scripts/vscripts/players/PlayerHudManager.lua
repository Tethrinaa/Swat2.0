-- The main manager of player related functions

SHOW_PLAYER_HUD_LOGS = SHOW_PLAYER_LOGS

PLAYER_HUD_UPDATE_DELAY = 1 -- time (in seconds) to wait between updating the hud

PlayerHudManager = {}
function PlayerHudManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Stores Hud Info tables based on playerIndex
    self.playerIndexToHudInfo = {}

    return o
end

function PlayerHudManager:startHudUpdateLoop()
    Timers:CreateTimer(0, function()
        self:updatePlayerHud()
        return PLAYER_HUD_UPDATE_DELAY
    end)
end

function PlayerHudManager:updatePlayerHud()
    local allPlayersHudInfo = {}

    for _,playerInfo in pairs(g_PlayerManager.playersInfo) do
        local playerHudInfo = self.playerIndexToHudInfo[playerInfo.playerIndex]
        if not playerHudInfo then
            -- We've never seen this player before. Add him in
            if SHOW_PLAYER_HUD_LOGS then
                print("Creating Hud Info for playerIndex=" .. playerInfo.playerIndex)
            end
            playerHudInfo = {
                playerindex=playerInfo.playerIndex
                , playername=playerInfo.playerName
                , playerclass=playerInfo.className
                , playerrank="officerI"
                , playerhealth=500
                , playermana=1000
                , playermaxhealth=500
                , playermaxmana=1000
            }
            self.playerIndexToHudInfo[playerInfo.playerIndex] = playerHudInfo
        end

        local hero = playerInfo.hero
        if hero then
            if hero:IsAlive() then
                playerHudInfo.playerhealth=hero:GetHealth()
                playerHudInfo.playermana=hero:GetMana()
                playerHudInfo.playermaxhealth=hero:GetMaxHealth()
                playerHudInfo.playermaxmana=hero:GetMaxMana()
            else
                playerHudInfo.playerhealth=0
                playerHudInfo.playermana=0
                playerHudInfo.playermaxhealth=hero:GetMaxHealth()
                playerHudInfo.playermaxmana=hero:GetMaxMana()
            end
        end
		--PrintTable(playerHudInfo)
    end
	
	-- sends the player info tables to the squad status UI
	CustomGameEventManager:Send_ServerToAllClients("squad_update", self.playerIndexToHudInfo )
end
