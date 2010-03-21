
local PLUGIN = {}

PLUGIN.Name = "Burn"
PLUGIN.Author = "PC Camp"
PLUGIN.Date = "May, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_BURN")
	
	function PLUGIN.Burn( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local TO_RECIEVE = ASS_FindPlayer(ARGS[1])
			local ENABLE = tonumber(ARGS[2]) > 0

			if (!TO_RECIEVE) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end
			
			if (PLAYER != TO_RECIEVE) then
				if (TO_RECIEVE:IsBetterOrSame(PLAYER) && !ENABLE) then

					// disallow!
					ASS_MessagePlayer(PLAYER, "Access denied! \"" .. TO_RECIEVE:Nick() .. "\" has same or better access then you.")
					return
	
				end
			end

			if (ASS_RunPluginFunction( "AllowGod", true, PLAYER, TO_RECIEVE, ENABLE )) then

				if (ENABLE) then
					TO_RECIEVE:Ignite(60, 10)
					ASS_LogAction( PLAYER, ASS_ACL_BURN, "set " .. ASS_FullNick(TO_RECIEVE).." on fire" )
				else
					TO_RECIEVE:Extinguish()
					ASS_LogAction( PLAYER, ASS_ACL_BURN, "extinguished " .. ASS_FullNick(TO_RECIEVE) )
				end
								
			end

		end

	end
	concommand.Add("ASS_Burn", PLUGIN.Burn)

end

if (CLIENT) then

	function PLUGIN.Burn(PLAYER, ALLOW)

		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_Burn", ITEM:UniqueID(), ALLOW )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_Burn", PLAYER:UniqueID(), ALLOW )
		end
			
	end
	
	function PLUGIN.BurnEnableDisable(MENU, PLAYER)

		MENU:AddOption( "Enable",	function() PLUGIN.Burn(PLAYER, 1) end )
		MENU:AddOption( "Disable",	function() PLUGIN.Burn(PLAYER, 0) end )

	end

	function PLUGIN.AddMenu(DMENU)			

	DMENU:AddSubMenu( "Burn", nil, 
			function(NEWMENU) 
				ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.BurnEnableDisable  ) 
			end
		)

	end

end

ASS_RegisterPlugin(PLUGIN)


