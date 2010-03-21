
local PLUGIN = {}

PLUGIN.Name = "Gimp"
PLUGIN.Author = "PC Camp"
PLUGIN.Date = "May, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

/*====================================================
================== CONFIGURATION =====================
====================================================*/
	local GimpSentences = {
	"im a nub",
	"i love it when the admin physguns meh :P",
	"DIS IS SPARTA!!!",
	"my g, why r u guys such nubs?",
	"k rly, u guys sux at teh wirmod!",
	"admin? cn u jail me?",
	"whr do babys cum fom?",
	"I LOV BEIN GIMPED BI TEH ADMINZZZ!!!"
	}
/*====================================================
======================================================
====================================================*/

	ASS_NewLogLevel("ASS_ACL_GIMP")
	
	function PLUGIN.Gimp( PLAYER, CMD, ARGS )

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

			if (ASS_RunPluginFunction( "AllowGimp", true, PLAYER, TO_RECIEVE, ENABLE )) then

				if (ENABLE) then
					TO_RECIEVE:SetNWBool( "playergimped", true )
					ASS_LogAction( PLAYER, ASS_ACL_GIMP, "gimped " .. ASS_FullNick(TO_RECIEVE) )
				else
					TO_RECIEVE:SetNWBool( "playergimped", false )
					ASS_LogAction( PLAYER, ASS_ACL_GIMP, "ungimped " .. ASS_FullNick(TO_RECIEVE) )
				end
								
			end

		end

	end
	concommand.Add("ASS_Gimp", PLUGIN.Gimp)
	
	function PLUGIN.IsPlayerGimped( PLAYER, TEXT, TEAMSPEAK )
		if file.Exists( "../lua/plugins/ass_mute.lua" ) and PLAYER:GetNWBool( "playermuted" ) then return end
		if PLAYER:GetNWBool( "playergimped" ) then
			return GimpSentences[ math.random( 1, #GimpSentences ) ]
		end
	end
	hook.Add( "PlayerSay", "IsPlayerGimped", PLUGIN.IsPlayerGimped)
	hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawnMute", function( PLAYER ) PLAYER:SetNWBool( "playergimped", false ) end )

end

if (CLIENT) then

	function PLUGIN.Gimp(PLAYER, ALLOW)

		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_Gimp", ITEM:UniqueID(), ALLOW )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_Gimp", PLAYER:UniqueID(), ALLOW )
		end
			
	end
	
	function PLUGIN.GimpEnableDisable(MENU, PLAYER)

		MENU:AddOption( "Enable",	function() PLUGIN.Gimp(PLAYER, 1) end )
		MENU:AddOption( "Disable",	function() PLUGIN.Gimp(PLAYER, 0) end )

	end

	function PLUGIN.AddMenu(DMENU)			

		DMENU:AddSubMenu( "Gimp", nil, 
			function(NEWMENU) 
				ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.GimpEnableDisable  ) 
			end
		)
		
	end

end

ASS_RegisterPlugin(PLUGIN)


