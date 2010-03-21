//Assmod needed this so lets just copy paste this plugin becuase it just needs to do the same thing.


local PLUGIN = {}

PLUGIN.Name = "Stop Sounds"
PLUGIN.Author = "Pc Camp, Slayer3032"
PLUGIN.Date = "2nd January 2008, 8th December 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	function PLUGIN.StopSounds(Player, Arguments)
		if (Player:IsOperator()) then
			local Players = player.GetAll()

			-- For Loop.

			for K, V in pairs(Players) do V:ConCommand("stopsounds\n") end
		end
	end
	concommand.Add("ASS_StopSounds", PLUGIN.StopSounds)
end

if (CLIENT) then

	function PLUGIN.StopSounds(MENUITEM)
	
		LocalPlayer():ConCommand("ASS_StopSounds\n")
	
	end
	
	function PLUGIN.AddMenu(DMENU)			
	
		DMENU:AddOption( "Stop Sounds", StopSounds )

	end

end

ASS_RegisterPlugin(PLUGIN)
