extends Node2D

const THING_LIMIT = -1
const ACTION_POINT_LIMIT = -1 #255
const CREATURE_LIMIT = -1 #255
const LIGHT_LIMIT = -1

enum {
	NAME_ID = 0
	SPRITE = 1
	EDITOR_TAB = 2
}

enum TYPE {
	NONE = 0
	OBJECT = 1
	SHOT = 2
	EFFECTELEM = 3
	DEADCREATURE = 4
	CREATURE = 5
	EFFECT = 6
	EFFECTGEN = 7
	TRAP = 8
	DOOR = 9
	UNKN10 = 10
	UNKN11 = 11
	AMBIENTSND = 12
	CAVEIN = 13
	EXTRA = 696969
}

var default_data = {}
func _init():
	# This only takes 1ms
	default_data["DATA_EXTRA"] = DATA_EXTRA.duplicate(true)
	default_data["DATA_DOOR"] = DATA_DOOR.duplicate(true)
	default_data["DATA_TRAP"] = DATA_TRAP.duplicate(true)
	default_data["DATA_EFFECTGEN"] = DATA_EFFECTGEN.duplicate(true)
	default_data["DATA_CREATURE"] = DATA_CREATURE.duplicate(true)
	default_data["DATA_OBJECT"] = DATA_OBJECT.duplicate(true)
	default_data["LIST_OF_BOXES"] = LIST_OF_BOXES.duplicate(true)

func reset_thing_data_to_default(): # Reset data. Takes 1ms.
	DATA_EXTRA = default_data["DATA_EXTRA"].duplicate(true)
	DATA_DOOR = default_data["DATA_DOOR"].duplicate(true)
	DATA_TRAP = default_data["DATA_TRAP"].duplicate(true)
	DATA_EFFECTGEN = default_data["DATA_EFFECTGEN"].duplicate(true)
	DATA_CREATURE = default_data["DATA_CREATURE"].duplicate(true)
	DATA_OBJECT = default_data["DATA_OBJECT"].duplicate(true)
	LIST_OF_BOXES = default_data["LIST_OF_BOXES"].duplicate(true)

func fetch_sprite(thing_type:int, sub_type:int):
	var sub_type_data = data_structure(thing_type).get(sub_type)
	if sub_type_data:
		var sprite = Graphics.sprite_id.get(sub_type_data[SPRITE])
		if sprite:
			return sprite
		match sub_type_data[EDITOR_TAB]:
			TAB_SPECIAL: return Graphics.sprite_id.get(901, null)
			TAB_SPELL:   return Graphics.sprite_id.get(777, null)
			TAB_BOX:     return Graphics.sprite_id.get(114, null)
	return null


func fetch_portrait(thing_type, sub_type):
	var sub_type_data = data_structure(thing_type).get(sub_type)
	if sub_type_data:
		var sprID = sub_type_data[SPRITE]
		var asdf = str(sprID) + "_PORTRAIT"
		return Graphics.sprite_id.get(asdf, null)
	return null


func fetch_name(thing_type, sub_type):
	var dictionary_of_names = Names.things.get(thing_type)
	if dictionary_of_names:
		var data_structure = data_structure(thing_type)
		var sub_type_data = data_structure.get(sub_type)
		if sub_type_data:
			var nameId = sub_type_data[NAME_ID]
			if nameId is String:
				return dictionary_of_names.get(nameId, nameId.capitalize())
			elif nameId is Array: # This is to take into considersation someone accidentally using two words with spaces as an object name. (otherwise we get a crash)
				return dictionary_of_names.get(nameId[0], nameId[0].capitalize())
			return "Error1337"
		else:
			return "Unknown " + data_structure_name[thing_type] + ": " + str(sub_type)
	else:
		return "Unknown Thingtype " + str(thing_type) + ", Subtype: " + str(sub_type)

func fetch_id_string(thing_type, sub_type):
	var data_structure = data_structure(thing_type)
	var sub_type_data = data_structure.get(sub_type)
	if sub_type_data:
		var nameId = sub_type_data[NAME_ID]
		if nameId is String:
			return nameId
		elif nameId is Array: # This is to take into considersation someone accidentally using two words with spaces as an object name. (otherwise we get a crash)
			return nameId[0].capitalize()
		return "Error1337"
	else:
		return "Unknown " + data_structure_name.get(thing_type, "Unknown") + ": " + str(sub_type)


