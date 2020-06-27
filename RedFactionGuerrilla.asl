//Red Faction Guerrilla Autosplitter + Load Remover by rythin

//Contanct info in case issues arise:
//Discord: rythin#0135
//Twitter: rythin_sr
//Twitch:  rythin_sr

//todo:
//smarter splits for gurriella activities/side missions (address for activity name needed)
//(im not doing this)

state("RFG", "Steam") {

	//basic splitting
	int missions:			0xDDC350;	//completed mission counter
	string35 missionVid:		0x1C8FF0D; 	//name of the little video that plays before each mission, updates when a new one plays
	int activities:			0xDDC3BC;	//completed guerrilla activity counter
	int cutscene:			0x7EACD0;	//20 first cutscene, 29 cs after intro
	int loading:			0x768D90;
	
	//collectibles & hundo related
	int ores:			0xDDDC34;
	int radioLogs:			0x1102CD8;
	
	//currently unused 
	//int crates:			0xDDDE50;	//EDF Supply Crates counter
	//int sectors:			0xDCEA48;	//liberated sectors counter
}

state("RFG", "Remarstered") {

	//basic splitting
	int missions:			0x21126B0;	
	string35 missionVid:		0x27DB1F5; 	
	int activities:			0x211275C;	
	int cutscene:			0x124BEB4;	
	int loading:			0x125E86C;
	
	//collectibles & hundo related
	int ores:			0x2114E54;
	int radioLogs:			0x279DCE0;
}
	
startup {

	settings.Add("missions" , true, "Missions");
	settings.SetToolTip("missions", "There is no setting for Mars Attacks as the end of that mission will always autosplit and cannot be disabled");
	//i think this makes sense for any% runs but i guess it might cause issues for 100%? if thats the case i'll make it a setting too
	
	//missions
	
	settings.Add("tutorial", true, "Intro", "missions");
	
	vars.m1 = new Dictionary<string,string> { 				
		{"intro_1.bik", "Better Red Than Dead"}, 					
		{"intro_2.bik", "Ambush"},
		{"we_know_where_you_are.bik", "Start Your Engines"},
		{"walker_martian_ranger.bik", "Industrial Revolution"},
		{"friends_martians_countrymen.bik", "Rallying Point"},
		{"partytime.bik", "Ultor Echo"},
		{"death_from_above.bik", "Ashes to Ashes..."},
		{"refugee_truck.bik", "Emergency Response"},
		{"highway_to_hell.bik", "Catch and Release"},
		{"start_your_engines.bik", "Air Traffic Control"},
		{"traffic_jam.bik", "Access Denied"},
		{"tank_attack.bik", "Blitzkrieg"},
		{"guns_of_tharsis.bik", "The Guns of Tharsis"},
		{"death_by_committee.bik", "Death by Committee"},
		{"sniper_hunter.bik", "The Dogs of War"},
		{"save_the_guerrilla_camp.bik", "Hammer of the Gods"}
	};
	
	vars.ml = new List<string>();						
	foreach (var Tag in vars.m1) {							
		settings.Add(Tag.Key, true, Tag.Value, "missions");					
    vars.ml.Add(Tag.Key); };
	
	//splitting the dictionary here because this split requires a different condition than the other mission splits
	//but i still want the list in livesplit to be in order
	settings.Add("marauderCS", true, "Marauder Negotiations (Cutscene)", "missions");
	settings.SetToolTip("marauderCS", "Untested, might split on other cutscenes, if so please contact me and tell me where it splits");
	
	vars.m2 = new Dictionary<string,string> {
		{"ants_vs_magnifying_glass.bik", "Manual Override"},
		{"emergency_broadcast_system.bik", "Emergency Broadcast System"},
		{"assault_the_edf_central_command.bik", "Guerrillas at the Gates"}
		//{"final_mission.bik", "Mars Attacks"}
	};

	foreach (var Tag in vars.m2) {							
		settings.Add(Tag.Key, true, Tag.Value, "missions");					
    vars.ml.Add(Tag.Key); };
	
	//activities *WIP*
	
	settings.Add("act", true, "Activities");
	settings.Add("actAll", false, "Split on completing any Guerrilla Activity", "act");
	
	//initially i wanted to be able to enable/disable every activity but nah its not happening lol
	//vars.a = new Dictionary<string, string> {
	//	{"", ""}
	//};
	
	//vars.al = new List<string>();						
	//foreach (var Tag in vars.a) {							
	//	settings.Add(Tag.Key, true, Tag.Value, "act");					
	//vars.al.Add(Tag.Key); };
	
	//collectibles
	settings.Add("col", false, "Collectibles");
	settings.Add("ore1", false, "Split when destroying an ore cluster", "col");
	settings.Add("ore300", false, "Split upon having destroyed all 300 ore clusters", "col");
	settings.Add("log1", false, "Split upon collecting a Radio Log", "col");
	settings.Add("log36", false, "Split upon collecting all 36 Radio Logs", "col");
	//crates are probably not necessary for hundo
	//settings.Add("crate1", false, "Split upon destroying an EDF Supply Crate", "col");
	//settings.Add("crate250", false, "Split upon having destroyed all 250 EDF Supply Crates", "col");
}

