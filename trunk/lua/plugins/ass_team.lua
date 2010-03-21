
local PLUGIN = {}

PLUGIN.Name = "Team"
PLUGIN.Author = "Andy Vincent"
PLUGIN.Date = "10th August 2007"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

local Teams = {}
Teams[TEAM_CONNECTING] 	= "Joining/Connecting"
Teams[TEAM_UNASSIGNED] 	= "Unassigned"
Teams[TEAM_SPECTATOR] 	= "Spectator"

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_TEAM")
	
	function PLUGIN.SetTeam( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local TO_CHANGE = ASS_FindPlayer(ARGS[1])
			local TEAM = tonumber(ARGS[2]) or TEAM_UNASSIGNED

			if (!TO_CHANGE) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end

			if (ASS_RunPluginFunction( "AllowTeamChange", true, PLAYER, TO_CHANGE, TEAM )) then

				TO_CHANGE:SetTeam(TEAM)
				ASS_LogAction( PLAYER, ASS_ACL_TEAM, "changed " .. ASS_FullNick(TO_CHANGE) .. " to team " .. (Teams[TEAM] or TEAM) )
								
			end

		end

	end
	concommand.Add("ASS_SetTeam", PLUGIN.SetTeam)

end

if (CLIENT) then
	
	function PLUGIN.SetTeam(PLAYER, TEAM)
	
		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_SetTeam", ITEM:UniqueID(), TEAM )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_SetTeam", PLAYER:UniqueID(), TEAM )
		end

	end
	
	function PLUGIN.TeamChoice(MENU, PLAYER)

		for k,v in pairs(Teams) do
			MENU:AddOption( v, function() PLUGIN.SetTeam(PLAYER, k) end )
		end
	end

	function PLUGIN.AddMenu(DMENU)			
	
		DMENU:AddSubMenu( "Change Team", nil, function(NEWMENU) ASS_PlayerMenu(NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.TeamChoice ) end )

	end

end

ASS_RegisterPlugin(PLUGIN)
	
// HACK: override the default team.SetUp so we can catch the Team setup that the gamemode uses.
local oldTeamSetup = team.SetUp
function team.SetUp( id, name, color )

	Teams[id] = name
	return oldTeamSetup(id, name, color)

end

