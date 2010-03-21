
local PLUGIN = {}

PLUGIN.Name = "Weapons / Items"
PLUGIN.Author = "Andy Vincent"
PLUGIN.Date = "22nd September 2007"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

local DEFAULT_WEAPON_TABLE = {

	{	text = "GravGun",		item = "weapon_physcannon"	},
	{	text = "Physgun",		item = "weapon_physgun"		},
	{	text = "Crowbar",		item = "weapon_crowbar"		},
	{	text = "Stunstick",		item = "weapon_stunstick"	},
	{	text = "Pistol",		item = "weapon_pistol"		},
	{	text = ".357",			item = "weapon_357"		},
	{	text = "SMG",			item = "weapon_smg1"		},
	{	text = "Shotgun",		item = "weapon_shotgun"		},
	{	text = "Crossbow",		item = "weapon_crossbow"	},
	{	text = "AR2",			item = "weapon_ar2"		},
	{	text = "Bug Bait",		item = "weapon_bugbait"		},
	{	text = "RPG",			item = "weapon_rpg"		},

}

local DEFAULT_ITEM_TABLE = {

	{	text = "Power",			item = "item_battery",			},
	{	text = "Suit",			item = "item_suit",			},
	{	text = "Health kit",		item = "item_healthkit",		},
	{	text = "Health vial",		item = "item_healthvial",		},
	{	},
	{	text = ".357 ammo",		item = "item_ammo_357",			},
	{	text = ".357 ammo (large)",	item = "item_ammo_357_large",		},
	{	text = "AR2 ammo",		item = "item_ammo_ar2",			},
	{	text = "AR2 ammo (large)",	item = "item_ammo_ar2_large",		},
	{	text = "Crossbow ammo",		item = "item_ammo_crossbow",		},
	{	text = "Pistol ammo",		item = "item_ammo_pistol",		},
	{	text = "Pistol ammo (large)",	item = "item_ammo_pistol_large",	},
	{	text = "SMG ammo",		item = "item_ammo_smg1",		},
	{	text = "SMG ammo (large)",	item = "item_ammo_smg1_large",		},
	{	text = "SMG grenades",		item = "item_ammo_smg1_grenade",	},
	{	text = "RPG ammo",		item = "item_rpg_round",		},
	{	text = "Shotgun ammo",		item = "item_box_buckshot",		},

}