var data_structure_name = {
	TYPE.NONE: "Empty",
	TYPE.OBJECT: "Object",
	TYPE.SHOT: "Shot",
	TYPE.EFFECTELEM: "EffectElem",
	TYPE.DEADCREATURE: "DeadCreature",
	TYPE.CREATURE: "Creature",
	TYPE.EFFECT: "Effect",
	TYPE.EFFECTGEN: "EffectGen",
	TYPE.TRAP: "Trap",
	TYPE.DOOR: "Door",
	TYPE.UNKN10: "Unkn10",
	TYPE.UNKN11: "Unkn11",
	TYPE.AMBIENTSND: "AmbientSnd",
	TYPE.CAVEIN: "CaveIn",
	TYPE.EXTRA: "Extra"
}


var reverse_data_structure_name = {
	"Empty": TYPE.NONE,
	"Object":TYPE.OBJECT,
	"Shot":TYPE.SHOT,
	"EffectElem":TYPE.EFFECTELEM,
	"DeadCreature":TYPE.DEADCREATURE,
	"Creature":TYPE.CREATURE,
	"Effect":TYPE.EFFECT,
	"EffectGen":TYPE.EFFECTGEN,
	"Trap":TYPE.TRAP,
	"Door":TYPE.DOOR,
	"Unkn10":TYPE.UNKN10,
	"Unkn11":TYPE.UNKN11,
	"AmbientSnd":TYPE.AMBIENTSND,
	"CaveIn":TYPE.CAVEIN,
	"Extra":TYPE.EXTRA,
}


enum { # I only used the official DK keeperfx categories as a guide rather than strict adherence. What strict adherence gets you is all the egg objects classified as Furniture, while Chicken sits alone in its own Food category.
	TAB_ACTION
	TAB_CREATURE
	TAB_GOLD
	TAB_TRAP
	TAB_SPELL
	TAB_SPECIAL
	TAB_BOX
	TAB_LAIR
	TAB_EFFECTGEN
	TAB_FURNITURE
	TAB_DECORATION
	TAB_MISC
}


var GENRE_TO_TAB = {
	"DECORATION": TAB_DECORATION,
	"EFFECT": TAB_EFFECTGEN,
	"FOOD": TAB_FURNITURE,
	"FURNITURE": TAB_FURNITURE,
	"LAIR_TOTEM": TAB_LAIR,
	"POWER": TAB_MISC,
	"SPECIALBOX": TAB_SPECIAL,
	"SPELLBOOK": TAB_SPELL,
	"TREASURE_HOARD": TAB_GOLD,
	"VALUABLE": TAB_GOLD,
	"WORKSHOPBOX": TAB_BOX,
	"HEROGATE": TAB_ACTION,
}


func data_structure(thingType:int):
	match thingType:
		Things.TYPE.OBJECT: return DATA_OBJECT
		Things.TYPE.CREATURE: return DATA_CREATURE
		Things.TYPE.EFFECTGEN: return DATA_EFFECTGEN
		Things.TYPE.TRAP: return DATA_TRAP
		Things.TYPE.DOOR: return DATA_DOOR
		Things.TYPE.EXTRA: return DATA_EXTRA
	print("This should never happen.")
	return {}


var LIST_OF_BOXES = {
"WRKBOX_BOULDER" : [TYPE.TRAP, 1],
"WRKBOX_ALARM" : [TYPE.TRAP, 2],
"WRKBOX_POISONG" : [TYPE.TRAP, 3],
"WRKBOX_LIGHTNG" : [TYPE.TRAP, 4],
"WRKBOX_WRDOFPW" : [TYPE.TRAP, 5],
"WRKBOX_LAVA" : [TYPE.TRAP, 6],
"WRKBOX_WOOD" : [TYPE.DOOR, 1],
"WRKBOX_BRACE" : [TYPE.DOOR, 2],
"WRKBOX_STEEL" : [TYPE.DOOR, 3],
"WRKBOX_MAGIC" : [TYPE.DOOR, 4],
}



