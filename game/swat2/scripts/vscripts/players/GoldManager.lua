-- Class that handles player gold and gold sharing

SHOW_GOLD_MANAGER_LOGS = SHOW_DEBUG_LOGS

GoldManager = {}

function GoldManager:new(o)
	 o = o or {}
    setmetatable(o, self)
    self.__index = self
	
	self.leftoverGold = 0
	
	if SHOW_GOLD_MANAGER_LOGS then
		print("GoldManager | Initializing")
	end
	
	return o
end
	
--sets the amount that a player keeps for themselves
function GoldManager:setPlayerGoldKept(goldKept, playerID)
	self:updateGoldDisplay()
end

--gives gold to a certain player
function GoldManager:givePlayerGold(gold, playerID)
	self:updateGoldDisplay()
end

--distributes an amount of gold equally to all players as reliable gold
function GoldManager:distributeGold(gold, shouldInform)
	
	local playerCount = g_PlayerManager.playerCount
	local leftoverGold = gold % playerCount
	local givenGold = math.floor(gold/playerCount)
	self.leftoverGold = self.leftoverGold + leftoverGold
	
	if gold < 1 or playerCount < 1 then
		return
	end	
	local playerInfos = g_PlayerManager.playersInfo
	for _,playerInfo in pairs(playerInfos) do
		local playerId = playerInfo.playerId
		PlayerResource:SetGold( playerId, givenGold, true)
		if shouldInform then
			--TODO Message player if shouldInform
		end
    end
	
	if SHOW_GOLD_MANAGER_LOGS then
		print ( "GoldManager | "..givenGold.." credits given" )
	end
	
	--self:updateGoldDisplay()
end

--calculates hazard pay and distributes to all players as reliable gold
function GoldManager:distributeHazardPay()
	local hazardPay
	
	if g_GameManager.survivalValue > 0 then
		hazardPay = 180*g_PlayerManager.playerCount
	else
		--TODO Uncomment when civilian manager is finished
		--hazardPay = 10*(g_GameManager.difficultyValue+7)*g_PlayerManager.playerCount+g_CivillianManager.civsRescued*g_PlayerManager.playerCount
		hazardPay = 10*(g_GameManager.difficultyValue+7)*g_PlayerManager.playerCount*g_PlayerManager.playerCount
	end	
	
	GoldManager:distributeGold( hazardPay, false )
	
	if SHOW_GOLD_MANAGER_LOGS then
		print ("GoldManager | "..hazardPay.." credits given as hazard pay" )
	end
	
	--self:updateGoldDisplay()
end

--lets player send an amount of gold to golbal pool
function GoldManager:givePoolGold(gold, playerID)
	self:updateGoldDisplay()
end

function GoldManager:takePoolGold(gold, playerID)
	self:updateGoldDisplay()
end

--updates the gold ui display
function GoldManager:updateGoldDisplay()
	--sends tables for each player
	table.insert(tables, {keptgold = self.keptgold, playergold = self.gold, globalgold = self.globalgold})
	CustomGameEventManager:Send_ServerToAllClients("display_gold", tables )
end
	

--TODO REMOVE: Basic Functions
--starting gold (reliable gold)
--killing heroes (reliable gold)
--passive gold over time
--killing creeps
--buying items (uses unreliable gold first, then reliable gold)
--dying (lose 30xherolevel unreliable gold)
--selling items
--hazard pay
--buying back (can immediatly respawn when dead, for a fee) (uses reliable gold first, and cancles unreliable gold gain for some time)
--if player is disconnected for more then 5 min, all unreliable gold is equally divided including passicve gold gain
--requesting gold from other players
--giving gold to other players


--TODO REMOVE: Plan
--Have global gold pool.
--Each player decides how much they want to keep
--If the player's gold amount changes, send the remainder
-----to the global pool , update both


