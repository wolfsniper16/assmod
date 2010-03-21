
local PLUGIN = {}

PLUGIN.Name = "Default Writer"
PLUGIN.Author = "Andy Vincent"
PLUGIN.Date = "09th August 2007"
PLUGIN.Filename = PLUGIN_FILENAME
PLUGIN.ClientSide = false
PLUGIN.ServerSide = true
PLUGIN.APIVersion = 2
PLUGIN.Gamemodes = {}

function PLUGIN.AddToLog(PLAYER, ACL, ACTION)

	if (ASS_Config["writer"] != PLUGIN.Name) then return end
	
	local fn = "asslog/" .. ACL .. ".txt"
	local log = ""
	
	if (file.Exists(fn)) then
		log = file.Read(fn)
		
		if (#log > 200000000000000000000000000000) then
			log = "Logs cleared!\n"
		end
	end
	
	log = log .. ASS_FullNick(PLAYER) .. " -> " .. ACTION .. "\n"
	
	file.Write(fn, log)

end

function PLUGIN.LoadRankings()

	if (ASS_Config["writer"] != PLUGIN.Name) then return end

	local rt = ASS_GetRankingTable()
	local ranks = file.Read("ass_rankings.txt")
	
	if (!ranks || ranks == "") then return end
	
	local ranktable = util.KeyValuesToTable(ranks)
	
	for k,v in pairs(ranktable) do
	
		rt[v.id] = {}
		rt[v.id].Rank = v.rank
		rt[v.id].Name = v.name
		rt[v.id].PluginValues = v.pluginvalues or {}
		rt[v.id].UnbanTime = v.unbantime
	
	end

end

function PLUGIN.SaveRankings()

	if (ASS_Config["writer"] != PLUGIN.Name) then return end

	local rt = ASS_GetRankingTable()
	local ranktbl = {}
	
	for k,v in pairs(rt) do

		if (v.Rank != ASS_LVL_GUEST || table.Count(v.PluginValues) != 0) then
	
			local r = {}
			r.Name = v.Name
			r.Rank = v.Rank
			r.Id = k
			r.PluginValues = {}
			r.UnbanTime = v.UnbanTime
			for nm,val in pairs(v.PluginValues) do
				r.PluginValues[nm] = tostring(val)
			end
			table.insert(ranktbl, r)

		end
	
	end

	local ranks = util.TableToKeyValues( ranktbl )
	file.Write("ass_rankings.txt", ranks)
	
end

ASS_RegisterPlugin(PLUGIN)


