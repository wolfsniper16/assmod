
local PLUGIN = {}

PLUGIN.Name = "Clear Decals"
PLUGIN.Author = "PC Camper"
PLUGIN.Date = "2nd January 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	function PLUGIN.Cleardecals(Player, Arguments)
		if (Player:IsTempAdmin()) then
			local Players = player.GetAll()

			-- For Loop.

			for K, V in pairs(Players) do V:ConCommand("r_cleardecals\n") end
		end
	end
	concommand.Add("ASS_Cleardecals", PLUGIN.Cleardecals)
end

if (CLIENT) then

	function PLUGIN.Cleardecals(MENUITEM)
	
		LocalPlayer():ConCommand("ASS_Cleardecals\n")
	
	end
	
	function PLUGIN.AddMenu(DMENU)			
	
		DMENU:AddOption( "Clear Decals", PLUGIN.Cleardecals )

	end

end

ASS_RegisterPlugin(PLUGIN)
