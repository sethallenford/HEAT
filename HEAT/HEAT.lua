HEAT = HEAT or { initialized = false }

local PROJECT_ERA = 2 -- 1.15.8.64907 
local PROJECT_TBC = 3 -- 2.5.5.65000

local currentProject = WOW_PROJECT_ID or PROJECT_ERA 

local function init()
    if HEAT.initialized then return end

    -- MODIFIED: Initialize as empty, we will populate this dynamically below
    local MAXSIZE = math.huge;
    HEAT.spellData = {}
    HEAT.nameplateBuffs = {} 
    HEAT.soundTable = {}
    HEAT.storedBuffs = {}
    HEAT.spellIDMap = {} 
    HEAT.AuraInfo = {}   
    HEAT.unitCastDelayed = {}
    HEAT.playerGUID = UnitGUID("player");
    HEAT.guidToUnit = {} 
    HEAT.unitTokens = {}
    HEAT.hostilityCache = { cache = {}, head = nil, tail = nil, size = 0, maxSize = MAXSIZE };
    HEAT.SOUND_PREFIX = "Interface\\AddOns\\HEAT\\Sounds\\"
    HEAT.CHANNEL = "Master";
    HEAT.fileExtension = ".ogg";
    HEAT.prefix = "HEAT";
    C_ChatInfo.RegisterAddonMessagePrefix(HEAT.prefix);

    ----------------------------------------------------------------------------
    -- CLASSIC ERA
    ----------------------------------------------------------------------------
    if currentProject == PROJECT_ERA then
        HEAT = HEAT or {}
    
        -- Raw Data: ["Name"] = "ID=Icon=Duration,ID2=Icon2=Duration2"
        HEAT.spellData = {
            -- ommited for Gemini file size requirements
        }
        
        HEAT.nameplateBuffs = {
            "Blessing of Sacrifice",
            "Divine Protection",
            "Divine Shield",
            "Hide",
            "Stealth",
            "Prowl",
            "Shadowmeld",
            "Camouflage",
            "Subterfuge",
            "Perception",
            "Ice Block",
            "Berserker Rage",
            "Divine Intervention",
            "Shield Wall",
            "Retaliation",
            "Recklessness",
            "Blessing of Protection",
            "Death Wish",
            "Divine Shield",
            "Blood Fury",
            "Light of Elune",
            "Honorless Target",
            "Stormpike's Salvation",
            "Evasion",
            "Flee",
            "Sprint",
            "Berserking",
            "Sweeping Strikes",
            "Blessing of Freedom",
            "Will of the Forsaken",
            "Invulnerability",
            "Free Action",
            "Evocation",
            "Stoneform",
            "Petrification",
            "Presence of Mind",
            "Blade Flurry",
            "Elemental Mastery",
            "Mind Quickening",
            "Last Stand"
        }
        
        HEAT.soundTable = {
            ["EXTRA_STRIKES"] = {
                ["Hand of Justice"] = {"Hand of Justice", [15600]=false, [15601]=false},
            },
            ["SPELL_SUMMON"] = {
                ["Death by Peasant"] = {"Death by Peasant", [18307]=false, [18308]=false},
            },
            ["SPELL_CAST_SUCCESS"] = {
                ["Astral Recall"] = {"Astral Recall", [556]=false, [577]=false, [1352]=false},
                ["Blink"] = {"Blink", [517]=false, [894]=false, [1953]=false, [5499]=false, [11262]=false, [12604]=false, [14514]=false, [21655]=false, [23025]=false, [28391]=false, [28401]=false, [29208]=false, [29209]=false, [29210]=false, [29211]=false, [368188]=false, [1231199]=false, [1231233]=false, [1231235]=false, [1231236]=false, [1231237]=false, [1231238]=false, [1231239]=false, [1236175]=false},
                ["Call Pet"] = {"Call Pet", [883]=false, [23498]=false, [27639]=false},
                ["Corruption"] = {"Corruption", [172]=false, [979]=false, [1025]=false, [1107]=false, [6217]=false, [6221]=false, [6222]=false, [6223]=false, [6224]=false, [6225]=false, [7648]=false, [7649]=false, [11671]=false, [11672]=false, [11673]=false, [11674]=false, [11711]=false, [11712]=false, [11713]=false, [13530]=false, [16402]=false, [16985]=false, [17510]=false, [18088]=false, [18376]=false, [18656]=false, [21068]=false, [23439]=false, [23642]=false, [25311]=false, [25419]=false, [25982]=false, [28829]=false, [468242]=false, [1213450]=false, [1219428]=false, [1223963]=false},
                ["Curse of Agony"] = {"Curse of Agony", [980]=false, [981]=false, [1014]=false, [1015]=false, [1029]=false, [1296]=false, [1297]=false, [6217]=false, [6218]=false, [11711]=false, [11712]=false, [11713]=false, [11714]=false, [11715]=false, [11716]=false, [14868]=false, [14875]=false, [17771]=false, [18266]=false, [18671]=false, [462250]=false, [1233077]=false},
                ["Curse of Doom"] = {"Curse of Doom", [603]=false, [18753]=false, [449432]=false},
                ["Curse of Elements"] = {"Curse of Elements", [1490]=false, [7666]=false, [11721]=false, [11722]=false, [11723]=false, [11724]=false, [402792]=false},
                ["Curse of Recklessness"] = {"Curse of Recklessness", [704]=false, [7650]=false, [7658]=false, [7659]=false, [7660]=false, [7661]=false, [11717]=false, [11718]=false, [16231]=false, [1225841]=false},
                ["Curse of Shadow"] = {"Curse of Shadow", [17862]=false, [17865]=false, [17937]=false, [17938]=false, [402791]=false},
                ["Curse of Tongues"] = {"Curse of Tongues", [956]=false, [1714]=false, [5736]=false, [11719]=false, [11720]=false, [12889]=false, [13338]=false, [15470]=false, [25195]=false, [402794]=false, [444046]=false},
                ["Curse of Weakness"] = {"Curse of Weakness", [702]=false, [729]=false, [1031]=false, [1108]=false, [1109]=false, [1393]=false, [1394]=false, [6205]=false, [6206]=false, [7646]=false, [7647]=false, [8552]=false, [11707]=false, [11708]=false, [11709]=false, [11710]=false, [11980]=false, [12493]=false, [12741]=false, [17227]=false, [18267]=false, [21007]=false},
                ["Dark Pact"] = {"Dark Pact", [18220]=false, [18937]=false, [18938]=false, [18939]=false, [18940]=false},
                ["Dark Rune"] = {"Dark Rune", [27869]=false},
                ["Demonic Rune"] = {"Demonic Rune", [16666]=false},
                ["Dispel Magic"] = {"Dispel Magic", [527]=false, [615]=false, [988]=false, [989]=false, [1283]=false, [1284]=false, [15090]=false, [16908]=false, [17201]=false, [19476]=false, [19477]=false, [21076]=false, [23859]=false, [27609]=false, [364812]=false, [1236156]=false},
                ["Drinking"] = {"Drinking", [430]=false, [431]=false, [432]=false, [1133]=false, [1135]=false, [1137]=false, [3359]=false, [3368]=false, [6355]=false, [7920]=false, [8554]=false, [9956]=false, [10250]=false, [14823]=false, [15503]=false, [22734]=false, [23692]=false, [23698]=false, [24355]=false, [25696]=false, [26261]=false, [26402]=false, [26473]=false, [26475]=false, [29007]=false, [29029]=false, [29038]=false, [29039]=false, [29040]=false, [446714]=false, [468767]=false},
                ["Drink"] = {"Drink", [430]=false, [431]=false, [432]=false, [1133]=false, [1135]=false, [1137]=false, [10250]=false, [22734]=false, [24355]=false, [25696]=false, [26261]=false, [26402]=false, [26473]=false, [26475]=false, [29007]=false, [446714]=false, [468767]=false},
                ["Earth Shock"] = {"Earth Shock", [8042]=false, [8043]=false, [8044]=false, [8045]=false, [8046]=false, [8047]=false, [8048]=false, [8049]=false, [10412]=false, [10413]=false, [10414]=false, [10415]=false, [10416]=false, [10417]=false, [13281]=false, [13728]=false, [15501]=false, [22885]=false, [23114]=false, [24685]=false, [25025]=false, [26194]=false, [408681]=false, [408683]=false, [408685]=false, [408687]=false, [408688]=false, [408689]=false, [408690]=false, [408693]=false, [1219379]=false, [1220744]=false, [1220746]=false, [1220747]=false, [1220748]=false, [1220749]=false, [1220750]=false, [1220751]=false},
                ["Feign Death"] = {"Feign Death", [5384]=false, [5385]=false, [19286]=false, [19287]=false, [24432]=false},
                ["Find Herbs"] = {"Find Herbs", [2383]=false, [2481]=false, [8387]=false, [8390]=false},
                ["Find Minerals"] = {"Find Minerals", [2580]=false, [8388]=false, [8389]=false},
                ["Find Treasure"] = {"Find Treasure", [2481]=false},
                ["Fishing"] = {"Fishing", [7620]=false, [7731]=false, [7732]=false, [13615]=false, [18248]=false, [24303]=false, [1229271]=false},
                ["Food"] = {"Food", [433]=false, [434]=false, [435]=false, [1127]=false, [1129]=false, [1131]=false, [2639]=false, [5004]=false, [5005]=false, [5006]=false, [5007]=false, [6410]=false, [7737]=false, [10256]=false, [10257]=false, [18229]=false, [18230]=false, [18231]=false, [18232]=false, [18233]=false, [18234]=false, [22731]=false, [24005]=false, [24707]=false, [24800]=false, [24869]=false, [25660]=false, [25695]=false, [25700]=false, [25702]=false, [25886]=false, [25888]=false, [26260]=false, [26401]=false, [26472]=false, [26474]=false, [28616]=false, [29008]=false, [29073]=false, [446713]=false, [470362]=false, [470369]=false, [1225769]=false, [1225771]=false, [1225772]=false, [1225774]=false, [1226808]=false},
                ["Frost Nova"] = {"Frost Nova", [122]=false, [497]=false, [865]=false, [866]=false, [1194]=false, [1225]=false, [6131]=false, [6132]=false, [6644]=false, [9915]=false, [10230]=false, [10231]=false, [11831]=false, [12674]=false, [12748]=false, [14907]=false, [15063]=false, [15531]=false, [15532]=false, [22645]=false, [29849]=false, [30094]=false, [463448]=false, [1220855]=false},
                ["Frost Trap"] = {"Frost Trap", [13809]=false, [13811]=false, [409520]=false},
                ["Honorless Target"] = {"Honorless Target", [2479]=false},
                ["Hunter's Mark"] = {"Hunter's Mark", [1130]=false, [5298]=false, [14323]=false, [14324]=false, [14325]=false, [14431]=false, [14432]=false, [14434]=false, [1213268]=false},
                ["Immune Charm/Fear/Stun"] = {"Trinketed Druid", [23277]=false},
                ["Immune Root/Snare/Stun"] = {"Trinketed Hunter", [5579]=false},
                ["Immune Fear/Polymorph/Stun"] = {"Trinketed Paladin", [23276]=false},
                ["Immune Fear/Polymorph/Stun"] = {"Trinketed Priest", [23276]=false},
                ["Immune Fear/Polymorph/Snare"] = {"Trinketed Mage", [18850]=false, [23274]=false},
                ["Immune Charm/Fear/Polymorph"] = {"Trinketed Rogue", [23273]=false},
                ["Immune Root/Snare/Stun"] = {"Trinketed Shaman", [5579]=false},
                ["Immune Charm/Fear/Polymorph"] = {"Trinketed Warlock", [23273]=false},
                ["Immune Root/Snare/Stun"] = {"Trinketed Warrior", [5579]=false},
                ["Life Tap"] = {"Life Tap", [1454]=false, [1455]=false, [1456]=false, [1476]=false, [1477]=false, [1478]=false, [3095]=false, [3096]=false, [3097]=false, [4090]=false, [11687]=false, [11688]=false, [11689]=false, [11690]=false, [11691]=false, [11692]=false, [28830]=false, [31818]=false, [468029]=false},
                ["Mana Spring Totem"] = {"Mana Spring Totem", [5675]=false, [5678]=false, [10495]=false, [10496]=false, [10497]=false, [10512]=false, [10514]=false, [10515]=false, [24854]=false},
                ["Mana Tide Totem"] = {"Mana Tide Totem", [16190]=false, [17354]=false, [17359]=false, [17362]=false, [17363]=false},
                ["Mind Soothe"] = {"Mind Soothe", [453]=false, [8126]=false, [8192]=false, [8193]=false, [10953]=false, [10954]=false},
                ["Noggenfogger Elixir"] = {"Noggenfogger Elixir", [16589]=false, [16591]=false, [16593]=false, [16595]=false},
                ["Prowl"] = {"Prowl", [5215]=false, [5216]=false, [6783]=false, [6784]=false, [8152]=false, [9913]=false, [9914]=false, [24450]=false, [24451]=false, [24452]=false, [24453]=false, [24454]=false, [24455]=false},
                ["Psychic Scream"] = {"Psychic Scream", [8122]=false, [8123]=false, [8124]=false, [8125]=false, [10888]=false, [10889]=false, [10890]=false, [10891]=false, [13704]=false, [15398]=false, [22884]=false, [26042]=false, [27610]=false, [437928]=false},
                ["Refocus"] = {"Refocus", [24531]=false},
                ["Shadowburn"] = {"Shadowburn", [17877]=false, [18867]=false, [18868]=false, [18869]=false, [18870]=false, [18871]=false, [18872]=false, [18875]=false, [18876]=false, [18877]=false, [18878]=false},
                ["Stealth"] = {"Stealth", [1784]=false, [1785]=false, [1786]=false, [1787]=false, [1789]=false, [1790]=false, [1791]=false, [1792]=false, [8822]=false, [420536]=false, [450667]=false, [460228]=false, [468879]=false, [1234823]=false},
                ["Thrash"] = {"Thrash", [3391]=false, [3417]=false, [8876]=false, [12787]=false, [21919]=false, [369079]=false, [417437]=false, [417440]=false, [417441]=false, [417448]=false, [417450]=false, [417453]=false},
                ["Track Beasts"] = {"Track Beasts", [1494]=false, [1547]=false},
                ["Track Demons"] = {"Track Demons", [19878]=false, [20155]=false},
                ["Track Dragonkin"] = {"Track Dragonkin", [19879]=false, [20156]=false},
                ["Track Elementals"] = {"Track Elementals", [19880]=false, [20157]=false},
                ["Track Giants"] = {"Track Giants", [19882]=false, [20158]=false},
                ["Track Hidden"] = {"Track Hidden", [19885]=false, [20159]=false},
                ["Track Humanoids"] = {"Track Humanoids", [5225]=false, [19883]=false, [20160]=false},
                ["Track Undead"] = {"Track Undead", [19884]=false, [20161]=false},
                ["Travel Form"] = {"Travel Form", [783]=false, [1441]=false, [5419]=false},
                ["Vanish"] = {"Vanish", [1856]=false, [1857]=false, [1858]=false, [1859]=false, [11327]=false, [11329]=false, [24223]=false, [24228]=false, [24229]=false, [24230]=false, [24231]=false, [24232]=false, [24233]=false, [24699]=false, [24700]=false, [27617]=false, [457437]=false, [1231389]=false, [1234595]=false},
            },
            ["SPELL_CAST_START"] = {
                ["Aimed Shot"] = {"Aimed Shot", [19434]=true, [20900]=true, [20901]=true, [20902]=true, [20903]=true, [20904]=true, [20931]=true, [20932]=true, [20933]=true, [20934]=true, [20935]=true, [27632]=true, [1236188]=true},
                ["Ancestral Healing"] = {"Ancestral Healing", [16176]=false, [16235]=false, [16240]=false},
                ["Ancestral Spirit"] = {"Ancestral Spirit", [2008]=false, [2014]=false, [20609]=false, [20610]=false, [20776]=false, [20777]=false, [20778]=false, [20779]=false, [20780]=false, [20781]=false},
                ["Arcane Bomb"] = {"Arcane Bomb", [19821]=false, [19831]=false, [462664]=false, [466283]=false, [466357]=false},
                ["Arcanite Dragonling"] = {"Arcanite Dragonling", [19804]=false, [19830]=false, [23052]=false, [23074]=false},
                ["Astral Recall"] = {"Astral Recall", [556]=false, [577]=false, [1352]=false},
                ["Bandage"] = {"Bandage", [2379]=false, [14530]=false, [17498]=false, [19307]=false, [22863]=false, [23451]=false, [23978]=false, [462149]=false, [1213972]=false},
                ["Banish"] = {"Banish", [710]=false, [7664]=false, [8994]=false, [18647]=false, [18648]=false, [24466]=false, [27565]=false, [457569]=false, [465352]=false},
                ["Basic Campfire"] = {"Basic Campfire", [818]=false, [1290]=false},
                ["Big Bronze Bomb"] = {"Big Bronze Bomb", [3950]=false, [4010]=false, [4067]=false},
                ["Big Iron Bomb"] = {"Big Iron Bomb", [3967]=false, [4023]=false, [4069]=false},
                ["Blinding Powder"] = {"Blinding Powder", [6510]=false, [6511]=false},
                ["Cannibalize"] = {"Cannibalize", [20577]=false, [20578]=false},
                ["Chain Heal"] = {"Chain Heal", [1064]=false, [1444]=false, [10622]=false, [10623]=false, [10624]=false, [10625]=false, [14900]=false, [15799]=false, [16367]=false, [416244]=false, [416245]=false, [416246]=false},
                ["Chain Lightning"] = {"Chain Lightning", [421]=true, [920]=true, [930]=true, [1339]=true, [1340]=true, [2860]=true, [2862]=true, [2863]=true, [10605]=true, [12058]=true, [15117]=true, [15305]=true, [15659]=true, [16006]=true, [16033]=true, [16921]=true, [20831]=true, [21179]=true, [22355]=true, [23106]=true, [23206]=true, [24680]=true, [25021]=true, [27567]=true, [28167]=true, [28293]=true, [408479]=true, [408481]=true, [408482]=true, [408484]=true, [429825]=true, [446338]=true, [450601]=true, [461686]=true, [461687]=true, [463641]=true, [463946]=true, [465700]=true, [468670]=true, [468671]=true, [1213477]=true},
                ["Chronoboon"] = {"Chronoboon", [1538]=false, [349858]=false, [1223679]=false},
                ["Coarse Dynamite"] = {"Coarse Dynamite", [3931]=false, [3994]=false, [4061]=false, [8333]=false, [9002]=false, [9003]=false, [9004]=false, [9009]=false},
                ["Conjure Food"] = {"Conjure Food", [587]=false, [597]=false, [608]=false, [619]=false, [990]=false, [991]=false, [1249]=false, [1250]=false, [1251]=false, [6129]=false, [6130]=false, [6641]=false, [8736]=false, [10144]=false, [10145]=false, [10146]=false, [10147]=false, [28612]=false, [28613]=false},
                ["Conjure Mana Agate"] = {"Conjure Mana Agate", [759]=false, [1210]=false},
                ["Conjure Mana Citrine"] = {"Conjure Mana Citrine", [10053]=false, [10055]=false},
                ["Conjure Mana Jade"] = {"Conjure Mana Jade", [3552]=false, [3553]=false},
                ["Conjure Mana Ruby"] = {"Conjure Mana Ruby", [10054]=false, [10056]=false},
                ["Conjure Water"] = {"Conjure Water", [3696]=false, [5504]=false, [5505]=false, [5506]=false, [5507]=false, [5565]=false, [5566]=false, [6127]=false, [6128]=false, [6635]=false, [6638]=false, [6639]=false, [10138]=false, [10139]=false, [10140]=false, [10141]=false, [10142]=false, [10143]=false, [468766]=false},
                ["Control Machine"] = {"Control Machine", [8345]=false},
                ["Corruption"] = {"Corruption", [172]=true, [979]=true, [1025]=true, [1107]=true, [6221]=true, [6222]=true, [6223]=true, [6224]=true, [6225]=true, [7648]=true, [7649]=true, [11671]=true, [11672]=true, [11673]=true, [11674]=true, [13530]=true, [16402]=true, [16985]=true, [17510]=true, [18088]=true, [18376]=true, [18656]=true, [21068]=true, [23439]=true, [23642]=true, [25311]=true, [25419]=true, [25982]=true, [28829]=true, [468242]=true, [1213450]=true, [1219428]=true, [1223963]=true},
                ["Create Firestone"] = {"Create Firestone", [607]=false, [17951]=false},
                ["Create Firestone (Greater)"] = {"Create Firestone (Greater)", [17952]=false, [18170]=false},
                ["Create Firestone (Lesser)"] = {"Create Firestone (Lesser)", [1197]=false, [6366]=false},
                ["Create Firestone (Major)"] = {"Create Firestone (Major)", [17953]=false, [18171]=false},
                ["Create Healthstone"] = {"Create Healthstone", [1049]=false, [5699]=false, [5700]=false, [23813]=false, [23814]=false, [23815]=false, [28023]=false},
                ["Create Healthstone (Greater)"] = {"Create Healthstone (Greater)", [5702]=false, [11729]=false, [23816]=false, [23817]=false, [23818]=false},
                ["Create Healthstone (Lesser)"] = {"Create Healthstone (Lesser)", [6202]=false, [6204]=false, [23520]=false, [23521]=false, [23522]=false},
                ["Create Healthstone (Major)"] = {"Create Healthstone (Major)", [11730]=false, [11731]=false, [20018]=false, [23819]=false, [23820]=false, [23821]=false},
                ["Create Healthstone (Minor)"] = {"Create Healthstone (Minor)", [6201]=false, [6203]=false, [23517]=false, [23518]=false, [23519]=false},
                ["Create Soulstone"] = {"Create Soulstone", [719]=false, [20022]=false, [20755]=false, [20767]=false},
                ["Create Soulstone (Greater)"] = {"Create Soulstone (Greater)", [20756]=false, [20768]=false},
                ["Create Soulstone (Lesser)"] = {"Create Soulstone (Lesser)", [20752]=false, [20766]=false},
                ["Create Soulstone (Major)"] = {"Create Soulstone (Major)", [20757]=false, [20769]=false},
                ["Create Soulstone (Minor)"] = {"Create Soulstone (Minor)", [693]=false, [1377]=false},
                ["Create Soulstone"] = {"Create Soulstone", [719]=false, [20022]=false, [20755]=false, [20767]=false},
                ["Create Spellstone (Greater)"] = {"Create Spellstone (Greater)", [17727]=false, [17732]=false},
                ["Create Spellstone (Major)"] = {"Create Spellstone (Major)", [17728]=false, [17733]=false},
                ["Defibrillate"] = {"Defibrillate", [8342]=false, [22999]=false, [435532]=false},
                ["Dense Dynamite"] = {"Dense Dynamite", [12419]=false, [12586]=false, [12630]=false, [23063]=false, [23070]=false, [23095]=false},
                ["Dimensional Ripper - Everlook"] = {"Dimensional Ripper - Everlook", [23442]=false, [23486]=false},
                ["Disarm Trap"] = {"Disarm Trap", [1842]=false, [1845]=false},
                ["Discolored Healing Potion"] = {"Discolored Healing Potion", [4508]=false},
                ["Dismiss Pet"] = {"Dismiss Pet", [2641]=false},
                ["Dominate Mind"] = {"Dominate Mind", [7645]=true, [14515]=true, [15859]=true, [20604]=true, [20740]=true, [429687]=true, [429688]=true, [1213356]=true},
                ["Dominion of Soul"] = {"Dominion of Soul", [16053]=false},
                ["Drain Life"] = {"Drain Life", [689]=false, [699]=false, [709]=false, [714]=false, [725]=false, [736]=false, [1367]=false, [1368]=false, [1369]=false, [7651]=false, [7652]=false, [7653]=false, [11699]=false, [11700]=false, [11701]=false, [11702]=false, [12693]=false, [16375]=false, [16414]=false, [16608]=false, [17173]=false, [17238]=false, [17620]=false, [18084]=false, [18557]=false, [18815]=false, [18817]=false, [20743]=false, [21170]=false, [24300]=false, [24435]=false, [24585]=false, [24618]=false, [26693]=false, [27994]=false, [29155]=false, [403677]=false, [403685]=false, [403686]=false, [403687]=false, [403688]=false, [403689]=false, [446317]=false, [461683]=false, [461684]=false, [462221]=false, [468184]=false, [1213862]=false, [1213864]=false, [1213873]=false, [1213874]=false, [1214208]=false, [1220711]=false},
                ["Drain Mana"] = {"Drain Mana", [496]=false, [862]=false, [5138]=false, [5139]=false, [6226]=false, [6227]=false, [11703]=false, [11704]=false, [11705]=false, [11706]=false, [17008]=false, [17243]=false, [17682]=false, [18394]=false, [25671]=false, [25676]=false, [25754]=false, [25755]=false, [26457]=false, [26559]=false, [26639]=false, [1215779]=false, [1215781]=false, [1216500]=false, [1216501]=false},
                ["Drain Soul"] = {"Drain Soul", [1120]=false, [7662]=false, [8288]=false, [8289]=false, [8290]=false, [8291]=false, [11675]=false, [11676]=false},
                ["Eagle Eye"] = {"Eagle Eye", [6197]=false, [6198]=false},
                ["Electrified Net"] = {"Electrified Net", [11820]=true, [11825]=true, [441453]=true},
                ["Entangling Roots"] = {"Entangling Roots", [339]=true, [790]=true, [1062]=true, [1063]=true, [1435]=true, [1436]=true, [2919]=true, [2920]=true, [5195]=true, [5196]=true, [5309]=true, [9852]=true, [9853]=true, [9854]=true, [9855]=true, [11922]=true, [12747]=true, [19970]=true, [19971]=true, [19972]=true, [19973]=true, [19974]=true, [19975]=true, [20654]=true, [20699]=true, [21331]=true, [22127]=true, [22415]=true, [22800]=true, [24648]=true, [26071]=true, [28858]=true, [435991]=true, [460690]=true, [1213253]=true},
                ["Enveloping Winds"] = {"Enveloping Winds", [6728]=false, [15535]=false, [23103]=false, [25189]=false},
                ["Escape Artist"] = {"Escape Artist", [20589]=false},
                ["Evocation"] = {"Evocation", [12051]=false, [28403]=false, [28763]=false, [456397]=false},
                ["Eye of Kilrogg"] = {"Eye of Kilrogg", [126]=false, [928]=false, [6228]=false},
                ["Eyes of the Beast"] = {"Eyes of the Beast", [1002]=false, [2899]=false},
                ["Far Sight"] = {"Far Sight", [570]=false, [1345]=false, [6196]=false},
                ["Fear"] = {"Fear", [654]=false, [663]=false, [1045]=false, [1397]=false, [5782]=false, [5783]=false, [6213]=false, [6214]=false, [6215]=false, [6216]=false, [12096]=false, [12542]=false, [22678]=false, [26070]=false, [26580]=false, [27641]=false, [27990]=false, [29168]=false, [30002]=false, [411959]=false, [469521]=false, [469793]=false, [469879]=false, [1213452]=false, [1222563]=false},
                ["Fireball"] = {"Fireball", [133]=true, [143]=true, [145]=true, [483]=true, [502]=true, [854]=true, [1173]=true, [1198]=true, [3140]=true, [3142]=true, [3688]=true, [8400]=true, [8401]=true, [8402]=true, [8403]=true, [8404]=true, [8405]=true, [9053]=true, [9487]=true, [9488]=true, [10148]=true, [10149]=true, [10150]=true, [10151]=true, [10152]=true, [10153]=true, [10154]=true, [10155]=true, [10578]=true, [11839]=true, [11921]=true, [11985]=true, [12466]=true, [13140]=true, [13375]=true, [13438]=true, [14034]=true, [15228]=true, [15242]=true, [15536]=true, [15662]=true, [15665]=true, [16101]=true, [16412]=true, [16413]=true, [16415]=true, [16788]=true, [17290]=true, [18082]=true, [18105]=true, [18108]=true, [18199]=true, [18392]=true, [18796]=true, [19391]=true, [19816]=true, [20420]=true, [20678]=true, [20692]=true, [20714]=true, [20793]=true, [20797]=true, [20808]=true, [20811]=true, [20815]=true, [20823]=true, [21072]=true, [21159]=true, [21162]=true, [21402]=true, [21549]=true, [22088]=true, [23024]=true, [23411]=true, [24374]=true, [24611]=true, [25306]=true, [25415]=true, [25978]=true, [447546]=true, [460342]=true, [1220408]=true, [1231200]=true, [1232762]=true, [1236172]=true},
                ["Flamestrike"] = {"Flamestrike", [846]=false, [872]=false, [2120]=false, [2121]=false, [2124]=false, [2125]=false, [8422]=false, [8423]=false, [8425]=false, [8426]=false, [10215]=false, [10216]=false, [10217]=false, [10218]=false, [11829]=false, [12468]=false, [16102]=false, [16419]=false, [18399]=false, [18816]=false, [18818]=false, [20296]=false, [20794]=false, [20813]=false, [20827]=false, [22275]=false, [24612]=false, [30091]=false, [447547]=false},
                ["Flash Heal"] = {"Flash Heal", [2061]=false, [2066]=false, [9472]=false, [9473]=false, [9474]=false, [9475]=false, [9476]=false, [9477]=false, [10915]=false, [10916]=false, [10917]=false, [10918]=false, [10919]=false, [10920]=false, [17137]=false, [17138]=false, [17843]=false, [27608]=false, [1232758]=false, [1236153]=false},
                ["Flash of Light"] = {"Flash of Light", [19750]=false, [19751]=false, [19939]=false, [19940]=false, [19941]=false, [19942]=false, [19943]=false, [19944]=false, [19945]=false, [19946]=false, [19947]=false, [19948]=false, [19993]=false, [25514]=false, [412020]=false},
                ["Frostbolt"] = {"Frostbolt", [116]=true, [205]=true, [478]=true, [494]=true, [837]=true, [838]=true, [1142]=true, [1191]=true, [1211]=true, [7322]=true, [7323]=true, [7324]=true, [8406]=true, [8407]=true, [8408]=true, [8409]=true, [8410]=true, [8411]=true, [9672]=true, [10179]=true, [10180]=true, [10181]=true, [10182]=true, [10183]=true, [10184]=true, [11538]=true, [12675]=true, [12737]=true, [13322]=true, [13439]=true, [15043]=true, [15497]=true, [15530]=true, [16249]=true, [16799]=true, [17503]=true, [20297]=true, [20792]=true, [20806]=true, [20819]=true, [20822]=true, [21369]=true, [23102]=true, [23412]=true, [24942]=true, [25304]=true, [25414]=true, [25940]=true, [25977]=true, [28478]=true, [28479]=true, [350025]=true, [406680]=true, [420526]=true, [1213276]=true, [1220854]=true},
                ["Ghost Wolf"] = {"Ghost Wolf", [519]=false, [2645]=false, [3691]=false, [5387]=false, [5389]=false, [415233]=false},
                ["Gnomish Jumper Cables"] = {"Gnomish Jumper Cables", [7147]=false, [7148]=false, [439114]=false, [439115]=false},
                ["Gnomish Jumper Cables XL"] = {"Gnomish Jumper Cables XL", [8342]=false, [22999]=false, [435532]=false},
                ["Goblin Rocket Helmet"] = {"Goblin Rocket Helmet", [12718]=false, [12758]=false, [12770]=false, [12780]=false, [13821]=false, [451709]=false, [451719]=false},
                ["Greater Heal"] = {"Greater Heal", [2060]=false, [2065]=false, [2067]=false, [2068]=false, [2069]=false, [3085]=false, [10963]=false, [10964]=false, [10965]=false, [22009]=false, [25314]=false, [25350]=false, [25983]=false, [28809]=false, [1220910]=false, [1220911]=false},
                ["Greater Healing Potion"] = {"Greater Healing Potion", [7181]=false, [7182]=false},
                ["Gyrofreeze Ice Reflector"] = {"Gyrofreeze Ice Reflector", [23077]=false},
                ["Hammer of Wrath"] = {"Hammer of Wrath", [24239]=false, [24274]=false, [24275]=false, [24276]=false, [24277]=false, [24278]=false, [429151]=false},
                ["Heal"] = {"Heal", [964]=false, [983]=false, [1153]=false, [2054]=false, [2055]=false, [2058]=false, [2059]=false, [3810]=false, [6063]=false, [6064]=false, [6071]=false, [6072]=false, [8812]=false, [10577]=false, [11642]=false, [12039]=false, [14053]=false, [15586]=false, [22167]=false, [22883]=false, [24947]=false, [450650]=false, [1232740]=false},
                ["Healing Potion"] = {"Healing Potion", [439]=false, [440]=false, [441]=false, [2024]=false, [3447]=false, [3458]=false, [4042]=false, [17534]=false, [450106]=false, [450107]=false},
                ["Healing Touch"] = {"Healing Touch", [3735]=false, [5185]=false, [5186]=false, [5187]=false, [5188]=false, [5189]=false, [5190]=false, [5191]=false, [5192]=false, [5193]=false, [5194]=false, [5294]=false, [5295]=false, [5296]=false, [5297]=false, [6659]=false, [6778]=false, [6779]=false, [8903]=false, [8904]=false, [9758]=false, [9759]=false, [9888]=false, [9889]=false, [9890]=false, [9891]=false, [11431]=false, [20790]=false, [23381]=false, [25297]=false, [25407]=false, [25970]=false, [27527]=false, [28719]=false, [28742]=false, [28848]=false, [426821]=false, [462585]=false},
                ["Healing Wave"] = {"Healing Wave", [331]=false, [332]=false, [538]=false, [547]=false, [565]=false, [913]=false, [914]=false, [939]=false, [959]=false, [1326]=false, [1327]=false, [1354]=false, [1355]=false, [1356]=false, [8005]=false, [8006]=false, [10395]=false, [10396]=false, [10397]=false, [10398]=false, [11986]=false, [12491]=false, [12492]=false, [15982]=false, [25357]=false, [25402]=false, [25964]=false, [26097]=false, [411210]=false, [411220]=false, [411239]=false, [416247]=false, [416316]=false, [416317]=false, [416318]=false, [416319]=false, [416320]=false, [416322]=false, [416323]=false, [416324]=false, [416325]=false, [438019]=false, [438338]=false, [438339]=false, [450603]=false},
                ["Hearthstone"] = {"Hearthstone", [8690]=false},
                ["Heavy Dynamite"] = {"Heavy Dynamite", [3946]=false, [4007]=false, [4062]=false},
                ["Heavy Runecloth Bandage"] = {"Heavy Runecloth Bandage", [746]=false, [1159]=false, [3267]=false, [3268]=false, [3273]=false, [3274]=false, [7162]=false, [7924]=false, [7926]=false, [7927]=false, [10838]=false, [10839]=false, [10846]=false, [18608]=false, [18610]=false, [18630]=false, [18632]=false, [23567]=false, [23568]=false, [23569]=false, [23696]=false, [24412]=false, [24413]=false, [24414]=false, [30020]=false, [470345]=false},
                ["Hi-explosive Bomb"] = {"Hi-explosive Bomb", [12543]=false, [12619]=false, [12641]=false},
                ["Hibernate"] = {"Hibernate", [2637]=false, [5299]=false, [18657]=false, [18658]=false, [18659]=false, [18660]=false},
                ["Holy Fire"] = {"Holy Fire", [14914]=false, [15261]=false, [15262]=false, [15263]=false, [15264]=false, [15265]=false, [15266]=false, [15267]=false, [15452]=false, [15454]=false, [15455]=false, [15457]=false, [15459]=false, [15460]=false, [17140]=false, [17141]=false, [17142]=false, [18165]=false, [18167]=false, [18806]=false, [23860]=false, [27796]=false, [437809]=false, [459622]=false, [1236162]=false, [1236287]=false},
                ["Holy Light"] = {"Holy Light", [635]=false, [639]=false, [647]=false, [656]=false, [664]=false, [1026]=false, [1027]=false, [1042]=false, [1043]=false, [1872]=false, [1873]=false, [1874]=false, [1913]=false, [1914]=false, [3472]=false, [3473]=false, [3474]=false, [10328]=false, [10329]=false, [10330]=false, [10331]=false, [13952]=false, [15493]=false, [19968]=false, [19980]=false, [19981]=false, [19982]=false, [25263]=false, [25292]=false, [25400]=false, [25963]=false, [469566]=false, [1213298]=false, [1232709]=false, [1236181]=false},
                ["Holy Wrath"] = {"Holy Wrath", [685]=false, [2812]=false, [10318]=false, [10320]=false, [23979]=false, [28883]=false, [429145]=false, [429146]=false, [1238817]=false, [1238818]=false, [1238819]=false, [1238821]=false},
                ["Howl of Terror"] = {"Howl of Terror", [5484]=false, [5486]=false, [17928]=false, [18169]=false},
                ["Hyper-radiant Flame Reflector"] = {"Hyper-radiant Flame Reflector", [23081]=false},
                ["Immolate"] = {"Immolate", [348]=false, [707]=false, [734]=false, [1094]=false, [1095]=false, [1374]=false, [1375]=false, [1376]=false, [2941]=false, [2942]=false, [3686]=false, [8981]=false, [9034]=false, [9275]=false, [9276]=false, [11665]=false, [11666]=false, [11667]=false, [11668]=false, [11669]=false, [11670]=false, [11962]=false, [11984]=false, [12742]=false, [15505]=false, [15506]=false, [15570]=false, [15661]=false, [15732]=false, [15733]=false, [17883]=false, [18542]=false, [20294]=false, [20787]=false, [20800]=false, [20826]=false, [25309]=false, [25418]=false, [25981]=false, [1219425]=false, [1235317]=false},
                ["Impale"] = {"Impale", [15860]=false, [16001]=false, [16493]=false, [16494]=false, [24049]=false, [26025]=false, [26548]=false, [28783]=false},
                ["Inferno"] = {"Inferno", [1122]=false, [1413]=false, [19695]=false, [19698]=false, [20799]=false, [22699]=false, [24670]=false, [364837]=false, [364838]=false, [366430]=false, [461087]=false, [461088]=false, [461108]=false, [461110]=false, [461111]=false, [1220927]=false},
                ["Instant Poison"] = {"Instant Poison", [8679]=false, [8680]=false, [8681]=false, [8700]=false, [8701]=false, [8810]=false, [11344]=false, [11345]=false, [11346]=false, [28428]=false},
                ["Instant Poison II"] = {"Instant Poison II", [8685]=false, [8686]=false, [8687]=false},
                ["Instant Poison III"] = {"Instant Poison III", [8688]=false, [8689]=false, [8691]=false},
                ["Instant Poison IV"] = {"Instant Poison IV", [11335]=false, [11338]=false, [11341]=false},
                ["Instant Poison V"] = {"Instant Poison V", [11336]=false, [11339]=false, [11342]=false},
                ["Instant Poison VI"] = {"Instant Poison VI", [11337]=false, [11340]=false, [11343]=false},
                ["Iron Grenade"] = {"Iron Grenade", [3962]=false, [4018]=false, [4068]=false},
                ["Large Copper Bomb"] = {"Large Copper Bomb", [3937]=false, [3999]=false, [4065]=false},
                ["Lesser Heal"] = {"Lesser Heal", [613]=false, [622]=false, [2050]=false, [2051]=false, [2052]=false, [2053]=false, [2056]=false, [2057]=false},
                ["Lesser Healing Potion"] = {"Lesser Healing Potion", [2337]=false, [2341]=false},
                ["Lesser Healing Wave"] = {"Lesser Healing Wave", [8004]=false, [8007]=false, [8008]=false, [8009]=false, [8010]=false, [8011]=false, [10466]=false, [10467]=false, [10468]=false, [10469]=false, [10470]=false, [10471]=false, [27624]=false, [28849]=false, [28850]=false},
                ["Lesser Invisibility Potion"] = {"Lesser Invisibility Potion", [2172]=false, [3448]=false, [3459]=false},
                ["Lesser Mana Potion"] = {"Lesser Mana Potion", [3173]=false, [3181]=false},
                ["Lesser Stoneshield Potion"] = {"Lesser Stoneshield Potion", [4942]=false},
                ["Lightning Bolt"] = {"Lightning Bolt", [403]=true, [529]=true, [531]=true, [548]=true, [566]=true, [915]=true, [943]=true, [944]=true, [1324]=true, [1325]=true, [1357]=true, [1358]=true, [3089]=true, [6041]=true, [6043]=true, [8246]=true, [9532]=true, [10391]=true, [10392]=true, [10393]=true, [10394]=true, [12167]=true, [13482]=true, [13527]=true, [14109]=true, [14119]=true, [15207]=true, [15208]=true, [15209]=true, [15210]=true, [15234]=true, [15801]=true, [16782]=true, [18081]=true, [18089]=true, [19874]=true, [20295]=true, [20802]=true, [20805]=true, [20824]=true, [22414]=true, [23592]=true, [26098]=true, [370102]=true, [370156]=true, [408439]=true, [408440]=true, [408441]=true, [408442]=true, [408443]=true, [408472]=true, [408473]=true, [408474]=true, [408475]=true, [408477]=true, [411282]=true, [411284]=true, [434838]=true, [434842]=true, [450602]=true, [466740]=true, [469372]=true},
                ["Limited Invulnerability Potion"] = {"Limited Invulnerability Potion", [3172]=false, [3175]=false},
                ["Living Action Potion"] = {"Living Action Potion", [20006]=false, [24367]=false},
                ["Mageblood Potion"] = {"Mageblood Potion", [24365]=false},
                ["Major Healing Potion"] = {"Major Healing Potion", [17556]=false},
                ["Major Mana Potion"] = {"Major Mana Potion", [17553]=false, [17580]=false},
                ["Major Recombobulator"] = {"Major Recombobulator", [23079]=false},
                ["Major Rejuvenation Potion"] = {"Major Rejuvenation Potion", [22732]=false},
                ["Mana Burn"] = {"Mana Burn", [2691]=false, [4091]=false, [8129]=false, [8130]=false, [8131]=false, [8132]=false, [10874]=false, [10875]=false, [10876]=false, [10877]=false, [10878]=false, [10879]=false, [11981]=false, [12745]=false, [13321]=false, [14033]=false, [15785]=false, [15800]=false, [15980]=false, [17615]=false, [17630]=false, [20817]=false, [22189]=false, [22936]=false, [22947]=false, [25779]=false, [26046]=false, [26049]=false, [27992]=false, [28301]=false, [29310]=false, [348789]=false, [1213331]=false},
                ["Mana Potion"] = {"Mana Potion", [3452]=false, [3461]=false},
                ["Might of Shahram"] = {"Might of Shahram", [16600]=false},
                ["Mind Blast"] = {"Mind Blast", [8092]=false, [8093]=false, [8102]=false, [8103]=false, [8104]=false, [8105]=false, [8106]=false, [8107]=false, [8108]=false, [8109]=false, [8110]=false, [8111]=false, [10945]=false, [10946]=false, [10947]=false, [10948]=false, [10949]=false, [10950]=false, [13860]=false, [15587]=false, [17194]=false, [17287]=false, [20830]=false, [26048]=false, [425233]=false, [426493]=false, [474402]=false, [1213336]=false, [1222574]=false, [1232743]=false},
                ["Mind Control"] = {"Mind Control", [605]=true, [627]=true, [1293]=true, [10911]=true, [10912]=true, [10913]=true, [10914]=true, [11446]=true, [15690]=true, [1213332]=true},
                ["Mind Flay"] = {"Mind Flay", [7378]=true, [15407]=true, [16568]=true, [17165]=true, [17311]=true, [17312]=true, [17313]=true, [17314]=true, [17316]=true, [17317]=true, [17318]=true, [18807]=true, [18808]=true, [22919]=true, [23953]=true, [26044]=true, [26143]=true, [28310]=true, [29407]=true, [368292]=true, [368315]=true, [368320]=true, [412526]=true, [474204]=true, [474268]=true, [1215740]=true},
                ["Mind Vision"] = {"Mind Vision", [1150]=true, [2096]=true, [2097]=true, [10909]=true, [10910]=true, [450108]=true},
                ["Mind-numbing Poison"] = {"Mind-numbing Poison", [5760]=false, [5761]=false, [5763]=false, [5768]=false, [8695]=false, [11401]=false, [25810]=false},
                ["Mind-numbing Poison II"] = {"Mind-numbing Poison II", [8692]=false, [8693]=false, [8694]=false},
                ["Mind-numbing Poison III"] = {"Mind-numbing Poison III", [11398]=false, [11399]=false, [11400]=false},
                ["Mining"] = {"Mining", [2575]=false, [2576]=false, [2577]=false, [2578]=false, [2579]=false, [3564]=false, [10248]=false, [12560]=false, [13611]=false},
                ["Minor Healing Potion"] = {"Minor Healing Potion", [2330]=false},
                ["Minor Magic Resistance Potion"] = {"Minor Magic Resistance Potion", [3170]=false, [3172]=false, [3184]=false},
                ["Minor Mana Potion"] = {"Minor Mana Potion", [2331]=false, [2339]=false},
                ["Minor Rejuvenation Potion"] = {"Minor Rejuvenation Potion", [2332]=false, [2336]=false, [2340]=false},
                ["Mithril Frag Bomb"] = {"Mithril Frag Bomb", [12421]=false, [12603]=false, [12638]=false},
                ["Mithril Mechanical Dragonling"] = {"Mithril Mechanical Dragonling", [12624]=false, [12749]=false, [23050]=false, [23075]=false},
                ["Ornate Spyglass"] = {"Ornate Spyglass", [6458]=false, [6459]=false},
                ["Parachute Cloak"] = {"Parachute Cloak", [7215]=false, [9783]=false, [9964]=false, [12616]=false},
                ["Pick Lock"] = {"Pick Lock", [1804]=false, [6461]=false, [6463]=false, [6480]=false},
                ["Polymorph"] = {"Polymorph", [118]=true, [1168]=true, [1192]=true, [1219]=true, [12824]=true, [12825]=true, [12826]=true, [12827]=true, [12828]=true, [12829]=true, [13323]=true, [14621]=true, [15534]=true, [27760]=true, [28271]=true, [28272]=true, [29124]=true, [29848]=true, [434754]=true, [1236174]=true, [1236290]=true},
                ["Polymorph: Turtle"] = {"Polymorph Turtle", [118]=true, [1168]=true, [1192]=true, [1219]=true, [12824]=true, [12825]=true, [12826]=true, [12827]=true, [12828]=true, [12829]=true, [13323]=true, [14621]=true, [15534]=true, [27760]=true, [28271]=true, [28272]=true, [28286]=true, [29124]=true, [29848]=true, [434754]=true, [1236174]=true, [1236290]=true},
                ["Polymorph: Pig"] = {"Polymorph Pig", [477]=true, [28272]=true, [28285]=true},
                ["Polymorph: Cow"] = {"Polymorph Cow", [28270]=true},
                ["Poisons"] = {"Poisons", [2842]=false, [2995]=false, [364159]=false},
                ["Prayer of Healing"] = {"Prayer of Healing", [596]=false, [618]=false, [996]=false, [997]=false, [1287]=false, [1288]=false, [2049]=false, [10960]=false, [10961]=false, [10962]=false, [13857]=false, [15585]=false, [25316]=false, [25353]=false, [25985]=false},
                ["Pyroblast"] = {"Pyroblast", [1830]=true, [11366]=true, [12505]=true, [12522]=true, [12523]=true, [12524]=true, [12525]=true, [12526]=true, [13011]=true, [13012]=true, [13014]=true, [13015]=true, [13016]=true, [13017]=true, [17273]=true, [17274]=true, [18809]=true, [20228]=true, [24995]=true, [434443]=true, [460858]=true, [460860]=true, [1236173]=true, [1236291]=true},
                ["Rage Potion"] = {"Rage Potion", [6617]=false},
                ["Health Funnel"] = {"Health Funnel", [730]=false, [755]=false, [3698]=false, [3699]=false, [3700]=false, [3701]=false, [3702]=false, [3703]=false, [3704]=false, [3705]=false, [3706]=false, [3707]=false, [11693]=false, [11694]=false, [11695]=false, [11696]=false, [11697]=false, [11698]=false, [16569]=false},
                ["Rain of Fire"] = {"Rain of Fire", [3354]=false, [3751]=false, [4629]=false, [5740]=false, [5741]=false, [6219]=false, [6220]=false, [11677]=false, [11678]=false, [11679]=false, [11680]=false, [11990]=false, [16005]=false, [19474]=false, [19475]=false, [19717]=false, [20754]=false, [24669]=false, [28794]=false, [365100]=false, [365128]=false, [365188]=false, [365196]=false, [369330]=false, [460692]=false, [460698]=false, [460699]=false, [460700]=false, [469990]=false, [1213451]=false},
                ["Rebirth"] = {"Rebirth", [20484]=false, [20485]=false, [20739]=false, [20742]=false, [20744]=false, [20745]=false, [20747]=false, [20748]=false, [20749]=false, [20750]=false},
                ["Redemption"] = {"Redemption", [574]=false, [7328]=false, [7329]=false, [10322]=false, [10323]=false, [10324]=false, [10325]=false, [20772]=false, [20773]=false, [20774]=false, [20775]=false},
                ["Regrowth"] = {"Regrowth", [3734]=false, [8936]=false, [8937]=false, [8938]=false, [8939]=false, [8940]=false, [8941]=false, [8942]=false, [8943]=false, [8944]=false, [8945]=false, [9750]=false, [9751]=false, [9856]=false, [9857]=false, [9858]=false, [9859]=false, [9860]=false, [9861]=false, [16561]=false, [20665]=false, [22373]=false, [22695]=false, [27637]=false, [28744]=false, [436937]=false, [436938]=false, [436939]=false, [436940]=false, [436942]=false, [436943]=false, [436944]=false, [436945]=false, [436946]=false},
                ["Resurrection"] = {"Resurrection", [2006]=false, [2010]=false, [2013]=false, [2016]=false, [3215]=false, [3216]=false, [7330]=false, [10880]=false, [10881]=false, [10882]=false, [10883]=false, [20770]=false, [20771]=false, [24173]=false, [420882]=false, [420883]=false, [420884]=false, [420885]=false, [439995]=false, [439996]=false, [439998]=false, [440106]=false, [1218624]=false, [1222743]=false, [1228009]=false},
                ["Revive Pet"] = {"Revive Pet", [982]=false, [1236]=false, [23499]=false, [439956]=false},
                ["Ritual of Doom"] = {"Ritual of Doom", [1123]=false, [18540]=false, [20700]=false},
                ["Ritual of Summoning"] = {"Ritual of Summoning", [698]=false, [7663]=false},
                ["Rough Copper Bomb"] = {"Rough Copper Bomb", [3923]=false, [3985]=false, [4064]=false},
                ["Rough Dynamite"] = {"Rough Dynamite", [3919]=false, [3981]=false, [4054]=false},
                ["Sacrifice"] = {"Sacrifice", [1050]=false, [7812]=false, [7885]=false, [19438]=false, [19439]=false, [19440]=false, [19441]=false, [19442]=false, [19443]=false, [19444]=false, [19445]=false, [19446]=false, [19447]=false, [20381]=false, [20382]=false, [20383]=false, [20384]=false, [20385]=false, [20386]=false, [22651]=false, [1231689]=false},
                ["Scare Beast"] = {"Scare Beast", [1513]=false, [1567]=false, [14326]=false, [14327]=false, [14445]=false, [14446]=false},
                ["Scorch"] = {"Scorch", [1811]=false, [2948]=false, [8444]=false, [8445]=false, [8446]=false, [8447]=false, [8448]=false, [8449]=false, [10205]=false, [10206]=false, [10207]=false, [10208]=false, [10209]=false, [10210]=false, [13878]=false, [15241]=false, [17195]=false},
                ["Searing Pain"] = {"Searing Pain", [2945]=false, [5676]=false, [17919]=false, [17920]=false, [17921]=false, [17922]=false, [17923]=false, [18154]=false, [18155]=false, [18156]=false, [18157]=false, [18158]=false},
                ["Seduction"] = {"Seduction", [6358]=true, [6359]=true, [20407]=true},
                ["Shackle Undead"] = {"Shackle Undead", [1425]=false, [9484]=false, [9485]=false, [9486]=false, [10955]=false, [10956]=false, [11444]=false},
                ["Shadow Bolt"] = {"Shadow Bolt", [686]=true, [695]=true, [705]=true, [721]=true, [732]=true, [1088]=true, [1089]=true, [1106]=true, [1381]=true, [1382]=true, [1406]=true, [1407]=true, [2965]=true, [7617]=true, [7619]=true, [7641]=true, [7642]=true, [9613]=true, [11659]=true, [11660]=true, [11661]=true, [11662]=true, [11663]=true, [11664]=true, [12471]=true, [12739]=true, [13440]=true, [13480]=true, [14106]=true, [14122]=true, [15232]=true, [15472]=true, [15537]=true, [16408]=true, [16409]=true, [16410]=true, [16783]=true, [16784]=true, [17393]=true, [17434]=true, [17435]=true, [17483]=true, [17509]=true, [18111]=true, [18138]=true, [18164]=true, [18205]=true, [18211]=true, [18214]=true, [18217]=true, [19728]=true, [19729]=true, [20298]=true, [20791]=true, [20807]=true, [20816]=true, [20825]=true, [21077]=true, [21141]=true, [22336]=true, [22677]=true, [24668]=true, [25307]=true, [25417]=true, [25980]=true, [26006]=true, [29317]=true, [350026]=true, [402790]=true, [429434]=true, [446258]=true, [446361]=true, [450659]=true, [460749]=true, [461279]=true, [461280]=true, [467740]=true, [1225482]=true, [1226282]=true},
                ["Skinning"] = {"Skinning", [8613]=false, [8617]=false, [8618]=false, [10768]=false, [13697]=false},
                ["Slam"] = {"Slam", [1464]=false, [1482]=false, [8820]=false, [8821]=false, [11430]=false, [11604]=false, [11605]=false, [11606]=false, [11607]=false, [462893]=false, [462895]=false, [462896]=false, [462897]=false},
                ["Sleep"] = {"Sleep", [700]=true, [726]=true, [1090]=true, [1091]=true, [3069]=true, [8399]=true, [9159]=true, [9160]=true, [12098]=true, [15970]=true, [20663]=true, [20669]=true, [20989]=true, [24004]=true, [24664]=true, [24778]=true, [423133]=true, [423135]=true, [423140]=true, [423415]=true, [425465]=true, [425480]=true, [448572]=true, [450662]=true, [450852]=true, [460756]=true, [460930]=true, [461324]=true, [462058]=true, [462577]=true, [468591]=true, [469146]=true, [1222578]=true, [1227435]=true, [1233025]=true},
                ["Small Bronze Bomb"] = {"Small Bronze Bomb", [3941]=true, [4003]=true, [4066]=true},
                ["Smite"] = {"Smite", [585]=false, [591]=false, [598]=false, [984]=false, [1004]=false, [1275]=false, [1276]=false, [1300]=false, [1301]=false, [6060]=false, [6062]=false, [10933]=false, [10934]=false, [10935]=false, [10936]=false, [437805]=false, [459619]=false, [1236159]=false},
                ["Soothe Animal"] = {"Soothe Animal", [2908]=false, [2910]=false, [8955]=false, [8956]=false, [9901]=false, [9902]=false},
                ["Soul Fire"] = {"Soul Fire", [1571]=false, [6353]=false, [17924]=false, [18160]=false},
                ["Soulstone Resurrection"] = {"Soulstone Resurrection", [20707]=false, [20762]=false, [20763]=false, [20764]=false, [20765]=false},
                ["Starfire"] = {"Starfire", [2912]=false, [2914]=false, [8949]=false, [8950]=false, [8951]=false, [8952]=false, [8953]=false, [8954]=false, [9875]=false, [9876]=false, [9877]=false, [9878]=false, [21668]=false, [25298]=false, [25408]=false, [25971]=false, [463285]=false},
                ["Starshards"] = {"Starshards", [10797]=false, [19296]=false, [19299]=false, [19302]=false, [19303]=false, [19304]=false, [19305]=false, [19350]=false, [19351]=false, [19352]=false, [19353]=false, [19354]=false, [19355]=false, [19356]=false, [22822]=false, [22823]=false, [27636]=false, [459705]=false},
                ["Strong Anti-venom"] = {"Strong Anti-venom", [7933]=false, [7935]=false},
                --["Strong Troll's Blood Potion"] = {"Strong Troll's Blood Potion", [3451] = false},
                ["Subjugate Demon"] = {"Subjugate Demon", [1098]=false, [7665]=false, [11725]=false, [11726]=false, [11727]=false, [11728]=false, [20882]=false},
                ["Summon Charger"] = {"Summon Charger", [23214]=false, [23215]=false},
                ["Summon Dreadsteed"] = {"Summon Dreadsteed", [23161]=false},
                ["Summon Felhunter"] = {"Summon Felhunter", [691]=false, [8176]=false, [8712]=false, [8717]=false, [23500]=false},
                ["Summon Felsteed"] = {"Summon Felsteed", [1710]=false, [5784]=false},
                ["Summon Imp"] = {"Summon Imp", [688]=false, [1366]=false, [11939]=false, [23503]=false, [462863]=false},
                ["Summon Incubus"] = {"Summon Incubus", [713]=false, [366881]=false, [366894]=false, [366902]=false},
                ["Summon Succubus"] = {"Summon Succubus", [712]=false, [1403]=false, [7729]=false, [8674]=false, [8722]=false, [9223]=false, [9224]=false, [23502]=false},
                ["Summon Voidwalker"] = {"Summon Voidwalker", [697]=false, [1385]=false, [7728]=false, [9221]=false, [9222]=false, [12746]=false, [23501]=false, [25112]=false},
                ["Summon Warhorse"] = {"Summon Warhorse", [13819]=false, [13820]=false},
                ["Supercharged Chronoboon"] = {"Supercharged Chronoboon", [349863]=false},
                ["Tame Beast"] = {"Tame Beast", [1515]=false, [1579]=false, [13481]=false, [13535]=false, [411624]=false, [411631]=false, [469277]=false, [469301]=false, [469306]=false},
                ["Teleport: Darnassus"] = {"Teleport Darnassus", [3565]=false, [3578]=false},
                ["Teleport: Ironforge"] = {"Teleport Ironforge", [3562]=false, [3581]=false, [27597]=false},
                ["Teleport: Moonglade"] = {"Teleport Moonglade", [18960]=false, [19027]=false},
                ["Teleport: Orgrimmar"] = {"Teleport Orgrimmar", [3567]=false, [3580]=false},
                ["Teleport: Stormwind"] = {"Teleport Stormwind", [665]=false, [3561]=false},
                ["Teleport: Thunder Bluff"] = {"Teleport Thunder Bluff", [3566]=false, [3579]=false},
                ["Teleport: Undercity"] = {"Teleport Undercity", [3563]=false, [3577]=false, [27598]=false},
                ["The Big One"] = {"The Big One", [12562]=false, [12754]=false, [12778]=false, [451711]=false},
                ["Thorium Grenade"] = {"Thorium Grenade", [19769]=false, [19790]=false},
                ["Turn Undead"] = {"Turn Undead", [1011]=false, [2878]=false, [5253]=false, [5627]=false, [5629]=false, [10326]=false, [10327]=false, [19725]=false, [368397]=false},
                ["Ultrasafe Transporter Gadgetzan"] = {"Ultrasafe Transporter Gadgetzan", [23489]=false},
                ["Volley"] = {"Volley", [1510]=false, [1540]=false, [1564]=false, [1598]=false, [14294]=false, [14295]=false, [14361]=false, [14362]=false, [22908]=false},
                ["War Stomp"] = {"War Stomp", [45]=false, [11876]=false, [15593]=false, [16727]=false, [16740]=false, [19482]=false, [20549]=false, [24375]=false, [25188]=false, [27758]=false, [28125]=false, [28725]=false, [448707]=false, [470031]=false, [1222567]=false, [1223459]=false},
                ["Wound Poison"] = {"Wound Poison", [13218]=false, [13219]=false, [13220]=false, [13221]=false, [13222]=false, [13223]=false, [13224]=false, [13225]=false, [13226]=false, [13227]=false, [13231]=false, [13232]=false, [13233]=false},
                ["Wound Poison II"] = {"Wound Poison II", [13218]=false, [13219]=false, [13220]=false, [13221]=false, [13222]=false, [13223]=false, [13224]=false, [13225]=false, [13226]=false, [13227]=false, [13228]=false, [13231]=false, [13232]=false, [13233]=false},
                ["Wound Poison III"] = {"Wound Poison III", [13218]=false, [13219]=false, [13220]=false, [13221]=false, [13222]=false, [13223]=false, [13224]=false, [13225]=false, [13226]=false, [13227]=false, [13229]=false, [13231]=false, [13232]=false, [13233]=false},
                ["Wound Poison IV"] = {"Wound Poison IV", [13218]=false, [13219]=false, [13220]=false, [13221]=false, [13222]=false, [13223]=false, [13224]=false, [13225]=false, [13226]=false, [13227]=false, [13230]=false, [13231]=false, [13232]=false, [13233]=false},
                ["Wrath"] = {"Wrath", [3737]=false, [5176]=false, [5177]=false, [5178]=false, [5179]=false, [5180]=false, [5181]=false, [5182]=false, [5183]=false, [5184]=false, [5289]=false, [5290]=false, [5291]=false, [5292]=false, [6780]=false, [6781]=false, [6806]=false, [8905]=false, [8906]=false, [9739]=false, [9911]=false, [9912]=false, [17144]=false, [18104]=false, [20698]=false, [21667]=false, [21807]=false, [429139]=false, [429248]=false, [460671]=false, [462580]=false, [469143]=false, [1213248]=false},
            },
            ["SPELL_AURA_APPLIED"] = {
                ["Adrenaline Rush"] = {"Adrenaline Rush", [13750]=false, [28752]=false, [28753]=false},
                ["Aspect of the Beast"] = {"Aspect of the Beast", [13161]=false, [13162]=false},
                ["Aspect of the Cheetah"] = {"Aspect of the Cheetah", [5118]=false, [5131]=false},
                ["Aspect of the Hawk"] = {"Aspect of the Hawk", [6385]=false, [13165]=false, [14318]=false, [14319]=false, [14320]=false, [14321]=false, [14322]=false, [14374]=false, [14375]=false, [14376]=false, [14377]=false, [14378]=false, [25296]=false, [25406]=false, [25969]=false},
                ["Aspect of the Monkey"] = {"Aspect of the Monkey", [13163]=false, [13164]=false},
                ["Aspect of the Pack"] = {"Aspect of the Pack", [13159]=false, [13160]=false},
                ["Aspect of the Wild"] = {"Aspect of the Wild", [20043]=false, [20044]=false, [20190]=false, [20191]=false},
                ["Barkskin"] = {"Barkskin", [20655]=false, [22812]=false, [22826]=false, [428713]=false},
                ["Barkskin Effect (dnd)"] = {"Barkskin Effect (dnd)", [22839]=false},
                ["Battle Shout"] = {"Battle Shout", [5242]=false, [5243]=false, [6192]=false, [6193]=false, [6543]=false, [6673]=false, [6674]=false, [9128]=false, [11549]=false, [11550]=false, [11551]=false, [11552]=false, [11553]=false, [24438]=false, [25101]=false, [25289]=false, [25356]=false, [25959]=false, [26043]=false, [26099]=false, [27578]=false},
                ["Berserker Rage"] = {"Berserker Rage", [18499]=false, [18556]=false},
                ["Berserking"] = {"Berserking", [20554]=false, [23270]=false, [23301]=false, [23303]=false, [23505]=false, [24378]=false, [26296]=false, [26297]=false, [26635]=false},
                ["Bestial Wrath"] = {"Bestial Wrath", [19574]=false, [24395]=false, [24396]=false, [24397]=false, [26592]=false},
                ["Blade Flurry"] = {"Blade Flurry", [13877]=false, [22482]=false, [1226883]=false, [1230700]=false},
                ["Blessing of Freedom"] = {"Blessing of Freedom", [1044]=false, [1909]=false},
                ["Blessing of Protection"] = {"Blessing of Protection", [1022]=false, [1911]=false, [5599]=false, [5600]=false, [10278]=false, [10279]=false, [442948]=false},
                ["Blind"] = {"Blind", [2094]=false, [6505]=false, [21060]=false, [447563]=false},
                ["Blood Fury"] = {"Blood Fury", [20572]=false, [23230]=false, [23234]=false, [24571]=false},
                ["Bloodrage"] = {"Bloodrage", [2687]=false, [2688]=false, [29131]=false},
                ["Cannibalize"] = {"Cannibalize", [20577]=false, [20578]=false},
                ["Counterspell"] = {"Counterspell", [1053]=false, [2139]=false, [3576]=false, [15122]=false, [18469]=false, [19715]=false, [20537]=false, [20788]=false, [29443]=false, [1233255]=false},
                ["Cower"] = {"Cower", [1742]=false, [1747]=false, [1748]=false, [1749]=false, [1750]=false, [1751]=false, [1753]=false, [1754]=false, [1755]=false, [1756]=false, [8998]=false, [8999]=false, [9000]=false, [9001]=false, [9892]=false, [9893]=false, [16697]=false, [16698]=false, [456333]=false},
                ["Dash"] = {"Dash", [1151]=false, [1850]=false, [9821]=false, [9822]=false, [23099]=false, [23100]=false, [23109]=false, [23110]=false, [23111]=false, [23112]=false},
                ["Death Coil"] = {"Death Coil", [1572]=false, [6789]=false, [17925]=false, [17926]=false, [18161]=false, [18162]=false, [28412]=false},
                ["Death Wish"] = {"Death Wish", [12328]=false},
                ["Demon Skin"] = {"Demon Skin", [687]=false, [696]=false, [722]=false, [1383]=false, [20798]=false},
                ["Detect Greater Invisibility"] = {"Detect Greater Invisibility", [11743]=false, [11788]=false, [16882]=false, [469668]=false},
                ["Detect Invisibility"] = {"Detect Invisibility", [2970]=false, [2972]=false, [3692]=false, [11649]=false},
                ["Detect Lesser Invisibility"] = {"Detect Lesser Invisibility", [132]=false, [2971]=false, [3099]=false, [6512]=false},
                ["Deterrence"] = {"Deterrence", [19263]=false},
                ["Devouring Plague"] = {"Devouring Plague", [2944]=false, [2946]=false, [19276]=false, [19277]=false, [19278]=false, [19279]=false, [19280]=false, [19313]=false, [19314]=false, [19315]=false, [19316]=false, [19317]=false, [459713]=false, [1219275]=false},
                ["Diamond Flask"] = {"Diamond Flask", [24427]=false, [363880]=false, [363881]=false},
                ["Disarm"] = {"Disarm", [676]=false, [1646]=false, [6713]=false, [8379]=false, [11879]=false, [13534]=false, [15752]=false, [22691]=false, [27581]=false, [445282]=false, [458880]=false, [1225423]=false, [1225428]=false, [1236176]=false},
                ["Divine Intervention"] = {"Divine Intervention", [19752]=false, [19753]=false, [19754]=false},
                ["Divine Protection"] = {"Divine Protection", [498]=false, [735]=false, [3697]=false, [5572]=false, [5573]=false, [5574]=false, [13007]=false, [27778]=false, [27779]=false, [458312]=false, [458371]=false, [1213300]=false},
                ["Divine Shield"] = {"Divine Shield", [642]=false, [659]=false, [1020]=false, [1021]=false, [1897]=false, [1898]=false, [13874]=false},
                ["Dreamless Sleep"] = {"Dreamless Sleep", [15822]=false},
                ["Drink"] = {"Drink", [430]=false, [431]=false, [432]=false, [1133]=false, [1135]=false, [1137]=false, [10250]=false, [22734]=false, [24355]=false, [25696]=false, [26261]=false, [26402]=false, [26473]=false, [26475]=false, [29007]=false, [446714]=false, [468767]=false},
                ["Earthbind Totem"] = {"Earthbind Totem", [2076]=false, [2484]=false, [15786]=false, [1213480]=false},
                ["Electrified Net"] = {"Electrified Net", [11820]=false, [11825]=false, [441453]=false},
                ["Elune's Grace"] = {"Elune's Grace", [2651]=false, [19289]=false, [19291]=false, [19292]=false, [19293]=false, [19357]=false, [19358]=false, [19359]=false, [19360]=false, [19361]=false, [459706]=false},
                ["Enrage"] = {"Enrage", [1640]=false, [3019]=false, [5228]=false, [5229]=false, [8269]=false, [8599]=false, [12317]=false, [12686]=false, [12795]=false, [12880]=false, [13045]=false, [13046]=false, [13047]=false, [13048]=false, [14201]=false, [14202]=false, [14203]=false, [14204]=false, [15061]=false, [15097]=false, [15716]=false, [18501]=false, [19516]=false, [19953]=false, [23537]=false, [24318]=false, [25503]=false, [26527]=false, [27897]=false, [28131]=false, [28468]=false, [28747]=false, [28798]=false, [425415]=false, [427066]=false, [440483]=false, [446327]=false, [460862]=false, [461347]=false, [461348]=false, [461349]=false, [462885]=false, [1223458]=false},
                ["Fade"] = {"Fade", [586]=false, [1265]=false, [9578]=false, [9579]=false, [9580]=false, [9581]=false, [9592]=false, [9593]=false, [10941]=false, [10942]=false, [10943]=false, [10944]=false, [12685]=false, [20672]=false},
                ["Faerie Fire"] = {"Faerie Fire", [770]=false, [778]=false, [784]=false, [793]=false, [1070]=false, [1414]=false, [1415]=false, [1416]=false, [2889]=false, [6950]=false, [9749]=false, [9907]=false, [13424]=false, [13752]=false, [16498]=false, [20656]=false, [21670]=false},
                ["Fear Ward"] = {"Fear Ward", [6346]=false, [19337]=false, [459699]=false},
                ["Feedback"] = {"Feedback", [6347]=false, [13896]=false, [19267]=false, [19268]=false, [19269]=false, [19270]=false, [19271]=false, [19273]=false, [19274]=false, [19275]=false, [19345]=false, [19346]=false, [19347]=false, [19348]=false, [19349]=false, [447549]=false, [459703]=false},
                ["Fire Shield"] = {"Fire Shield", [134]=false, [1167]=false, [2947]=false, [2949]=false, [8316]=false, [8317]=false, [8318]=false, [8319]=false, [11350]=false, [11351]=false, [11770]=false, [11771]=false, [11772]=false, [11773]=false, [11966]=false, [11968]=false, [13376]=false, [13377]=false, [18268]=false, [18968]=false, [19626]=false, [19627]=false, [20322]=false, [20323]=false, [20324]=false, [20326]=false, [20327]=false},
                ["Flee"] = {"Flee", [5024]=false},
                ["Food"] = {"Food", [433]=false, [434]=false, [435]=false, [1127]=false, [1129]=false, [1131]=false, [2639]=false, [5004]=false, [5005]=false, [5006]=false, [5007]=false, [6410]=false, [7737]=false, [10256]=false, [10257]=false, [18229]=false, [18230]=false, [18231]=false, [18232]=false, [18233]=false, [18234]=false, [22731]=false, [24005]=false, [24707]=false, [24800]=false, [24869]=false, [25660]=false, [25695]=false, [25700]=false, [25702]=false, [25886]=false, [25888]=false, [26260]=false, [26401]=false, [26472]=false, [26474]=false, [28616]=false, [29008]=false, [29073]=false, [446713]=false, [470362]=false, [470369]=false, [1225769]=false, [1225771]=false, [1225772]=false, [1225774]=false, [1226808]=false},
                ["Frost Armor"] = {"Frost Armor", [168]=false, [484]=false, [1174]=false, [1200]=false, [6116]=false, [6643]=false, [7300]=false, [7301]=false, [12544]=false, [12556]=false, [15784]=false, [18100]=false},
                ["Frost Ward"] = {"Frost Ward", [3723]=false, [6143]=false, [6144]=false, [8461]=false, [8462]=false, [8463]=false, [8464]=false, [10177]=false, [10178]=false, [15044]=false, [28609]=false, [412202]=false, [412205]=false, [412207]=false, [412209]=false, [412210]=false},
                ["Ghostly Strike"] = {"Ghostly Strike", [14278]=false},
                ["Gnomish Mind Control Cap"] = {"Gnomish Mind Control Cap", [12907]=false, [12918]=false, [13180]=false, [13181]=false, [26740]=false, [451723]=false},
                ["Goblin Rocket Boots"] = {"Goblin Rocket Boots", [7189]=false, [8892]=false, [8895]=false, [12776]=false, [451715]=false},
                ["Gouge"] = {"Gouge", [1776]=false, [1777]=false, [1780]=false, [1781]=false, [8629]=false, [8630]=false, [11285]=false, [11286]=false, [11287]=false, [11288]=false, [12540]=false, [13579]=false, [24698]=false, [28456]=false},
                ["Grounding Totem"] = {"Grounding Totem", [8177]=false, [8180]=false},
                ["Hammer of Justice"] = {"Hammer of Justice", [853]=false, [5584]=false, [5588]=false, [5589]=false, [5590]=false, [5591]=false, [10308]=false, [10309]=false, [13005]=false, [1213301]=false},
                ["Healing Stream Totem"] = {"Healing Stream Totem", [5394]=false, [5396]=false, [6375]=false, [6377]=false, [6383]=false, [6384]=false, [10462]=false, [10463]=false, [10464]=false, [10465]=false},
                ["Holy Shield"] = {"Holy Shield", [9800]=false, [20925]=false, [20927]=false, [20928]=false, [20955]=false, [20956]=false, [20957]=false, [456544]=false},
                ["Honorless Target"] = {"Honorless Target", [2479]=false},
                ["Ice Armor"] = {"Ice Armor", [506]=false, [844]=false, [1214]=false, [1228]=false, [7302]=false, [7320]=false, [10219]=false, [10220]=false, [10221]=false, [10222]=false},
                ["Ice Barrier"] = {"Ice Barrier", [2890]=false, [11426]=false, [13031]=false, [13032]=false, [13033]=false, [13037]=false, [13038]=false, [13039]=false, [1213278]=false},
                ["Ice Block"] = {"Ice Block", [11958]=false, [27619]=false},
                ["Inner Fire"] = {"Inner Fire", [588]=false, [602]=false, [609]=false, [624]=false, [1006]=false, [1007]=false, [1252]=false, [1253]=false, [1254]=false, [7128]=false, [7129]=false, [7130]=false, [10951]=false, [10952]=false, [11025]=false, [11026]=false},
                ["Inner Focus"] = {"Inner Focus", [14751]=false},
                ["Innervate"] = {"Innervate", [29166]=false, [29167]=false, [456195]=false},
                ["Insect Swarm"] = {"Insect Swarm", [5570]=false, [24974]=false, [24975]=false, [24976]=false, [24977]=false, [24978]=false, [24979]=false, [24980]=false, [24981]=false},
                ["Intimidating Shout"] = {"Intimidating Shout", [5246]=false, [5247]=false, [19134]=false, [20511]=false, [29544]=false, [1213465]=false},
                ["Kidney Shot"] = {"Kidney Shot", [408]=false, [6735]=false, [8643]=false, [8644]=false, [27615]=false},
                ["Last Stand"] = {"Last Stand", [12975]=false, [12976]=false},
                ["Levitate"] = {"Levitate", [1706]=false, [3745]=false, [6492]=false, [27986]=false, [461329]=false},
                ["Lightning Shield"] = {"Lightning Shield", [324]=false, [325]=false, [532]=false, [557]=false, [905]=false, [906]=false, [945]=false, [946]=false, [1303]=false, [1304]=false, [1305]=false, [1363]=false, [8134]=false, [8135]=false, [8788]=false, [10431]=false, [10432]=false, [10433]=false, [10434]=false, [12550]=false, [13585]=false, [15507]=false, [19514]=false, [20545]=false, [23551]=false, [23552]=false, [25020]=false, [26363]=false, [26364]=false, [26365]=false, [26366]=false, [26367]=false, [26369]=false, [26370]=false, [26545]=false, [27635]=false, [28820]=false, [28821]=false, [432143]=false, [432144]=false, [432145]=false, [432146]=false, [432147]=false, [432148]=false, [432149]=false, [466739]=false, [470743]=false, [470744]=false, [470745]=false, [470746]=false, [470748]=false, [470749]=false, [470753]=false, [1213479]=false},
                ["Mage Armor"] = {"Mage Armor", [6117]=false, [6121]=false, [22782]=false, [22783]=false, [22784]=false, [22785]=false},
                ["Magma Totem"] = {"Magma Totem", [8187]=false, [8189]=false, [8190]=false, [10579]=false, [10580]=false, [10581]=false, [10585]=false, [10586]=false, [10587]=false, [10588]=false, [10589]=false, [10590]=false},
                ["Mana Shield"] = {"Mana Shield", [1463]=false, [1481]=false, [8494]=false, [8495]=false, [8496]=false, [8497]=false, [10191]=false, [10192]=false, [10193]=false, [10194]=false, [10195]=false, [10196]=false, [17740]=false, [17741]=false, [412116]=false, [412118]=false, [412120]=false, [412121]=false, [412122]=false, [412123]=false},
                ["Nature's Grasp"] = {"Nature's Grasp", [5230]=false, [16689]=false, [16810]=false, [16811]=false, [16812]=false, [16813]=false, [17329]=false, [17373]=false, [17374]=false, [17375]=false, [17376]=false},
                ["Nature's Swiftness"] = {"Nature's Swiftness", [16188]=false, [17116]=false, [29274]=false},
                ["Omen of Clarity"] = {"Omen of Clarity", [16864]=false},
                ["Noggenfogger Elixir"] = {"Noggenfogger Elixir", [16589]=false, [16591]=false, [16593]=false, [16595]=false},
                ["Perception"] = {"Perception", [20600]=false},
                ["Poison Cleansing Totem"] = {"Poison Cleansing Totem", [8166]=false, [8169]=false},
                ["Polymorph Backfire"] = {"Polymorph Backfire", [28406]=false},
                ["Pounce"] = {"Pounce", [9005]=false, [9006]=false, [9823]=false, [9825]=false, [9827]=false, [9828]=false},
                ["Power Infusion"] = {"Power Infusion", [10060]=false},
                ["Power Word: Fortitude"] = {"Power Word Fortitude", [1243]=false, [1244]=false, [1245]=false, [1255]=false, [1256]=false, [1257]=false, [2791]=false, [2793]=false, [10937]=false, [10938]=false, [10939]=false, [10940]=false, [13864]=false, [23947]=false, [23948]=false},
                ["Power Word: Shield"] = {"Power Word Shield", [17]=false, [592]=false, [600]=false, [1277]=false, [1278]=false, [1298]=false, [2851]=false, [3747]=false, [6065]=false, [6066]=false, [6067]=false, [6068]=false, [10898]=false, [10899]=false, [10900]=false, [10901]=false, [10902]=false, [10903]=false, [10904]=false, [10905]=false, [11647]=false, [11835]=false, [11974]=false, [17139]=false, [20697]=false, [22187]=false, [27607]=false, [437930]=false, [1226566]=false, [1236154]=false},
                ["Prayer of Fortitude"] = {"Prayer of Fortitude", [21562]=false, [21564]=false, [21568]=false, [21569]=false, [450086]=false},
                ["Prayer of Shadow Protection"] = {"Prayer of Shadow Protection", [27683]=false, [27684]=false},
                ["Premeditation"] = {"Premeditation", [14183]=false},
                ["Presence of Mind"] = {"Presence of Mind", [12043]=false},
                ["Prowl"] = {"Prowl", [5215]=false, [5216]=false, [6783]=false, [6784]=false, [8152]=false, [9913]=false, [9914]=false, [24450]=false, [24451]=false, [24452]=false, [24453]=false, [24454]=false, [24455]=false},
                ["Rapid Fire"] = {"Rapid Fire", [3045]=false, [3049]=false, [28755]=false, [1227772]=false},
                ["Reckless Charge"] = {"Reckless Charge", [13327]=false, [22641]=false, [22646]=false},
                ["Recklessness"] = {"Recklessness", [1719]=false, [1722]=false, [13847]=false},
                ["Rejuvenation"] = {"Rejuvenation", [774]=false, [788]=false, [1058]=false, [1059]=false, [1428]=false, [1429]=false, [1430]=false, [1431]=false, [2090]=false, [2091]=false, [2092]=false, [2093]=false, [3062]=false, [3063]=false, [3627]=false, [3628]=false, [8070]=false, [8910]=false, [8911]=false, [9839]=false, [9840]=false, [9841]=false, [9842]=false, [9843]=false, [9844]=false, [12160]=false, [15981]=false, [20664]=false, [20701]=false, [25299]=false, [25409]=false, [25972]=false, [27532]=false, [28716]=false, [28722]=false, [28723]=false, [28724]=false, [417057]=false, [417058]=false, [417059]=false, [417060]=false, [417061]=false, [417062]=false, [417063]=false, [417064]=false, [417065]=false, [417066]=false, [417068]=false, [1219706]=false, [1219707]=false, [1219708]=false, [1236307]=false},
                ["Renew"] = {"Renew", [139]=false, [860]=false, [870]=false, [890]=false, [3070]=false, [3071]=false, [3072]=false, [6073]=false, [6074]=false, [6075]=false, [6076]=false, [6077]=false, [6078]=false, [6079]=false, [6080]=false, [6081]=false, [6082]=false, [6083]=false, [8362]=false, [10927]=false, [10928]=false, [10929]=false, [10930]=false, [10931]=false, [10932]=false, [11640]=false, [22168]=false, [23895]=false, [25058]=false, [25315]=false, [25352]=false, [25984]=false, [27606]=false, [28807]=false, [425268]=false, [425269]=false, [425270]=false, [425271]=false, [425272]=false, [425273]=false, [425274]=false, [425275]=false, [425276]=false, [425277]=false, [438341]=false, [450658]=false, [1232734]=false, [1236151]=false},
                ["Repentance"] = {"Repentance", [20066]=false},
                ["Resurrection Sickness"] = {"Resurrection Sickness", [15007]=false},
                ["Retaliation"] = {"Retaliation", [20230]=false, [20240]=false, [20724]=false, [22857]=false, [22858]=false},
                ["Revenge Stun"] = {"Revenge Stun", [12798]=false},
                ["Riposte"] = {"Riposte", [5237]=false, [6187]=false, [6569]=false, [14251]=false},
                ["Sap"] = {"Sap", [652]=false, [2070]=false, [6770]=false, [6771]=false, [11297]=false, [11298]=false},
                ["Scatter Shot"] = {"Scatter Shot", [1988]=false, [19503]=false, [23601]=false, [462666]=false},
                ["Searing Totem"] = {"Searing Totem", [2075]=false, [3599]=false, [6363]=false, [6364]=false, [6365]=false, [6379]=false, [6380]=false, [6381]=false, [10437]=false, [10438]=false, [10439]=false, [10440]=false},
                ["Sentry Totem"] = {"Sentry Totem", [6495]=false, [6496]=false},
                ["Shadow Reflector"] = {"Shadow Reflector", [23082]=false, [23132]=false},
                ["Shadow Ward"] = {"Shadow Ward", [535]=false, [6229]=false, [6232]=false, [11739]=false, [11740]=false, [11741]=false, [11742]=false, [28610]=false, [28611]=false},
                ["Shadowform"] = {"Shadowform", [15473]=false, [16592]=false, [22917]=false, [401980]=false, [412527]=false, [412569]=false, [426223]=false, [1213334]=false},
                ["Shadowguard"] = {"Shadowguard", [18137]=false, [19308]=false, [19309]=false, [19310]=false, [19311]=false, [19312]=false, [19331]=false, [19332]=false, [19333]=false, [19334]=false, [19335]=false, [19336]=false, [28376]=false, [28377]=false, [28378]=false, [28379]=false, [28380]=false, [28381]=false, [28382]=false, [421248]=false, [459709]=false, [466219]=false, [466266]=false, [466269]=false},
                ["Shadowmeld"] = {"Shadowmeld", [743]=false, [20580]=false},
                ["Shatter"] = {"Shatter", [11170]=false, [12982]=false, [12983]=false, [12984]=false, [12985]=false},
                ["Shield Wall"] = {"Shield Wall", [871]=false, [1055]=false, [15062]=false, [29061]=false},
                ["Silence"] = {"Silence", [6726]=false, [8988]=false, [12528]=false, [15487]=false, [18278]=false, [18327]=false, [22666]=false, [23207]=false, [26069]=false, [27559]=false, [29943]=false, [30225]=false, [1214273]=false, [1224125]=false},
                ["Siphon Life"] = {"Siphon Life", [18265]=false, [18879]=false, [18880]=false, [18881]=false, [18927]=false, [18928]=false, [18929]=false},
                ["Slice and Dice"] = {"Slice and Dice", [5171]=false, [5175]=false, [6434]=false, [6774]=false, [6775]=false},
                ["Slow Fall"] = {"Slow Fall", [130]=false, [6493]=false, [12438]=false},
                ["Spell Lock"] = {"Spell Lock", [19244]=false, [19647]=false, [19648]=false, [19650]=false, [20433]=false, [20434]=false, [24259]=false},
                ["Spell Reflection"] = {"Spell Reflection", [9906]=false, [9941]=false, [9943]=false, [10074]=false, [10831]=false, [11818]=false, [17106]=false, [17107]=false, [17108]=false, [20619]=false, [21118]=false, [22067]=false, [23920]=false, [27564]=false},
                ["Sprint"] = {"Sprint", [2983]=false, [2984]=false, [8696]=false, [8697]=false, [11305]=false, [11318]=false, [26542]=false, [26543]=false},
                ["Starfire Stun"] = {"Starfire Stun", [16922]=false},
                ["Stealth"] = {"Stealth", [1784]=false, [1785]=false, [1786]=false, [1787]=false, [1789]=false, [1790]=false, [1791]=false, [1792]=false, [8822]=false, [420536]=false, [450667]=false, [460228]=false, [468879]=false, [1234823]=false},
                ["Stoneclaw Totem"] = {"Stoneclaw Totem", [5730]=false, [5731]=false, [6390]=false, [6391]=false, [6392]=false, [6400]=false, [6401]=false, [6402]=false, [10427]=false, [10428]=false, [10429]=false, [10430]=false},
                ["Stoneform"] = {"Stoneform", [7020]=false, [20594]=false, [20612]=false},
                ["Stoneskin Totem"] = {"Stoneskin Totem", [8071]=false, [8073]=false, [8154]=false, [8155]=false, [8158]=false, [8159]=false, [10406]=false, [10407]=false, [10408]=false, [10409]=false, [10410]=false, [10411]=false},
                ["Stormstrike"] = {"Stormstrike", [17364]=false, [410156]=false},
                ["Strength of Earth Totem"] = {"Strength of Earth Totem", [8075]=false, [8077]=false, [8160]=false, [8161]=false, [8164]=false, [8165]=false, [10442]=false, [10443]=false, [25361]=false, [25403]=false, [25965]=false},
                ["Stun"] = {"Stun", [25]=false, [56]=false, [2880]=false, [9179]=false, [17308]=false, [20170]=false, [20310]=false, [23454]=false, [24647]=false, [27880]=false, [429147]=false, [436473]=false, [461579]=false, [461628]=false, [1238096]=false},
                ["Stunning Blow"] = {"Stunning Blow", [5726]=false, [5727]=false, [15283]=false},
                ["Sweeping Strikes"] = {"Sweeping Strikes", [12292]=false, [12723]=false, [18765]=false, [26654]=false, [462890]=false, [1228365]=false, [1230702]=false, [1230704]=false, [1230712]=false},
                ["Swiftmend"] = {"Swiftmend", [18562]=false},
                ["Swiftness Potion"] = {"Swiftness Potion", [2329]=false, [2335]=false},
                ["Tidal Charm"] = {"Tidal Charm", [835]=false},
                ["Tiger's Fury"] = {"Tiger's Fury", [5217]=false, [5218]=false, [6793]=false, [6794]=false, [9845]=false, [9846]=false, [9847]=false, [9848]=false, [417045]=false},
                ["Touch of Weakness"] = {"Touch of Weakness", [2652]=false, [2943]=false, [19249]=false, [19251]=false, [19252]=false, [19253]=false, [19254]=false, [19261]=false, [19262]=false, [19264]=false, [19265]=false, [19266]=false, [19318]=false, [19320]=false, [19321]=false, [19322]=false, [19323]=false, [19324]=false, [28598]=false, [459714]=false},
                ["Travel Form"] = {"Travel Form", [783]=false, [1441]=false},
                ["Tremor Totem"] = {"Tremor Totem", [8143]=false, [8144]=false},
                ["Unending Breath"] = {"Unending Breath", [5697]=false, [5698]=false},
                ["Vampiric Embrace"] = {"Vampiric Embrace", [15286]=false, [15290]=false, [461966]=false, [1237618]=false},
                ["Vanish"] = {"Vanish", [1856]=false, [1857]=false, [1858]=false, [1859]=false, [11327]=false, [11329]=false, [24223]=false, [24228]=false, [24229]=false, [24230]=false, [24231]=false, [24232]=false, [24233]=false, [24699]=false, [24700]=false, [27617]=false, [457437]=false, [1231389]=false, [1234595]=false},
                ["Water Breathing"] = {"Water Breathing", [131]=false, [488]=false, [5386]=false, [7178]=false, [11789]=false, [16881]=false},
                ["Water Walking"] = {"Water Walking", [546]=false, [562]=false, [1338]=false, [11319]=false},
                ["Will of the Forsaken"] = {"Will of the Forsaken", [7744]=false},
                ["Windfury Totem"] = {"Windfury Totem", [8512]=false, [8513]=false, [8516]=false, [10608]=false, [10610]=false, [10613]=false, [10614]=false, [10615]=false, [10616]=false, [27621]=false},
                ["Windfury Weapon"] = {"Windfury Weapon", [8232]=false, [8233]=false, [8234]=false, [8235]=false, [8236]=false, [8237]=false, [10484]=false, [10486]=false, [10488]=false, [16361]=false, [16362]=false, [16363]=false, [439431]=false, [439440]=false, [439441]=false, [461636]=false},
                ["Windwall Totem"] = {"Windwall Totem", [15107]=false, [15111]=false, [15112]=false, [15113]=false, [15115]=false, [15116]=false},
                ["Wing Clip"] = {"Wing Clip", [2974]=false, [2979]=false, [14267]=false, [14268]=false, [14339]=false, [14340]=false, [27633]=false},
                ["Wyvern Sting"] = {"Wyvern Sting", [19386]=false, [20940]=false, [20941]=false, [24131]=false, [24132]=false, [24133]=false, [24134]=false, [24135]=false, [24335]=false, [24336]=false, [26180]=false, [26233]=false, [26748]=false, [1215753]=false},
            },
            ["SPELL_AURA_REMOVED"] = {
                ["Adrenaline Rush"] = {"Adrenaline Rush Down", [13750]=false, [28752]=false, [28753]=false},
                ["Barkskin"] = {"Barkskin Down", [20655]=false, [22812]=false, [22826]=false, [428713]=false},
                ["Barkskin Effect (dnd)"] = {"Barkskin Effect (dnd) Down", [22839]=false},
                ["Berserker Rage"] = {"Berserker Rage Down", [18499]=false, [18556]=false},
                ["Berserking"] = {"Berserking Down", [20554]=false, [23270]=false, [23301]=false, [23303]=false, [23505]=false, [24378]=false, [26296]=false, [26297]=false, [26635]=false},
                ["Bestial Wrath"] = {"Bestial Wrath Down", [19574]=false, [24395]=false, [24396]=false, [24397]=false, [26592]=false},
                ["Blade Flurry"] = {"Blade Flurry Down", [13877]=false, [22482]=false, [1226883]=false, [1230700]=false},
                ["Blessing of Freedom"] = {"Blessing of Freedom Down", [1044]=false, [1909]=false},
                ["Blessing of Protection"] = {"Blessing of Protection Down", [1022]=false, [1911]=false, [5599]=false, [5600]=false, [10278]=false, [10279]=false, [442948]=false},
                ["Blind"] = {"Blind Down", [2094]=false, [6505]=false, [21060]=false, [447563]=false},
                ["Blood Fury"] = {"Blood Fury Down", [20572]=false, [23230]=false, [23234]=false, [24571]=false},
                ["Bloodrage"] = {"Bloodrage Down", [2687]=false, [2688]=false, [29131]=false},
                ["Counterspell"] = {"Counterspell Down", [1053]=false, [2139]=false, [3576]=false, [15122]=false, [18469]=false, [19715]=false, [20537]=false, [20788]=false, [29443]=false, [1233255]=false},
                ["Cower"] = {"Cower Down", [1742]=false, [1747]=false, [1748]=false, [1749]=false, [1750]=false, [1751]=false, [1753]=false, [1754]=false, [1755]=false, [1756]=false, [8998]=false, [8999]=false, [9000]=false, [9001]=false, [9892]=false, [9893]=false, [16697]=false, [16698]=false, [456333]=false},
                ["Dash"] = {"Dash Down", [1151]=false, [1850]=false, [9821]=false, [9822]=false, [23099]=false, [23100]=false, [23109]=false, [23110]=false, [23111]=false, [23112]=false},
                ["Death Coil"] = {"Death Coil Down", [1572]=false, [6789]=false, [17925]=false, [17926]=false, [18161]=false, [18162]=false, [28412]=false},
                ["Death Wish"] = {"Death Wish Down", [12328]=false},
                ["Demon Skin"] = {"Demon Skin Down", [687]=false, [696]=false, [722]=false, [1383]=false, [20798]=false},
                ["Deterrence"] = {"Deterrence Down", [19263]=false},
                ["Devouring Plague"] = {"Devouring Plague Down", [2944]=false, [2946]=false, [19276]=false, [19277]=false, [19278]=false, [19279]=false, [19280]=false, [19313]=false, [19314]=false, [19315]=false, [19316]=false, [19317]=false, [459713]=false, [1219275]=false},
                ["Diamond Flask"] = {"Diamond Flask Down", [24427]=false, [363880]=false, [363881]=false},
                ["Disarm"] = {"Disarm Down", [676]=false, [1646]=false, [6713]=false, [8379]=false, [11879]=false, [13534]=false, [15752]=false, [22691]=false, [27581]=false, [445282]=false, [458880]=false, [1225423]=false, [1225428]=false, [1236176]=false},
                ["Divine Intervention"] = {"Divine Intervention Down", [19752]=false, [19753]=false, [19754]=false},
                ["Divine Protection"] = {"Divine Protection Down", [498]=false, [735]=false, [3697]=false, [5572]=false, [5573]=false, [5574]=false, [13007]=false, [27778]=false, [27779]=false, [458312]=false, [458371]=false, [1213300]=false},
                ["Divine Shield"] = {"Divine Shield Down", [642]=false, [659]=false, [1020]=false, [1021]=false, [1897]=false, [1898]=false, [13874]=false},
                ["Dreamless Sleep"] = {"Dreamless Sleep Down", [15822]=false},
                ["Earthbind Totem"] = {"Earthbind Totem Down", [2076]=false, [2484]=false, [15786]=false, [1213480]=false},
                ["Electrified Net"] = {"Electrified Net Down", [11820]=false, [11825]=false, [441453]=false},
                ["Elune's Grace"] = {"Elune's Grace Down", [2651]=false, [19289]=false, [19291]=false, [19292]=false, [19293]=false, [19357]=false, [19358]=false, [19359]=false, [19360]=false, [19361]=false, [459706]=false},
                ["Enrage"] = {"Enrage Down", [1640]=false, [3019]=false, [5228]=false, [5229]=false, [8269]=false, [8599]=false, [12317]=false, [12686]=false, [12795]=false, [12880]=false, [13045]=false, [13046]=false, [13047]=false, [13048]=false, [14201]=false, [14202]=false, [14203]=false, [14204]=false, [15061]=false, [15097]=false, [15716]=false, [18501]=false, [19516]=false, [19953]=false, [23537]=false, [24318]=false, [25503]=false, [26527]=false, [27897]=false, [28131]=false, [28468]=false, [28747]=false, [28798]=false, [425415]=false, [427066]=false, [440483]=false, [446327]=false, [460862]=false, [461347]=false, [461348]=false, [461349]=false, [462885]=false, [1223458]=false},
                ["Evasion"] = {"Evasion Down", [4086]=false, [5277]=false, [5278]=false, [15087]=false},
                ["Evocation"] = {"Evocation Down", [12051]=false, [28403]=false, [28763]=false, [456397]=false},
                ["Faerie Fire"] = {"Faerie Fire Down", [770]=false, [778]=false, [784]=false, [793]=false, [1070]=false, [1414]=false, [1415]=false, [1416]=false, [2889]=false, [6950]=false, [9749]=false, [9907]=false, [13424]=false, [13752]=false, [16498]=false, [20656]=false, [21670]=false},
                ["Fear Ward"] = {"Fear Ward Down", [6346]=false, [19337]=false, [459699]=false},
                ["Feedback"] = {"Feedback Down", [6347]=false, [13896]=false, [19267]=false, [19268]=false, [19269]=false, [19270]=false, [19271]=false, [19273]=false, [19274]=false, [19275]=false, [19345]=false, [19346]=false, [19347]=false, [19348]=false, [19349]=false, [447549]=false, [459703]=false},
                ["Fire Shield"] = {"Fire Shield Down", [134]=false, [1167]=false, [2947]=false, [2949]=false, [8316]=false, [8317]=false, [8318]=false, [8319]=false, [11350]=false, [11351]=false, [11770]=false, [11771]=false, [11772]=false, [11773]=false, [11966]=false, [11968]=false, [13376]=false, [13377]=false, [18268]=false, [18968]=false, [19626]=false, [19627]=false, [20322]=false, [20323]=false, [20324]=false, [20326]=false, [20327]=false},
                ["Flee"] = {"Flee Down", [5024]=false},
                ["Frost Armor"] = {"Frost Armor Down", [168]=false, [484]=false, [1174]=false, [1200]=false, [6116]=false, [6643]=false, [7300]=false, [7301]=false, [12544]=false, [12556]=false, [15784]=false, [18100]=false},
                ["Frost Ward"] = {"Frost Ward Down", [3723]=false, [6143]=false, [6144]=false, [8461]=false, [8462]=false, [8463]=false, [8464]=false, [10177]=false, [10178]=false, [15044]=false, [28609]=false, [412202]=false, [412205]=false, [412207]=false, [412209]=false, [412210]=false},
                ["Ghostly Strike"] = {"Ghostly Strike Down", [14278]=false},
                ["Gnomish Mind Control Cap"] = {"Gnomish Mind Control Cap Down", [12907]=false, [12918]=false, [13180]=false, [13181]=false, [26740]=false, [451723]=false},
                ["Goblin Rocket Boots"] = {"Goblin Rocket Boots Down", [7189]=false, [8892]=false, [8895]=false, [12776]=false, [451715]=false},
                ["Gouge"] = {"Gouge Down", [1776]=false, [1777]=false, [1780]=false, [1781]=false, [8629]=false, [8630]=false, [11285]=false, [11286]=false, [11287]=false, [11288]=false, [12540]=false, [13579]=false, [24698]=false, [28456]=false},
                ["Grounding Totem"] = {"Grounding Totem Down", [8177]=false, [8180]=false},
                ["Hammer of Justice"] = {"Hammer of Justice Down", [853]=false, [5584]=false, [5588]=false, [5589]=false, [5590]=false, [5591]=false, [10308]=false, [10309]=false, [13005]=false, [1213301]=false},
                ["Healing Stream Totem"] = {"Healing Stream Totem Down", [5394]=false, [5396]=false, [6375]=false, [6377]=false, [6383]=false, [6384]=false, [10462]=false, [10463]=false, [10464]=false, [10465]=false},
                ["Holy Shield"] = {"Holy Shield Down", [9800]=false, [20925]=false, [20927]=false, [20928]=false, [20955]=false, [20956]=false, [20957]=false, [456544]=false},
                ["Honorless Target"] = {"Honorless Target Down", [2479]=false},
                ["Ice Armor"] = {"Ice Armor Down", [506]=false, [844]=false, [1214]=false, [1228]=false, [7302]=false, [7320]=false, [10219]=false, [10220]=false, [10221]=false, [10222]=false},
                ["Ice Barrier"] = {"Ice Barrier Down", [2890]=false, [11426]=false, [13031]=false, [13032]=false, [13033]=false, [13037]=false, [13038]=false, [13039]=false, [1213278]=false},
                ["Ice Block"] = {"Ice Block Down", [11958]=false, [27619]=false},
                ["Innervate"] = {"Innervate Down", [29166]=false, [29167]=false, [456195]=false},
                ["Insect Swarm"] = {"Insect Swarm Down", [5570]=false, [24974]=false, [24975]=false, [24976]=false, [24977]=false, [24978]=false, [24979]=false, [24980]=false, [24981]=false},
                ["Intimidating Shout"] = {"Intimidating Shout Down", [5246]=false, [5247]=false, [19134]=false, [20511]=false, [29544]=false, [1213465]=false},
                ["Kidney Shot"] = {"Kidney Shot Down", [408]=false, [6735]=false, [8643]=false, [8644]=false, [27615]=false},
                ["Last Stand"] = {"Last Stand Down", [12975]=false, [12976]=false},
                ["Levitate"] = {"Levitate Down", [1706]=false, [3745]=false, [6492]=false, [27986]=false, [461329]=false},
                ["Lightning Shield"] = {"Lightning Shield Down", [324]=false, [325]=false, [532]=false, [557]=false, [905]=false, [906]=false, [945]=false, [946]=false, [1303]=false, [1304]=false, [1305]=false, [1363]=false, [8134]=false, [8135]=false, [8788]=false, [10431]=false, [10432]=false, [10433]=false, [10434]=false, [12550]=false, [13585]=false, [15507]=false, [19514]=false, [20545]=false, [23551]=false, [23552]=false, [25020]=false, [26363]=false, [26364]=false, [26365]=false, [26366]=false, [26367]=false, [26369]=false, [26370]=false, [26545]=false, [27635]=false, [28820]=false, [28821]=false, [432143]=false, [432144]=false, [432145]=false, [432146]=false, [432147]=false, [432148]=false, [432149]=false, [466739]=false, [470743]=false, [470744]=false, [470745]=false, [470746]=false, [470748]=false, [470749]=false, [470753]=false, [1213479]=false},
                ["Mage Armor"] = {"Mage Armor Down", [6117]=false, [6121]=false, [22782]=false, [22783]=false, [22784]=false, [22785]=false},
                ["Magma Totem"] = {"Magma Totem Down", [8187]=false, [8189]=false, [8190]=false, [10579]=false, [10580]=false, [10581]=false, [10585]=false, [10586]=false, [10587]=false, [10588]=false, [10589]=false, [10590]=false},
                ["Mana Shield"] = {"Mana Shield Down", [1463]=false, [1481]=false, [8494]=false, [8495]=false, [8496]=false, [8497]=false, [10191]=false, [10192]=false, [10193]=false, [10194]=false, [10195]=false, [10196]=false, [17740]=false, [17741]=false, [412116]=false, [412118]=false, [412120]=false, [412121]=false, [412122]=false, [412123]=false},
                ["Mana Spring Totem"] = {"Mana Spring Totem Down", [5675]=false, [5678]=false, [10495]=false, [10496]=false, [10497]=false, [10512]=false, [10514]=false, [10515]=false, [24854]=false},
                ["Mana Tide Totem"] = {"Mana Tide Totem Down", [16190]=false, [17354]=false, [17359]=false, [17362]=false, [17363]=false},
                ["Nature's Grasp"] = {"Nature's Grasp Down", [5230]=false, [16689]=false, [16810]=false, [16811]=false, [16812]=false, [16813]=false, [17329]=false, [17373]=false, [17374]=false, [17375]=false, [17376]=false},
                ["Nature's Swiftness"] = {"Nature's Swiftness Down", [16188]=false, [17116]=false, [29274]=false},
                ["Omen of Clarity"] = {"Omen of Clarity Down", [16864]=false},
                ["Noggenfogger Elixir"] = {"Noggenfogger Elixir Down", [16589]=false, [16591]=false, [16593]=false, [16595]=false},
                ["Perception"] = {"Perception Down", [20600]=false},
                ["Poison Cleansing Totem"] = {"Poison Cleansing Totem Down", [8166]=false, [8169]=false},
                ["Polymorph Backfire"] = {"Polymorph Backfire Down", [28406]=false},
                ["Pounce"] = {"Pounce Down", [9005]=false, [9006]=false, [9823]=false, [9825]=false, [9827]=false, [9828]=false},
                ["Power Infusion"] = {"Power Infusion Down", [10060]=false},
                ["Power Word: Fortitude"] = {"Power Word Fortitude Down", [1243]=false, [1244]=false, [1245]=false, [1255]=false, [1256]=false, [1257]=false, [2791]=false, [2793]=false, [10937]=false, [10938]=false, [10939]=false, [10940]=false, [13864]=false, [23947]=false, [23948]=false},
                ["Power Word: Shield"] = {"Power Word Shield Down", [17]=false, [592]=false, [600]=false, [1277]=false, [1278]=false, [1298]=false, [2851]=false, [3747]=false, [6065]=false, [6066]=false, [6067]=false, [6068]=false, [10898]=false, [10899]=false, [10900]=false, [10901]=false, [10902]=false, [10903]=false, [10904]=false, [10905]=false, [11647]=false, [11835]=false, [11974]=false, [17139]=false, [20697]=false, [22187]=false, [27607]=false, [437930]=false, [1226566]=false, [1236154]=false},
                ["Prayer of Shadow Protection"] = {"Prayer of Shadow Protection Down", [27683]=false, [27684]=false},
                ["Premeditation"] = {"Premeditation Down", [14183]=false},
                ["Presence of Mind"] = {"Presence of Mind Down", [12043]=false},
                ["Prowl"] = {"Prowl Down", [5215]=false, [5216]=false, [6783]=false, [6784]=false, [8152]=false, [9913]=false, [9914]=false, [24450]=false, [24451]=false, [24452]=false, [24453]=false, [24454]=false, [24455]=false},
                ["Psychic Scream"] = {"Psychic Scream Down", [8122]=false, [8123]=false, [8124]=false, [8125]=false, [10888]=false, [10889]=false, [10890]=false, [10891]=false, [13704]=false, [15398]=false, [22884]=false, [26042]=false, [27610]=false, [437928]=false},
                ["Rapid Fire"] = {"Rapid Fire Down", [3045]=false, [3049]=false, [28755]=false, [1227772]=false},
                ["Reckless Charge"] = {"Reckless Charge Down", [13327]=false, [22641]=false, [22646]=false},
                ["Recklessness"] = {"Recklessness Down", [1719]=false, [1722]=false, [13847]=false},
                ["Rejuvenation"] = {"Rejuvenation Down", [774]=false, [788]=false, [1058]=false, [1059]=false, [1428]=false, [1429]=false, [1430]=false, [1431]=false, [2090]=false, [2091]=false, [2092]=false, [2093]=false, [3062]=false, [3063]=false, [3627]=false, [3628]=false, [8070]=false, [8910]=false, [8911]=false, [9839]=false, [9840]=false, [9841]=false, [9842]=false, [9843]=false, [9844]=false, [12160]=false, [15981]=false, [20664]=false, [20701]=false, [25299]=false, [25409]=false, [25972]=false, [27532]=false, [28716]=false, [28722]=false, [28723]=false, [28724]=false, [417057]=false, [417058]=false, [417059]=false, [417060]=false, [417061]=false, [417062]=false, [417063]=false, [417064]=false, [417065]=false, [417066]=false, [417068]=false, [1219706]=false, [1219707]=false, [1219708]=false, [1236307]=false},
                ["Renew"] = {"Renew Down", [139]=false, [860]=false, [870]=false, [890]=false, [3070]=false, [3071]=false, [3072]=false, [6073]=false, [6074]=false, [6075]=false, [6076]=false, [6077]=false, [6078]=false, [6079]=false, [6080]=false, [6081]=false, [6082]=false, [6083]=false, [8362]=false, [10927]=false, [10928]=false, [10929]=false, [10930]=false, [10931]=false, [10932]=false, [11640]=false, [22168]=false, [23895]=false, [25058]=false, [25315]=false, [25352]=false, [25984]=false, [27606]=false, [28807]=false, [425268]=false, [425269]=false, [425270]=false, [425271]=false, [425272]=false, [425273]=false, [425274]=false, [425275]=false, [425276]=false, [425277]=false, [438341]=false, [450658]=false, [1232734]=false, [1236151]=false},
                ["Repentance"] = {"Repentance Down", [20066]=false},
                ["Resurrection Sickness"] = {"Resurrection Sickness Down", [15007]=false},
                ["Retaliation"] = {"Retaliation Down", [20230]=false, [20240]=false, [20724]=false, [22857]=false, [22858]=false},
                ["Revenge Stun"] = {"Revenge Stun Down", [12798]=false},
                ["Riposte"] = {"Riposte Down", [5237]=false, [6187]=false, [6569]=false, [14251]=false},
                ["Sap"] = {"Sap Down", [652]=false, [2070]=false, [6770]=false, [6771]=false, [11297]=false, [11298]=false},
                ["Scatter Shot"] = {"Scatter Shot Down", [1988]=false, [19503]=false, [23601]=false, [462666]=false},
                ["Searing Totem"] = {"Searing Totem Down", [2075]=false, [3599]=false, [6363]=false, [6364]=false, [6365]=false, [6379]=false, [6380]=false, [6381]=false, [10437]=false, [10438]=false, [10439]=false, [10440]=false},
                ["Sentry Totem"] = {"Sentry Totem Down", [6495]=false, [6496]=false},
                ["Shadow Reflector"] = {"Shadow Reflector Down", [23082]=false, [23132]=false},
                ["Shadowform"] = {"Shadowform Down", [15473]=false, [16592]=false, [22917]=false, [401980]=false, [412527]=false, [412569]=false, [426223]=false, [1213334]=false},
                ["Shadowguard"] = {"Shadowguard Down", [18137]=false, [19308]=false, [19309]=false, [19310]=false, [19311]=false, [19312]=false, [19331]=false, [19332]=false, [19333]=false, [19334]=false, [19335]=false, [19336]=false, [28376]=false, [28377]=false, [28378]=false, [28379]=false, [28380]=false, [28381]=false, [28382]=false, [421248]=false, [459709]=false, [466219]=false, [466266]=false, [466269]=false},
                ["Shadowmeld"] = {"Shadowmeld Down", [743]=false, [20580]=false},
                ["Shatter"] = {"Shatter Down", [11170]=false, [12982]=false, [12983]=false, [12984]=false, [12985]=false},
                ["Shield Wall"] = {"Shield Wall Down", [871]=false, [1055]=false, [15062]=false, [29061]=false},
                ["Silence"] = {"Silence Down", [6726]=false, [8988]=false, [12528]=false, [15487]=false, [18278]=false, [18327]=false, [22666]=false, [23207]=false, [26069]=false, [27559]=false, [29943]=false, [30225]=false, [1214273]=false, [1224125]=false},
                ["Siphon Life"] = {"Siphon Life Down", [18265]=false, [18879]=false, [18880]=false, [18881]=false, [18927]=false, [18928]=false, [18929]=false},
                ["Slice and Dice"] = {"Slice and Dice Down", [5171]=false, [5175]=false, [6434]=false, [6774]=false, [6775]=false},
                ["Slow Fall"] = {"Slow Fall Down", [130]=false, [6493]=false, [12438]=false},
                ["Spell Lock"] = {"Spell Lock Down", [19244]=false, [19647]=false, [19648]=false, [19650]=false, [20433]=false, [20434]=false, [24259]=false},
                ["Spell Reflection"] = {"Spell Reflection Down", [9906]=false, [9941]=false, [9943]=false, [10074]=false, [10831]=false, [11818]=false, [17106]=false, [17107]=false, [17108]=false, [20619]=false, [21118]=false, [22067]=false, [23920]=false, [27564]=false},
                ["Sprint"] = {"Sprint Down", [2983]=false, [2984]=false, [8696]=false, [8697]=false, [11305]=false, [11318]=false, [26542]=false, [26543]=false},
                ["Starfire Stun"] = {"Starfire Stun Down", [16922]=false},
                ["Stealth"] = {"Stealth Down", [1784]=false, [1785]=false, [1786]=false, [1787]=false, [1789]=false, [1790]=false, [1791]=false, [1792]=false, [8822]=false, [420536]=false, [450667]=false, [460228]=false, [468879]=false, [1234823]=false},
                ["Stoneclaw Totem"] = {"Stoneclaw Totem Down", [5730]=false, [5731]=false, [6390]=false, [6391]=false, [6392]=false, [6400]=false, [6401]=false, [6402]=false, [10427]=false, [10428]=false, [10429]=false, [10430]=false},
                ["Stoneform"] = {"Stoneform Down", [7020]=false, [20594]=false, [20612]=false},
                ["Stoneskin Totem"] = {"Stoneskin Totem Down", [8071]=false, [8073]=false, [8154]=false, [8155]=false, [8158]=false, [8159]=false, [10406]=false, [10407]=false, [10408]=false, [10409]=false, [10410]=false, [10411]=false},
                ["Stormstrike"] = {"Stormstrike Down", [17364]=false, [410156]=false},
                ["Strength of Earth Totem"] = {"Strength of Earth Totem Down", [8075]=false, [8077]=false, [8160]=false, [8161]=false, [8164]=false, [8165]=false, [10442]=false, [10443]=false, [25361]=false, [25403]=false, [25965]=false},
                ["Stun"] = {"Stun Down", [25]=false, [56]=false, [2880]=false, [9179]=false, [17308]=false, [20170]=false, [20310]=false, [23454]=false, [24647]=false, [27880]=false, [429147]=false, [436473]=false, [461579]=false, [461628]=false, [1238096]=false},
                ["Stunning Blow"] = {"Stunning Blow Down", [5726]=false, [5727]=false, [15283]=false},
                ["Sweeping Strikes"] = {"Sweeping Strikes Down", [12292]=false, [12723]=false, [18765]=false, [26654]=false, [462890]=false, [1228365]=false, [1230702]=false, [1230704]=false, [1230712]=false},
                ["Swiftmend"] = {"Swiftmend Down", [18562]=false},
                ["Swiftness Potion"] = {"Swiftness Potion Down", [2329]=false, [2335]=false},
                ["Tidal Charm"] = {"Tidal Charm Down", [835]=false},
                ["Tiger's Fury"] = {"Tiger's Fury Down", [5217]=false, [5218]=false, [6793]=false, [6794]=false, [9845]=false, [9846]=false, [9847]=false, [9848]=false, [417045]=false},
                ["Touch of Weakness"] = {"Touch of Weakness Down", [2652]=false, [2943]=false, [19249]=false, [19251]=false, [19252]=false, [19253]=false, [19254]=false, [19261]=false, [19262]=false, [19264]=false, [19265]=false, [19266]=false, [19318]=false, [19320]=false, [19321]=false, [19322]=false, [19323]=false, [19324]=false, [28598]=false, [459714]=false},
                ["Travel Form"] = {"Travel Form Down", [783]=false, [1441]=false},
                ["Tremor Totem"] = {"Tremor Totem Down", [8143]=false, [8144]=false},
                ["Vampiric Embrace"] = {"Vampiric Embrace Down", [15286]=false, [15290]=false, [461966]=false, [1237618]=false},
                ["Vanish"] = {"Vanish Down", [1856]=false, [1857]=false, [1858]=false, [1859]=false, [11327]=false, [11329]=false, [24223]=false, [24228]=false, [24229]=false, [24230]=false, [24231]=false, [24232]=false, [24233]=false, [24699]=false, [24700]=false, [27617]=false, [457437]=false, [1231389]=false, [1234595]=false},
                ["Water Breathing"] = {"Water Breathing Down", [131]=false, [488]=false, [5386]=false, [7178]=false, [11789]=false, [16881]=false},
                ["Water Walking"] = {"Water Walking Down", [546]=false, [562]=false, [1338]=false, [11319]=false},
                ["Will of the Forsaken"] = {"Will of the Forsaken Down", [7744]=false},
                ["Windfury Totem"] = {"Windfury Totem Down", [8512]=false, [8513]=false, [8516]=false, [10608]=false, [10610]=false, [10613]=false, [10614]=false, [10615]=false, [10616]=false, [27621]=false},
                ["Windfury Weapon"] = {"Windfury Weapon Down", [8232]=false, [8233]=false, [8234]=false, [8235]=false, [8236]=false, [8237]=false, [10484]=false, [10486]=false, [10488]=false, [16361]=false, [16362]=false, [16363]=false, [439431]=false, [439440]=false, [439441]=false, [461636]=false},
                ["Windwall Totem"] = {"Windwall Totem Down", [15107]=false, [15111]=false, [15112]=false, [15113]=false, [15115]=false, [15116]=false},
                ["Wing Clip"] = {"Wing Clip Down", [2974]=false, [2979]=false, [14267]=false, [14268]=false, [14339]=false, [14340]=false, [27633]=false},
                ["Wyvern Sting"] = {"Wyvern Sting Down", [19386]=false, [20940]=false, [20941]=false, [24131]=false, [24132]=false, [24133]=false, [24134]=false, [24135]=false, [24335]=false, [24336]=false, [26180]=false, [26233]=false, [26748]=false, [1215753]=false},
            },
            ["SPELL_INTERRUPT"] = {
                ["Counterspell"] = {"Counterspell", [1053]=false, [2139]=false, [3576]=false, [15122]=false, [18469]=false, [19715]=false, [20537]=false, [20788]=false, [29443]=false, [1233255]=false},
                ["Kick"] = {"Kick", [1766]=false, [1767]=false, [1768]=false, [1769]=false, [1771]=false, [1772]=false, [1773]=false, [1774]=false, [1775]=false, [3467]=false, [11978]=false, [15610]=false, [15614]=false, [18425]=false, [27613]=false, [27814]=false},
                ["Pummel"] = {"Pummel", [6552]=false, [6553]=false, [6554]=false, [6556]=false, [12555]=false, [13491]=false, [15615]=false, [19639]=false, [19640]=false},
                ["Silence"] = {"Silence", [6726]=false, [8988]=false, [12528]=false, [15487]=false, [18278]=false, [18327]=false, [22666]=false, [23207]=false, [26069]=false, [27559]=false, [29943]=false, [30225]=false, [1214273]=false, [1224125]=false},
                ["Spell Lock"] = {"Spell Lock", [19244]=false, [19647]=false, [19648]=false, [19650]=false, [20433]=false, [20434]=false, [24259]=false}
            }
    else
    ----------------------------------------------------------------------------
    -- TBC CLASSIC ERA
    ---------------------------------------------------------------------------- 
        HEAT = HEAT or {}

        -- Raw Data: ["Name"] = "ID=Icon=Duration,ID2=Icon2=Duration2"
        HEAT.spellData = {
            -- ommited for Gemini file size requirements
        }
    
        HEAT.nameplateBuffs = {
            "Avenging Wrath",
            "Divine Illumination",
            "Blessing of Sacrifice",
            "Divine Protection",
            "Divine Shield",
            "Hide",
            "Stealth",
            "Prowl",
            "Shadowmeld",
            "Camouflage",
            "Subterfuge",
            "Perception",
            "Ice Block",
            "Berserker Rage",
            "Divine Intervention",
            "Shield Wall",
            "Retaliation",
            "Recklessness",
            "Blessing of Protection",
            "Death Wish",
            "Divine Shield",
            "Blood Fury",
            "Light of Elune",
            "Honorless Target",
            "Stormpike's Salvation",
            "Evasion",
            "Flee",
            "Sprint",
            "Berserking",
            "Sweeping Strikes",
            "Blessing of Freedom",
            "Will of the Forsaken",
            "Invulnerability",
            "Free Action",
            "Evocation",
            "Stoneform",
            "Petrification",
            "Presence of Mind",
            "Blade Flurry",
            "Elemental Mastery",
            "Mind Quickening",
            "Last Stand"
        }
        
        HEAT.soundTable = {
            -- ommited for Gemini file size requirements
        }
    end
        
        HEAT.unitTokens = { "playerpet", "target", "focus", "mouseover" }
        for i = 1, 5 do table.insert(HEAT.unitTokens, "boss"..i) end
        for i = 1, 5 do table.insert(HEAT.unitTokens, "arena"..i) end
        for i = 1, 5 do table.insert(HEAT.unitTokens, "arenapet"..i) end
        for i = 1, 40 do table.insert(HEAT.unitTokens, "nameplate"..i) end
        for i = 1, 4 do table.insert(HEAT.unitTokens, "party"..i) end
        for i = 1, 4 do table.insert(HEAT.unitTokens, "partypet"..i) end
        for i = 1, 40 do table.insert(HEAT.unitTokens, "raid"..i) end
        for i = 1, 40 do table.insert(HEAT.unitTokens, "raidpet"..i) end
        
        HEAT.FLAGS = {
            PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400,
            NPC = COMBATLOG_OBJECT_TYPE_NPC or 0x00000800,
            PET = COMBATLOG_OBJECT_TYPE_PET or 0x00002000,
            GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN or 0x00004000,
            CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100,
            REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY or 0x00000010,
            REACTION_NEUTRAL  = COMBATLOG_OBJECT_REACTION_NEUTRAL  or 0x00000020,
            REACTION_HOSTILE  = COMBATLOG_OBJECT_REACTION_HOSTILE  or 0x00000040,
            AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
        };
                            
        
        if HEAT.soundTable["SPELL_AURA_APPLIED"] and not HEAT.soundTable["SPELL_AURA_REFRESH"] then
            HEAT.soundTable["SPELL_AURA_REFRESH"] = HEAT.soundTable["SPELL_AURA_APPLIED"]
            HEAT.soundTable["UNIT_AURA"] = HEAT.soundTable["SPELL_AURA_APPLIED"]
        end

        if HEAT.soundTable["SPELL_CAST_START"] then
            HEAT.soundTable["UNIT_SPELLCAST_START"] = HEAT.soundTable["SPELL_CAST_START"]
            
            -- Channel Start
            HEAT.soundTable["UNIT_SPELLCAST_CHANNEL_START"] = HEAT.soundTable["SPELL_CAST_START"] 
            
            -- Channel Update (e.g., pushback) - Maps to same data as Start
            HEAT.soundTable["UNIT_SPELLCAST_CHANNEL_UPDATE"] = HEAT.soundTable["SPELL_CAST_START"] 
            
            -- Channel Stop - Maps to same data as Start so we can look up the Spell ID
            HEAT.soundTable["UNIT_SPELLCAST_CHANNEL_STOP"] = HEAT.soundTable["SPELL_CAST_START"] 
        end

        if HEAT.soundTable["SPELL_CAST_SUCCESS"] then
            HEAT.soundTable["UNIT_SPELLCAST_SUCCEEDED"] = HEAT.soundTable["SPELL_CAST_SUCCESS"]
        end

        -- Build spell cache
        if HEAT.spellData then
            local spellCount = 0
            local parsedSpellData = {} -- Map: [ID] = Duration (for Static_Buffs.lua)
            
            for spellName, dataString in pairs(HEAT.spellData) do
                -- Parse "ID=Icon=Duration,ID2=Icon2=Dur2"
                for entry in string.gmatch(dataString, "([^,]+)") do
                    local sID, sIcon, sDur = string.match(entry, "(%d+)=(%d+)=([%d%-]+)")
                    if sID then
                        local id = tonumber(sID)
                        local icon = tonumber(sIcon)
                        local dur = tonumber(sDur)
                        
                        -- Populate table (ID -> Duration lookup)
                        parsedSpellData[id] = dur
                        
                        -- Populate master Tracker Info (Database)
                        HEAT.AuraInfo[id] = {
                            spellID = id,
                            icon = icon,
                            name = spellName,
                            duration = dur
                        }
                        spellCount = spellCount + 1
                    end
                end
            end
            
            HEAT.spellData = parsedSpellData
            print(string.format("|cFFFFD700H|r |cFFFF8C00E|r |cFFFF4500A|r |cFFFF0000T|r Successfully built and cached |cFF00FF00%d|r spell definitions.", spellCount))
        end

        -- Build Sound Map (Sounds Only)
        if HEAT.soundTable then
            for eventType, eventSpells in pairs(HEAT.soundTable) do
                HEAT.spellIDMap[eventType] = {}
                for _, spellConfig in pairs(eventSpells) do
                    local soundFile = spellConfig[1]
                    for key, value in pairs(spellConfig) do
                        if type(key) == "number" then
                            -- Populate Sound Map
                            HEAT.spellIDMap[eventType][key] = { soundFile = soundFile, requireDst = value }
                        end
                    end
                end
            end
        end
    
    -- Mark as initialized so we don't run this again
    HEAT.initialized = true

end

----------------------------------------------------------------------------
-- FUNCTION DEFINITIONS
----------------------------------------------------------------------------
function HEAT:SendMessage(message)
        if IsInGroup() then
            local msg = ("%s#"):format(message)
            local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() and "INSTANCE_CHAT" or "RAID"               
            if channel and msg then C_ChatInfo.SendAddonMessage(HEAT.prefix, msg, channel) end
        end
    end
    
function HEAT:PlaySound(file, channel)
        if not file then return end
        local soundPath = self.SOUND_PREFIX .. file .. self.fileExtension
        local soundChannel = channel or self.CHANNEL
        if soundPath and soundChannel then PlaySoundFile(soundPath, soundChannel) end
    end
    
function HEAT:RemoveNode(node)
        if not node or not self.hostilityCache then return end
        if node.prev then node.prev.next = node.next else self.hostilityCache.head = node.next end
        if node.next then node.next.prev = node.prev else self.hostilityCache.tail = node.prev end
        self.hostilityCache.cache[node.guid] = nil
        if self.hostilityCache.size > 0 then self.hostilityCache.size = self.hostilityCache.size - 1 end
    end
    
function HEAT:MoveToHead(node)
        if not node or not self.hostilityCache or node == self.hostilityCache.head then return end
        if node.prev then node.prev.next = node.next end
        if node.next then node.next.prev = node.prev end
        if self.hostilityCache.tail == node then self.hostilityCache.tail = node.prev end
        node.prev = nil
        node.next = self.hostilityCache.head
        if self.hostilityCache.head then self.hostilityCache.head.prev = node end
        self.hostilityCache.head = node
    end
    
function HEAT:AddNode(guid)
        if not guid or not self.hostilityCache then return end
        
        -- Remove tail if cache is full
        if self.hostilityCache.size >= self.hostilityCache.maxSize then
            local tail = self.hostilityCache.tail
            if tail then self:RemoveNode(tail) end
        end
        
        -- isEnemy is now hardcoded to true
        local node = { guid = guid, isEnemy = true, buffs = {}, prev = nil, next = self.hostilityCache.head }
        
        if self.hostilityCache.head then self.hostilityCache.head.prev = node end
        self.hostilityCache.head = node
        if not self.hostilityCache.tail then self.hostilityCache.tail = node end
        
        self.hostilityCache.cache[guid] = node
        self.hostilityCache.size = self.hostilityCache.size + 1
    end
    
function HEAT:IsEnemy(guid, unitFlags)
        if guid == self.playerGUID then return false end
        
        if not guid or not unitFlags then return false end
        
        local isHostile = (bit.band(unitFlags, self.FLAGS.REACTION_HOSTILE) > 0)
        
        -- Only interact with the cache if the unit is hostile
        if isHostile then
            local node = self.hostilityCache.cache[guid]
            if node then
                -- It's already in cache, move it to the front
                self:MoveToHead(node)
            else
                self:AddNode(guid)
            end
        end
        
        return isHostile
    end
    
function HEAT:BuildFlags(unit, guid)
        if not unit or not UnitExists(unit) then return 0 end
        local unitGUID = guid or UnitGUID(unit)
        if not unitGUID then return 0 end
        
        local flags = 0
        if UnitIsEnemy("player", unit) then flags = self.FLAGS.REACTION_HOSTILE
        elseif UnitIsFriend("player", unit) then flags = self.FLAGS.REACTION_FRIENDLY
        else flags = self.FLAGS.REACTION_NEUTRAL end
        
        if string.sub(unitGUID, 1, 3) == "Pet" then flags = bit.bor(flags, self.FLAGS.PET)
        elseif UnitIsPlayer(unit) then flags = bit.bor(flags, self.FLAGS.PLAYER)
        else flags = bit.bor(flags, self.FLAGS.NPC) end
        
        if UnitPlayerControlled(unit) then flags = bit.bor(flags, self.FLAGS.CONTROL_PLAYER) end
        
        if not UnitInParty(unit) and not UnitInRaid(unit) and unit ~= "player" and unit ~= "pet" and unit ~= "vehicle" then
            flags = bit.bor(flags, self.FLAGS.AFFILIATION_OUTSIDER)
        end
        return flags
    end
    
function HEAT:UpdateUnitHostility(unit, guid)
        if not UnitExists(unit) then return 0, false end
        local unitGUID = guid or UnitGUID(unit)
        if not unitGUID then return 0, false end
        
        local flags = self:BuildFlags(unit, unitGUID)
        local isHostile = self:IsEnemy(unitGUID, flags)
        return flags, isHostile
    end
    
function HEAT:UpdateUnitCache(unit)
        if not unit then return end
        local guid = UnitGUID(unit)
        if guid then
            self.guidToUnit[guid] = unit
        end
    end
    
function HEAT:StoreBuff(guid, spellID, data)
        if not self.storedBuffs[guid] then self.storedBuffs[guid] = {} end
        self.storedBuffs[guid][spellID] = data
    end
    
function HEAT:RemoveBuff(guid, spellID)
        if self.storedBuffs[guid] then
            self.storedBuffs[guid][spellID] = nil
            if not next(self.storedBuffs[guid]) then self.storedBuffs[guid] = nil end
        end
    end
    
function HEAT:ScanAllUnits()
        if not self.unitTokens then return end
        for _, unit in ipairs(self.unitTokens) do
            if UnitExists(unit) then
                local guid = UnitGUID(unit)
                if guid then
                    local flags, isHostile = self:UpdateUnitHostility(unit, guid)
                    self:ScanUnitBuffs(unit, flags, isHostile, guid)
                end
            end
        end
    end
    
function HEAT:ScanUnitBuffs(unit, providedFlags, providedIsEnemy, providedGUID)
        local guid = providedGUID or UnitGUID(unit)
        if not guid then return end
        
        local isEnemy = providedIsEnemy
        if isEnemy == nil then
            local flags = providedFlags or self:BuildFlags(unit, guid)
            isEnemy = self.IsEnemy and self:IsEnemy(guid, flags)
        end
        
        if not isEnemy then return end
                
        local now = GetTime()
        local foundSpells = {}
        local filterList = {"HELPFUL", "HARMFUL"}
        
        for _, filter in ipairs(filterList) do
            for i = 1, 40 do
                local name, icon, _, _, duration, expirationTime, source, _, _, spellID = UnitAura(unit, i, filter)
                if not name then break end 
                
                local skip = (filter == "HARMFUL") --and source == "player")
                
                if not skip and spellID and self.AuraInfo[spellID] then
                    local calculatedDuration = duration
                    if calculatedDuration == 0 then calculatedDuration = -1 end
                    
                    foundSpells[spellID] = true
                    
                    self:StoreBuff(guid, spellID, {
                            destGUID = guid, duration = calculatedDuration, expirationTime = expirationTime,
                            spellID = spellID, icon = icon,
                            startTime = (expirationTime and expirationTime > 0) and (expirationTime - duration) or now
                    })
                end
            end
        end
        
        if self.storedBuffs[guid] then
            for spellID, _ in pairs(self.storedBuffs[guid]) do
                if not foundSpells[spellID] then
                        self.storedBuffs[guid][spellID] = nil
                end
            end
            -- Cleanup if empty
            if not next(self.storedBuffs[guid]) then self.storedBuffs[guid] = nil end
        end
    end
    
