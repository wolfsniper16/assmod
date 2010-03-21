
ASS_Config["writer"] = "Default Writer"
ASS_Config["max_temp_admin_time"] = 	4 * 60
ASS_Config["max_temp_admin_ban_time"] = 1 * 10080

ASS_Config["bw_background"] = 1
ASS_Config["tell_admins_what_happened"] = 1

ASS_Config["demomode"] = 0
ASS_Config["demomode_ta_time"] = 30

ASS_Config["admin_speak_prefix"] = "@"

ASS_Config["reasons"] = {

	{	name = "Prop or Tool Abuse", 	reason = "Rule #1: Prop or Tool Abuse"			},
	{	name = "No RDM",				reason = "Rule #2: No RDM"		},
	{	name = "Retaliation",			reason = "Rule #3: Do not Retaliate, contact and admin isntead."		},
	{	name = "NLR",					reason = "Rule #4: Do not break the New Life Rule - NLR"		},
	{	name = "Voice or Text Abuase",	reason = "Rule #5: Do not abuse Voice or Text"		},
	{	name = "Annoying",				reason = "Rule #6: Do not be annoying"		},
	{	name = "Social Ignorance",		reason = "Rule #7: Social Ignorance - Racism/Religion"		},
		


}

ASS_Config["ban_times"] = {

	{ 	time = 5,		name = "5 Min"		},
	{ 	time = 15,		name = "15 Min"		},
	{ 	time = 30,		name = "30 Min" 	},
	{ 	time = 60,		name = "1 Hour"		},
	{ 	time = 120,		name = "2 Hours"	},
	{ 	time = 1440,	name = "1 Day"		},
	{ 	time = 10080,	name = "1 Week"		},
	{ 	time = 0,		name = "Permanently"		},

}

ASS_Config["temp_admin_times"] = {

	{ 	time = 5,		name = "5 Min"		},
	{ 	time = 15,		name = "15 Min"		},
	{ 	time = 30,		name = "30 Min" 	},
	{ 	time = 60,		name = "1 Hour"		},
	{ 	time = 120,		name = "2 Hours"	},
	{ 	time = 1440,	name = "1 Day"		},
	{ 	time = 10080,	name = "1 Week"		},
	{ 	time = 0,		name = "Permanently"		},

}

ASS_Config["fixed_notices"] = {

	{	duration = 10,		text = "Please read the rules carefully.  We use Permanent Bans!"			},
	{	duration = 6,		text = "Rule #1: No Prop or Tool Abuse"			},
	{	duration = 6,		text = "Rule #2: No random deathmatching/demoting"			},
	{	duration = 6,		text = "Rule #3: Do not Retaliate, contact and admin instead."			},
	{	duration = 6,		text = "Rule #4: Do not break the New Life Rule - NLR"			},
	{	duration = 6,		text = "Rule #5: Do not abuse Voice or Text"			},
	{	duration = 6,		text = "Rule #6: Do not be annoying"			},
	{	duration = 6,		text = "Rule #7: No Social Ignorance - Racism/Religion"			},
	
}
		
ASS_Config["rcon"] = {

	{	cmd = "exit"	},
	{	cmd = "ulx csay Server will be restarting shortly."	},

}