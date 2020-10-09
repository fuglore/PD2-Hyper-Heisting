Hooks:Add("LocalizationManagerPostInit", "shin_loc", function(loc)
	LocalizationManager:add_localized_strings({
		["hud_assault_FG_cover1"] = "KILL EACHOTHER, BUT IT'S GOOD INVERSES",
		["hud_assault_FG_cover2"] = "UNADULTERATED MADNESS",
		["hud_assault_FG_cover3"] = "THUGGERY AT THE FULLEST OF DISPLAYS",
		["hud_assault_FG_cover4"] = "ANOTHER FIGHT IS COMING YOUR WAY",
		["hud_assault_FG_cover5"] = "THE WHEEL OF FATE IS TURNING",
		["hud_assault_FG_cover6"] = "THIS IS TUNA WITH BACON",
		["hud_assault_FG_cover7"] = "THIS BATTLE IS ABOUT TO EXPLODE",
		["hud_assault_FG_cover8"] = "TIME TO DEAL REAL CROATIAN DAMAGE",
		["hud_assault_FG_cover9"] = "SHOW ME YOUR MOTIVATION",
		["hud_assault_FG_cover10"] = "LOOK TO LA LUNA",
		["hud_assault_FG_cover11"] = "YOU CANNOT ESCAPE FROM CROSSING FATE",
		["hud_assault_FG_cover12"] = "LIVE AND LET DIE",
		["hud_assault_FG_cover13"] = "WHERE YO CURLY MUSTACHE AT",
		["hud_assault_FG_cover14"] = "WELCOME TO HYPER HEISTING",
		["hud_assault_FG_cover15"] = "LET'S ROCK, BABY",
		["hud_assault_FG_cover16"] = "WE ARE CONTROLLING TRANSMISSION",
		["hud_assault_FG_cover17"] = "LET'S DO IT NOW",
		["hud_assault_FG_cover18"] = "THE SHADOW REMAINS CAST",
		["hud_assault_FG_cover19"] = "HOT SAUCE FOR JEROME",
		["hud_assault_FG_cover20"] = "THE ANSWER LIES IN THE HEART OF BATTLE",
		["hud_assault_FG_cover21"] = "THIS PARTY IS GETTIN CRAZY",
		["hud_assault_FG_cover22"] = "BLAZING STILL MY HEART IS BLAZING",
		["hud_assault_FG_cover23"] = "HEAVEN OR HELL, LET'S ROCK",
		["hud_assault_FG_cover24"] = "FIGHT LIKE A TIGER, WALK IN THE PARK",
		["hud_assault_FG_cover25"] = "EAT CAPTAIN TO END ASS",
		["hud_assault_FG_cover26"] = "CHAD WUZ HERE",
		["hud_assault_FG_cover27"] = "RIP AND TEAR, UNTIL IT IS DONE",
		["hud_assault_FG_cover28"] = "MARANAX INFIRMUX",
		["hud_assault_FG_cover29"] = "CHAKA CHAKA PATA PON", --i gushed to a friend for like 30 minutes over how fun modding pd2 is and they told me to make a patapon reference, i am not allowed to say no
		["hud_assault_FG_cover30"] = "DEROGATORY COMMENTS GO HERE", --fuglore? more like buglore
		["hud_assault_FG_cover31"] = "BATTLE TILL YOU DROP",
		["hud_assault_FG_cover32"] = "YOU MAY TAKE COVER EVERY TIME YOU SCARE THE SHIT",
		["hud_assault_FG_cover33"] = "THIS BRINGS NEW INSANITY",	
		["hud_assault_FG_cover34"] = "WHITE VANS SPOTTED",
		["hud_assault_FG_cover35"] = "NO SWAMP SHARKS INCLUDED",
		["hud_assault_FG_cover36"] = "OH MY GOD WE'RE DOOOOOMED",
		["hud_assault_FG_cover37"] = "VERY DANGEROUS", --a need for speed reference :)
		["hud_assault_FG_cover38"] = "RANDOM CHIMP EVENT",
		["hud_assault_FG_cover39"] = "ENEMY COUNT; A LOT",
		["hud_assault_FG_cover40"] = "HI?",
		["hud_assault_FG_cover41"] = "I EXPECT YOU TO DINE",
		["hud_assault_FG_cover42"] = "YOU WANNA LEARN HOW TO DO A FOCKEN INFINITE",
		["hud_assault_FG_cover43"] = "THE MOVIE IS ON",
		["hud_assault_FG_cover44"] = "NON-STOP DEADLY ACTION",
		["hud_assault_FG_cover45"] = "KEEP THOSE SAUSAGES SAFE",
		["hud_assault_FG_cover46"] = "YOU ARE HALF HEISTER, HALF PUSSY",
		["hud_assault_FG_cover47"] = "GARRETT MUST BE REALLY MAD AT YOU",
		["hud_assault_FG_cover48"] = "410,757,864,530 DEAD COPS",
		["hud_assault_FG_cover49"] = "WELCOME TO HEISTER HOOTERS",
		["hud_assault_FG_cover50"] = "THAT AIN'T DRAGAN",
		["hud_assault_FG_cover51"] = "WHEN GUAC IS EXTRA",
		["hud_assault_FG_cover52"] = "UPPERS GOT ME ACTING STRANGE",
		["hud_assault_FG_cover53"] = "BLUE, RED AND BLACK PARANOIA",
		["hud_assault_FG_cover54"] = "NO ONE CAN SEE THE COLORS BUT YOU",
		["hud_assault_FG_cover55"] = "MANKIND KNEW THEY COULD NOT CHANGE SOCIETY, SO THEY BLAMED THE BEASTS", --long ass stay in cover text lol
		["hud_assault_FG_cover56"] = "TOUCH ME AND I'LL BREAK YOUR FACE",
		["hud_assault_FG_cover57"] = "ARMOR CLAD'N FAITH",
		["hud_assault_FG_cover58"] = "THIS BEAT IS RARE",
		["hud_assault_FG_cover59"] = "IT'S THE WAY U MOVE, TO THE KILLER GROOVE",
		["hud_assault_FG_cover60"] = "FIGHT ON",
		["hud_assault_FG_cover61"] = "STUPID COPS, I'M FUCKIN' BALLIN",
		["hud_assault_FG_cover62"] = "DID HE JUST WALK UP SLOWLY AND CUFF PUNCH?",
		["hud_assault_FG_cover63"] = "#verifyvenuz",
		["hud_assault_FG_cover64"] = "ARE YOU READY TO MEET GOD",
		["hud_assault_FG_cover65"] = "IF ONLY YOU COULD TALK TO THE COPS",
		["hud_assault_FG_cover66"] = "ROLLING EYES FALL",
		["hud_assault_FG_cover67"] = "RULING DIES OUT",
		["hud_assault_FG_cover68"] = "THIS IS WHY WE'VE GOT GUNS",
		["hud_assault_faction_federales"] = "VS. LOS FEDERALES",
		["hud_assault_faction_swat"] = "VS. SWAT TEAM",
		["hud_assault_faction_sharedswat"] = "VS. SWAT TEAM & MURKYWATER BATTALION",		
		["hud_assault_faction_sharedfbi"] = "VS. FBI SQUADRON & MURKYWATER BATTALION",
		["hud_assault_faction_sharedgensec"] = "VS. GENSEC TASKFORCE & MURKYWATER BATTALION",		
		["hud_assault_faction_sharedzeal"] = "VS. ZEAL LEGION",				
		["hud_assault_faction_fbi"] = "VS. FBI SQUADRON",
		["hud_assault_faction_fbitsu"] = "VS. FBI & GENSEC",
		["hud_assault_faction_ftsu"] = "VS. GENSEC TASKFORCE",
		["hud_assault_faction_zeal"] = "VS. ZEAL LEGION",
		["hud_assault_faction_psc"] = "VS. MURKYWATER BATTALION",
		["hud_assault_faction_mad"] = "VS. TRIANGLE TROOPS",
		["hud_assault_faction_hvh"] = "YOU HAVE STARTLED THE HORDE",
		["hud_assault_faction_generic"] = "VS. EVERYONE",
		["hud_assault_faction_mexcross"] = "VS. BATALLÓN MURKYWATER",
		["hud_assault_danger"] = "!!! DANGER !!!",
		["hud_assault_dangermex"] = "!!! PERIGO !!!",
		["hud_assault_FG_danger1"] = "!!! HANG IN THERE !!!",
		["hud_assault_FG_danger2"] = "!!! IT'S NOT OVER YET !!!",
		["hud_assault_FG_danger3"] = "!!! TIME FOR A COMEBACK !!!",
		["hud_assault_FG_danger4"] = "!!! DON'T GIVE UP !!!",
		["hud_assault_FG_danger5"] = "!!! GO OUT WITH A BANG !!!",
		["hud_assault_FG_danger6"] = "!!! GET IT TOGETHER !!!",
		["hud_assault_FG_danger7"] = "!!! CAN'T FALL APART NOW !!!",
		["hud_assault_FG_danger8"] = "!!! IF THEY TRY TO KILL YOU, KILL THEM HARDER !!!",
		["hud_assault_FG_danger9"] = "!!! FAILURE IS IN THE MIND !!!",
		["hud_assault_FG_danger10"] = "!!! HOW QUICKLY THE TIDE TURNS !!!",
		["hud_assault_FG_danger11"] = "!!! MY SNAILS LOVE TO FUCK !!!",
		["hud_assault_FG_danger12"] = "!!! STAY DEFIANT !!!",
		["hud_assault_FG_danger13"] = "!!! THIS IS DEFINITELY NOT YOUR FAULT !!!",
		["hud_assault_FG_danger14"] = "!!! THIS IS TOTALLY YOUR FAULT !!!",
		["hud_assault_FG_danger15"] = "!!! DON'T GO DRIFTING !!!",
		["hud_assault_FG_danger16"] = "!!! WELCOME TO HYPER HEISTING, NERD !!!",
		["hud_assault_FG_danger17"] = "!!! IS THIS YOUR FIRST TIME PLAYING? !!!",
		["hud_assault_FG_danger18"] = "!!! OH SHIT OH SHIT OH SHIT !!!",
		["hud_assault_FG_danger19"] = "!!! BETTER WATCH OUT !!!",
		["hud_assault_FG_danger20"] = "!!! UH OH !!!",
		["hud_assault_FG_danger21"] = "!!! GUESS YOU'LL DIE !!!",
		["hud_assault_FG_danger22"] = "!!! RARE FOOTAGE OF DRAGAN ACTUALLY ANGRY !!!",
		["hud_assault_FG_danger23"] = "!!! ME SAY ALONE BANK, ME SAY ALONE BANK !!!",
		["hud_assault_FG_danger24"] = "!!! YOU WERE LISTENING THE STAY IN COVER PART, RIGHT? !!!",
		["hud_assault_FG_danger25"] = "!!! YOU TOTALLY DID NOT NEED HELP ANYWAY !!!",
		["hud_assault_FG_danger26"] = "!!! YOU HAVE BEEN SUCCESSFULLY DISTRACTED BY THE ASSAULT BANNER !!!",
		["hud_assault_FG_danger27"] = "!!! THIS IS ALL GOING TO HELL !!!",
		["hud_assault_FG_danger28"] = "!!! SCREW THIS !!!",
		["hud_assault_heat"] = "HEAT BONUS",
		["hud_heat_common"] = "BREAK TIME!",
		["hud_heat_1"] = "ANARCHY RULES!",
		["hud_heat_2"] = "DON'T GET COCKY!",
		["hud_heat_3"] = "ROCK ON!",
		["hud_heat_4"] = "STRIIIIIKE!",
		["hud_heat_5"] = "A TOTAL KNOCKOUT!",
		["hud_heat_6"] = "COMPLETE FUCKING OVERKILL!",
		["hud_heat_7"] = "WRECKED!",
		["hud_heat_8"] = "ULTRAAAAAAAA!!!",
		["hud_heat_9"] = "BANISHED!",
		["hud_heat_10"] = "DOMINATING!",
		["hud_heat_11"] = "HOLY SHIT!",
		["hud_heat_12"] = "WOMBO COMBO!",
		["hud_heat_13"] = "YOU'RE A WILD ONE!",
		["hud_heat_14"] = "THIS IS YOUR TIME!",
		["hud_heat_15"] = "GIVE IT YOUR ALL!",
		["hud_heat_16"] = "SMOKIN' SEXY STYLE!",
		["hud_heat_17"] = "DESTRUCTIVE FINISH!",
		["hud_heat_18"] = "DEAD ON!",
		["hud_heat_19"] = "BULLSEYE!",
		["hud_heat_20"] = "BADASS!",
		["hud_heat_21"] = "THAT'S RAD!",
		["hud_heat_22"] = "ACES!",
		["hud_heat_gameplay"] = "YOU HAVE PUSHED BACK THE HORDE MOMENTARILY",
		["hud_assault_cover"] = "STAY IN COVER",
		["hud_assault_cover_blma"] = "stya cover she set u up godamn bitch",		
		["hud_assault_coverhvh"] = "DON'T STOP MOVING",
		["hud_assault_cover_mexcross"] = "MANTENTE A CUBIERTO",
		["hud_assault_cover_repers"] = "ОСТАВАЙТЕСЬ В УКРЫТИИ",		
		["hud_assault_assault"] = "ASSAULT IN PROGRESS",
		["hud_assault_assault_blma"] = "asal,t: blackmailer",		
		["hud_assault_assaultrepers"] = "ИДЁТ ШТУРМ НАЁМНИКОВ",		
		["hud_assault_assaulthvh"] = "NECROCIDE IN PROGRESS",
		["hud_assault_assault_mexcross"] = "ASALTO EN MARCHA",
		["menu_toggle_one_down"] = "SHIN SHOOTOUT",
		["menu_one_down"] = "SHIN SHOOTOUT",
		["menu_cs_modifier_heavies"] = "All special enemies except Bulldozers now have body armor, adds a chance for an armored SMG heavy to spawn.",
		["menu_cs_modifier_magnetstorm"] = "When enemies reload, they emit an electric burst after a short moment that tases players.",
		["menu_cs_modifier_heavy_sniper"] = "Adds a chance for Sniperdozers to spawn.",
		["menu_cs_modifier_taser_overcharge"] = "Tasers now deal double the amount of shock damage while tasing you.",
		["menu_cs_modifier_dozer_lmg"] = "EVERYTHING IS HORRIBLE!!!",
		["menu_cs_modifier_unison"] = "WIP NEW MODIFIER, DOES NOTHING CURRENTLY",
		["menu_cs_modifier_dozer_rage"] = "Adds a chance for an armor piercing Deagle-toting Medic from another dimension to spawn.",
		["menu_cs_modifier_monsoon"] = "Enemies become 15% faster for every assault wave.",
		["menu_cs_modifier_dozer_minigun"] = "Adds a chance for Medicdozers and Minigun Dozers to spawn.",
		["menu_cs_modifier_shield_phalanx"] = "Shotgunners have a chance to be replaced by a Gensec Saiga SWAT.",
		["menu_cs_modifier_dozer_medic"] = "ERROR: menu_cs_modifier_suppressive_winters",
		["menu_cs_modifier_shin"] = "SHIN SHOOTOUT is now enabled.",
		["menu_cs_modifier_no_hurt"] = "Enemies are now more resistant to staggers.",
		["menu_cs_modifier_medic_adrenaline"] = "Adds a chance for a fully armored ZEAL Light to spawn, killable only by shots in the back of the head.",
		["menu_cs_modifier_megacloakers"] = "Cloakers now kick for double damage, send you twice as far, and can jumpkick you from twice as far.",
		["menu_cs_modifier_voltergas"] = "Smoke Grenades are replaced by Tear Gas Smoke Grenades.",
		["menu_cs_modifier_bouncers"] = "Enemies have a chance drop a destructible explosive grenade with a beeping timer on death.",
		["menu_cs_modifier_cloaker_tear_gas"] = "Cloakers are now silent while charging and move 25% faster.",
		["menu_cs_modifier_enemy_health_damage"] = "Enemies deal an additional 15% more damage, are 10% more accurate, have 15% more health, turn 5% faster and detect you slightly faster in Stealth.",
		["loading_heister_13"] = "Go shoot a cop in real life RIGHT NOW!!! It'll end well! Trust me!",
		["loading_heister_21"] = "Only certain special enemies and SMG units can suppress you while you are behind cover!",
		["loading_heister_44"] = "Mayhem, Death Wish and Death Sentence enemies are much better at dodging! Try to predict when they will execute them!",
		["loading_heister_45"] = "The ZEAL Legion only shows up on Death Sentence, a worthy challenge, maybe?",
		["loading_heister_46"] = "All Bulldozers have their own way of being dangerous, try to keep an eye out for their damage, suppression and range!",
		["loading_heister_49"] = "Try to pick your fights properly! Taking on a Minigun Dozer alone is not always gonna work out the way you want it to!",
		["loading_heister_51"] = "Having a generalist build that can do a lot of things is completely ok, assuming you have the raw skill to back it up!",
		["loading_heister_52"] = "The Steadiness stat of your selected armor tracks how hard your camera shakes when getting hit...but in Hyper Heisting, that stat is the same for all armors!",
		["loading_gameplay_15"] = "The ZEALs have extremely good fashion sense, look out for their colors in a crowd to tell what weapons they're using!",
		["loading_gameplay_37"] = "Higher damage rifles and shotguns can take out tougher enemies like Tasers and Bulldozers with less shots, but are weak at crowd control, try to make up for that with another weapon's capabilities!",
		["loading_gameplay_46"] = "Snipers get more accurate as you spend time in their line of fire, try to kill them before that happens!",
		["loading_gameplay_56"] = "During infinite assaults, players can still get out of custody by simply waiting!",
		["loading_gameplay_76"] = "To kill the bulldozer, shoot at it until it dies! It's faceplate, visor, or face in specific!",
		["loading_gameplay_92"] = "Snipers can very easily deplete your armor and health in seconds if ignored, deal with them quickly!",
		["loading_gameplay_13"] = "Know your enemy. The Medic wears a red outfit when wielding a shotgun and a blue outfit when wielding a rifle!",
		["loading_gameplay_73"] = "Running from the horde isn't a bad idea sometimes, but killing enemies is essential to ending an assault wave!",
		["loading_gameplay_96"] = "Captain Winters does not show up in Hyper Heisting! Well, he does! But not really! But kinda! Yeah!",
		["loading_gameplay_97"] = "If regular Captain Winters shows up in any way, for any reason, please post a comment on the MWS page! That's not supposed to happen!",
		["loading_gameplay_126"] = "If you can't tolerate the game without Captain Winters in it, maybe try Restoration Mod!",
		["loading_trivia_59"] = "Winters is the coldest season of the year in polar and temperate zones. It occurs after Autumn and before Spring in each year.",
		["loading_trivia_60"] = "01110111 01101001 01101110 01110100 01100101 01110010 01110011",
		["loading_trivia_61"] = "winters",
		["loading_trivia_62"] = "Captain Winters is not ",
		["loading_trivia_93"] = "Dragan absolutely loathes Tasers! Try punching one in the face with your bare hands while playing as him! You won't regret it!",		
		["loading_hh_title"] = "Hyper Heisting tips",
		["loading_hh_1"] = "Enemies on Death Sentence tend to perform a lot of different tactics, try to identify which groups do which to get an advantage!",
		["loading_hh_2"] = "Ninja enemies deal more damage, and are way better at dodging than the regular assault force! Look out for less armored, more unique units during the assault!",
		["loading_hh_3"] = "Shin Shootout is a mode meant for only the smartest, fastest, toughest players! Enemies become much more aggressive when it's enabled!",
		["loading_hh_4"] = "If you're in a tough situation, don't give up! There's always a way out!",
		["loading_hh_5"] = "Cloaker kicks can send you FLYING backwards and deal massive damage! Stay away from them!",
		["loading_hh_6"] = "Special enemies get more dangerous as difficulties increase! Keep a close eye on them!",
		["loading_hh_7"] = "The cops are generally more intelligent, get faster, deal slightly more damage, and are more accurate every 2 difficulties, while their group tactics get better every difficulty!",
		["loading_hh_8"] = "Listen out for what the cops are saying from around the corner if you can, it'll help you predict what kind of tactics some of the groups might have! You can even hear them throw out smoke grenades and flashbangs!",
		["loading_hh_9"] = "Shotgunners have massive smoke puffs that come out of their gun when they fire, these can help you locate them, and also help you figure out when they can fire again!",	
		["loading_hh_10"] = "If you see extra-bright powerful tracers that distort the area around them, that's probably coming from some important enemy! Like a Shotgunner, or a Bulldozer!",
		["loading_hh_11"] = "Join the Hyper Heisting Discord! You can find a link to it in the ModWorkshop page!",
		["loading_hh_12"] = "Ninja enemies are particularly hard to dominate, but are very strong when converted into Jokers!",
		["loading_hh_13"] = "Heavy SWATs, Maximum Force Responders, and ZEAL Heavy SWATs gain protection from bullet-based instant kills on Death Sentence! But only from weapons and ammo types that can't shoot through walls!",
		["loading_hh_14"] = "You can get to the Hyper Heisting Options through Mod Options in the Options menu!",
		["loading_hh_15"] = "Getting hit by an enemy melee attack will temporarily stagger you, and cause you to be unable to attack for a few moments!",
		["loading_hh_16"] = "Punks are overconfident fodder enemies wielding revolvers, double barreled shotguns, and submachine guns. They will not hurt you much if you do not let them!",
		["loading_hh_17"] = "In Hyper Heisting, Tasers tasing you into incapacitation and getting downed by Cloakers count as actual downs, which can send you into custody! Be careful around them!",
		["loading_hh_18"] = "Ammo pickups have a 5% chance by default to give you one throwable back!",				
		["pattern_truthrunes_title"] = "Truth Runes",				
		["menu_l_global_value_hyperheist"] = "This is a Hyper Heisting item!",
		["menu_l_global_value_hyperheisting_desc"] = "This is a Hyper Heisting item!",		
		["shin_options_title"] = "Hyper Heisting Options!",		
		["shin_toggle_helmet_title"] = "Extreme Helmet Popping!",
		["shin_toggle_helmet_desc"] = "Enhances the force and power of flying helmets, and changes its calculations to give that feeling of extra oomph!",
		["shin_toggle_hhassault_title"] = "Stylish Assault Corner!",
		["shin_toggle_hhassault_desc"] = "Enhances the [POLICE ASSAULT IN PROGRESS] hud area by adding extra flavor! (Such as entirely unique assault text based on the faction you are fighting against!) NOTE: Requires restarting the heist if changed mid-game!",
		["shin_toggle_hhskulldiff_title"] = "Extreme Difficulty Names!",
		["shin_toggle_hhskulldiff_desc"] = "Changes the difficulty names to suit Hyper Heisting's style!",
		["shin_toggle_blurzonereduction_title"] = "Less Blurry Blurzones!",
		["shin_toggle_blurzonereduction_desc"] = "Gently reduces the blurring effect of things such as the Cook Off Methlab in order to stop them from getting in the way of gameplay!",
		["shin_albanian_content_enable_title"] = "enable albanian joke content",
		["shin_enable_albanian_content_title"] = "enable albanian joke content",
		["shin_albanian_content_enable_desc"] = "nable abanian përmbajtje (WARNING: You probably shouldn't enable this!)",		
		["shin_toggle_overhaul_player_title"] = "HH Player-Side Rebalance!",
		["shin_toggle_overhaul_player_desc"] = "Enables the HH playerside rebalance, paired with a modified version of Gambyt's VIWR mod! Featuring various reworks of existing skills to make the game feel fresh! WARNING: ONLY TAKES EFFECT AFTER FULL GAME RESTART!!!",
		["shin_requires_restart_title"] = "Restart required!",
		["shin_requires_restart_desc"] = "You have made changes to the following settings:\n$SETTINGSLIST\nChanges will take effect on game restart.\nHave a nice day!",
		["menu_risk_pd"] = "Accessible. Stone cold.",
		["menu_risk_swat"] = "Simple but challenging. We are cool.",
		["menu_risk_fbi"] = "Challenging, but relaxed. A nice breeze.",
		["menu_risk_special"] = "Plain challenging, keeps your attention. A warm, summer day.",
		["menu_risk_easy_wish"] = "Demands focus. Getting hot in here!",
		["menu_risk_elite"] = "More units rolling in! More heat around the corner!",
		["menu_risk_sm_wish"] = "There is no escaping the flames! FIGHT!"
	})
