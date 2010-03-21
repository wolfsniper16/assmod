
local PLUGIN = {}

PLUGIN.Name = "Mute"
PLUGIN.Author = "PC Camp"
PLUGIN.Date = "May, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_MUTE")
	
	function PLUGIN.Mute( PLAYER, CMD, ARGS )

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

			if (ASS_RunPluginFunction( "AllowMute", true, PLAYER, TO_RECIEVE, ENABLE )) then

				if (ENABLE) then
					TO_RECIEVE:SetNWBool( "playermuted", true )
					ASS_LogAction( PLAYER, ASS_ACL_MUTE, "muted " .. ASS_FullNick(TO_RECIEVE) )
				else
					TO_RECIEVE:SetNWBool( "playermuted", false )
					ASS_LogAction( PLAYER, ASS_ACL_MUTE, "un-muted " .. ASS_FullNick(TO_RECIEVE) )
				end
								
			end

		end

	end
	concommand.Add("ASS_Mute", PLUGIN.Mute)
	
	function PLUGIN.IsPlayerMuted( PLAYER, TEXT, TEAMSPEAK )
		if PLAYER:GetNWBool( "playermuted" ) then
			return ""
		end
	end
	hook.Add( "PlayerSay", "IsPlayerMuted", PLUGIN.IsPlayerMuted)
	hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawnMute", function( PLAYER ) PLAYER:SetNWBool( "playermuted", false ) end )
	
end

if (CLIENT) then

	function PLUGIN.Mute(PLAYER, ALLOW)

		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_Mute", ITEM:UniqueID(), ALLOW )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_Mute", PLAYER:UniqueID(), ALLOW )
		end
			
	end
	
	function PLUGIN.MuteEnableDisable(MENU, PLAYER)

		MENU:AddOption( "Enable",	function() PLUGIN.Mute(PLAYER, 1) end )
		MENU:AddOption( "Disable",	function() PLUGIN.Mute(PLAYER, 0) end )

	end

	function PLUGIN.AddMenu(DMENU)			

		DMENU:AddSubMenu( "Mute", nil, 
			function(NEWMENU) 
				ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.MuteEnableDisable  ) 
			end
		)
		
	end

end

ASS_RegisterPlugin(PLUGIN)