var LIST_OF_GOLDPILES = [
	3, 6, 43, 128, 136
]


var LIST_OF_SPELLBOOKS = [ ]
var LIST_OF_HEROGATES = [ ]

enum SPELLBOOK {
	HAND = 11
	SLAP = 14
	POSSESS = 135
	IMP = 12
	SIGHT = 15
	SPEED = 21
	OBEY = 13
	CALL_TO_ARMS = 16
	CONCEAL = 23
	HOLD_AUDIENCE = 19
	CAVE_IN = 17
	HEAL_CREATURE = 18
	LIGHTNING = 20
	PROTECT = 22
	CHICKEN = 46
	DISEASE = 45
	ARMAGEDDON = 134
	DESTROY_WALLS = 47
}

var collectible_belonging = {
	TAB_GOLD : Slabs.TREASURE_ROOM,
	TAB_SPELL : Slabs.LIBRARY,
	TAB_SPECIAL : Slabs.LIBRARY,
	TAB_BOX : Slabs.WORKSHOP,
}

func convert_relative_256_to_float(datnum):
	if datnum >= 32768: # If the sign bit is set (indicating a negative value)
		datnum -= 65536 # Convert to signed by subtracting 2^16
	return datnum / 256.0 # Scale it to floating-point


func find_subtype_by_name(thingType, findName):
	var data = data_structure(thingType)
	for subtype_key in data:
		var subtype_data = data[subtype_key]
		if subtype_data and subtype_data[NAME_ID] == findName:
			return subtype_key
	return null

var DATA_EXTRA = {
0 : [null, null, null, null],
1 : ["ACTIONPOINT", "ACTIONPOINT", TAB_ACTION],
2 : ["LIGHT", "LIGHT", TAB_EFFECTGEN],
}

var DATA_DOOR = { #
0 : [null, null, null],
1 : ["WOOD", "WOOD" , TAB_MISC],
2 : ["BRACED", "BRACED", TAB_MISC],
3 : ["STEEL", "STEEL", TAB_MISC],
4 : ["MAGIC", "MAGIC", TAB_MISC]
}

var DATA_TRAP = {
00 : [null, null, null],
01 : ["BOULDER", "BOULDER", TAB_TRAP],
02 : ["ALARM", "ALARM", TAB_TRAP],
03 : ["POISON_GAS", "POISON_GAS", TAB_TRAP],
04 : ["LIGHTNING", "LIGHTNING", TAB_TRAP],
05 : ["WORD_OF_POWER", "WORD_OF_POWER", TAB_TRAP],
06 : ["LAVA", "LAVA", TAB_TRAP],
}

var DATA_EFFECTGEN = {
0 : [null, null, null],
1 : ["EFFECTGENERATOR_LAVA", "EFFECTGENERATOR_LAVA", TAB_EFFECTGEN],
2 : ["EFFECTGENERATOR_DRIPPING_WATER", "EFFECTGENERATOR_DRIPPING_WATER", TAB_EFFECTGEN],
3 : ["EFFECTGENERATOR_ROCK_FALL", "EFFECTGENERATOR_ROCK_FALL", TAB_EFFECTGEN],
4 : ["EFFECTGENERATOR_ENTRANCE_ICE", "EFFECTGENERATOR_ENTRANCE_ICE", TAB_EFFECTGEN],
5 : ["EFFECTGENERATOR_DRY_ICE", "EFFECTGENERATOR_DRY_ICE", TAB_EFFECTGEN]
}