end)

 if _G.BB or FullSpeedSwarm or Iter or _G.SC or _G.deathvox then
	Hooks:Add("LocalizationManagerPostInit", "HH_Incompatible", function(loc)
	LocalizationManager:add_localized_strings({	
		["menu_toggle_one_down"] = "PLEASE UNINSTALL YOUR AI MODS",
		["menu_one_down"] = "PLEASE UNINSTALL YOUR AI MODS"
	})		
	end)
 end
 
if InFmenu then
  if InFmenu.settings.rainbowassault == true or InFmenu.settings.sanehp == true or InFmenu.settings.copmiss == true or InFmenu.settings.copfalloff or InFmenu.settings.skulldozersahoy == 2 or InFmenu.settings.skulldozersahoy == 3 then
	Hooks:Add("LocalizationManagerPostInit", "HH_IncompatibleIren", function(loc)
	LocalizationManager:add_localized_strings({	
		["menu_toggle_one_down"] = "DISABLE ALL OF IRENFIST'S ENEMY AND ENEMY SPAWN ADJUSTMENTS",
		["menu_one_down"] = "DISABLE ALL OF IRENFIST'S ENEMY AND ENEMY SPAWN ADJUSTMENTS"
	})		
	end)
  end
end

if PD2THHSHIN and PD2THHSHIN:SkullDiffEnabled() then
	Hooks:Add("LocalizationManagerPostInit", "HH_SKULLS", function(loc)
		LocalizationManager:add_localized_strings({			
			["menu_difficulty_normal"] = "SIMPLE",
			["menu_difficulty_hard"] = "SWEET",
			["menu_difficulty_very_hard"] = "MILD",
			["menu_difficulty_overkill"] = "SPICY",
			["menu_difficulty_easy_wish"] = "ULTRA SPICY",
			["menu_difficulty_apocalypse"] = "SCORCHING HOT",
			["menu_difficulty_sm_wish"] = "INFERNAL"	
		})
	end)