if (SERVER) then

	ASS_NewLogLevel("ASS_ACL_GIVE")

	function PLUGIN.GiveItem( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local TO_GIVE = ASS_FindPlayer(ARGS[1])
			local ITEM = ARGS[2]
			
			if (!ITEM) then return end

			if (!TO_GIVE) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end
			
			if (ASS_GetSwepLevel) then
				local LVL = ASS_GetSwepLevel(ITEM)
				if (!PLAYER:HasLevel( LVL )) then
					ASS_MessagePlayer( PLAYER, "Sorry, only " .. LevelToString(LVL) .. " are allowed to give this item!\n")
					return
				end
			end
			
			TO_GIVE:Give(ITEM)

			ASS_LogAction( PLAYER, ASS_ACL_GIVE, "gave " .. ASS_FullNick(TO_GIVE) .. " " .. ITEM  )

		else

			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end
		
	end
	concommand.Add("ASS_GiveItem", PLUGIN.GiveItem)

	function PLUGIN.SpawnItem( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local ITEM = ARGS[1]
			
			if (!ITEM) then return end
			
			if (ASS_GetSwepLevel) then
				local LVL = ASS_GetSwepLevel(ITEM)
				if (!PLAYER:HasLevel( LVL )) then
					ASS_MessagePlayer( PLAYER, "Sorry, only " .. LevelToString(LVL) .. " are allowed to spawn this item!\n")
					return
				end
			end

			local tr = util.GetPlayerTrace( PLAYER, PLAYER:GetCursorAimVector() )
			local tr_res = util.TraceLine( tr )
			
			local ENT = ents.Create( ITEM )
			
			if (ENT && ENT:IsValid()) then
			
				ENT:SetPos( tr_res.HitPos + (tr_res.HitNormal * 16) )
				ENT:Spawn()
			
			end
			
			ASS_LogAction( PLAYER, ASS_ACL_GIVE, "spawned " .. ITEM  )

		else

			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end
		
	end
	concommand.Add("ASS_SpawnItem", PLUGIN.SpawnItem)

	function PLUGIN.StripWeapons( PLAYER, CMD, ARGS )
 		if (PLAYER:IsTempAdmin()) then

 			local TO_STRIP = ASS_FindPlayer(ARGS[1])
           
			if (!TO_STRIP) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end

			TO_STRIP:StripWeapons()
			TO_STRIP:StripAmmo()

			ASS_LogAction( PLAYER, ASS_ACL_GIVE, "stripped " .. ASS_FullNick(TO_STRIP) .. " of all weapons and ammo")
		else

			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end
	end
	concommand.Add("ASS_StripWeapons", PLUGIN.StripWeapons)

	function PLUGIN.StripAllWeapons( PLAYER, CMD, ARGS )
		// Simple check: Is the player a temporary admin or above?
		if (PLAYER:IsTempAdmin()) then
		
			local INCLUDE_ADMINS = (ARGS[1] == 1)
			
			for _,TO_STRIP in pairs(player.GetAll()) do
			
				if (INCLUDE_ADMINS || (!INCLUDE_ADMINS && !TO_STRIP:IsTempAdmin())) then

					TO_STRIP:StripWeapons()
					TO_STRIP:StripAmmo()

				end
			
			end
		
			// Log the action. Note we're using the new log level we defined earlier.
			if (INCLUDE_ADMINS) then
				ASS_LogAction( PLAYER, ASS_ACL_GIVE, "stripped everyone of all weapons and ammo (including admins)" )
			else
				ASS_LogAction( PLAYER, ASS_ACL_GIVE, "stripped everyone of all weapons and ammo (excluding admins)" )
			end
		
		else

			// Player doesn't have enough access.
			ASS_MessagePlayer( PLAYER, "Access Denied!\n")

		end
	end
	concommand.Add("ASS_StripAllWeapons", PLUGIN.StripAllWeapons)

end

if (CLIENT) then

	function PLUGIN.SpawnItem(PLAYER, ITEM)
	
		RunConsoleCommand("ASS_SpawnItem", ITEM)
		
		return true
	
	end

	function PLUGIN.GiveItem(PLAYER, ITEM)
	
		if (type(PLAYER) == "table") then
			for _, PL in pairs(PLAYER) do
				if (ValidEntity(PL)) then
					RunConsoleCommand("ASS_GiveItem", PL:UniqueID(), ITEM)
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			
			RunConsoleCommand("ASS_GiveItem", PLAYER:UniqueID(), ITEM)
		end
		
		return true
	
	end

	function PLUGIN.WeaponMenu(MENU, PLAYER, FUNC)

		for k,v in pairs(DEFAULT_WEAPON_TABLE) do
			MENU:AddOption( v.text,	function() FUNC(PLAYER, v.item) end )
		end
		MENU:AddSpacer()

		for k,v in pairs(weapons.GetList()) do
			if (v.Spawnable || v.AdminSpawnable) then
				MENU:AddOption( v.PrintName, function() return FUNC(PLAYER, v.Classname) end )
			end
		end

		return false

	end
	
	function PLUGIN.ItemMenu(MENU, PLAYER, FUNC)

		for k,v in pairs(DEFAULT_ITEM_TABLE) do
			if (v.text == nil) then
				MENU:AddSpacer()
			else
				MENU:AddOption( v.text,	function() FUNC(PLAYER, v.item) end )
			end
		end

	end

	function PLUGIN.WeaponItemMenu(MENU, PLAYER, FUNC)

		MENU:AddSubMenu( "Weapon", nil, function(NEWMENU) PLUGIN.WeaponMenu( NEWMENU, PLAYER, FUNC ) end )
		MENU:AddSubMenu( "Item", nil, function(NEWMENU) PLUGIN.ItemMenu( NEWMENU, PLAYER, FUNC ) end )
		
	end
	
	function PLUGIN.StripWeapons(PLAYER, FUNC)
		if (!PLAYER:IsValid()) then return end
		RunConsoleCommand("ASS_StripWeapons", PLAYER:UniqueID() )
 	end

	function PLUGIN.TopMenu(MENU)			
	
		MENU:AddSubMenu( "Give",  nil, function(NEWMENU) ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu", "IncludeLocalPlayer" }, PLUGIN.WeaponItemMenu, PLUGIN.GiveItem  ) end )
		MENU:AddSubMenu( "Spawn", nil, function(NEWMENU) PLUGIN.WeaponItemMenu( NEWMENU, LocalPlayer(), PLUGIN.SpawnItem  ) end )
		MENU:AddSubMenu( "Strip", nil, function(NEWMENU) ASS_PlayerMenu( NEWMENU, {"IncludeAll", "IncludeLocalPlayer"}, PLUGIN.StripWeapons ) end )

	end

	function PLUGIN.AddMainMenu(DMENU)			

		DMENU:AddSpacer()
		DMENU:AddSubMenu( "Weapon / Items" , nil, PLUGIN.TopMenu )
        
    end

end

ASS_RegisterPlugin(PLUGIN)


