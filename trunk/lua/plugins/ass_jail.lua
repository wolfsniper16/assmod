
local PLUGIN = {}

PLUGIN.Name = "Jail"
PLUGIN.Author = "PC Camp"
PLUGIN.Date = "May, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then

	local meta = FindMetaTable( "Entity" )
	if not meta then return end
	
	function meta:DisallowMoving( bool )
		self.NoMoving = bool
	end

	function meta:DisallowDeleting( bool )
		self.NoDeleting = bool
	end
	
	local DeleteWhiteList = {
		"colour",
		"material",
		"paint",
		"hoverball",
		"emitter",
		"elastic",
		"hydraulic",
		"muscle",
		"nail",
		"ballsocket",
		"ballsocket_adv",
		"pulley",
		"rope",
		"slider",
		"weld",
		"winch",
		"balloon",
		"button",
		"duplicator",
		"dynamite",
		"keepupright",
		"lamp",
		"nocollide",
		"thruster",
		"turret",
		"wheel",
		"eyeposer",
		"faceposer",
		"statue",
		"weld_ez",
		"axis",
	}

	local ToolsWhiteList = {
		"colour",
		"material",
		"paint",
		"duplicator",
		"eyeposer",
		"faceposer",
		"remover",
	}

	function meta:DisallowMoving( bool )
		self.NoMoving = bool
	end

	function meta:DisallowDeleting( bool )
		self.NoDeleting = bool
	end

	function CanTheyUseThatToolJail( ply, tr, toolmode, second )

		if tr.Entity.NoMoving then
			if not table.HasValue( ToolsWhiteList, toolmode ) then
				return false
			end
		end

		if tr.Entity.NoDeleting then
			if not table.HasValue( DeleteWhiteList, toolmode ) then
				return false
			end
		end
	end
	
	function AllowPickupWithPhysGunJail( ply, ent )
		if ent.NoMoving then return false end
	end
	
	ASS_NewLogLevel("ASS_ACL_JAIL")
	
	local JailModel = "models/props_wasteland/interior_fence002d.mdl"
	local JailPeices = {
		{vec = Vector(0, 0, 0), ang = Angle(-0.032495182007551, -90.190528869629, 0.156479626894)},
		{vec = Vector(129.97778320313, -127.38626098633, -0.13224792480469), ang = Angle(0.12636932730675, 179.84873962402, 0.025045685470104)},
		{vec = Vector(2.905517578125, -258.35272216797, -0.79289245605469), ang = Angle(-3.4093172871508e-005, -90, 5.7652890973259e-005)},
		{vec = Vector(-123.9228515625, -127.88626098633, -1.0640182495117), ang = Angle(-0.00059019651962444, 179.99681091309, 359.99996948242)},
		{vec = Vector(-63.728271484375, -129.30960083008, -63.381893157959), ang = Angle(-89.999015808105, -179.42805480957, 180)},
		{vec = Vector(62.65771484375, -131.56051635742, -63.381889343262), ang = Angle(-89.999015808105, 179.91276550293, 180)},
		{vec = Vector(64.22265625, -127.65585327148, 65.902130126953), ang = Angle(-89.77417755127, -156.53060913086, 336.46817016602)},
		{vec = Vector(-64.297607421875, -124.14590454102, 65.455322265625), ang = Angle(-89.825218200684, -132.09020996094, 312.04119873047)}
	}
	
	cleanup.Register( "JailWallz" )
	
	function PLUGIN.JailPlayer( PLAYER, CMD, ARGS )

		if (PLAYER:IsTempAdmin()) then

			local TO_JAIL = ASS_FindPlayer(ARGS[1])
			local ENABLE = tonumber(ARGS[2]) > 0

			if (!TO_JAIL) then

				ASS_MessagePlayer(PLAYER, "Player not found!\n")
				return

			end
			
			if (PLAYER != TO_JAIL) then
				if (TO_JAIL:IsBetterOrSame(PLAYER) && !ENABLE) then

					// disallow!
					ASS_MessagePlayer(PLAYER, "Access denied! \"" .. TO_JAIL:Nick() .. "\" has same or better access then you.")
					return
	
				end
			end

			if (ASS_RunPluginFunction( "AllowJail", true, PLAYER, TO_JAIL, ENABLE )) then

				if (ENABLE) then
				
					if TO_JAIL:GetNWBool( "IsGoodBoy" ) then
				
						-- Boot them from a car if they are in one
						if TO_JAIL:InVehicle() then
							TO_JAIL:ExitVehicle()
							TO_JAIL:GetParent():Remove()
						end
						
						-- If in noclip, remove noclip
						if TO_JAIL:GetMoveType() == MOVETYPE_NOCLIP then
							TO_JAIL:SetMoveType( MOVETYPE_WALK )
						end
						
						local pos = TO_JAIL:GetPos() + Vector(0, 128, 64)
						local JailWalls = {}
						
						for K, JailPeice in ipairs( JailPeices ) do
							local ent = ents.Create( "prop_physics" )
							ent:SetModel( JailModel )
							ent:SetPos( pos + JailPeice.vec )
							ent:SetAngles( JailPeice.ang )
							ent:Spawn()
							ent:GetPhysicsObject():EnableMotion( false )
							ent:DisallowDeleting( true )
							ent:DisallowMoving( true )
							table.insert( JailWalls, ent )
							constraint.Weld(ent, JailWalls[K - 1], 0, 0, 0, true)
							TO_JAIL:AddCount("JailWallz", ent)
							TO_JAIL:AddCleanup("JailWallz", ent)
						end
						
						TO_JAIL:SetPos( TO_JAIL:GetPos() + Vector(0, 0, 15) )
						TO_JAIL:StripWeapons()
						TO_JAIL:SetMoveType(MOVETYPE_WALK)
						TO_JAIL:GodEnable()
						TO_JAIL:SetNWBool( "IsGoodBoy", false )
						
						ASS_LogAction( PLAYER, ASS_ACL_JAIL, "put " .. ASS_FullNick(TO_JAIL).." in jail" )
						
					else
						ASS_MessagePlayer(PLAYER, TO_JAIL:Nick() .. " is already in jail!")
					end
					
				else
					if not TO_JAIL:GetNWBool( "IsGoodBoy" ) then

						TO_JAIL:GodDisable()
						if file.Exists( "../lua/plugins/ass_grouping.lua" ) then
							ApplyASSGroupTeams( TO_JAIL )
						else
							gamemode.Call( "PlayerLoadout", TO_JAIL )
						end
						TO_JAIL:SetNWBool( "IsGoodBoy", true )
						cleanup.CC_Cleanup(TO_JAIL, "JailWallz", {} )
						
						ASS_LogAction( PLAYER, ASS_ACL_JAIL, "removed " .. ASS_FullNick(TO_JAIL).." from jail" )
					else
						ASS_MessagePlayer(PLAYER, TO_JAIL:Nick() .. " is not in jail!")
					end
					
				end
								
			end

		end

	end
	concommand.Add("ASS_JailPlayer", PLUGIN.JailPlayer)
	
	hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawnJail", function( PLAYER ) PLAYER:SetNWBool( "IsGoodBoy", true ) end )
	hook.Add( "PhysgunPickup", "PhysgunPickupJail", AllowPickupWithPhysGunJail )
	hook.Add( "CanTool", "CanToolJail", CanTheyUseThatToolJail )
	hook.Add( "PlayerSpawnedSENT", "PlayerSpawnedSENTJail", function( PLAYER, ENTITY ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then ENTITY:Remove() end end )
	
	hook.Add( "CanPlayerEnterVehicle", "CanPlayerEnterVehicleJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "CanPlayerSuicide", "CanPlayerSuicideJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerCanPickupWeapon", "PlayerCanPickupWeaponJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerGiveSWEP", "PlayerGiveSWEPJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerNoClip", "PlayerNoClipJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnEffect", "PlayerSpawnEffectJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnNPC", "PlayerSpawnNPCJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnObject", "PlayerSpawnObjectJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnSENT", "PlayerSpawnSENTJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnSWEP", "PlayerSpawnSWEPJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnProp", "PlayerSpawnPropJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnRagdoll", "PlayerSpawnRagdollJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerSpawnVehicle", "PlayerSpawnVehicleJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )
	hook.Add( "PlayerUse", "PlayerUseJail", function( PLAYER ) if not PLAYER:GetNWBool( "IsGoodBoy" ) then return false end end )

end

if (CLIENT) then

	hook.Add( "SpawnMenuOpen", "SpawnMenuOpenJail", function() if not LocalPlayer():GetNWBool( "IsGoodBoy" ) then return false end end )

	function PLUGIN.JailPlayer(PLAYER, ALLOW)
		
		if (type(PLAYER) == "table") then
			for _, ITEM in pairs(PLAYER) do
				if (ValidEntity(ITEM)) then
					RunConsoleCommand( "ASS_JailPlayer", ITEM:UniqueID(), ALLOW )
				end
			end
		else
			if (!ValidEntity(PLAYER)) then return end
			RunConsoleCommand( "ASS_JailPlayer", PLAYER:UniqueID(), ALLOW )
		end

	end
	
	function PLUGIN.JailEnableDisable(MENU, PLAYER)
		
		MENU:AddOption( "Enable",	function() PLUGIN.JailPlayer(PLAYER, 1) end )
		MENU:AddOption( "Disable",	function() PLUGIN.JailPlayer(PLAYER, 0) end )

	end

	function PLUGIN.AddMenu(DMENU)
		
		DMENU:AddSubMenu( "Jail", nil, 
			function(NEWMENU) 
				ASS_PlayerMenu( NEWMENU, {"IncludeAll", "HasSubMenu","IncludeLocalPlayer"}, PLUGIN.JailEnableDisable  ) 
			end
		)

	end

end

ASS_RegisterPlugin(PLUGIN)


