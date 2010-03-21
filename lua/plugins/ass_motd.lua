
local PLUGIN = {}

PLUGIN.Name = "ASSmod MOTD v2"
PLUGIN.Author = "PC Camp EDITED BY Cj"
PLUGIN.Date = "May, NOV, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if CLIENT then
/*====================================================
================== CONFIGURATION =====================
====================================================*/

	ASSMOTD_TimeToWait = 10 -- The time needed until the player can exit the MOTD in seconds

end --<<<<<-----<<<<< NOT a part of CONFIGURATION. DO NOT EDIT!!!

if (SERVER) then 
	
	function PLUGIN.OpenMOTDWhenPlayerSpawns( ply )
		ply:ConCommand( "ASS_MotdOpen" )
	end
	hook.Add( "PlayerInitialSpawn", "OpenMOTDWhenPlayerSpawns", PLUGIN.OpenMOTDWhenPlayerSpawns )
end

if (CLIENT) then

	function PLUGIN.OpenMOTD( ply, cmd, args )

		local MOTDFrame = vgui.Create( "DFrame" )
		MOTDFrame:SetTitle( "Message of The day" )
		MOTDFrame:SetSize( ScrW() - 100, ScrH() - 100 )
		MOTDFrame:Center()
		MOTDFrame:ShowCloseButton( false )
		MOTDFrame:SetBackgroundBlur( true )
		MOTDFrame:SetDraggable( false )
		MOTDFrame:SetVisible( true )
		MOTDFrame:MakePopup()

		local MOTDHTMLFrame = vgui.Create( "HTML", MOTDFrame )
		MOTDHTMLFrame:SetPos( 25, 50 )
		MOTDHTMLFrame:SetSize( MOTDFrame:GetWide() - 50, MOTDFrame:GetTall() - 150 )
		MOTDHTMLFrame:OpenURL("http://www.gamersepoch.com/darkrpmotd/motd.php")

		local CloseButton = vgui.Create( "DButton", MOTDFrame )
		CloseButton:SetSize( 200, 50 )
		CloseButton:SetPos( ( MOTDFrame:GetWide() / 2.3 ) - ( CloseButton:GetWide() / 2 ), MOTDFrame:GetTall() - 60 )
		CloseButton:SetText( "Rules will be followed." )
		CloseButton:SetVisible( false )
		CloseButton.DoClick = function()
			MOTDFrame:Remove()
		end
			
		local OpenButton = vgui.Create( "DButton", MOTDFrame )
		OpenButton:SetSize( 200, 50 )
		OpenButton:SetPos( ( MOTDFrame:GetWide() / 1.7 ) - ( OpenButton:GetWide() / 2 ), MOTDFrame:GetTall() - 60 )
		OpenButton:SetText( "I'm a minge. Ban me." )
		OpenButton:SetVisible( false )
		OpenButton.DoClick = function()
			RunConsoleCommand( "say", "/ooc I'm too much of a mingebag and didn't read the server rules so now I'm leaving." )
			RunConsoleCommand( "say", "/ooc But before I go, I'm going to drop some money.  I'm paying my ID-10T tax of $150." )
			timer.Simple( 9, RunConsoleCommand, "say", "/dropmoney 150" )
			timer.Simple( 10, RunConsoleCommand, "disconnect" )
			MOTDFrame:Remove()
		end

		local x, y = MOTDFrame:GetPos()
		timer.Simple( ASSMOTD_TimeToWait, function()
			CloseButton:SetVisible( true )
			OpenButton:SetVisible( true )
			gui.SetMousePos( x + ( MOTDFrame:GetWide() / 2 ), y + 50 )
		end )

	end
	concommand.Add( "ASS_MotdOpen", PLUGIN.OpenMOTD )

	function PLUGIN.DeleteOldMOTDWhenLeave( ply )
		file.Delete( "ASSmod/motd.txt" )
	end
	
	function PLUGIN.ShowMOTD(MENUITEM)
		RunConsoleCommand( "ASS_MotdOpen" )
	end
	function PLUGIN.AddNonAdminMenu(MENU)
		MENU:AddOption( "View MOTD", PLUGIN.ShowMOTD )
	end

end

ASS_RegisterPlugin(PLUGIN)


