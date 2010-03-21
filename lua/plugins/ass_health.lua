
local PLUGIN = {}

PLUGIN.Name = "Health"
PLUGIN.Author = "Andy Vincent"
PLUGIN.Date = "10th August 2007"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_HEALTH")

	function PLUGIN.GiveTakeHealth( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local TO_RECIEVE = ASS_FindPlayer(ARGS[1])
			local HEALTH = tonumber(ARGS[2]) or 0

			if (!TO_RECIEVE) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end
			
			if (HEALTH == 0) then return end // nothing to do!

			if (PLAYER != TO_RECIEVE) then
				if (TO_RECIEVE:IsBetterOrSame(PLAYER) && HEALTH < 0) then

					// disallow!
					ASS_MessagePlayer(PLAYER, "Access denied! \"" .. TO_RECIEVE:Nick() .. "\" has same or better access then you.")
					return
				end
			end

			if (ASS_RunPluginFunction( "AllowPlayerHealth", true, PLAYER, TO_RECIEVE, HEALTH )) then

				if (HEALTH < 0) then

					TO_RECIEVE:Hurt( -HEALTH )
					ASS_LogAction( PLAYER, ASS_ACL_HEALTH, "took " .. -HEALTH .. " health from " .. ASS_FullNick(TO_RECIEVE) )

				else

					TO_RECIEVE:SetHealth( TO_RECIEVE:Health() + HEALTH )
					ASS_LogAction( PLAYER, ASS_ACL_HEALTH, "gave " .. ASS_FullNick(TO_RECIEVE) .. " " .. HEALTH .. " health"  )

				end

			end


		else

			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end

	end
	concommand.Add("ASS_GiveTakeHealth", PLUGIN.GiveTakeHealth)

end

if (CLIENT) then

	function PLUGIN.GiveTakeHealth(PLAYER, AMOUNT)

		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_GiveTakeHealth", ITEM:UniqueID(), AMOUNT )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_GiveTakeHealth", PLAYER:UniqueID(), AMOUNT )
		end
		
		return true
	end
	
	function PLUGIN.PosAmountPower(MENU, PLAYER)

		for i=10,100,10 do
			MENU:AddOption( tostring(i),	function() return PLUGIN.GiveTakeHealth(PLAYER,  i) end )
		end

	end
	
	function PLUGIN.NegAmountPower(MENU, PLAYER)

		for i=10,100,10 do
			MENU:AddOption( tostring(i),	function() return PLUGIN.GiveTakeHealth(PLAYER,  -i) end )
		end

	end

	function PLUGIN.AddMenu(DMENU)			
	
		DMENU:AddSubMenu( "Give Health", nil, function(NEWMENU) ASS_PlayerMenu( NEWMENU, {"IncludeAll", "IncludeLocalPlayer","HasSubMenu"}, PLUGIN.PosAmountPower  ) end ):SetImage( "gui/silkicons/heart" )
		DMENU:AddSubMenu( "Take Health", nil, function(NEWMENU) ASS_PlayerMenu( NEWMENU, {"IncludeAll", "IncludeLocalPlayer","HasSubMenu"}, PLUGIN.NegAmountPower  ) end ):SetImage( "gui/silkicons/pill" )

	end

end

ASS_RegisterPlugin(PLUGIN)


