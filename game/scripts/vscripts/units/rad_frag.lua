function RadRemoved()
   print("here")
   print("radiation:", Global_Radiation)
   Global_Radiation = Global_Radiation - 1
   if Global_Radiation == 0 then
      --Do stuff
   elseif Global_Radiation % 20 == 19 then
      Global_Radiation_Bracket = Global_Radiation_Bracket - 1
      print("radiation_bracket:", Global_Radiation_Bracket)
   end
   print("radiation:", Global_Radiation)
end