
local PLUGIN = {}

PLUGIN.Name = "Voice Mute"
PLUGIN.Author = "PC Camp"
PLUGIN.Date = "May, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_VOICEMUTE")
	
	function PLUGIN.VoiceMute( PLAYER, CMD, ARGS )

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

			if (ASS_RunPluginFunction( "AllowVoiceMute", true, PLAYER, TO_RECIEVE, ENABLE )) then

				if (ENABLE) then
					TO_RECIEVE:SetNWBool( "PlayerMuted", true )
					ASS_LogAction( PLAYER, ASS_ACL_VOICEMUTE, "voice muted " .. ASS_FullNick(TO_RECIEVE) )
				else
					TO_RECIEVE:SetNWBool( "PlayerMuted", false )
					ASS_LogAction( PLAYER, ASS_ACL_VOICEMUTE, "un-voice muted " .. ASS_FullNick(TO_RECIEVE) )
				end
								
			end

		end

	end
	concommand.Add("ASS_VoiceMute", PLUGIN.VoiceMute)
	
	function PLUGIN.IsPlayerVoiceMuted( PLAYER )
		for k, v in pairs( player.GetAll() ) do
			if v and v:GetNWBool( "PlayerMuted" ) then
				v:ConCommand( "-voicerecord " )
			end
		end
	end
	
	hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawnVoiceMute", function( PLAYER ) PLAYER:SetNWBool( "PlayerMuted", false ) end )

end

if (CLIENT) then

	function PLUGIN.VoiceMute(PLAYER, ALLOW)

		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_VoiceMute", ITEM:UniqueID(), ALLOW )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_VoiceMute", PLAYER:UniqueID(), ALLOW )
		end
			
	end
	
	function PLUGIN.VoiceMuteEnableDisable(MENU, PLAYER)

		MENU:AddOption( "Enable",	function() PLUGIN.VoiceMute(PLAYER, 1) end )
		MENU:AddOption( "Disable",	function() PLUGIN.VoiceMute(PLAYER, 0) end )

	end

	function PLUGIN.AddMenu(DMENU)			

		DMENU:AddSubMenu( "Voice Mute", nil, 
			function(NEWMENU) 
				ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.VoiceMuteEnableDisable  ) 
			end
		)
		
	end

end

hook.Add( "Think", "ThinkForVoiceMute", PLUGIN.IsPlayerVoiceMuted )

ASS_RegisterPlugin(PLUGIN)


