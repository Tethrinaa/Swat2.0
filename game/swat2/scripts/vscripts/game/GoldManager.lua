-- Class that handles player gold and sharing

SHOW_GOLD_MANAGER_LOGS = SHOW_GAME_SYSTEM_LOGS

GoldManager = {}



function GoldManager:new(o)
	 o = o or {}
    setmetatable(o, self)
    self.__index = self
	
	self.debugMode = true
	
	self.globalGold = 0
	self.players = 0
	
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

--distributes an amount of gold equally to all players
function GoldManager:distributeGold(gold)
	self:updateGoldDisplay()
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
	

--TODO REMOVE: Useful provided DOTA2 code (much more at https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API)
--CDOTABaseAbility------------------------------------------
-------------------------------------------------------------
--GetGold Cost: int GetGoldCost(int iLevel)
--GetGoldCostForUpgrade: int GetGoldCostForUpgrade(int iLevel)
--IsOwnersGoldEnough: bool IsOwnersGoldEnough(int nIssuerPlayerID)
--IsOwnersGoldEnoughForUpgrade: bool IsOwnersGoldEnoughForUpgrade()
--PayGoldCost: 	void PayGoldCost()
--PayGoldCostForUpgrade: void PayGoldCostForUpgrade()
--UseResources: void UseResources(bool bMana, bool bGold, bool bCooldown)
--CDOTAPlayer------------------------------------------------
-------------------------------------------------------------
--GetPlayerID: int GetPlayerID() Get the player's official PlayerID; notably is -1 when the player isn't yet on a team.
--CDOTA_PlayerResource---------------------------------------
--Global accessor variable: PlayerResource-------------------
--AddGoldSpentOnSupport: void AddGoldSpentOnSupport(int iPlayerID, int iCost)
--GetGold:	int GetGold(int playerID)	Returns how much gold the specified player currently has	
--GetGoldLostToDeath: int GetGoldLostToDeath(int iPlayerID)	
--GetGoldPerMin: float GetGoldPerMin(int iPlayerID)
--GetGoldSpentOnBuybacks: int GetGoldSpentOnBuybacks(int iPlayerID)	
--GetGoldSpentOnConsumables: int GetGoldSpentOnConsumables(int iPlayerID)	
--GetGoldSpentOnItems: int GetGoldSpentOnItems(int iPlayerID)	
--GetGoldSpentOnSupport: int GetGoldSpentOnSupport(int iPlayerID)
--GetReliableGold: int GetReliableGold(int playerID)
--GetTotalEarnedGold: int GetTotalEarnedGold(int iPlayerID)
--GetTotalGoldSpent: int GetTotalGoldSpent(int iPlayerID)
--GetUnreliableGold: int GetUnreliableGold(int playerID)	Returns how much unreliable gold the specified player currently has
--ModifyGold	int ModifyGold(int playerID, int goldAmmt, bool reliable, int nReason)
--ResetBuybackCostTime	void ResetBuybackCostTime(int nPlayerID)	No Description Set
--ResetTotalEarnedGold	void ResetTotalEarnedGold(int iPlayerID)
--SetBuybackGoldLimitTime	void SetBuybackGoldLimitTime(int nPlayerID, float flBuybackCooldown)
--SetGold	void SetGold(int playerID, int amount, bool reliableGold)	Sets the reliable/unreliable gold of the specified player
--SpendGold	void SpendGold(int playerID, int amount, int reason)	No Description Set
--CDOTABaseGameMode------------------------------------------
-------------------------------------------------------------
--SetLoseGoldOnDeath	void SetLoseGoldOnDeath(bool bEnabled)	Use to disable gold loss on death.
--SetModifyGoldFilter	void SetModifyGoldFilter(handle hFunction, handle hContext)	Set a filter function to control the behavior when a hero's gold is modified. (Modify the table and Return true to use new values, return false to cancel the event)
--CDOTAGamerules---------------------------------------------
-------------------------------------------------------------
--SetGoldPerTick	void SetGoldPerTick(int int_1)	Set the auto gold increase per timed interval.
--SetGoldTickTime	void SetGoldTickTime(float float_1)	Set the time interval between auto gold increases.
--SetStartingGold	void SetStartingGold(int int_1)	Set the starting gold amount.
--EDOTA_ModifyGold_Reason---------------------------------------------
-------------------------------------------------------------
-- DOTA_ModifyGold_Unspecified	0	
-- DOTA_ModifyGold_Death	1	
-- DOTA_ModifyGold_Buyback	2	
-- DOTA_ModifyGold_PurchaseConsumable	3	
-- DOTA_ModifyGold_PurchaseItem	4	
-- DOTA_ModifyGold_AbandonedRedistribute	5	
-- DOTA_ModifyGold_SellItem	6	
-- DOTA_ModifyGold_AbilityCost	7	
-- DOTA_ModifyGold_CheatCommand	8	
-- DOTA_ModifyGold_SelectionPenalty	9	
-- DOTA_ModifyGold_GameTick	10	
-- DOTA_ModifyGold_Building	11	
-- DOTA_ModifyGold_HeroKill	12	
-- DOTA_ModifyGold_CreepKill	13	
-- DOTA_ModifyGold_RoshanKill	14	
-- DOTA_ModifyGold_CourierKill	15	
-- DOTA_ModifyGold_SharedGold	16


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


