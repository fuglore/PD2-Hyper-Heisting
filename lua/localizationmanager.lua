Hooks:Add("LocalizationManagerPostInit", "shin_loc", function(loc)
	LocalizationManager:add_localized_strings({
		["hhmenu_hold_to_jump"] = "AUTO-JUMP",
		["hhmenu_hold_to_jump_help"] = "Allow consecutive jumps by simply holding the jump button.",
		["hhmenu_staticrecoil"] = "Static Recoil",
		["hhmenu_staticrecoil_help"] = "Disables the automatic recoil compensation, making you have to manually pull down on the mouse to adjust your aim after you stop firing.",
		["hhmenu_holdtofire"] = "HOLD TO FIRE SINGLE-FIRE WEAPONS",
		["hhmenu_holdtofire_help"] = "Allows players to fire single-fire weapons at their maximum firerate by Fire button.",
		
		["hud_assault_boss_incoming"] = "/// WARNING: BOSS INCOMING ///",
		["hud_assault_boss"] = "DEFEAT THE BOSS TO END THE ASSAULT",
		["hud_assault_bosses"] = "DEFEAT ALL BOSSES TO END THE ASSAULT",
	
		["hud_assault_FG_cover1"] = "KILL EACHOTHER, BUT IT'S GOOD INVERSES",
		["hud_assault_FG_cover2"] = "UNADULTERATED MADNESS",
		["hud_assault_FG_cover3"] = "THUGGERY AT THE FULLEST OF DISPLAYS",
		["hud_assault_FG_cover4"] = "ANOTHER FIGHT IS COMING YOUR WAY",
		["hud_assault_FG_cover5"] = "THE WHEEL OF FATE IS TURNING",
		["hud_assault_FG_cover6"] = "THIS IS TUNA WITH BACON",
		["hud_assault_FG_cover7"] = "THIS BATTLE IS ABOUT TO EXPLODE",
		["hud_assault_FG_cover8"] = "BODY THE COPS",
		["hud_assault_FG_cover9"] = "SHOW ME YOUR MOTIVATION",
		["hud_assault_FG_cover10"] = "LOOK TO LA LUNA",
		["hud_assault_FG_cover11"] = "CAN'T ESCAPE FROM CROSSING FATE",
		["hud_assault_FG_cover12"] = "LIVE AND LET DIE",
		["hud_assault_FG_cover13"] = "WHERE YO CURLY MUSTACHE AT",
		["hud_assault_FG_cover14"] = "WELCOME TO HYPER HEISTING",
		["hud_assault_FG_cover15"] = "LET'S ROCK, BABY",
		["hud_assault_FG_cover16"] = "WE ARE CONTROLLING TRANSMISSION",
		["hud_assault_FG_cover17"] = "LET'S DO IT NOW",
		["hud_assault_FG_cover18"] = "LET'S DANCE, BOYS",
		["hud_assault_FG_cover19"] = "HOT SAUCE FOR JEROME",
		["hud_assault_FG_cover20"] = "THE ANSWER LIES IN THE HEART OF BATTLE",
		["hud_assault_FG_cover21"] = "THIS PARTY IS GETTIN CRAZY",
		["hud_assault_FG_cover22"] = "BLAZING STILL MY HEART IS BLAZING",
		["hud_assault_FG_cover23"] = "HEAVEN OR HELL, LET'S ROCK",
		["hud_assault_FG_cover24"] = "FIGHT LIKE A TIGER, WALK IN THE PYRE",
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
		["hud_assault_FG_cover37"] = "VERY DANGEROUS", --w
		["hud_assault_FG_cover38"] = "RANDOM CHIMP EVENT",
		["hud_assault_FG_cover39"] = "ENEMY COUNT: A LOT",
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
		["hud_assault_FG_cover69"] = "YOU BETTER RUN, YOU BETTER TAKE COVER",
		["hud_assault_FG_cover70"] = "COP. ATHETOS SAY COVER",
		["hud_assault_FG_cover71"] = "LAST ONE ALIVE, LOCK THE DOOR",
		["hud_assault_FG_cover72"] = "BLOOD IS FUEL",
		["hud_assault_FG_cover73"] = "TAKE CALIFORNIA",
		["hud_assault_FG_cover74"] = "WHAT YOU GONNA DO",
		["hud_assault_FG_cover75"] = "WE ARE THE ENERGY",
		["hud_assault_FG_cover76"] = "MAINTAIN 5 METER DISTANCE",
		["hud_assault_FG_cover77"] = "WE'RE TAKING THE POWER",
		["hud_assault_FG_cover78"] = "GUESS IT'LL HAVE TO BE THE PAINFUL WAY",
		["hud_assault_FG_cover79"] = "DO NOT THE COVER",
		["hud_assault_FG_cover80"] = "MYURDERRRRR",
		["hud_assault_FG_cover81"] = "GIVE THEM NO QUARTER",
		["hud_assault_FG_cover82"] = "YOUR FOES ASSEMBLE",
		["hud_assault_FG_cover83"] = "IT'S ON, FOLKS",
		["hud_assault_FG_cover84"] = "FEATURING 0 PERCENT FROGCODE",
		["hud_assault_FG_cover85"] = "NO CARD HOUSES PERMITTED",
		["hud_assault_FG_cover86"] = "BUCKLE YOUR PANTS",
		["hud_assault_FG_cover87"] = "WELCOME TO VIOLENCE",
		["hud_assault_FG_cover88"] = "DOSH, GRAB IT WHILE YA CAN LADS",
		["hud_assault_FG_cover89"] = "NON-STOP HORDE VIOLENCE",
		["hud_assault_FG_cover90"] = "NODE AND NEXUS, FEED UPON THIS LIFE",
		["hud_assault_FG_cover91"] = "DON'T YOU LECTURE ME WITH YOUR 30 SKILL POINT BUILD",
		["hud_assault_FG_cover92"] = "I DO I, DON'T BE FAKE",
		["hud_assault_FG_cover93"] = "GET CRAZY",
		["hud_assault_FG_cover94"] = "JUST SHOOT IN THEIR GENERAL DIRECTION",
		["hud_assault_FG_cover95"] = "ACTIVATE GORILLA MODE",
		["hud_assault_FG_cover96"] = "I HOPE YOU'VE GOT YOUR PANTS ON",
		["hud_assault_FG_cover97"] = "VIOLATE THEIR ACCESS",
		["hud_assault_FG_cover98"] = "YOU HAVE THE RIGHT TO REMAIN VIOLENT",
		["hud_assault_FG_cover99"] = "SHUT THE FUCK UP EAT COVER",
		["hud_assault_FG_cover100"] = "SHOW ME YOUR MOVES",
		["hud_assault_FG_cover101"] = "GET PSYCHED",
		["hud_assault_FG_cover102"] = "ADRENALINE IS PUMPING",
		["hud_assault_FG_cover102"] = "ATOMIC OVERDRIVE",
		["hud_assault_FG_cover103"] = "THERE IS NO FATE",
		["hud_assault_FG_cover104"] = "LET THE HEIST BEGIN",
		["hud_assault_FG_cover105"] = "GET IN THE DAMN COVER, LOVE",
		["hud_assault_FG_cover106"] = "THERE IS NO SPOON",
		["hud_assault_FG_cover107"] = "BRING THE HEAT",
		["hud_assault_FG_cover108"] = "SOMETHING SOMETHING COVER",
		["hud_assault_FG_cover109"] = "DARE TO BELIEVE YOU CAN SURVIVE",
		["hud_assault_FG_cover110"] = "STYLE ON THEM",
		["hud_assault_FG_cover111"] = "ACTION IS COMING",
		["hud_assault_FG_cover112"] = "KEEP IT MOVIN'",
		["hud_assault_FG_cover113"] = "LET'S DO THIS",
		["hud_assault_FG_cover114"] = "I HAVE THE POWER",
		["hud_assault_FG_cover115"] = "IT'S HEISTING TIME",
		["hud_assault_FG_cover116"] = "ROBBERS WITH ATTITUDE",
		["hud_assault_FG_cover117"] = "COME ON YOU PUNK, LET'S HAVE SOME APHEX ACID",
		["hud_assault_FG_cover118"] = "ERROR: hud_assault_F- JUST KIDDING",
		["hud_assault_FG_cover119"] = "IT'S NOT A BIG DEAL",
		["hud_assault_FG_cover120"] = "WHY OH YOU ARE LOVE",
		["hud_assault_FG_cover121"] = "ROB BEARS WITH ATTITUDE",
		["hud_assault_FG_cover122"] = "ROB BEERS WITH ATTITUDE",
		["hud_assault_FG_cover123"] = "BRING IT ON YOU BASTARDS",
		["hud_assault_FG_cover124"] = "THROW ALL YOUR GRENADES",
		["hud_assault_FG_cover125"] = "WASH AWAY THE ANGER",
		["hud_assault_FG_cover126"] = "FEATURING KURGAN FROM RAID: WORLD WAR 2",
		["hud_assault_FG_cover127"] = "I'M HARDLY DRESSED FOR A PARTY",
		["hud_assault_FG_cover128"] = "LAW AHEAD THEREFORE TRY COVER",
		["hud_assault_FG_cover129"] = "GUARD YOUR VALOR",
		["hud_assault_FG_cover130"] = "BY SIGMAR, THEY COME IN NUMBER",
		["hud_assault_FG_cover131"] = "WANTED: DEAD OR ALIVE",
		["hud_assault_faction_nightmare"] = "VS. ???",
		["hud_assault_faction_sbz"] = "VS. SBZ OPERATORS",
		["hud_assault_faction_ovk"] = "VS. OVERKILL MODERATORS",
		["hud_assault_faction_bofadeez"] = "VS. BOVERKILL TAG TEAM",
		["hud_assault_faction_bofa"] = "VS. BO FORCE ALPHA ADMINISTRATORS",
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
		["hud_assault_FG_danger29"] = "!!! THERE IS NO ESCAPE !!!",
		["hud_assault_FG_danger30"] = "!!! NOBODY IS AROUND TO HELP !!!",
		["hud_assault_FG_danger31"] = "!!! YOU WILL BE PROSECUTED TO THE FULL EXTENT OF THE JAM !!!",
		["hud_assault_FG_danger32"] = "!!! HEY SHITASS, WANNA WATCH ME FIGHT OFF THIS ASSAULT WAVE? !!!",
		["hud_assault_FG_danger33"] = "!!! GOSH FLIPPIN DANG IT !!!",
		["hud_assault_FG_danger34"] = "!!! AW COME ON !!!",
		["hud_assault_FG_danger35"] = "!!! REPORTED FOR THROWING !!!",
		["hud_assault_FG_danger36"] = "!!! YOU CAN GO AHEAD AND RESTART NOW !!!",
		["hud_assault_FG_danger37"] = "!!! EVERYTHING IS OK, YOU GOT THIS !!!",
		["hud_assault_FG_danger38"] = "!!! YOU'LL MAKE IT !!!",
		["hud_assault_FG_danger39"] = "!!! THE WITCH HUNTS ARE OVER !!!",
		["hud_assault_FG_danger40"] = "!!! I LEAVE FOR ONE MINUTE AND THIS SHIT HAPPENS !!!",
		["hud_assault_FG_danger41"] = "!!! RUN FOR YOUR FUCKING LIFE !!!",
		["hud_assault_FG_danger42"] = "!!! WE'RE SCREWED, LEG IT !!!",
		["hud_assault_FG_danger43"] = "!!! YOUR LIGHT FADES AWAY !!!",
		["hud_assault_FG_danger44"] = "!!! EMBRACE THE DARKNESS !!!",
		["hud_assault_FG_danger45"] = "!!! UNFORTUNATE BALLSACK !!!",
		["hud_assault_FG_danger46"] = "!!! LAW PREVAILS !!!",
		["hud_assault_FG_danger47"] = "!!! HONESTLY IT'S NOT AS BAD AS IT LOOKS !!!",
		["hud_assault_FG_danger48"] = "!!! STOP BEATING AROUND THE BUSH !!!",
		["hud_assault_FG_danger49"] = "!!! NOW IS THE TIME FOR FEAR !!!",
		["hud_assault_FG_danger50"] = "!!! YOUR BODY WILL SHATTER !!!",
		["hud_assault_FG_danger51"] = "!!! YOU'RE FINISHED !!!",
		["hud_assault_FG_danger52"] = "!!! YOUR SHIT AINT TIGHT !!!",
		["hud_assault_FG_danger53"] = "!!! JUDGEMENT !!!",
		["hud_assault_FG_danger54"] = "!!! IT ENDETH NOW !!!",
		["hud_assault_FG_danger55"] = "!!! THY GORE SHALL GLISTEN !!!",
		["hud_assault_FG_danger56"] = "!!! DIE !!!",
		["hud_assault_FG_danger57"] = "!!! YOU MAKE EVEN THE DEVIL CRY !!!",
		["hud_assault_FG_danger58"] = "!!! FOOLISHNESS, HEISTER, FOOLISHNESS !!!",
		["hud_assault_FG_danger59"] = "!!! SAY PAL, YOU DON'T LOOK SO GOOD !!!",
		["hud_assault_FG_danger60"] = "!!! IT IS INEVITABLE !!!",
		["hud_assault_FG_danger61"] = "!!! WE'RE GOING HOME ALIVE, LIAR, LIAR !!!",
		["hud_assault_FG_danger62"] = "!!! TRY THROWING MORE GRENADES !!!",
		["hud_assault_FG_danger63"] = "!!! YOUR MEMES END HERE !!!",
		["hud_assault_heat"] = "HEAT BONUS",
		["hud_heat_common"] = "BREAK TIME!",
		["hud_heat_1"] = "ANARCHY REIGNS!",
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
		["hud_heat_23"] = "ASSAULT VANQUISHED!",
		["hud_heat_24"] = "PEACE AND TRANQUILITY ACHIEVED!",
		["hud_heat_25"] = "REMINDER: OVERCONFIDENCE IS A SLOW AND INSIDIOUS KILLER!",
		["hud_heat_26"] = "THE SHADOW REMAINS CAST!",
		["hud_heat_27"] = "YOU'RE ALL FURCOAT AND NO KNICKERS, BITCHES!",
		["hud_heat_28"] = "ULTRAKILL!",
		["hud_heat_29"] = "KEEP IT REAL!",
		["hud_heat_30"] = "WELCOME TO HYPER HEISTING!",
		["hud_heat_31"] = "PERFECT!",
		["hud_heat_32"] = "SUPREME VICTORY!",
		["hud_heat_33"] = "KILLER!",
		["hud_heat_34"] = "MASSACRE!",
		["hud_heat_35"] = "THIS IS FUCKIN' WAR, BABY!",
		["hud_heat_36"] = "JACKPOT!",
		["hud_heat_37"] = "TOASTY!",
		["hud_heat_38"] = "VANISH INTO DARK!",
		["hud_heat_39"] = "SAYONARA!",
		["hud_heat_40"] = "TAKE CONTROL, BRAIN POWER!",
		["hud_heat_41"] = "ULTRA-VIOLENCE!",
		["hud_heat_42"] = "HELLFIRE, HELLFIRE!",
		["hud_heat_43"] = "DON'T TELL THE VANGUARD!",
		["hud_heat_44"] = "GUARDIANS MAKE THEIR OWN FATE!",
		["hud_heat_45"] = "SPINE TINGLING!",
		["hud_heat_46"] = "BONE CHILLING!",
		["hud_heat_47"] = "HORROR SHOW!",
		["hud_heat_48"] = "SHRIEKIFIED!",
		["hud_heat_49"] = "RULES OF NATURE!",
		["hud_heat_50"] = "BLAMMO!",
		["hud_heat_51"] = "A VICTORY, YES, BUT THERE IS ALWAYS ANOTHER BATTLE!",
		["hud_heat_52"] = "HOORAY FOR VIOLENCE!",
		["hud_heat_53"] = "BLOOD, SO MUCH BLOOD!",
		["hud_heat_54"] = "YOU HAVE BEEN SUCCESSFULLY CELEBRATED BY THE ASSAULT BANNER!",
		["hud_heat_55"] = "YAY!",
		["hud_heat_56"] = "SMASHING!",
		["hud_heat_57"] = "EXCLAMATION MARK!",
		["hud_heat_58"] = "MEAT BONUS!",
		["hud_heat_gameplay"] = "YOU HAVE PUSHED BACK THE HORDE MOMENTARILY",
		["hud_assault_cover"] = "STAY IN COVER",
		["hud_assault_cover_blma"] = "stya cover she set u up godamn bitch",		
		["hud_assault_coverhvh"] = "DON'T STOP MOVING",
		["hud_assault_cover_mexcross"] = "MANTENTE A CUBIERTO",
		["hud_assault_cover_repers"] = "ОСТАВАЙТЕСЬ В УКРЫТИИ",
		["hud_assault_cover_nightmare"] = "REMAIN HIDDEN",
		["hud_assault_assault"] = "ASSAULT IN PROGRESS",
		["hud_assault_assault_blma"] = "asal,t: blackmailer",		
		["hud_assault_assaultrepers"] = "ИДЁТ ШТУРМ НАЁМНИКОВ",		
		["hud_assault_assaulthvh"] = "NECROCIDE IN PROGRESS",
		["hud_assault_assault_mexcross"] = "ASALTO EN MARCHA",
		["hud_assault_assault_nightmare"] = "SOMETHING IS WRONG",
		["hud_assault_assault_ghosts"] = "MANIFESTATION IN PROGRESS",
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
		["menu_cs_modifier_megacloakers"] = "Cloakers now kick for 50% more damage, send you twice as far, and can jumpkick you from twice as far.",
		["menu_cs_modifier_voltergas"] = "Smoke Grenades are replaced by Tear Gas Smoke Grenades.",
		["menu_cs_modifier_bouncers"] = "Enemies have a chance drop a destructible explosive grenade with a beeping timer on death.",
		["menu_cs_modifier_cloaker_tear_gas"] = "Cloakers are now silent while charging and move 25% faster.",
		["menu_cs_modifier_enemy_health_damage"] = "Enemies deal an additional 10% more damage, have 5% more health, and detect you slightly faster in Stealth.",
		["loading_heister_13"] = "Go shoot a cop in real life RIGHT NOW!!! It'll end well! Trust me!",
		["loading_heister_21"] = "Suppression does NOT completely stop armor regeneration! When taking fire with your armor down, don't panic! Try to cut line of sight and be patient!",
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
		["loading_gameplay_126"] = "If you can't tolerate the game without Captain Winters in it, you can always go back to vanilla! I won't judge!",
		["loading_trivia_59"] = "Winters is the coldest season of the year in polar and temperate zones, opposite to Summers. It occurs after Autumn and before Spring in each year.",
		["loading_trivia_60"] = "01110111 01101001 01101110 01110100 01100101 01110010 01110011",
		["loading_trivia_61"] = "THIS IS THEIR SEASON. YOU WILL NOT ESCAPE.",
		["loading_trivia_62"] = "Captain Winters is not ",
		["loading_trivia_93"] = "Dragan absolutely loathes Tasers! Try punching one in the face with your bare hands while playing as him! You won't regret it!",		
		["loading_hh_title"] = "Hyper Heisting tips",
		["loading_hh_1"] = "Enemies on Death Sentence tend to perform a lot of different tactics, try to identify which groups do which to get an advantage!",
		["loading_hh_2"] = "Ninja enemies deal more damage, and are way better at dodging than the regular assault force! Look out for less armored, more unique units during the assault!",
		["loading_hh_3"] = "Shin Shootout is a mode meant for only the smartest, fastest, toughest players! Enemies become much more aggressive when it's enabled!",
		["loading_hh_4"] = "If you're in a tough situation, don't give up! There's always a way out!",
		["loading_hh_5"] = "In Hyper Heisting, cloaker kicks can send you FLYING backwards and deal massive damage! Stay away from them!",
		["loading_hh_6"] = "In Hyper Heisting, special enemies get more dangerous as difficulties increase! Keep a close eye on them!",
		["loading_hh_7"] = "In Hyper Heisting, the cops are generally more intelligent, get faster, deal slightly more damage, and are more accurate every 2 difficulties, while their group tactics get better every difficulty!",
		["loading_hh_8"] = "Listen out for what the cops are saying from around the corner if you can, it'll help you predict what kind of tactics some of the groups might have! You can even hear them throw out smoke grenades and flashbangs!",
		["loading_hh_9"] = "In Hyper Heisting, shotgunners have massive smoke puffs that come out of their gun when they fire, these can help you locate them, and also help you figure out when they can fire again!",	
		["loading_hh_10"] = "If you see extra-bright powerful tracers that distort the area around them, that's probably coming from some important enemy! Like a Shotgunner, or a Bulldozer!",
		["loading_hh_11"] = "Join the Hyper Heisting Discord! You can find a link to it in the ModWorkshop page!",
		["loading_hh_12"] = "Ninja enemies are particularly hard to dominate, but are very strong when converted into Jokers!",
		["loading_hh_13"] = "In Hyper Heisting, Heavy SWATs, Maximum Force Responders, and ZEAL Heavy SWATs gain protection from bullet-based instant kills on all difficulties! But only from weapons and ammo types that can't shoot through shields!",
		["loading_hh_14"] = "You can get to the Hyper Heisting Options through Mod Options in the Options menu!",
		["loading_hh_15"] = "In Hyper Heisting, getting hit by an enemy melee attack will temporarily stagger you, and cause you to be unable to attack for a few moments!",
		["loading_hh_16"] = "Punks are overconfident fodder enemies wielding revolvers, double barreled shotguns, and submachine guns. They will not hurt you much if you do not let them!",
		["loading_hh_17"] = "In Hyper Heisting, Tasers tasing you into incapacitation and getting downed by Cloakers count as actual downs, which can send you into custody! Be careful around them!",
		["loading_hh_18"] = "In Hyper Heisting, certain throwables can get their ammo back just from pickups by default!",
		["loading_hh_19"] = "In Hyper Heisting, being out of stamina does not cancel your sprint, but does cause it to be slower, and not apply sprinting-related bonuses or effects!",
		["loading_hh_20"] = "In Hyper Heisting, a regular sprint consists of sprinting while above 10 stamina! Sprinting with lower stamina than that will cause sprint-related effects to not activate!",
		["loading_hh_21"] = "Staying in cover is a great way to keep your armor constantly regenerating and intact! Just be careful with enemies pushing in!",
		["loading_hh_22"] = "Ninjas tend to take flanking routes, and are often accompanied by other units!",
		["loading_hh_23"] = "A Heat Bonus will regenerate 50% of your HP and ammo!",
		["loading_hh_24"] = "Heat Bonuses tend to stop cops right in their tracks from pushing in, and buys you some time to do objectives!",
		["loading_hh_25"] = "Heat Bonuses tend to only happen if your crew is doing well, and playing aggressively!",
		["loading_hh_26"] = "Enemies recover much quicker from being wounded on higher difficulties!",
		["loading_hh_27"] = "Sometimes killing an enemy to get away them isn't nescessary! You can just make them keel over with a few gunshots to the body and run!",
		["loading_hh_28"] = "Focusing a lot of gunfire on Bulldozers will stun them for a brief moment, allowing for a quick getaway, or finishing blow!",
		["loading_hh_29"] = "A great way to stun Bulldozers is to pelt them with flames from a Flamethrower for a bit, and then use a gun to guarantee the stun animation!",
		["loading_hh_30"] = "Flamethrowers are great at locking down enemies into stun animations, and tend to finish common mooks off extremely quickly!",
		["loading_hh_31"] = "Cloakers make loud breathing sounds from their gas masks when moving around, keep an ear out!",
		["loading_hh_32"] = "In Hyper Heisting, Shotguns deal a minimum of 10% of their damage at a range! SWAT snipers beware!",
		["loading_hh_33"] = "In Hyper Heisting, when using Shotguns, raising your weapon's Accuracy above 50 grants you increased minimum damage at higher ranges!",
		["loading_hh_34"] = "In Hyper Heisting, the continuous damage an enemy takes when burning is based on the weapon's damage stat! Both for Flamethrowers, and Dragon's Breath rounds on shotguns!",
		["loading_hh_35"] = "A Flamethrower's damage over time will mostly always exceed the Dragon's Breath rounds' damage over time, but will also be much shorter!",
		["loading_hh_36"] = "Move fast, baby, don't be slow! Enemies will have a harder time hitting you if you are moving around!",
		
		["loading_hs_1"] = "It's imperative that everything you say has an exclamation mark in front of it!",
		["loading_hs_2"] = "If it doesn't die, shoot it harder!",
		["loading_hs_3"] = "Three words! Math! Is! For! Losers!",
		["loading_hs_4"] = "They can't kill you if they're dead!",
		["loading_hs_5"] = "You can't be bad at the game if you insult them every other sentence you say!",
		["loading_hs_6"] = "Jerome has many brothers!",
		["loading_hs_7"] = "The Jerome that works with the ZEALs is called Jerome (Cooler)!",
		["loading_hs_8"] = "Go to Crackdown's discord and ask for more neon units!",
		["loading_hs_9"] = "The Deagle-wielding Medic in Crime Spree is from Crackdown's universe! Don't ask how he got here!",
		["loading_hs_10"] = "Jovanny's favorite food is plain oatmeal!",
		["loading_hs_11"] = "Dragan does not have games on his phone.",
		["pattern_truthrunes_title"] = "Truth Runes",				
		["menu_l_global_value_hyperheist"] = "This is a Hyper Heisting item!",
		["menu_l_global_value_hyperheisting_desc"] = "This is a Hyper Heisting item!",		
		
		["shin_options_title"] = "Hyper Heisting Options!",	
		
		["shin_toggle_helmet_title"] = "Extreme Helmet Popping!",
		["shin_toggle_helmet_desc"] = "Enhances the force and power of flying helmets, and changes its calculations to give that feeling of extra oomph!",
		
		["shin_toggle_hhassault_title"] = "Stylish Assault Corner!",
		["shin_toggle_hhassault_desc"] = "Enhances the [POLICE ASSAULT IN PROGRESS] hud area by adding extra flavor! (Such as entirely unique assault text based on the faction you are fighting against!) NOTE: Requires restarting the heist if changed mid-game!",
		
		["shin_toggle_hhskulldiff_title"] = "Hyper Difficulty Names!",
		["shin_toggle_hhskulldiff_desc"] = "Changes the difficulty names to suit Hyper Heisting's style!",
		
		["shin_toggle_blurzonereduction_title"] = "Less Blurry Blurzones!",
		["shin_toggle_blurzonereduction_desc"] = "Gently reduces the blurring effect of things such as the Cook Off Methlab in order to stop them from getting in the way of gameplay!",
		
		["shin_toggle_highpriorityglint_title"] = "High Priority Tells!",
		["shin_toggle_highpriorityglint_desc"] = "Adds a glint to high priority enemies when they're about to fire, and plays a *ding!* when they're within 3 meters to let you know your goose is cooked! (Note: All of this only applies if they're targeting you!)",
		
		["shin_toggle_screenFX_title"] = "Ultra ScreenFX!",
		["shin_toggle_screenFX_desc"] = "Adds various visual adjustments and additions to screen effects that are present in Vanilla! Note: Not recommended to those prone to epilepsy.",
		
		["shin_toggle_suppression_title"] = "X-treme Visible Suppression!",
		["shin_toggle_suppression_desc"] = "Adds a unique visual effect to your screen for when you are being suppressed by enemies!",
		
		["shin_toggle_health_effect_title"] = "Low Health Visuals!",
		["shin_toggle_health_effect_desc"] = "Adds a bloody screen border effect to indicate how low your health is! NOTE: Requires a heist restart to apply changes.",
		
		["shin_screenshakemult_title"] = "Screenshake Intensity",
		["shin_screenshakemult_desc"] = "Allows you to manually set how intense screenshake effects are! You can lower it if you're prone to motion sickness! NOTE: Lowering the screenshake can make the game feel a lot less impactful!",
		
		["shin_toggle_noweirddof_title"] = "Disable Enviromental Depth Of Field!",
		["shin_toggle_noweirddof_desc"] = "Removes the Depth Of Field from backgrounds and the skybox allowing for them to look much clearer! NOTE: Works with the aiming Depth Of Field!",
		
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
		["menu_risk_sm_wish"] = "There is no escaping the flames! FIGHT!",
		["menu_hh_mutator_incomp"] = "This mutator is incompatible with Hyper Heisting...! Sadly!",
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
			["menu_difficulty_normal"] = "SWEET",
			["menu_difficulty_hard"] = "SOFT",
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
			--SPEED IS WAR
			["bm_menu_movement"] = "M/S",

			--Rogue
			["menu_deck4_1_desc"] = "Your chance to dodge is increased by ##5%##.",
			["menu_deck4_5_desc"] = "Your chance to dodge is increased by ##10%##.",
			["menu_deck4_7_desc"] = "Your chance to dodge is increased by ##15%##.",
		
			--Crook
			["menu_deck6_1_desc"] = "Your chance to dodge is increased by ##5%##.",
			["menu_deck6_5_desc"] = "Your chance to dodge is increased by ##5%## for ballistic vests.\n\nYour armor is increased by ##20%## for ballistic vests.",
			["menu_deck6_7_desc"] = "Your chance to dodge is increased by ##5%## for ballistic vests.\n\nYour armor is increased by ##25%## for ballistic vests.",
			
			--Burglar
			["menu_deck7_1_desc"] = "Your chance to dodge is increased by ##5%##.",
			
			--Ex-President
			["menu_deck13_3_desc"] = "Increases the amount of health stored from kills by ##4##.\n\nYou gain ##5%## more health.",
			["menu_deck13_5_desc"] = "Increases the maximum health that can be stored by ##50%##.\n\nYou gain ##5%## more health.\n\nYour chance to dodge is increased by ##5%##.",
			["menu_deck13_7_desc"] = "Increases the amount of health stored from kills by ##4##.\n\nYou gain ##5%## more health.",
			
			--Sicario
			["menu_deck18_3_desc"] = "Every time the player gets shot, ##10%## dodge chance is gained.\n\nThis effect is reset once the player dodges and will not occur for the next ##6## seconds.",
			["menu_deck18_5_desc"] = "Your chance to dodge is increased by ##5%##.",
			
			--Hacker
			["menu_deck21_3_desc"] = "Your maximum health is increased by ##+10%##.",
			["menu_deck21_5_desc"] = "Killing at least ##1## enemy while the feedback or jamming effect is active will grant ##+15%## dodge for ##30## seconds.",
		
			--Anarchist
			["menu_deck15_1"] = "Warrior Sound",
			["menu_deck15_1_desc"] = "Instead of fully regenerating armor instantly once the Armor Recovery timer has elapsed, The Anarchist will generate ##12## armor every ##6## seconds.\n\nHeavier armors ##generate more armor## per tick, but have a ##longer delay## between ticks.\n\nKilling enemies ##speeds up the delay## between ticks for armor generation, with each enemy killed being ##1/20th## of the timer.\n\nNote: Skills and perks that increases the armor recovery rate are disabled when using this perk deck.",
			
			["menu_deck15_3"] = "Run You",
			["menu_deck15_3_desc"] = "##50%## of your health is converted into ##25%## armor.",
			
			["menu_deck15_5"] = "New Design",
			["menu_deck15_5_desc"] = "##75%## of your health is converted into ##50%## armor.",
			
			["menu_deck15_7"] = "Requiem",
			["menu_deck15_7_desc"] = "Killing enemies now speeds up the delay between ticks for armor generation by ##1/10th## of the timer.",
			
			["menu_deck15_9"] = "No Respect",
			["menu_deck15_9_desc"] = "Upon taking health damage, ##you regenerate the next tick of armor instantly##.\n\nDeck Completion Bonus: Your chance of getting a higher quality item during a PAYDAY is increased by ##10%.##",

			--Even more Fire Power!--
			["menu_more_fire_power_desc"] = "BASIC: ##$basic;##\nYou gain ##1## more shaped charge and ##4## more trip mines.\n\nACE: ##$pro;##\nYou gain ##4## more shaped charges and ##7## more trip mines.",
			
			--Infiltrator/Sociopath Shit--
			["menu_deck8_1_desc"] = "Your movement speed is further increased by ##5%##.",
			
			["menu_deck8_3_desc"] = "Your movement speed is further increased by ##5%##.",
			
			["menu_deck8_7_desc"] = "Your movement speed is increased by ##15%##. \n\nEach consecutive melee hit will increase your melee weapon swing speed by ##25%## for ##1.5## seconds.\n\nThis can be stacked up to ##4## times.\n\nRunning out of time will reset all stacks",
			
			["menu_deck8_9_desc"] = "Striking an enemy with your melee weapon will heal you for ##+25 Health##.\n\nThis cannot occur more than once every ##5## seconds",

			["menu_deck9_1"] = "No Talk",

			["menu_deck9_1_desc"] = "Your movement speed is increased by ##15%##. \n\nEach consecutive melee hit will increase your melee weapon swing speed by ##25%##for ##1.5## seconds.\n\nThis can be stacked up to ##4## times.\n\nRunning out of time will reset all stacks.",
 
			["menu_deck9_5_desc"] ="Killing an enemy with a melee weapon regenerates ##10%## health. \n\nThis cannot occur more than once every ##1## second. \n\nYour movement speed is further increased by ##5%##.",
 
			--Stoic--
			["menu_deck19_1_desc"] = "Unlocks and equips the Stoic Hip Flask.\n\nDamage taken is now reduced by ##66%##. The remaining damage will be applied directly.\n\nThe ##66%## reduced damage will be applied over-time (##12## seconds) instead.\n\nYou can use the throwable key to activate the Stoic Hip Flask and immediately negate any pending damage. The flask has a ##15## second cooldown but time remaining will be lessened by 1 second per enemy killed.",
			["menu_deck19_3_desc"] = "You gain ##+15%## more health.",

			["menu_deck17_9"] = "Push It To The Limit",
			
			["menu_deck2_1_desc"] = "You gain ##5%## more health.",
			
			["menu_deck2_3_desc"] = "You are ##15%## more likely to be targeted by enemies when you are close to your crew members.\n\nYou gain ##5%## more health.",
			
			["menu_deck2_5_desc"] = "You gain ##5%## more health.",
			
			["menu_deck2_7_desc"] = "On killing an enemy, you have a ##50%## chance to spread ##Panic## amongst enemies within a ##6m## radius of the victim.\n\n##Panic## will make enemies go into ##bursts of uncontrollable fear.##",
			
			["menu_deck2_9_desc"] = "You gain an additional ##5%## more health.\n\nYou regenerate ##1%## of your health every ##5## seconds.",
			
			["menu_deck10_3_desc"] = "When you pick up ammo, you trigger an ammo pickup for ##50%## of normal pickup to other players in your team.\n\nCannot occur more than once every ##5## seconds.\n\nYou gain ##10%## more health.",

			["menu_deck10_5_desc"] = "When you get healed from picking up ammo packs, your teammates also get healed for ##50%## of the amount.\n\nYou gain ##5%## more health.",
			
			--Grinder
			["menu_deck11_1_desc"] = "You start with ##50%## of your Maximum Health and cannot heal above that.\n\nDamaging an enemy heals ##1## life points every ##0.3## seconds for ##3## seconds.\n\nThis effect stacks but cannot occur more than once every ##1.5## seconds, and only while wearing the ##Two-Piece Suit## or ##Lightweight Ballistic Vest##.\n\nNOTE: The health limit stacks with ##Something To Prove##.",
			
			["menu_deck11_3_desc"] = "Damaging an enemy now heals ##2## life points every ##0.3## seconds for ##3## seconds.\n\nYou gain ##10%## more health.",
			
			["menu_deck11_7_desc"] = "Damaging an enemy now heals ##4## life points every ##0.3## seconds for ##3## seconds.\n\nYou gain ##5%## more health.",
			
			["menu_deck17_3_desc"] = "You gain ##5%## more health.",
			["menu_deck17_5_desc"] = "You gain ##5%## more health.\n\nEnemies nearby will prefer targeting you, whenever possible, while the Injector effect is active.",
			["menu_deck17_7_desc"] = "You gain ##5%## more health.\n\nThe amount of health received during the Injector effect is increased by ##25%## while below ##50%## health.",
			["menu_deck17_9_desc"] = "You gain an additional ##5%## more health.\n\nFor every ##50## points of health gained during the Injector effect while at maximum health, the recharge time of the injector is reduced by ##1## second.",
			
			--Leech
			["menu_deck22_1_desc"] = "Unlocks and equips the Leech Ampule.\n\nChanging to another perk deck will make the Leech Ampule unavailable again.\n\nThe Leech Ampule replaces your current throwable, is equipped in your throwable slot and can be switched out if desired.\n\nWhile in game you can use throwable key ##$BTN_ABILITY;## to activate the Leech Ampule.\n\nActivating the Leech Ampule will restore ##40%## health, drain all your stamina and disable your armor and your ability to sprint for the duration of the Leech Ampule.\n\nWhile the Leech Ampule is active your health is divided into segments of ##20%## and damage taken from enemies removes one segment.\n\nKilling ##2## enemies will restore one segment of your health and block damage for ##1## second.\n\nAnytime you take damage your teammates are healed for ##5%## of their health.\n\nThe Leech Ampule lasts ##6## seconds and has a cooldown of ##60## seconds.",
			
			["menu_second_chances_beta_desc"] = "BASIC: ##$basic##\nYou gain the ability to disable ##1## camera from detecting you and your crew. Effect lasts for ##25## seconds.\n\nACE: ##$pro##\nYou lockpick ##75%## faster. You also gain the ability to lockpick safes.",
			
			["menu_perseverance_beta_desc"] = "BASIC: ##$basic##\nInstead of getting downed instantly, you gain the ability to keep on fighting for ##3## seconds with a ##60%## movement penalty before going down. \n\nACE: ##$pro##\nIncreases the duration of Swan Song to ##6## seconds.",
						
			["menu_overkill_beta_desc"] = "BASIC: ##$basic##\nKilling an enemy at medium range has a ##75%## chance to spread ##Panic## among your enemies.\n\n##Panic## will make enemies go into ##bursts of uncontrollable fear.##\n\nACE: ##$pro##\nWhen you kill an enemy with a shotgun, shotguns recieve a ##50%## damage increase that lasts for ##3## seconds.",
			
			["menu_tea_time_beta"] = "Trooper's Syringe",
			["menu_tea_time_beta_desc"] = "BASIC: ##$basic##\nAnyone who uses one of your First Aid Kits or Doctor Bags gains a ##+50%## increase in ##Reload Speed and Interaction Speed## that lasts for ##15## seconds.\n\nACE: ##$pro##\nUsing one of your First Aid Kits or Doctor Bags now also grants the user ##infinite stamina## for ##15## seconds.\n\n##Contains vaccinations, antibiotics, pain killers, steroids, heroine, gasoline...and something that feels like burning.##",
			
			["menu_tea_cookies_beta_desc"] = "BASIC: ##$basic##\nYou gain ##2## extra First Aid Kits.\n\nACE: ##$pro##\nYou gain ##2## more extra First Aid Kits.\n\nYour deployed First Aid Kits will be automatically used if a player is downed within a ##5## meter radius of the First Aid Kit.\n\nThis cannot occur more than once every ##60## seconds.",
			
			["menu_medic_2x_beta"] = "Vitamins",
			["menu_medic_2x_beta_desc"] = "BASIC: ##$basic##\nYour doctor bags now have ##2## charges.\n\nACE: ##$pro##\nYou receive ##+25%## healing from all sources.\n\nYour Doctor Bags now grant the user the ability to resist one instance of ##lethal damage##.\n\n##The container's label has very visible quotation marks.##",
			
			["menu_inspire_beta_desc"] = "BASIC: ##$basic##\nYou revive crew members ##100%## faster. Shouting at your teammates will increase both their movement and reload speed by ##30%## and enable them to resist suppression for ##10## seconds. \n\nACE: ##$pro##\nThere is a ##100%## chance that you can revive crew members at a distance of up to ##9## meters by shouting at them. This cannot occur more than once every ##30## seconds.",
			
			["menu_martial_arts_beta"] = "Martial Master",			
			["menu_martial_arts_beta_desc"] = "BASIC:##$basic##\nYou take ##50%## less damage from all melee attacks.\n\nACE: ##$pro##\nYou are ##100%## more likely to knock down enemies with a melee strike.",
			
			["menu_carbon_blade_beta_desc"] = "BASIC: ##$basic##\nYour saws no longer wear down on damage to enemies. Your saws deal ##100%## more damage.\n\n##Don't forget, huh, I mean for real, my saws all rule, with the world, with appeal!## \n\nACE: ##$pro##\nYou can now saw through shields with your OVE9000 portable saw. When killing an enemy with the saw, you have a ##50%## chance to cause nearby enemies in a ##10m## radius to panic. Panic will make enemies go into short bursts of uncontrollable fear.",
			
			["menu_single_shot_ammo_return_beta"] = "Strange Bandolier",
			["menu_single_shot_ammo_return_beta_desc"] = "BASIC: ##$basic##\nGetting a headshot will refund ##1## bullet to your used weapon.\n\nThis can only be triggered by Pistols, SMGs, Assault Rifles and Sniper Rifles.\n\nACE: ##$pro##\nGetting a headshot will increase your firerate by ##20%## for ##5## seconds.\n\nThis can only be activated by Pistols, SMGs, Assault Rifles and Sniper Rifles.\n\n##The internal mechanisms of your weapons appear to have been re-shapen into mobius strips...##",
			
			["menu_sniper_graze_damage"] = "Fine Red Mist",
			["menu_sniper_graze_damage_desc"] = "BASIC: ##$basic##\nSuccessfully killing an enemy with a headshot will cause a ##massive blood explosion## that ##staggers## enemies and deals ##300## damage within a ##2m## radius of the victim.\n\nThis can only be activated by weapons fired in their ##single-fire## mode.\n\nACE: ##$pro##\nFine Red Mist's blood explosion range is increased to ##4 meters##.\n\n##Thanks for standing still, wanker!##",
			
			["menu_shotgun_cqb_beta"] = "High Quality Grease",
			["menu_shotgun_cqb_beta_desc"] = "BASIC: ##$basic##\nYour weapon swap speed is increased by ##+50%## while you are ##sprinting##.\n\nACE: ##$pro##\nYou reload shotguns ##+20%## faster while sprinting and ##+40%## faster when you're not.\n\n##You don't want to know what it actually is, but there's no arguing with the results.##",
			
			["menu_shotgun_impact_beta"] = "Shotgun Shoulders",
			["menu_shotgun_impact_beta_desc"] = "BASIC: ##$basic##\nYour shotguns gain ##+12## stability.\n\nACE: ##$pro##\nYour shotguns deal ##+25%## damage to ##healthy enemies##.\n\n##FLASHYN!##",
			
			["menu_close_by_beta"] = "Cool Hunting",
			["menu_close_by_beta_desc"] = "BASIC: ##$basic##\nYour shotguns gain ##+25%## increased magazine capacity.\n\nIn addition, your shotguns with magazines have their magazine size increased by ##+8##.\n\nACE: ##$pro##\nYour shotguns gain a ##+0.5%## increase to firerate when you kill an enemy.\n\nThe buff lasts ##2## seconds, and can be stacked ##infinitely##, with each activation ##refreshing it's duration##.\n\n##Problem solved!##",
			
			["menu_iron_man_beta_desc"] = "BASIC: ##$basic##\nIncreases the armor recovery rate for you and your crew by ##25%##.\n\nACE: ##$pro##\nYour Melee Weapons can now ##stagger shields##.",
			
			["menu_juggernaut_beta"] = "Big Guy",
			["menu_juggernaut_beta_desc"] = "BASIC: ##$basic##\nUnlocks the ability to wear the ##Improved Combined Tactical Vest##.\n\nACE: ##$pro##\nYou gain ##115## extra health.\n\nNOTE: ##Big Guy Aced## is applied after multipliers.\n\n##For you.##",
			
			["bm_menu_skill_locked_level_7"] = "Requires the Big Guy skill",
			
			["menu_bandoliers_beta"] = "Destructive Criticism",
			["menu_bandoliers_beta_desc"] = "BASIC: ##$basic##\nYour total ammo capacity is increased by ##25%## and the ammo pickup of your weapons is increased by ##100%##.\n\nACE: ##$pro##\nKilling enemies speeds up the cooldowns on your grenades by ##2%## of their cooldown.\n\nIn addition, the chance of regaining non-grenade Throwables from ammo boxes is increased by ##100%##.\n\nNOTE: Does not stack with the ##Walk-in Closet## ammo pickup bonus gained from perk decks.\n\n##Sticks and stones may break their bones, but YOU are going to VAPORIZE them.##",
			
			["menu_nine_lives_beta"] = "Necromantic Aspect",
			["menu_nine_lives_beta_desc"] = "BASIC: ##$basic##\nAfter being revived, you knock down all cops within ##4 meters##.\n\nACE: ##$pro##\nYou are now protected from ##lethal damage## for ##1.5## seconds after being revived.\n\n##I live...again.##",
			
			["menu_feign_death"] = "Dark Metamorphosis",
			["menu_feign_death_desc"] = "BASIC: ##$basic##\nUpon killing an enemy, regenerate ##2.5## Health.\n\nACE: ##$pro##\nThe regeneration is increased to ##5## Health.\n\n##...But enough talk! Have at you!##",
			
			["menu_pistol_beta_messiah"] = "Resurrection",
			["menu_pistol_beta_messiah_desc"] = "BASIC: ##$basic##\nWhile in bleedout, you can revive yourself if you kill an enemy.  This can only happen every ##240## seconds.\n\nACE: ##$pro##\nYou gain the ability to get downed ##1## more time before going into custody.\n\n##The mark of my divinity shall scar thy DNA.##",
			
			["menu_heavy_impact_beta"] = "Short Holster",
			["menu_heavy_impact_beta_desc"] = "BASIC: ##$basic##\nYou swap weapons ##50%## faster.\n\nACE: ##$pro##\nYour weapons' recoil is reduced by ##20%##.\n\nNOTE: This applies separately from the Stability weapon stat.\n\n##Comfy and easy to wear.##",
			
			["menu_fast_fire_beta"] = "Lead Demiurge",
			["menu_fast_fire_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, LMGs and Assault Rifles gain ##+50%## increased magazine size.\n\nACE: ##$pro##\nHolding down your fire button with any weapon set to automatic fire will slowly increase your firerate by ##25%## over the course of ##3## seconds.\n\n##no popo##",
			
			["menu_body_expertise_beta"] = "Livid Lead",
			["menu_body_expertise_beta_desc"] = "BASIC: ##$basic##\nKilling an enemy with a weapon set to automatic fire will ##automatically## reload ##10%## of your magazine ##from your reserve ammo##.\n\nACE: ##$pro##\n##Livid Lead## reloads ##one extra bullet## on activation and can now also be activated by ##killing an enemy with a Melee Weapon##.\n\n##No better way to take your anger out on people.##",
			
			["menu_gun_fighter_beta_desc"] = "BASIC: ##$basic##\nPistols gain ##5## more damage points. \n\nACE: ##$pro##\nPistols gain an additional ##5## damage points.",
		
			["menu_dance_instructor_desc"] = "BASIC: ##$basic##\nYour pistol magazine sizes are increased by ##5## bullets. \n\nACE: ##$pro##\nYou gain a ##25%## increased rate of fire with pistols.",
			
			["menu_expert_handling_desc"] = "BASIC: ##$basic##\nEach successful pistol hit gives you a ##10%## increased accuracy bonus for ##10## seconds and can stack ##4## times.\n\nACE: ##$pro##\nYou reload all pistols ##25%## faster.",
			
			["menu_sprinter_beta"] = "High Vigour",
			["menu_sprinter_beta_desc"] = "BASIC: ##$basic##\nYour stamina regenerates ##25%## faster.\n\nACE: ##$pro##\nYou gain ##+10## ##Dodge##. ##Dodge## gives you a random chance to ##completely negate damage##.\n\nUpon successfully ##dodging## an attack, regain ##5## stamina.",
			
			["menu_insulation_beta"] = "The Rubber",
			["menu_insulation_beta_desc"] = "BASIC: ##$basic##\nYou ##no longer uncontrollably fire your weapons## while being electrocuted. Your camera shake while being electrocuted is reduced by ##50%##.\n\nACE: ##$pro##\nYou can now move while being electrocuted at ##20%## of your normal movement speed. Your weapon's Accuracy and Stability ##are no longer affected by electrocution##.\n\n##Never engage without protection.##",
			
			--BASIC: When tased, you can now withstand being ##shocked## ##2## more times before you explode with electricity.
			--ACED: When tased, ##you can now free yourself from the Taser## by completing a ##Quick Time Event##.\n\nPressing the Interact key just as a Taser ##shocks## you three times in a row will free you.\n\nFailing to press the Interact key or pressing it at the wrong time cancels the skill.
			
			["menu_jail_diet_beta"] = "Sneakier Bastard",
			["menu_jail_diet_beta_desc"] = "BASIC: ##$basic##\nYou gain a ##1+## ##Dodge## for every ##1## point of detection risk under ##35## up to ##10%##.\n\nACE: ##$pro##\nUpon ##failing to dodge## an attack, re-roll for the same chance as your current ##Dodge## chance to reduce taken damage from the attack by ##25%##.",
			
			["menu_backstab_beta"] = "Lower Blow",
			["menu_backstab_beta_desc"] = "BASIC: ##$basic##\nYou gain ##3%## chance to deal ##Critical Hits## for every ##1## point of concealment under ##35## up to ##30%##.\n\n##Critical Hits## deal ##1.5x## the damage of normal hits.\n\nACE: ##$pro##\nYour ##Critical Hits## now deal ##3x## the damage of normal hits.",
			
			["menu_unseen_strike_beta_desc"] = "BASIC: ##$basic##\nIf you do not lose any armor or health for ##4## seconds, you gain a ##35%## chance to deal ##Critical Hits## for ##6## seconds.\n\nACE: ##$pro##\nThe duration of the ##Critical Hits## buff is increased by ##12## seconds.\n\nTaking damage at any point while the effect is active will cancel the effect.",
			
			["menu_oppressor_beta_desc"] = "BASIC: ##$basic##\nThe duration of the visual effect caused by flashbangs is reduced by ##25%##.\n\nACE: ##$pro##\nYour armor recovery rate is increased by ##15%##.",
			
			["menu_prison_wife_beta"] = "Jackpot",
			["menu_prison_wife_beta_desc"] = "BASIC: ##$basic##\nYou regenerate ##5## armor for each successful headshot. This effect cannot occur more than once every ##10## seconds.\n\nACE: ##$pro##\nUpon killing an enemy with a headshot, you gain the ability to resist one instance of ##lethal damage##. This does not apply multiple times, and can only be activated every ##10## seconds.\n\n##Let's rock, baby!##",
			
			["menu_show_of_force_beta"] = "Cool Headed",
			["menu_show_of_force_beta_desc"] = "BASIC: ##$basic##\nYou gain ##+50%## resistance to suppression while interacting with objects.\n\nACE: ##$pro##\nYou gain ##+50%## resistance to damage while performing interactions.\n\n##Phew, good thing I'm indestructible.##",
			
			["menu_awareness_beta"] = "Wave Dash",
			["menu_awareness_beta_desc"] = "BASIC: ##$basic##\nAt the first ##0.3## seconds of a regular sprint, you gain ##25%## faster movement speed.\n\nYou gain ##+5## ##Dodge## while this effect is active.\n\nACE: ##$pro##\nThe stamina cost of starting a sprint and jumping while sprinting is reduced by ##50%##.\n\nThe stamina requirement to activate sprint-related effects and bonuses is reduced by ##50%##.\n\n##Mission Complete!##",
			
			["menu_trigger_happy_beta"] = "Two Tap",
			["menu_trigger_happy_beta_desc"] = "BASIC: ##$basic##\nAfter ##hitting an enemy## with a Pistol or Akimbo Pistols, gain a ##+40%## damage boost that lasts for ##1.25## seconds.\n\nACE: ##$pro##\nThe duration of the damage boost is increased to ##2## seconds.\n\n##Stay friends, problem that you can't defend!##",	

			["menu_bloodthirst"] = "The Instinct",
			["menu_bloodthirst_desc"] = "BASIC: ##$basic##\nAfter every ##2## non-melee kills, gain ##100%## increased Melee damage and an inactive ##5%## reload speed bonus for your next reload.\n\nThis can be stacked for up to ##600%## extra melee damage and ##30%## extra reload speed.\n\nKilling an enemy with a Melee Weapon will ##activate## the reload speed bonus and ##reset## the melee damage bonus.\n\nACE: ##$pro##\nYour Melee Weapons gain ##100%## extra damage when fully charged and you charge your melee weapons ##50%## faster.\n\n##Fight on.##",
			
			["menu_steroids_beta"] = "Swing Rhythm",
			["menu_steroids_beta_desc"] = "BASIC: ##$basic##\nYour melee attacks deal ##100%## more damage and you swing your melee weapons ##100%## faster.\n\nACE: ##$pro##\nYou cannot be staggered by enemies while ##charging your melee or swinging it.##\n\n##Groovy.##",
			
			["menu_wolverine_beta"] = "Unstoppable",
			["menu_wolverine_beta_desc"] = "BASIC: ##$basic##\nThe less health you have, the more power you gain.\n\nWhen under ##100%## Health, deal up to ##500%## more melee and saw damage.\n\nWhen under ##50%## Health, you reload all weapons ##50%## faster.\n\nACE: ##$pro##\nWhen at ##50%## Health or below, you gain ##+50%## resistance to suppression and your interaction speed with Medic Bags and First Aid Kits is increased by ##75%##.",
			
			["menu_frenzy"] = "Something To Prove",
			["menu_frenzy_desc"] = "BASIC: ##$basic##\nYou start with ##50%## of your Maximum Health and cannot heal above that.\n\n##ALL DAMAGE DEALT## is increased by ##25%##.\n\nACE: ##$pro##\n##You lose 1 down.##\n\nYour movement speed is increased by ##25%##.\n\n##ALL DAMAGE DEALT## is further increased by ##25%##.\n\n##Kill all sons of bitches, right?##",
			
			["bm_grenade_copr_ability_desc"] = "Activating the Leech ability requires you to break a small opaque glass ampule under your nose and take a deep breath. You're not quite sure what's in it, but it makes the world come into focus, and causes your adrenaline to spike.\n\nOne thing is certain; it sure as shit isn't smelling salts, if the faint wriggling shadow inside it doesn't spell it out.",
			
			["hud_stats_pagers_used"] = "STRIKES LEFT",
			
			--mutual perks
			["menu_deckall_2"] = "Used To It",
			["menu_deckall_2_desc"] = "You gain ##+50%## resistance to suppression.",
			
			["menu_deckall_6_desc"] = "Unlocks the ##Armor Bag## equipment for you to use.\n\nThe ##Armor Bag## can be used to change your armor during a heist.",
			
			-- weapon stuff below
			["bm_GEN_speed_strap"] = "Gonzalez Magazine",
			["bm_GEN_decorative_strap"] = "Adds a useless decorative thingymajig to your weapon for style purposes! Makes you FEEL like you're reloading faster!",--bye bye power creep
			["bm_GEN_fmg9_speed_strap"] = "Celebrity X9 Magazine",
			["bm_GEN_fmg9_speed_strap_desc"] = "Used by famous celebrity rapper X9 during a stage performance before he was arrested, Makes you FEEL like you're reloading faster!",
			
			["bm_wp_g3_b_short"] = "Short Barrel",
			["bm_wp_g3_b_sniper"] = "Long Barrel",
			
			["bm_wp_upg_a_piercing_desc"] = "Pierces through enemy armor.",
			["bm_wp_upg_a_custom_desc"] = "Gives your shotgun rounds fancy tracer effects! Purely aesthetic!",
			
			["bm_w_p90"] = "Kobus 90 Piercer Submachine Gun",
			["bm_w_p90_desc"] = "Piercer Rounds that penetrate Walls, Enemies, Shields and Body Armor!",
			["bm_w_asval"] = "Valkyria Piercer Rifle",
			["bm_w_asval_desc"] = "Piercer Rounds that penetrate Walls, Enemies, Shields and Body Armor!",
			["des_shak12"] = "Heavy Rounds that pierce Enemies and Body Armor!",
			["bm_w_shak12_desc"] = "Heavy Rounds that pierce Enemies and Body Armor!",
			["des_ching"] = "High-Caliber Rounds that pierce Enemies, Shields and Body Armor!",
			["bm_w_ching_desc"] = "High-Caliber Rounds that pierce Enemies, Shields and Body Armor!",
			["des_akm"] = "AP Rounds that pierce Body Armor!",
			["bm_w_akm_desc"] = "AP Rounds that pierce Body Armor!",
			["des_scar"] = "AP Rounds that pierce Body Armor!",
			["bm_w_scar_desc"] = "AP Rounds that pierce Body Armor!",
			["des_akm_gold"] = "AP Rounds that pierce Body Armor!",
			["bm_w_akm_gold_desc"] = "AP Rounds that pierce Body Armor!",
			["des_flint"] = "AP Rounds that pierce Body Armor!",
			["bm_w_flint_desc"] = "AP Rounds that pierce Body Armor!",
			["des_ak12"] = "AP Rounds that pierce Body Armor!",
			["bm_w_ak12_desc"] = "AP Rounds that pierce Body Armor!",
			["des_fal"] = "AP Rounds that pierce Body Armor!",
			["bm_w_fal_desc"] = "AP Rounds that pierce Body Armor!",
			["des_m16"] = "AP Rounds that pierce Body Armor!",
			["bm_w_m16_desc"] = "AP Rounds that pierce Body Armor!",
			
			["des_GEN_shotgun_push"] = "This weapon has shotgun push functionality.",

			
			--DMR KITS
			["bm_GEN_light_DMR_desc"] = "Grants your weapon Heavy Rounds that pierce Enemies and Body Armor! Reduces your Rate Of Fire!",
			["bm_GEN_heavy_DMR_desc"] = "Grants your weapon High-Caliber Rounds that pierce Enemies, Shields and Body Armor! Greatly reduces your Rate Of Fire!",
			["bm_GEN_sniper_kit"] = "Highly Modified Kit",
			["bm_GEN_sniperkit_desc"] = "Grants your weapon Piercer Rounds that penetrate Walls, Enemies, Shields and Body Armor! Tremendously reduces your Rate of Fire!",
			
			["bm_menu_damage_falloff_lol_1"] = "A LOT",
			["bm_menu_damage_falloff_lol_2"] = "PLENTY",
			["bm_menu_damage_falloff_lol_3"] = "YES",
			["bm_menu_damage_falloff_lol_4"] = "ALL",
			["bm_menu_damage_falloff_lol_5"] = "MANY",
			["bm_menu_damage_falloff_lol_6"] = "LOTS",
			["bm_menu_damage_falloff_lol_7"] = "LONG",
			["bm_menu_damage_falloff_lol_8"] = "MUCH",
			["bm_menu_damage_falloff_lol_9"] = "145M+",
			["bm_menu_damage_falloff_lol_10"] = "HYPER",
			["bm_menu_damage_falloff_lol_11"] = "OVK",
			["bm_menu_damage_falloff_lol_12"] = "LOADS",
			["bm_menu_damage_falloff_lol_13"] = "HUGE",
			["bm_menu_damage_falloff_lol_14"] = "HATE",
			["bm_menu_damage_falloff_lol_15"] = "LARGE",
			["bm_menu_damage_falloff_lol_15"] = "NYOOM",
			["bm_menu_damage_falloff_lol_16"] = "SWOLE",
			["bm_menu_damage_falloff_lol_17"] = "LOVE",
			["bm_menu_damage_falloff_lol_18"] = "SEVEN",
			["bm_menu_damage_falloff_lol_19"] = "SPACE",
			["bm_menu_damage_falloff_lol_20"] = "TURBO",
			["bm_menu_damage_falloff_lol_21"] = "TACO",
			["bm_menu_damage_falloff_lol_22"] = "CANDY",
			["bm_menu_damage_falloff_lol_23"] = "NITRO",
			["bm_menu_damage_falloff_lol_24"] = "YEAH!",
			["bm_menu_damage_falloff_lol_24"] = "VERY",
			["bm_menu_damage_falloff_lol_25"] = "+++++",
			["bm_menu_damage_falloff_lol_26"] = "WOW",
			["bm_menu_damage_falloff_lol_27"] = "SIGHT",
			["bm_menu_damage_falloff_lol_28"] = "OH MY",
			["bm_menu_damage_falloff_lol_29"] = "FUN",
			["bm_menu_damage_falloff_lol_30"] = "NICE",
			["bm_menu_damage_falloff_lol_31"] = "RUDE",
			["bm_menu_damage_falloff_lol_32"] = "HAPPY",
			["bm_menu_damage_falloff_lol_33"] = "UWU",
			["bm_menu_damage_falloff_lol_34"] = "JEEZ",
			["bm_menu_damage_falloff_lol_35"] = "WOAH",
			["bm_menu_damage_falloff_lol_36"] = "DANG",
			["bm_menu_damage_falloff_lol_37"] = "YOWZA",
			["bm_menu_damage_falloff_lol_38"] = "CASH",
			["bm_menu_damage_falloff_lol_39"] = "CONGA",
			["bm_menu_damage_falloff_lol_40"] = "UNGA",
			["bm_menu_damage_falloff_lol_41"] = "BUNGA",
			["bm_menu_damage_falloff_lol_42"] = "OWO",
		})
	end
	
end)