init {
	vars.startReady = 0;
	
	if (modules.First().ModuleMemorySize == 60276736) {
		version = "Remarstered";
	}
	
	else if (modules.First().ModuleMemorySize == 34639872) {
		version = "Steam";
	}
	
	else {
		version = "Unsupported";
	}
	
	//print(modules.First().ModuleMemorySize.ToString());
}

update {

	if (version == "Unsupported") {
		return false;
	}

	//logic used to start the timer after the load that happens after the first cutscene
	//not used currently but might be in the future
	//if (current.cutscene == 0 && old.cutscene == 20) {
	//	vars.startReady = 1;
	//}
	
}

start {
	//this start condition has one false positive ~1 hour into the run
	//basically what im saying is ill let it exist and dont really care
	if (current.cutscene == 20 && old.cutscene == 0) {
		return true;
	}
}

split {

	//MAIN MISSION SPLITS

	//intro split
	//seems like there's 2 cutscenes in the game that share the same ID, but since this is not one of them
	//its convenient enough to use for the split after the intro
	if (current.cutscene == 0 && old.cutscene == 29 && settings["tutorial"] == true) {
		return true;
	}
	
	//split on completing a mission
	if (current.missions > old.missions && settings[current.missionVid] == true && vars.ml.Contains(current.missionVid)) {
		return true;
	}
	
	//split on marauder cutscene
	if (current.cutscene == 0 && old.cutscene == 23 && settings["marauderCS"] == true) {
		return true;
	}
	
	//final split
	//this is just so the final split can't be disabled
	//forcing everyone to have the same timing on run end reduces the possibility of people doing manual split for that for no reason
	if (current.missions == 20 && old.missions == 19) {
		return true;
	}
	
	//ACTIVITIES
	
	//to be improved at a later date
	//for now it just splits on any activity completion
	if (current.activities > old.activities && settings["actAll"]) {
		return true;
	}
	
	//COLLECTIBLES
	
	//ores
	//logic for when its set to only split for full completion and NOT to split for every ore
	if (settings["ore300"] == true && settings["ore1"] == false) {
		if (current.ores == 300 && old.ores == 299) {
			return true;
		}
	}
	
	//if splitting for every ore is enabled we can safely ignore the other setting
	//all this is simply to prevent double split on final pickup in case both options are enabled
	if (settings["ore1"] == true && current.ores > old.ores) {
		return true;
	}
	
	//radio logs
	//this is just a copy-paste of the bit above with altered variables to work for radio logs 
	if (settings["log36"] == true && settings["log1"] == false) {
		if (current.radioLogs == 36 && old.radioLogs == 35) {
			return true;
		}
	}
	
	if (settings["log1"] == true && current.radioLogs > old.radioLogs) {
		return true;
	}
}

isLoading {
	//pauses the timer from the moment a loading screen appears until gaining control of mason after a load
	//id prefer it to unpause the moment the loading screen disappears but i cba looking for a better address
	return current.loading == 0;
}
