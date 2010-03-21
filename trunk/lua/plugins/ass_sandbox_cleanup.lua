
local PLUGIN = {}

PLUGIN.Name = "Sandbox Cleanup"
PLUGIN.Author = "Andy Vincent"
PLUGIN.Date = "24th December 2007"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = { "sandbox" } // only load this plugin for sandbox and it's derivatives

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_SANDBOX")

	function PLUGIN.Cleanup(PLAYER, CMD, ARGS)

		if (PLAYER:IsOperator()) then
		
			if (ARGS[1]) then

				local TO_CLEAN = ASS_FindPlayer(ARGS[1])

				if (!TO_CLEAN) then
					ASS_MessagePlayer(PLAYER, "Player not found!\n")
					return

				end

				if (TO_CLEAN:IsBetterOrSame(PLAYER) && TO_CLEAN != PLAYER) then
					ASS_MessagePlayer(PLAYER, "Access denied! \"" .. TO_CLEAN:Nick() .. "\" has same or better access then you.")
					return
				end

				cleanup.CC_Cleanup(TO_CLEAN, "", {} )

				ASS_LogAction( PLAYER, ASS_ACL_SANDBOX, "cleaned up " .. ASS_FullNick(TO_CLEAN) )

			else
			
				cleanup.CC_AdminCleanup(PLAYER, "", {} )
				ASS_LogAction( PLAYER, ASS_ACL_SANDBOX, "cleaned up the server" )
			
			end

		else

			// Player doesn't have enough access.
			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end
	end
	concommand.Add("ASS_Cleanup", PLUGIN.Cleanup)
	
end

if (CLIENT) then


	function PLUGIN.Cleanup(PLAYER)
	
		if (!PLAYER:IsValid()) then return end
		
		RunConsoleCommand( "ASS_Cleanup", PLAYER:UniqueID() )
		
	end


	function PLUGIN.AddGamemodeMenu(DMENU)			

		DMENU:AddSubMenu( "Cleanup", nil, 
			function(NEWMENU)
				NEWMENU:AddOption("Entire Server", function() RunConsoleCommand( "ASS_Cleanup" ) end )
				NEWMENU:AddSpacer()
				ASS_PlayerMenu(NEWMENU, {"IncludeAll", "IncludeLocalPlayer"}, PLUGIN.Cleanup )
			end )

	end
	
end

ASS_RegisterPlugin(PLUGIN)