end

 
Hooks:Add("LocalizationManagerPostInit", "HH_overhaul", function(loc)
	
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		LocalizationManager:add_localized_strings({
			--Anarchist--
			["menu_deck15_1_desc"] = "Instead of fully regenerating armor when out of combat, The Anarchist will periodically regenerate armor at a rate equivalent to ##8## armor per second. Heavier armor regenerates more armor per tick, but has a longer delay between ticks.\n\nNote: Skills and perks that increases the armor recovery rate are disabled when using this perk deck.",
			["menu_deck15_3_desc"] = "##50%## of your health is converted into ##50%## armor.",
			["menu_deck15_5_desc"] = "##50%## of your health is converted into ##75%## armor.",
			["menu_deck15_7_desc"] = "##50%## of your health is converted into ##100%## armor.",
			["menu_deck15_9_desc"] = "Dealing damage will grant you armor - This can only occur once every ##3## seconds. Heavier armors are granted more armor.\n\nDeck Completion Bonus: Your chance of getting a higher quality item during a PAYDAY is increased by ##10%.##",

			--Even more Fire Power!--
			["menu_more_fire_power_desc"] = "BASIC: ##$basic;##\nYou gain ##1## more shaped charge and ##4## more trip mines.\n\nACE: ##$pro;##\nYou gain ##4## more shaped charges and ##7## more trip mines.",
			
			--Infiltrator/Sociopath Shit--
			["menu_deck8_7_desc"] = "Your movement speed is increased by ##15%##. \n\nYour second and each consecutive melee hit within ##1## second of the last one will deal ##10## times its normal damage.",
			
			["menu_deck8_1_desc"] = "Your movement speed is further increased by ##5%##.",
			
			["menu_deck8_3_desc"] = "Your movement speed is further increased by ##5%##.",

			["menu_deck9_1"] = "No Talk",

			["menu_deck9_1_desc"] = "Your movement speed is increased by ##15%##. \n\nYour second and each consecutive melee hit within ##1## second of the last one will deal ##10## times its normal damage.",
 
			["menu_deck9_5_desc"] ="Killing an enemy with a melee weapon regenerates ##10%## health. \n\nThis cannot occur more than once every ##1## second. \n\nYour movement speed is further increased by ##5%##.",
 
			--Stoic--
			["menu_deck19_1_desc"] = "Unlocks and equips the Stoic Hip Flask.\n\nDamage taken is now reduced by ##66%##. The remaining damage will be applied directly.\n\nThe ##66%## reduced damage will be applied over-time (##12## seconds) instead.\n\nYou can use the throwable key to activate the Stoic Hip Flask and immediately negate any pending damage. The flask has a ##15## second cooldown but time remaining will be lessened by 1 second per enemy killed.",

			["menu_deck17_9"] = "Push It To The Limit",
			
			["menu_second_chances_beta_desc"] = "BASIC: ##$basic##\nYou gain the ability to disable ##1## camera from detecting you and your crew. Effect lasts for ##25## seconds.\n\nACE: ##$pro##\nYou lockpick ##75%## faster. You also gain the ability to lockpick safes.",
			
			["menu_perseverance_beta_desc"] = "BASIC: ##$basic##\nInstead of getting downed instantly, you gain the ability to keep on fighting for ##3## seconds with a ##60%## movement penalty before going down. \n\nACE: ##$pro##\nIncreases the duration of Swan Song to ##6## seconds.",
						
			["menu_overkill_beta_desc"] = "BASIC: ##$basic##\nKilling an enemy at medium range has a ##75%## chance to spread panic among your enemies. \n\nACE: ##$pro##\nWhen you kill an enemy with a shotgun, shotguns recieve a ##35%## damage increase that lasts for ##8## seconds.",
			
			["menu_martial_arts_beta"] = "Martial Master",			
			["menu_martial_arts_beta_desc"] = "BASIC:##$basic##\nYou take ##50%## less damage from all melee attacks.\n\nACE: ##$pro##\nYou are ##100%## more likely to knock down enemies with a melee strike.",
			
			["menu_carbon_blade_beta_desc"] = "BASIC: ##$basic##\nYour saws no longer wear down on damage to enemies. Your saws deal ##100%## more damage.\n\n##Don't forget, huh, I mean for real, my saws all rule, with the world, with appeal!## \n\nACE: ##$pro##\nYou can now saw through shields with your OVE9000 portable saw. When killing an enemy with the saw, you have a ##50%## chance to cause nearby enemies in a ##10m## radius to panic. Panic will make enemies go into short bursts of uncontrollable fear.",
			
			-- ["menu_single_shot_ammo_return_beta_desc"] = "BASIC: ##$basic##\nGetting ##2## headshots in less than ##6## seconds without missing will magically refund ##1## bullet to your used weapon. Can only be triggered by SMGs, Assault Rifles and Sniper Rifles in any firemode.\n\nACE: ##$pro##\nThe amount of headshots required is reduced to ##1##.",
			
			-- this was sposed to have a 15% speed bonus but fuck you 			
			["menu_juggernaut_beta"] = "Big Guy",
			["menu_juggernaut_beta_desc"] = "BASIC: ##$basic##\nUnlocks the ability to wear the Improved Combined Tactical Vest. Your total armor value is increased by ##30%##. \n\nACE: ##$pro##\nYour total armor value is further increased by ##20%##.\n\n##For you.##",
			
			["bm_menu_skill_locked_level_7"] = "Requires the Big Guy skill",
			
			["menu_bandoliers_beta_desc"] = "BASIC: ##$basic##\nYour total ammo capacity is increased by ##25%##.\n\nACE: ##$pro##\nThe ammo pickup of your weapons is increased by ##100%##.\n\nNOTE: Does not stack with the ##Walk-in Closet## ammo pickup bonus gained from perk decks.",
			
			["menu_pistol_beta_messiah"] = "Resurrection",
			["menu_pistol_beta_messiah_desc"] = "BASIC: ##$basic##\nWhile in bleedout, you can revive yourself if you kill an enemy.  This can only happen every ##120## seconds.\n\nACE: ##$pro##\nYou are now protected from otherwise lethal damage for ##1.5## seconds after being revived.\n\n##The mark of my divinity shall scar thy DNA.##",
			
			["menu_fast_fire_beta"] = "Spray & Pray",
			["menu_fast_fire_beta_desc"] = "BASIC: ##$basic##\nYour ranged weapons can now pierce through enemy body armor. This does not apply to throwable weapons. \n\nACE: ##$pro##\nYour SMGs, LMGs and Assault Rifles gain ##15## more bullets in their magazines. This does not affect Lock n' Load aced.",
			
			["menu_gun_fighter_beta_desc"] = "BASIC: ##$basic##\nPistols gain ##5## more damage points. \n\nACE: ##$pro##\nPistols gain an additional ##5## damage points.",
		
			["menu_dance_instructor_desc"] = "BASIC: ##$basic##\nYour pistol magazine sizes are increased by ##5## bullets. \n\nACE: ##$pro##\nYou gain a ##25%## increased rate of fire with pistols.",
			
			["menu_expert_handling_desc"] = "BASIC: ##$basic##\nEach successful pistol hit gives you a ##10%## increased accuracy bonus for ##10## seconds and can stack ##4## times.\n\nACE: ##$pro##\nYou reload all pistols ##25%## faster.",
			
			["menu_backstab_beta"] = "Lower Blow",
			["menu_backstab_beta_desc"] = "BASIC: ##$basic##\nYou gain ##3%## chance to deal ##Critical Hits## for every ##1## point of concealment under ##35## up to ##30%##.\n\n##Critical Hits## deal ##1.5x## the damage of normal hits.\n\nACE: ##$pro##\nYour ##Critical Hits## now deal ##3x## the damage of normal hits.",
			
			["menu_unseen_strike_beta_desc"] = "BASIC: ##$basic##\nIf you do not lose any armor or health for ##4## seconds, you gain a ##35%## chance to deal ##Critical Hits## for ##6## seconds.\n\nACE: ##$pro##\nThe duration of the ##Critical Hits## buff is increased by ##12## seconds.\n\nTaking damage at any point while the effect is active will cancel the effect.",
			
			["menu_deck2_1_desc"] = "You gain ##5%## more health.",
			
			["menu_deck2_3_desc"] = "You are ##15%## more likely to be targeted by enemies when you are close to your crew members.\n\nYou gain ##5%## more health.",
			
			["menu_deck2_5_desc"] = "You gain ##10%## more health.",
			
			["menu_deck2_7_desc"] = "On killing an enemy, you have a chance to spread panic amongst enemies within a ##12m## radius of the victim. Panic will make enemies go into short bursts of uncontrollable fear.",
			
			["menu_deck2_9_desc"] = "You gain an additional ##20%## more health.\n\nYou regenerate ##0.5%## of your health every ##5## seconds.",
			
			["menu_deck10_3_desc"] = "When you pick up ammo, you trigger an ammo pickup for ##50%## of normal pickup to other players in your team.\n\nCannot occur more than once every ##5## seconds.\n\nYou gain ##10%## more health.",

			["menu_deck10_5_desc"] = "When you get healed from picking up ammo packs, your teammates also get healed for ##50%## of the amount.\n\nYou gain ##10%## more health.",
			
			["menu_deck11_3_desc"] = "Damaging an enemy now heals ##2## life points every ##0.3## seconds for ##3## seconds.\n\nYou gain ##10%## more health.",
			
			["menu_deck11_7_desc"] = "Damaging an enemy now heals ##4## life points every ##0.3## seconds for ##3## seconds.\n\nYou gain ##10%## more health.",
			
			["menu_deck13_3_desc"] = "Increases the amount of health stored from kills by ##4##.\n\nYou gain ##5%## more health.",
			
			["menu_deck13_5_desc"] = "Increases the maximum health that can be stored by ##50%##.\n\nYou gain ##5%## more health.\n\nYour chance to dodge is increased by ##10%##.",
			
			["menu_deck13_7_desc"] = "Increases the amount of health stored from kills by ##4##.\n\nYou gain ##5%## more health.",
			
			["menu_prison_wife_beta"] = "Jackpot",
			["menu_prison_wife_beta_desc"] = "BASIC: ##$basic##\nYou regenerate ##5## armor for each successful headshot. This effect cannot occur more than once every ##2## seconds.\n\nACE: ##$pro##\nUpon killing an enemy with a headshot, you gain the ability to resist damage that would otherwise down you. This is lost after taking lethal damage, and can only be activated every ##5## seconds.\n\n##Let's rock, baby!##",
			
			["menu_awareness_beta"] = "Wave Dash",
			["menu_awareness_beta_desc"] = "BASIC: ##$basic##\nAt the first ##0.3## seconds of your sprint, you gain ##50%## faster movement speed.\n\nACE: ##$pro##\nThe stamina cost of starting a sprint and jumping while sprinting is reduced by ##50%##.\n\n##Mission Complete!##",
			
			["menu_bloodthirst"] = "The Instinct",
			["menu_bloodthirst_desc"] = "BASIC: ##$basic##\nAfter every ##2## non-melee kills, gain ##100%## increased Melee damage and an inactive ##5%## reload speed bonus for your next reload.\n\nThis can be stacked for up to ##600%## extra melee damage and ##30%## extra reload speed.\n\nKilling an enemy with a Melee Weapon will ##activate## the reload speed bonus and ##reset## the melee damage bonus.\n\nACE: ##$pro##\nYour Melee Weapons gain ##100%## extra damage when fully charged and you charge your melee weapons ##50%## faster.\n\n##Fight on.##",
			
			["menu_wolverine_beta"] = "Unstoppable",
			["menu_wolverine_beta_desc"] = "BASIC: ##$basic##\nThe less health you have, the more power you gain.\n\nWhen under ##100%## Health, deal up to ##500%## more melee and saw damage.\n\nWhen under ##50%## Health, you reload all weapons 50% faster.\n\nACE: ##$pro##\nWhen at ##50%## Health or below, the effects of being suppressed by special enemies are less effective and your interaction speed with Medic Bags and First Aid Kits is increased by ##75%##.",
			
			["menu_frenzy"] = "Something To Prove",
			["menu_frenzy_desc"] = "BASIC: ##$basic##\nYou start with ##50%## of your Health and cannot heal above that.\n\n##ALL DAMAGE DEALT## is increased by ##25%##.\n\nACE: ##$pro##\n##You lose 1 down.##\n\nYour movement speed is increased by ##25%##.\n\n##ALL DAMAGE DEALT## is further increased by ##25%##.",
			
			-- weapon stuff below	
			["bm_wp_g3_b_short"] = "Short Barrel",
			["bm_wp_g3_b_sniper"] = "Long Barrel",
			["bm_w_p90"] = "Kobus 90 AP Submachine Gun",
			["bm_w_asval"] = "Valkyria AP Rifle",
			["bm_w_x_p90"] = "Akimbo Kobus 90 AP Submachine Guns"			
		})
	end
	
end)