function HEAT:ProcessDataEvents(event, ...)
    local now = GetTime()
    local INFINITY = -1
    
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, sourceFlags, _, destGUID, destName, destFlags, _, spellID, _, _, auraType, extraSpellID, durationMS = CombatLogGetCurrentEventInfo()
        
        -- Cleanup on Death
        if subEvent == "UNIT_DIED" or subEvent == "UNIT_DESTROYED" then
            if destGUID then
                self.storedBuffs[destGUID] = nil
                self.unitCastDelayed[destGUID] = nil 
                if self.hostilityCache and self.hostilityCache.cache[destGUID] then
                    self:RemoveNode(self.hostilityCache.cache[destGUID])
                end
            end
            return
        end
        
        if sourceGUID == self.playerGUID then return end
        
        local idToProcess = spellID
        local isApplication = subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH"
        local isRemoval = subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_BROKEN" or subEvent == "SPELL_AURA_BROKEN_SPELL"
        local isDispel = subEvent == "SPELL_DISPEL" or subEvent == "SPELL_STOLEN"
        if isDispel and extraSpellID and extraSpellID ~= 0 then idToProcess = extraSpellID end
        
        local spellDataForLookup = self.AuraInfo[idToProcess]
        local spellDataForApplication = self.AuraInfo[spellID]
        
        if (isApplication and spellDataForApplication) or ((isRemoval or isDispel) and spellDataForLookup) then
            if self.IsEnemy and self:IsEnemy(destGUID, destFlags) and auraType == "BUFF" then
                if isApplication and spellDataForApplication then
                
                    local buffDuration = INFINITY
                    if durationMS and durationMS > 0 then 
                        buffDuration = durationMS
                    elseif spellDataForApplication.duration and spellDataForApplication.duration ~= INFINITY then 
                        buffDuration = tonumber(spellDataForApplication.duration) 
                    end
                    
                    --print("Applying Buff:", spellDataForApplication.name, "| ID:", spellID, "| Dest:", destGUID, "| Dur:", buffDuration)

                    local expirationTime = (buffDuration == INFINITY) and nil or ((buffDuration > 0) and (now + buffDuration) or nil)
                    
                    self:StoreBuff(destGUID, spellID, {
                            destGUID = destGUID, duration = buffDuration, expirationTime = expirationTime,
                            spellID = spellID, icon = spellDataForApplication.icon, startTime = now
                    })
                    
                    self:SendMessage("APPLIED", destGUID, spellID, (expirationTime or 0))
                    
                elseif (isRemoval or isDispel) and spellDataForLookup then
                    self:RemoveBuff(destGUID, idToProcess)
                    self:SendMessage("REMOVED", destGUID, idToProcess)
                end
            end
        end
        
    elseif event == "CHAT_MSG_ADDON" then
        local messagePrefix, msg, _, sender = ...
        if messagePrefix == self.prefix and sender ~= UnitName("player") and msg then
            local eventType, data = msg:match("([^#]+)#(.*)")
            if not (eventType and data) then return end
            
            local guid = data:match("([^#]+)")
            if guid and guid == UnitGUID("target") then return end 
            
            if eventType == "APPLIED" then
                local _, spellID, expiration = data:match("([^#]+)#([^#]+)#([^#]+)")
                spellID = tonumber(spellID)
                expiration = tonumber(expiration)
                if not (guid and spellID and expiration) then return end
                
                local spell = self.AuraInfo[spellID]
                if not spell then return end
                local expirationTime = (expiration == 0) and nil or expiration
                local duration = INFINITY
                if expirationTime then duration = expirationTime - now; if duration < 0 then duration = 0 end
                elseif spell and spell.duration ~= INFINITY then duration = spell.duration end
                
                self:StoreBuff(guid, spellID, {
                        destGUID = guid, duration = duration, expirationTime = expirationTime,
                        spellID = spellID, icon = spell.icon, startTime = now
                })
                
            elseif eventType == "REMOVED" then
                local _, spellID = data:match("([^#]+)#([^#]+)")
                spellID = tonumber(spellID)
                if guid and spellID then self:RemoveBuff(guid, spellID) end
            end
        end
    end
