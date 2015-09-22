--Don't currently have zombies setup, Uber stuff won't work.  Commenting out until ready for implementation
--TODO: Minidorid Uber, LAD Uber, when leveling up, when tor finished, when LAD gets EXP, when player leaves, when you lose,
--      Upgrade Mobs. 

--[[
function GameMode:RedUpdateUber()
   local nSumA = 0
   local nSumB = 0
   local iSumR = 0
   local i = 1
	
   while i <= Global_Max_Player_Count
   --Sets nSumA to nSumA + Player i's uber, if player i is connected
      nSumA = nSumA + Global_Uber[i][1]*Global_Uber[i][2]
      --Sets nSumB to nSumB + Player i's secondary uber, if player i is connected
      nSumB = nSumB + Global_Uber[i+13][1]*Global_Uber[i+13][2]
      i=i+1
   end
   
   --boss upgrades
   --lua has no math.round therefore we use math.floor(num+.5)
   Global_Uber[12] = math.floor(nSumB/Global_nDifficulty + .5) + Global_Uber[23] --23 is EXT only extra uber
   nSumB = 0
   i = 100
   
   while (true)
      if nSumA > 100 then
         nSumA = nSumA - 100
		 nSumB = nSumB + 100*(i/100)
      else
	     nSumB = nSumB + nSumA*(i/100)
		 break
      end
	  i = i - 8 + Global_Nightmare
	  if i < 1 then
	     i = 1
	  end
   end
   
   --Mob Upgrades
   nSumB = nSumB + Global_LADUber
   --lua has no math.round therefore we use math.floor(num+.5)
   Global_Uber[13] = math.floor(nSumB/Global_nDifficulty + .5) + Global_Uber[23] --23 is EXT only extra uber
   
   if Global_Survival > 0 then
      i = 1
	  while i <= Global_Max_Player_Count
	    iSumR = iSumR + RedRankLevel( i )
		i = i+1
	  end
	  Global_Uber[12] = Global_Uber[12] + iSumR
	  Global_Uber[13] = Global_Uber[13] + iSumR
   end
   --call TriggerRegisterTimerEvent( gg_trg_UpgradeMobs, 0.1, false )
   --Not sure why red used a timer event for this.  Going to just call UpgradeMobs instead.   Might break.
   GameMode:UpgradeMobs()  
end
]]