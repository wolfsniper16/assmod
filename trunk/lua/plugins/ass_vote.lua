local PLUGIN = {}

PLUGIN.Name = "Vote"
PLUGIN.Author = "cpf"
PLUGIN.Date = "October, 2008"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = true
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

if (SERVER) then
PLUGIN.results={}
PLUGIN.isrunning=false
PLUGIN.options={}
PLUGIN.pnumAtStart=0
PLUGIN.creator=nil
PLUGIN.query=""

ASS_NewLogLevel("ASS_ACL_VOTE")
function PLUGIN.StartVote( PLAYER, CMD, ARGS ) 
if (PLAYER:IsOperator() and not PLUGIN.isrunning) then
--allowed
PrintTable(ARGS)
if (!ARGS[1] || !ARGS[2] || !ARGS[3] || !ARGS[4]) then
				ASS_MessagePlayer( PLAYER, "Error!\n")
				return
			end
local query=ARGS[1]
local duration=ARGS[2]


--load options
local options={}
for ai=3,#ARGS do
table.insert(options,ARGS[ai])

end
ASS_LogAction( PLAYER, ASS_ACL_VOTE, "created vote " .. query.." with options ".. string.Implode(",",options))
--setup vars
PLUGIN.query=query
PLUGIN.options=options
PLUGIN.isrunning=true
PLUGIN.results={}
PLUGIN.creator=PLAYER
PLUGIN.pnumAtStart=#player.GetAll()
--send
umsg.Start( "ASS_StartVote")
umsg.String(query)
umsg.Long(#options)
for ai=1,#options do
umsg.String(options[ai])

end
umsg.End()

ASS_NamedCountdownAll( "VoteEnd", "Vote Ends", duration )
timer.Create("VoteTimer",duration,1,function () PLUGIN:_StopVote() end)




end
end
concommand.Add("ASS_StartVote", PLUGIN.StartVote)

function PLUGIN.CastVote( PLAYER, CMD, ARGS ) 
PLUGIN.results[PLAYER:SteamID()]=ARGS[1]
PLAYER:PrintMessage(HUD_PRINTTALK,"Vote Cast!")
print (#PLUGIN.results.." "..PLUGIN.pnumAtStart)
local sofar=0
for k, v in pairs(PLUGIN.results) do
if v!="" then sofar=sofar+1 end

end

if sofar>=PLUGIN.pnumAtStart then
PLUGIN:_StopVote()
end

end

concommand.Add("ASS_CastVote",PLUGIN.CastVote)

function PLUGIN.StopVote( PLAYER, CMD, ARGS ) 
if (not PLAYER:IsOperator()) then return end
ASS_LogAction( PLAYER, ASS_ACL_VOTE, "aborted \""..PLUGIN.query.."\" vote")

PLUGIN:_StopVote()

end
concommand.Add("ASS_StopVote",PLUGIN.StopVote)

function PLUGIN._StopVote()
ASS_LogAction( PLUGIN.creator, ASS_ACL_VOTE, PLUGIN.query.." vote ended")
ASS_RemoveCountdownAll( "VoteEnd" )
timer.Destroy("VoteTimer")
umsg.Start( "ASS_EndVote")
umsg.End()
--tally
local totals={}
for k, v in pairs(PLUGIN.results) do
if v!="" then
if totals[v]==nil then totals[v]=0 end
totals[v]=totals[v]+1
end
end
local winnerOp=""
local highestVotes=0

for k, v in pairs(totals) do
if v>highestVotes then 
winnerOp=k
highestVotes=v
end

end

ASS_LogAction( PLUGIN.creator, ASS_ACL_VOTE, "Option " .. winnerOp .. " won vote for ".. PLUGIN.query)
PLUGIN.isrunning=false

end










--End Server
end

if (CLIENT) then
PLUGIN.currentoptions={}
PLUGIN.inprogress=false
PLUGIN.query=""
PLUGIN.numoptions=0
print("AssVote Init\n")
usermessage.Hook( "ASS_StartVote", function (UMSG)
		
			
			PLUGIN.query = UMSG:ReadString()
			PLUGIN.numoptions = UMSG:ReadLong()
			PLUGIN.inprogress=true
			--load up options
			PLUGIN.currentoptions={}
			for ai=1,PLUGIN.numoptions do
			PLUGIN.currentoptions[ai]=UMSG:ReadString()
			end
			PLUGIN:showvoteUI()
		end )
		
usermessage.Hook("ASS_EndVote",function(UMSG)
	if PLUGIN.TE.Close!=nil then
	PLUGIN.TE:Close()
	end
end )
////////////////////////////////////////////////////////////////////////////////////
// DVoteCastFrame
////////////////////////////////////////////////////////////////////////////////////
PANEL = {}

	function PANEL:Init()

		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar()
		self.List:SetSpacing(0)
		self.Query=vgui.Create("DLabel",self)
		self.Query:SetText(PLUGIN.query)
		self.Query:SizeToContents()
		
		

		
		
		
		for k,v in pairs(PLUGIN.currentoptions) do
			self:AddOption( v )
		end
		
		
	end
	
	function PANEL:AddOption( text )
		
		local item = vgui.Create("DButton",self)
		item:SetText(text)
		item.optext=text
		item.DoClick=function(btn) PLUGIN:Cast(btn.optext) end
		print (item:GetTall())
		self.List:AddItem(item)
		
	
	end
	
	function PANEL:Cast(optext)
		
				RunConsoleCommand("ASS_Vote", optext)
				self:Close()
				
	end
	
	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Frame", self )
		if #PLUGIN.currentoptions <8 then
		self.List:SetTall((#PLUGIN.currentoptions*22))
		else
		self.List:SetTall(200)
		end
		
		local height = 32

			height = height + self.List:GetTall()
			height = height + 8
			height = height + 32
			height = height + 8

		self:SetTall(height)

		local width = self:GetWide()

		self.List:SetPos( 8, 64 )
		self.List:SetWide( width - 16 )

		local btnY = 32 + self.List:GetTall() + 8
		self.Query:SetPos(8,32)
		--self.CancelButton:SetPos( width - 8 - btnWid, btnY )
		--self.ApplyButton:SetPos( width - 8 - btnWid - 8 - btnWid, btnY )
	end

	derma.DefineControl( "DVoteCastFrame", "Frame to cast votes", PANEL, "DFrame" )
	
////////////////////////////////////////////////////////////////////////////////////
// DVoteCreateFrame
////////////////////////////////////////////////////////////////////////////////////
PANEL = {}

	function PANEL:Init()

		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar()
		self.List:SetSpacing(0)
		self.Query=vgui.Create("DTextEntry",self)
		self.Query:SetText("Enter Question Here")
		
		
		self.OptionAdd=vgui.Create("DTextEntry",self)
		self.OptionAdd:SetText("")
		self.OptionAdd.OnEnter=function(txe) 
			self:AddOption(self.OptionAdd:GetValue())
			self.OptionAdd:SetText("")
		end
		
		self.TimeSlider=vgui.Create("DNumSlider", self)
		self.TimeSlider:SetMin(10)
		self.TimeSlider:SetMax(120)
		self.TimeSlider:SetText("Duration (seconds)")
		self.TimeSlider:SetValue(30)
		
		self.ApplyButton = vgui.Create("DButton", self)
		self.ApplyButton:SetText("Create")
		self.ApplyButton.DoClick = function(BTN) PLUGIN:StartVoteB() end
		
		
		
		
		
		
		
	end
	
	function PANEL:AddOption( text )
		
		local item = vgui.Create("DButton",self)
		item:SetText(text)
		item.optext=text
		item.DoClick=function(btn) 
			self.List:RemoveItem(btn) 
			self.List:Rebuild()
		end
		
		self.List:AddItem(item)
		
	
	end
	
	
	
	
	
	
	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Frame", self )
		
		self.List:SetTall(200)

		local height = 32

			height = height + self.List:GetTall()
			height = height + 8
			height = height + 128
			height = height + 8

		self:SetTall(height)

		local width = self:GetWide()

		self.List:SetPos( 8, 136 )
		self.List:SetWide( width - 16 )

		local btnY = 32 + self.List:GetTall() + 8
		self.Query:SetPos(8,32)
		self.Query:SetWide(width-16)
		
		self.OptionAdd:SetPos(8,64)
		self.OptionAdd:SetWide(width-16)
		
		self.TimeSlider:SetPos(8,96)
		self.TimeSlider:SetWide(width-16)
		
		
		self.ApplyButton:SetPos( 8, 200+96+2+32+16 )
		self.ApplyButton:SetWide(width-16)
		
	end

	derma.DefineControl( "DVoteCreateFrame", "Frame to create votes", PANEL, "DFrame" )
	
	
	
		
function PLUGIN:showvoteUI()

PLUGIN.TE = vgui.Create("DVoteCastFrame")
			PLUGIN.TE:SetBackgroundBlur( true )
			PLUGIN.TE:SetDrawOnTop( true )
			PLUGIN.TE:SetTitle("Vote")
			PLUGIN.TE:SetVisible( true )
			PLUGIN.TE:SetWide(200)
			PLUGIN.TE:PerformLayout()
			PLUGIN.TE:Center()
			PLUGIN.TE:MakePopup()	


end
function PLUGIN:Cast(option)
RunConsoleCommand("ASS_CastVote",option)
if PLUGIN.TE.Close != nil then
PLUGIN.TE:Close()
end

end
function PLUGIN.AbortVote()
print("Aborting Vote...")
RunConsoleCommand("ASS_StopVote")
return true
end

function PLUGIN.StartVote()
PLUGIN.VC = vgui.Create("DVoteCreateFrame")
			PLUGIN.VC:SetBackgroundBlur( true )
			PLUGIN.VC:SetDrawOnTop( true )
			PLUGIN.VC:SetTitle("Create Vote")
			PLUGIN.VC:SetVisible( true )
			PLUGIN.VC:SetWide(300)
			PLUGIN.VC:PerformLayout()
			PLUGIN.VC:Center()
			PLUGIN.VC:MakePopup()	

return true
end

function PLUGIN.StartVoteB()
local query=PLUGIN.VC.Query:GetValue()
local duration=PLUGIN.VC.TimeSlider:GetValue()
local optionsArray=PLUGIN.VC.List:GetItems()

--hackey hack hack
local cmd="RunConsoleCommand(\"ASS_StartVote\",\""..query.."\",\""..duration.."\""
for k,v in pairs(optionsArray) do
cmd=cmd..",\""..v.optext.."\""
end

cmd=cmd..")"

RunString(cmd)

PLUGIN.VC:Close()
end



function PLUGIN.AddMainMenu(DMENU)			
	
		DMENU:AddSpacer()
		DMENU:AddOption( "Start Vote", PLUGIN.StartVote )
		DMENU:AddOption( "Abort Vote", PLUGIN.AbortVote )

	end



end
ASS_RegisterPlugin(PLUGIN)