end

function HEAT:ProcessHostilityEvent(event, ...)
        if not self.hostilityCache then return end
        
        -- Process raw data (Combat Log / Chat Sync)
        self:ProcessDataEvents(event, ...)
        
        -- Handle Zone Changes / Roster updates
        if event == "PLAYER_ENTERING_WORLD" or event == "ARENA_OPPONENT_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
            self:ScanAllUnits()
            return
        end
        
        -- Determine if a specific unit needs scanning based on the event
        local unitToUpdate = nil
        if event == "PLAYER_TARGET_CHANGED" then unitToUpdate = "target"
        elseif event == "UPDATE_MOUSEOVER_UNIT" then unitToUpdate = "mouseover"
        elseif event == "PLAYER_FLAGS_CHANGED" then unitToUpdate = "player"
        elseif event == "NAME_PLATE_UNIT_ADDED" or event == "UNIT_FLAGS" or event == "UNIT_FACTION" or event == "UNIT_TARGET" or event == "UNIT_AURA" then
            local unitId = ...
            if unitId and UnitExists(unitId) then unitToUpdate = unitId end
        end
        
        -- Perform the scan if a unit was identified
        if unitToUpdate then
            local guid = UnitGUID(unitToUpdate)
            if guid then
                local flags, isHostile = self:UpdateUnitHostility(unitToUpdate, guid)
                self:ScanUnitBuffs(unitToUpdate, flags, isHostile, guid)
            end
        end
end

-- Global frame for event handling
local HeatFrame = CreateFrame("Frame")
HEAT.frame = HeatFrame

-- Register all necessary events once at load time
HeatFrame:RegisterEvent("ADDON_LOADED")
HeatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
HeatFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
HeatFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
HeatFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
HeatFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
HeatFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
HeatFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
HeatFrame:RegisterEvent("UNIT_FLAGS")
HeatFrame:RegisterEvent("UNIT_FACTION")
HeatFrame:RegisterEvent("UNIT_TARGET")
HeatFrame:RegisterEvent("UNIT_AURA")
HeatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
HeatFrame:RegisterEvent("CHAT_MSG_ADDON")
HeatFrame:RegisterEvent("UNIT_SPELLCAST_START")
HeatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
HeatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
HeatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
HeatFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

-- Main event handler
HeatFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ... 
    
    -- 1. Handle Initialization
    if event == "ADDON_LOADED" and arg1 == "HEAT" then
        init()
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        
    -- 2. Pass Combat/Chat events to your processing function
    -- This ensures HEAT.storedBuffs gets updated automatically!
    elseif HEAT.ProcessDataEvents then
        HEAT:ProcessDataEvents(event, ...)
    end
end)

init()