var DATA_CREATURE = {
00 : [null, null, null],
01 : ["WIZARD",          "WIZARD", TAB_CREATURE],
02 : ["BARBARIAN",       "BARBARIAN", TAB_CREATURE],
03 : ["ARCHER",          "ARCHER", TAB_CREATURE],
04 : ["MONK",            "MONK",  TAB_CREATURE],
05 : ["DWARFA",          "DWARFA", TAB_CREATURE],
06 : ["KNIGHT",          "KNIGHT", TAB_CREATURE],
07 : ["AVATAR",          "AVATAR", TAB_CREATURE],
08 : ["TUNNELLER",       "TUNNELLER", TAB_CREATURE],
09 : ["WITCH",           "WITCH", TAB_CREATURE],
10 : ["GIANT",           "GIANT", TAB_CREATURE],
11 : ["FAIRY",           "FAIRY", TAB_CREATURE],
12 : ["THIEF",           "THIEF", TAB_CREATURE],
13 : ["SAMURAI",         "SAMURAI", TAB_CREATURE],
14 : ["HORNY",           "HORNY", TAB_CREATURE],
15 : ["SKELETON",        "SKELETON", TAB_CREATURE],
16 : ["TROLL",           "TROLL", TAB_CREATURE],
17 : ["DRAGON",          "DRAGON", TAB_CREATURE],
18 : ["DEMONSPAWN",      "DEMONSPAWN", TAB_CREATURE],
19 : ["FLY",             "FLY",   TAB_CREATURE],
20 : ["DARK_MISTRESS",   "DARK_MISTRESS", TAB_CREATURE],
21 : ["SORCEROR",        "SORCEROR", TAB_CREATURE],
22 : ["BILE_DEMON",      "BILE_DEMON", TAB_CREATURE],
23 : ["IMP",             "IMP",   TAB_CREATURE],
24 : ["BUG",             "BUG",   TAB_CREATURE],
25 : ["VAMPIRE",         "VAMPIRE", TAB_CREATURE],
26 : ["SPIDER",          "SPIDER", TAB_CREATURE],
27 : ["HELL_HOUND",      "HELL_HOUND", TAB_CREATURE],
28 : ["GHOST",           "GHOST", TAB_CREATURE],
29 : ["TENTACLE",        "TENTACLE", TAB_CREATURE],
30 : ["ORC",             "ORC",   TAB_CREATURE],
31 : ["FLOATING_SPIRIT", "FLOATING_SPIRIT", TAB_CREATURE],
}

