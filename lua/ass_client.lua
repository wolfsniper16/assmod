
include("ass_shared.lua")

ASS_Initialized = false

local PLAYER = FindMetaTable("Player")
function PLAYER:UniqueID()	return self:GetNetworkedString("ASS_UniqueID")	end
PLAYER = nil

function ASS_BanPlayer( INFO )
	if (!ValidEntity(INFO.Player)) then
		return true
	end
	
	if (#INFO.Reason > 0) then
		RunConsoleCommand("ASS_BanPlayer", INFO.Player:UniqueID(), INFO.Time, INFO.Reason) 
	else
		RunConsoleCommand("ASS_BanPlayer", INFO.Player:UniqueID(), INFO.Time) 
	end
	
	return true
end

function ASS_KickPlayer( INFO )
	if (!ValidEntity(INFO.Player)) then
		return true
	end

	if (#INFO.Reason > 0) then
		RunConsoleCommand("ASS_KickPlayer", INFO.Player:UniqueID(), INFO.Reason) 
	else
		RunConsoleCommand("ASS_KickPlayer", INFO.Player:UniqueID() ) 
	end
	
	return true
end

function ASS_SetAccess( PLAYER, LEVEL, TIME )

	if (!ValidEntity(PLAYER)) then
		return true
	end

	if (TIME) then
		RunConsoleCommand("ASS_PromotePlayer", PLAYER:UniqueID(), LEVEL, TIME) 
	else
		RunConsoleCommand("ASS_PromotePlayer", PLAYER:UniqueID(), LEVEL) 
	end
	
end

function ASS_CustomReason(INFO)

	Derma_StringRequest( "Custom Reason...", 
		"Why do you want to " .. INFO.Type .. " " .. INFO.Player:Nick() .. "?", 
		"", 
		function( strTextOut ) 
			table.insert(ASS_Config["reasons"], 	{	name = strTextOut,	reason = strTextOut		} )
			ASS_WriteConfig()
		
			INFO.Reason = strTextOut
			INFO.Function(INFO)
		end 
	)
	
end

function ASS_KickBanReasonMenu( MENU, INFO )

	INFO = INFO or {}

	for k, v in pairs(ASS_Config["reasons"]) do
		MENU:AddOption( (v.name or ("Unnamed #" .. k)), 
				function() 
					INFO.Reason = v.reason or ""
					return INFO.Function(INFO)
				end
			)
	end
	MENU:AddSpacer()
	MENU:AddOption( "Custom...", 
			function() 
				ASS_CustomReason(INFO)
			end
		)

end

function ASS_BanTimeMenu( MENU, PLAYER )

	for k, v in pairs(ASS_Config["ban_times"]) do
		
		local txt = v.name or ("Unnamed #" .. k)
		
		MENU:AddSubMenu( txt, nil, function(NEWMENU) ASS_KickBanReasonMenu( NEWMENU, { ["Type"] = "ban", ["Function"] = ASS_BanPlayer, ["Player"] = PLAYER, ["Time"] = v.time } ) end )
		
	end

end

function ASS_KickReasonMenu( MENUITEM, PLAYER, INFO )

	INFO = {}
	INFO.Function = ASS_KickPlayer
	INFO.Type = "kick"
	INFO.Player = PLAYER
	
	ASS_KickBanReasonMenu(MENUITEM, INFO)

end

function ASS_TempAdminMenu( MENU, PLAYER )

	for k, v in pairs(ASS_Config["temp_admin_times"]) do
		MENU:AddOption(v.name, function() ASS_SetAccess(PLAYER, ASS_LVL_TEMPADMIN, v.time) end )
	end

end

function ASS_AccessMenu( SUBMENU, PLAYER )

	local Items = {}
	Items[ASS_LVL_SERVER_OWNER] = SUBMENU:AddOption( "Server Owner", 				function() ASS_SetAccess(PLAYER, ASS_LVL_SERVER_OWNER)	end )
	Items[ASS_LVL_SUPER_ADMIN] = SUBMENU:AddOption( "Super Admin", 				function() ASS_SetAccess(PLAYER, ASS_LVL_SUPER_ADMIN)	end )
	Items[ASS_LVL_ADMIN] = SUBMENU:AddOption( "Admin", 					function() ASS_SetAccess(PLAYER, ASS_LVL_ADMIN)		end )
	Items[ASS_LVL_TEMPADMIN] = SUBMENU:AddSubMenu( "Temp Admin" , 	nil, 			function(NEWMENU) ASS_TempAdminMenu( NEWMENU, PLAYER )	end )
	Items[ASS_LVL_OPERATOR] = SUBMENU:AddOption( "Operator", 				function() ASS_SetAccess(PLAYER, ASS_LVL_OPERATOR)	end )
	Items[ASS_LVL_DONATORGOLD] = SUBMENU:AddOption( "Donator - Gold", 				function() ASS_SetAccess(PLAYER, ASS_LVL_DONATORGOLD)	end )
	Items[ASS_LVL_DONATORSILVER] = SUBMENU:AddOption( "Donator - Silver", 				function() ASS_SetAccess(PLAYER, ASS_LVL_DONATORSILVER)	end )
	Items[ASS_LVL_RESPECTED] = SUBMENU:AddOption( "Respected", 				function() ASS_SetAccess(PLAYER, ASS_LVL_RESPECTED)	end )
	Items[ASS_LVL_GUEST] = SUBMENU:AddOption( "Guest", 					function() ASS_SetAccess(PLAYER, ASS_LVL_GUEST) 	end )
	Items[ASS_LVL_BANNED] = SUBMENU:AddOption( "Previously Banned", 					function() ASS_SetAccess(PLAYER, ASS_LVL_BANNED) 	end )
		
	if (Items[ PLAYER:GetLevel() ]) then
		Items[PLAYER:GetLevel()]:SetImage("gui/silkicons/check_on_s")
	end	

end

function ASS_TableContains( TAB, VAR )
	
	if (!TAB) then	
	
		return false	
	
	end
	
	for k,v in pairs(TAB) do
		
		if (v == VAR) then 
		
			return true 
		
		end
	
	end
	
	return false
	
end

// Oh god this is going to be hacky 
function ASS_FixMenu( MENU )
	
	// Call the callback when we need to build the menu
	// If we're creating the menu now, also register our
	// hacked functions with it, so this hack propagates
	// virus like among any DMenus spawned from this 
	// parent DMenu.. muhaha
 	function DMenuOption_OnCursorEntered(self) 
 	
 		local m = self.SubMenu
 		if (self.BuildFunction) then
 	 		m = DermaMenu( self ) 
	 		ASS_FixMenu(m)
 			m:SetVisible( false ) 
 			m:SetParent( self:GetParent() ) 
 			PCallError( self.BuildFunction, m)
		end
		
		self:GetParent():OpenSubMenu( self, m )	 
 	 
	end 	
	
	// Menu item images!
	function DMenuOption_SetImage(self, img)
	
		self.Image = ASS_Icon(img)
	
	end
	
	// Change the released hook so that if the click function
	// returns a non-nil or non-false value then the menus
	// get closed (this way menus can stay opened and be clicked
	// several time).
	function DMenuOption_OnMouseReleased( self, mousecode ) 

		DButton.OnMouseReleased( self, mousecode ) 

		if ( self.m_MenuClicking ) then 

			self.m_MenuClicking = false 
			
			if (!self.ClickReturn) then
				CloseDermaMenus() 
			end

		end 

	end 
	
	// Make sure we draw the image, should be done in the skin
	// but this is a total hack, so meh.
	function DMenuOption_Paint(self)
	
		derma.SkinHook( "Paint", "MenuOption", self )
		
		if (self.Image) then
	 		surface.SetTexture( self.Image ) 
 			surface.SetDrawColor( 255, 255, 255, 255 ) 
 			surface.DrawTexturedRect( 2, (self:GetTall() - 16) * 0.5, 16, 16)
 		end
		
		return false
	
	end

 	// Make DMenuOptions implement our new functions above.
	// Returns the new DMenuOption created.
	local function DMenu_AddOption( self, strText, funcFunction )

 		local pnl = vgui.Create( "DMenuOption", self ) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
 		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
  		pnl:SetText( strText ) 
 		if ( funcFunction ) then 
 			pnl.DoClick = function(self) 
 					self.ClickReturn = funcFunction(pnl) 
 				end
 		end
 	 
 		self:AddPanel( pnl ) 
 	 
 		return pnl 
 
 	end	

	// Make DMenuOptions implement our new functions above.
	// If we're creating the menu now, also register our
	// hacked functions with it, so this hack propagates
	// virus like among any DMenus spawned from this 
	// parent DMenu.. muhaha
	// Returns the new DMenu (if it exists), and the DMenuOption
	// created.
	local function DMenu_AddSubMenu( self, strText, funcFunction, openFunction ) 

	 	local SubMenu = nil
	 	if (!openFunction) then
	 		SubMenu = DermaMenu( self ) 
	 		ASS_FixMenu(SubMenu)
 			SubMenu:SetVisible( false ) 
 			SubMenu:SetParent( self ) 
 		end
 	
 		local pnl = vgui.Create( "DMenuOption", self ) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
  		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
		pnl.BuildFunction = openFunction
		pnl:SetSubMenu( SubMenu ) 
		pnl:SetText( strText ) 
		if ( funcFunction ) then 
			pnl.DoClick = function() pnl.ClickReturn = funcFunction(pnl) end
		else 
			pnl.DoClick = function() pnl.ClickReturn = true end
		end

		self:AddPanel( pnl ) 

		if (SubMenu) then
			return SubMenu, pnl
		else
			return pnl
		end

	end 
	
	// Register our new hacked function. muhahah
	MENU.AddOption = DMenu_AddOption
	MENU.AddSubMenu = DMenu_AddSubMenu
end
// See, told you it was hacky, hopefully won't have to do this for much longer

// This function was once fairly neat and tidy... Now it's a big
// mess of anonymous functions and submenus. 
// I'd tidy it up, but I think it'd stop working, or break everything...
// It's only the "IncludeAll" options that really screw it up actually,
// but it adds soo much flexability it's totally worth it.
function ASS_PlayerMenu( SUBMENU, OPTIONS, FUNCTION, ... )

	if (type(SUBMENU) != "Panel") then Msg("ASS_PlayerMenu: SUBMENU isn't a menu!\n") return end

	local others = player.GetAll()
	
	local includeSubMenus = ASS_TableContains(OPTIONS, "HasSubMenu")
	local includeSelf = ASS_TableContains(OPTIONS, "IncludeLocalPlayer")
	local includeAll = ASS_TableContains(OPTIONS, "IncludeAll")
	local includeAllSO = ASS_TableContains(OPTIONS, "IncludeAllSO")
	
	local NumOptions = 0
	
	if (includeAll || includeAllSO) then
	
		/* I love anonymous functions, good luck understanding what this does! */
		
		if (LocalPlayer():HasLevel(ASS_LVL_SERVER_OWNER) || includeAllSO) then		
			SUBMENU:AddSubMenu( "All", nil,
					function(ALLMENU)
						if (includeSubMenus) then
						
							ALLMENU:AddSubMenu( "Players", nil,
								function(NEWMENU)
									local List = {}
									for _, PL in pairs(player.GetAll()) do
										if (PL != LocalPlayer() || includeSelf) then
											table.insert(List, PL)
										end
									end
									PCallError( FUNCTION, NEWMENU, List, unpack(arg))
								end )

							ALLMENU:AddSubMenu( "Non-Admins", nil,
								function(NEWMENU)
									local List = {}
									for _, PL in pairs(player.GetAll()) do
										if (!PL:IsOperator() && (PL != LocalPlayer() || includeSelf)) then
											table.insert(List, PL)
										end
									end
									PCallError( FUNCTION, NEWMENU, List, unpack(arg))
								end )

							ALLMENU:AddSubMenu( "Admins", nil,
								function(NEWMENU)
									local List = {}
									for _, PL in pairs(player.GetAll()) do
										if (PL:IsOperator() && (PL != LocalPlayer() || includeSelf)) then
											table.insert(List, PL)
										end
									end
									PCallError( FUNCTION, NEWMENU, List, unpack(arg))
								end )
						else
						
							ALLMENU:AddOption( "Players", 
								function()
									local res = nil
									for _, PL in pairs(player.GetAll()) do
										if (PL != LocalPlayer() || includeSelf) then
											local err,res2 = PCallError( FUNCTION, PL, unpack(arg))
											res = res || res2
										end
									end
									return res
								end )
							ALLMENU:AddOption( "Non-Admins", 
								function()
									local res = nil
									for _, PL in pairs(player.GetAll()) do
										if (!PL:IsOperator() && (PL != LocalPlayer() || includeSelf)) then
											local err,res2 = PCallError( FUNCTION, PL, unpack(arg))
											res = res || res2
										end
									end
									return res
								end )
							ALLMENU:AddOption( "Admins", 
								function()
									local res = nil
									for _, PL in pairs(player.GetAll()) do
										if (PL:IsOperator() && (PL != LocalPlayer() || includeSelf)) then
											local err,res2 = PCallError( FUNCTION, PL, unpack(arg))
											res = res || res2
										end
									end
									return res
								end )
						
						end
					end )
		else
		
			if (includeSubMenus) then
			
				SUBMENU:AddSubMenu( "All Non-Admins", nil,
					function(NEWMENU)
						local List = {}
						for _, PL in pairs(player.GetAll()) do
							if (!PL:IsOperator()) then
								table.insert(List, PL)
							end
						end
						PCallError( FUNCTION, NEWMENU, List, unpack(arg))
					end )

			else
			
				SUBMENU:AddOption( "All Non-Admins", 
					function()
						local res = nil
						for _, PL in pairs(player.GetAll()) do
							if (!PL:IsOperator()) then
								local err, res2 = PCallError( FUNCTION, PL, unpack(arg))
								res = res or res2
							end
						end
						return res
					end )
					
			end

		end

		NumOptions = NumOptions + 1
	
		if (includeSelf) then
			SUBMENU:AddSpacer()
		end
		
	end

	if (includeSelf) then
		if (includeSubMenus) then
			SUBMENU:AddSubMenu( LocalPlayer():Nick(), nil, function(NEW_SUBMENU) PCallError( FUNCTION, NEW_SUBMENU, LocalPlayer(), unpack(arg) ) end )
		else
			SUBMENU:AddOption( LocalPlayer():Nick(), function() local err,res = PCallError( FUNCTION, LocalPlayer(), unpack(arg)) return res end )
		end
		NumOptions = NumOptions + 1
	end
	
	for idx,ply in pairs(others) do
		
		if (ply != LocalPlayer()) then		
			if (NumOptions == 1 && (includeSelf || includeAll || includeAllSO)) then
				SUBMENU:AddSpacer()
			end
			if (includeSubMenus) then
				SUBMENU:AddSubMenu( ply:Nick(), nil, function(NEW_SUBMENU) PCallError( FUNCTION, NEW_SUBMENU, ply, unpack(arg) ) end )
			else
				SUBMENU:AddOption( ply:Nick(), function() local err,res = PCallError( FUNCTION, ply, unpack(arg)) return res end )
			end
			NumOptions = NumOptions + 1
		end
		
	end
	
	if (NumOptions == 0) then
		SUBMENU:AddOption( "(none)", function() end )
	end
	
end

function ASS_Plugins( SUBMENU )

	ASS_RunPluginFunction("AddMenu", nil, SUBMENU )

	if (#SUBMENU.Panels == 0) then
		SUBMENU:AddOption("(none)", function() end)		
	end
	
end

function ASS_Gamemode( SUBMENU )

	local function CheckGamemode(PLUGIN)
	
		return	PLUGIN.Gamemodes != nil &&
			#PLUGIN.Gamemodes > 0 &&
			ASS_PluginCheckGamemode(PLUGIN.Gamemodes)
	
	end

	ASS_RunPluginFunctionFiltered("AddGamemodeMenu", CheckGamemode, nil, SUBMENU )
	
	if (#SUBMENU.Panels == 0) then
		SUBMENU:AddOption("(none)", function() end)		
	end
	
end

function ASS_Rcon(TEXT, TIME)

	RunConsoleCommand("ASS_RconBegin" )
	
	local i = 1
	while (i <= #TEXT) do

		local args = {}
		for j=i, i+6 do
			if (j > #TEXT) then
				break
			end
			args[j-i+1] = string.byte(TEXT, j)	
		end
				

		RunConsoleCommand("ASS_Rcon", unpack(args) )

		i = i + 7		
	end
	
	RunConsoleCommand("ASS_RconEnd", (TIME or 0) )

end

function ASS_RconEntry(MENUITEM)

	Derma_StringRequest( "Remote Command...", 
		"What command do you want to execute?", 
		"", 
		function( TEXT ) 

			local found = false
			for k,v in pairs(ASS_Config["rcon"]) do
				if (string.lower(v.cmd) == string.lower(TEXT)) then
					found = true
					break
				end
			end
			
			if (!found) then
				table.insert(ASS_Config["rcon"], { cmd=TEXT } )
				ASS_WriteConfig()
			end
			
			ASS_Rcon(TEXT)

		end 
	)
	
end

function ASS_RconMenu( MENU )

	MENU:AddOption( "Custom...", ASS_RconEntry )
	MENU:AddSpacer()
	for k,v in pairs(ASS_Config["rcon"]) do
		MENU:AddOption( v.cmd, function(MENUITEM) ASS_Rcon(v.cmd) end )
	end

end


function ASS_ShowUnbanList()
	
	PromptForChoice( "Unban a player...", ASS_BannedPlayers, 
		function (DLG, ITEM)
			
			RunConsoleCommand("ASS_UnBanPlayer", ITEM.ID)
			DLG:RemoveItem(DLG.Selection)
		
		end
	)
	
	ASS_BannedPlayers = nil
	
end

function ASS_UnbanMenu( MENUITEM )

	if (ASS_BannedPlayers) then return end
	
	ASS_BannedPlayers = {}
	RunConsoleCommand("ASS_UnbanList")

end

local IconsLoaded = {}
function ASS_Icon( img )
	if (IconsLoaded[img]) then
		return IconsLoaded[img]
	end
	IconsLoaded[img] = surface.GetTextureID(img)
	return IconsLoaded[img]
end

function ASS_ShowMenu()

	local MENU = DermaMenu()
	ASS_FixMenu(MENU)
	
	if (!LocalPlayer():IsOperator()) then	

		ASS_RunPluginFunction("AddNonAdminMenu", nil, MENU )
		if (#MENU.Panels == 0) then
			return	
		end
		
	else
	
		local GamemodeImage = "gui/silkicons/sport_soccer"
		if (GAMEMODE.ASS_MenuIcon) then
			GamemodeImage = GAMEMODE.ASS_MenuIcon
		end
		
		MENU:AddSubMenu("Set Access", nil, function(NEWMENU) ASS_PlayerMenu(NEWMENU, { "HasSubMenu" }, ASS_AccessMenu ) end ):SetImage( "gui/silkicons/key" )
		MENU:AddSubMenu("Kick", nil, function(NEWMENU) ASS_PlayerMenu(NEWMENU, { "HasSubMenu" }, ASS_KickReasonMenu ) end ):SetImage( "gui/silkicons/error" )
		MENU:AddSubMenu("Ban", nil, function(NEWMENU) ASS_PlayerMenu(NEWMENU, { "HasSubMenu" }, ASS_BanTimeMenu ) end ):SetImage( "gui/silkicons/exclamation" )
		MENU:AddOption("Unban...", ASS_UnbanMenu )
		MENU:AddSpacer()
		MENU:AddSubMenu("Rcon", nil, ASS_RconMenu):SetImage( "gui/silkicons/application_xp_terminal" )
		MENU:AddSpacer()
		MENU:AddSubMenu("Plugins", nil, ASS_Plugins ):SetImage( "gui/silkicons/wrench" )
		MENU:AddSubMenu( GAMEMODE.Name, nil, ASS_Gamemode ):SetImage(GamemodeImage)

		ASS_RunPluginFunction("AddMainMenu", nil, MENU )

	end
	
	MENU:Open( 100, 100 )	
	ASS_MenuShowing = true
	timer.Simple( 0, gui.SetMousePos, 110, 110 )
	
	ASS_Debug( "menu opened\n")

end

function ASS_HideMenu()

	CloseDermaMenus()
	ASS_Debug( "menu hiding\n")
	ASS_MenuShowing = false

end

local CountDownPanel = nil
local NoticePanel = nil

function ASS_Countdown( NAME, TEXT, DURATION ) 
	
	if (!CountDownPanel) then 	
		CountDownPanel = vgui.Create("DCountDownList")
		if (NoticePanel) then
			NoticePanel.CountDownPanel = CountDownPanel
		end
	end
	
	CountDownPanel:AddCountdown(NAME, TEXT, DURATION)
	
	if (NoticePanel) then	
		NoticePanel:InvalidateLayout()
	end
end

function ASS_RemoveCountdown( NAME ) 
	
	if (!CountDownPanel) then 
		return 
	end
	
	CountDownPanel:RemoveCountdown( NAME )
	
	if (NoticePanel) then	
		NoticePanel:InvalidateLayout()
	end
end

function ASS_BeginProgress( NAME, TEXT, MAXIMUM ) 
	
	if (MAXIMUM == 0) then
		return 
	end

	if (!CountDownPanel) then 	
		CountDownPanel = vgui.Create("DCountDownList")
		if (NoticePanel) then
			NoticePanel.CountDownPanel = CountDownPanel
		end
	end
	
	CountDownPanel:AddProgress(NAME, TEXT, MAXIMUM)
	
	if (NoticePanel) then	
		NoticePanel:InvalidateLayout()
	end
end

function ASS_IncProgress( NAME, INC ) 
	
	if (!CountDownPanel) then return end
	
	CountDownPanel:IncProgress(NAME, INC || 1)

end

function ASS_EndProgress( NAME ) 
	
	if (!CountDownPanel) then 
		return 
	end
	
	CountDownPanel:RemoveCountdown( NAME )
	
	if (NoticePanel) then	
		NoticePanel:InvalidateLayout()
	end

end

function ASS_ShouldShowNoticeBar()

	if (GAMEMODE.ASS_HideNoticeBar) then
		return false
	end

	return (tonumber(ASS_Config["show_notice_bar"]) or 1) == 1

end

function ASS_Notice( NAME, TEXT, DURATION ) 
	
	if (!NoticePanel) then 	
		NoticePanel = vgui.Create("DNoticePanel")	
		NoticePanel.CountDownPanel = CountDownPanel
		NoticePanel:SetVisible( ASS_ShouldShowNoticeBar() )
	end
	
	NoticePanel:AddNotice(NAME, TEXT, DURATION)
end

function ASS_RemoveNotice( NAME ) 
	
	if (!NoticePanel) then 	
		return
	end
	
	NoticePanel:RemoveNotice(NAME)
end

function ASS_ToggleNoticeBar( PLAYER, CMD, ARGS )

	if (ASS_Config["show_notice_bar"] == 0) then
		ASS_Config["show_notice_bar"] = 1
	else
		ASS_Config["show_notice_bar"] = 0
	end
	ASS_WriteConfig()
	
	if (NoticePanel) then
		NoticePanel:SetVisible( ASS_ShouldShowNoticeBar() )
	end

end
concommand.Add("ASS_ToggleNoticeBar", ASS_ToggleNoticeBar)

function ASS_Initialize_A()

	ASS_LoadPlugins()
	
end

function ASS_Initialize_B()

	if (ASS_Initialized) then return end

	concommand.Add("+ASS_Menu", ASS_ShowMenu)
	concommand.Add("-ASS_Menu", ASS_HideMenu)
	
	ASS_Init_Shared()
	
	ASS_Initialized = true

end
concommand.Add("ASS_CS_Initialize", ASS_Initialize_B)

usermessage.Hook( "ASS_BannedPlayer", 
			function(UM)
				ASS_IncProgress("ASS_BannedPlayer")
				local name = UM:ReadString()
				local id = UM:ReadString()
				
				name = name .. " (" .. id .. ")"
				table.insert( ASS_BannedPlayers, { Text = name, ID = id } )
			end
		)
usermessage.Hook( "ASS_ShowBannedPlayerGUI", 
			function(UM)
				ASS_EndProgress("ASS_BannedPlayer")
				ASS_ShowUnbanList()
			end
		)
usermessage.Hook( "ASS_NamedCountdown", 
			function(UM)
				ASS_Countdown( UM:ReadString(), UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_Countdown", 
			function(UM)
				ASS_Countdown( nil, UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_RemoveCountdown", 
			function(UM)
				ASS_RemoveCountdown( UM:ReadString() )
			end
		)	
usermessage.Hook( "ASS_NamedNotice", 
			function(UM)
				ASS_Notice( UM:ReadString(), UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_Notice", 
			function(UM)
				ASS_Notice( nil, UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_RemoveNotice", 
			function(UM)
				ASS_RemoveNotice( UM:ReadString() )
			end
		)	
usermessage.Hook( "ASS_BeginProgress", 
			function(UM)
				ASS_BeginProgress( UM:ReadString(), UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_IncProgress", 
			function(UM)
				ASS_IncProgress( UM:ReadString(), UM:ReadFloat() )
			end
		)
usermessage.Hook( "ASS_EndProgress", 
			function(UM)
				ASS_EndProgress( UM:ReadString() )
			end
		)	
hook.Add("Initialize", "ASS_Initialize", ASS_Initialize_A)