var DATA_OBJECT = {
000 : [null, null, null],
001 : ["BARREL", 930, TAB_DECORATION],
002 : ["TORCH", 962, TAB_DECORATION], #TAB_FURNITURE
003 : ["GOLD_CHEST", 934, TAB_GOLD],
004 : ["TEMPLE_STATUE", 950, TAB_DECORATION], #TAB_FURNITURE
005 : ["SOUL_CONTAINER", 948, TAB_FURNITURE],
006 : ["GOLD", 934, TAB_GOLD],
007 : ["TORCHUN", 962, TAB_DECORATION], #TAB_FURNITURE
008 : ["STATUEWO", 950, TAB_DECORATION], #Lit Statue No Flame # Partially Lit Statue
009 : ["CHICKEN_GRW", 893, TAB_MISC],
010 : ["CHICKEN_MAT", 819, TAB_MISC],
011 : ["SPELLBOOK_HOE", "SPELLBOOK_HOE", TAB_SPELL],
012 : ["SPELLBOOK_IMP", "SPELLBOOK_IMP", TAB_SPELL],
013 : ["SPELLBOOK_OBEY", "SPELLBOOK_OBEY", TAB_SPELL],
014 : ["SPELLBOOK_SLAP", "SPELLBOOK_SLAP", TAB_SPELL],
015 : ["SPELLBOOK_SOE", "SPELLBOOK_SOE", TAB_SPELL],
016 : ["SPELLBOOK_CTA", "SPELLBOOK_CTA", TAB_SPELL],
017 : ["SPELLBOOK_CAVI", "SPELLBOOK_CAVI", TAB_SPELL],
018 : ["SPELLBOOK_HEAL", "SPELLBOOK_HEAL", TAB_SPELL],
019 : ["SPELLBOOK_HLDAUD", "SPELLBOOK_HLDAUD", TAB_SPELL],
020 : ["SPELLBOOK_LIGHTN", "SPELLBOOK_LIGHTN", TAB_SPELL],
021 : ["SPELLBOOK_SPDC", "SPELLBOOK_SPDC", TAB_SPELL],
022 : ["SPELLBOOK_PROT", "SPELLBOOK_PROT", TAB_SPELL],
023 : ["SPELLBOOK_CONCL", "SPELLBOOK_CONCL", TAB_SPELL],
024 : ["CTA_ENSIGN", null, TAB_MISC],
025 : ["ROOM_FLAG", null, TAB_MISC],
026 : ["ANVIL", 789, TAB_FURNITURE],
027 : ["PRISON_BAR", 796, TAB_FURNITURE],
028 : ["CANDLESTCK", 791, TAB_DECORATION], #TAB_FURNITURE
029 : ["GRAVE_STONE", 793, TAB_FURNITURE],
030 : ["STATUE_HORNY", 905, TAB_DECORATION], #TAB_FURNITURE
031 : ["TRAINING_POST", 795, TAB_FURNITURE],
032 : ["TORTURE_SPIKE", 892, TAB_FURNITURE],
033 : ["TEMPLE_SPANGLE", 797, TAB_DECORATION],
034 : ["POTION_PURPLE", 804, TAB_DECORATION],
035 : ["POTION_BLUE", 806, TAB_DECORATION],
036 : ["POTION_GREEN", 808, TAB_DECORATION],
037 : ["POWER_HAND", 782, TAB_MISC],
038 : ["POWER_HAND_GRAB", 783, TAB_MISC],
039 : ["POWER_HAND_WHIP", 785, TAB_MISC],
040 : ["CHICKEN_STB", 894, TAB_MISC],
041 : ["CHICKEN_WOB", 895, TAB_MISC],
042 : ["CHICKEN_CRK", 896, TAB_MISC],
043 : ["GOLDL", 936, TAB_GOLD],
044 : ["SPINNING_KEY", 810, TAB_MISC],
045 : ["SPELLBOOK_DISEASE", "SPELLBOOK_DISEASE", TAB_SPELL],
046 : ["SPELLBOOK_CHKN", "SPELLBOOK_CHKN", TAB_SPELL],
047 : ["SPELLBOOK_DWAL", "SPELLBOOK_DWAL", TAB_SPELL],
048 : ["SPELLBOOK_TBMB", "SPELLBOOK_TBMB", TAB_SPELL],
049 : ["HERO_GATE", 776, TAB_ACTION],
050 : ["SPINNING_KEY2", 810, TAB_MISC],
051 : ["ARMOUR", null, TAB_MISC],
052 : ["GOLD_HOARD_1", 936, TAB_GOLD],
053 : ["GOLD_HOARD_2", 937, TAB_GOLD],
054 : ["GOLD_HOARD_3", 938, TAB_GOLD],
055 : ["GOLD_HOARD_4", 939, TAB_GOLD],
056 : ["GOLD_HOARD_5", 940, TAB_GOLD],
057 : ["LAIR_WIZRD", 124, TAB_LAIR],
058 : ["LAIR_BARBR", 124, TAB_LAIR],
059 : ["LAIR_ARCHR", 124, TAB_LAIR],
060 : ["LAIR_MONK", 124, TAB_LAIR],
061 : ["LAIR_DWRFA", 124, TAB_LAIR],
062 : ["LAIR_KNGHT", 124, TAB_LAIR],
063 : ["LAIR_AVATR", 124, TAB_LAIR],
064 : ["LAIR_TUNLR", 124, TAB_LAIR],
065 : ["LAIR_WITCH", 124, TAB_LAIR],
066 : ["LAIR_GIANT", 124, TAB_LAIR],
067 : ["LAIR_FAIRY", 124, TAB_LAIR],
068 : ["LAIR_THIEF", 124, TAB_LAIR],
069 : ["LAIR_SAMUR", 124, TAB_LAIR],
070 : ["LAIR_HORNY", 158, TAB_LAIR],
071 : ["LAIR_SKELT", 156, TAB_LAIR],
072 : ["LAIR_GOBLN", 154, TAB_LAIR],
073 : ["LAIR_DRAGN", 152, TAB_LAIR],
074 : ["LAIR_DEMSP", 150, TAB_LAIR],
075 : ["LAIR_FLY", 148, TAB_LAIR],
076 : ["LAIR_DKMIS", 146, TAB_LAIR],
077 : ["LAIR_SORCR", 144, TAB_LAIR],
078 : ["LAIR_BILDM", 142, TAB_LAIR],
079 : ["LAIR_IMP", 152, TAB_LAIR],
080 : ["LAIR_BUG", 140, TAB_LAIR],
081 : ["LAIR_VAMP", 138, TAB_LAIR],
082 : ["LAIR_SPIDR", 136, TAB_LAIR],
083 : ["LAIR_HLHND", 134, TAB_LAIR],
084 : ["LAIR_GHOST", 132, TAB_LAIR],
085 : ["LAIR_TENTC", 128, TAB_LAIR],
086 : ["SPECBOX_REVMAP", 901, TAB_SPECIAL],
087 : ["SPECBOX_RESURCT", 901, TAB_SPECIAL],
088 : ["SPECBOX_TRANSFR", 901, TAB_SPECIAL],
089 : ["SPECBOX_STEALHR", 901, TAB_SPECIAL],
090 : ["SPECBOX_MULTPLY", 901, TAB_SPECIAL],
091 : ["SPECBOX_INCLEV", 901, TAB_SPECIAL],
092 : ["SPECBOX_MKSAFE", 901, TAB_SPECIAL],
093 : ["SPECBOX_HIDNWRL", 901, TAB_SPECIAL],
094 : ["WRKBOX_BOULDER", 114, TAB_BOX],
095 : ["WRKBOX_ALARM", 114, TAB_BOX],
096 : ["WRKBOX_POISONG", 114, TAB_BOX],
097 : ["WRKBOX_LIGHTNG", 114, TAB_BOX],
098 : ["WRKBOX_WRDOFPW", 114, TAB_BOX],
099 : ["WRKBOX_LAVA", 114, TAB_BOX],
100 : ["WRKBOX_DEMOLTN", 114, TAB_BOX],
101 : ["WRKBOX_DUMMY3", 114, TAB_BOX],
102 : ["WRKBOX_DUMMY4", 114, TAB_BOX],
103 : ["WRKBOX_DUMMY5", 114, TAB_BOX],
104 : ["WRKBOX_DUMMY6", 114, TAB_BOX],
105 : ["WRKBOX_DUMMY7", 114, TAB_BOX],
106 : ["WRKBOX_WOOD", 114, TAB_BOX],
107 : ["WRKBOX_BRACE", 114, TAB_BOX],
108 : ["WRKBOX_STEEL", 114, TAB_BOX],
109 : ["WRKBOX_MAGIC", 114, TAB_BOX],
110 : ["WRKBOX_ITEM", 789, TAB_MISC],
111 : ["HEARTFLAME_RED", 798, TAB_FURNITURE],
112 : ["DISEASE", null, TAB_MISC],
113 : ["SCAVENGE_EYE", 130, TAB_FURNITURE],
114 : ["WORKSHOP_MACHINE", 98, TAB_FURNITURE],
115 : ["GUARDFLAG_RED", 102, TAB_FURNITURE],
116 : ["GUARDFLAG_BLUE", 104, TAB_FURNITURE],
117 : ["GUARDFLAG_GREEN", 106, TAB_FURNITURE],
118 : ["GUARDFLAG_YELLOW", 108, TAB_FURNITURE],
119 : ["FLAG_POST", 100, TAB_FURNITURE],
120 : ["HEARTFLAME_BLUE", 799, TAB_FURNITURE],
121 : ["HEARTFLAME_GREEN", 800, TAB_FURNITURE],
122 : ["HEARTFLAME_YELLOW", 801, TAB_FURNITURE],
123 : ["POWER_SIGHT", "POWER_SIGHT", TAB_MISC],
124 : ["POWER_LIGHTNG", null, TAB_MISC],
125 : ["TORTURER", 46, TAB_FURNITURE],
126 : ["LAIR_ORC", 126, TAB_LAIR],
127 : ["POWER_HAND_GOLD", 781, TAB_MISC],
128 : ["SPINNCOIN", null, TAB_MISC],
129 : ["STATUE2", 952, TAB_DECORATION],
130 : ["STATUE3", "GOLDEN_ARMOR", TAB_DECORATION],
131 : ["STATUE4", "KNIGHTSTATUE", TAB_DECORATION],
132 : ["STATUE5", 958, TAB_DECORATION],
133 : ["SPECBOX_CUSTOM", 901, TAB_SPECIAL],
134 : ["SPELLBOOK_ARMG", "SPELLBOOK_ARMG", TAB_SPELL],
135 : ["SPELLBOOK_POSS", "SPELLBOOK_POSS", TAB_SPELL],
}
