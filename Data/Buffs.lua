local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
EasyBuff = E:GetModule("EasyBuff");


--[[
	Aura Groups
	Used to define/access shared information about an Aura
]]--
local EasyBuff_AuraGroups = {
	-- Druid
	MOTW = {
		class 	 = "Druid",
		name     = "Mark of the Wild",
		selfOnly = false,
		multi 	 = "Gift of the Wild"
	},
	Thorns = {
		class 	 = "Druid",
		name     = "Thorns",
		selfOnly = false,
		multi 	 = nil
	},
	OOC = {
		class 	 = "Druid",
		name     = "Omen of Clarity",
		selfOnly = true,
		multi 	 = nil
	},
	-- Hunter
	TSA = {
		class 	 = "Hunter",
		name     = "Trueshot Aura",
		selfOnly = true,
		multi 	 = nil
	},
	AOTH = {
		class 	 = "Hunter",
		name     = "Aspect of the Hawk",
		selfOnly = true,
		multi 	 = nil
	},
	AOTM = {
		class 	 = "Hunter",
		multi 	 = nil,
		name     = "Aspect of the Monkey",
		selfOnly = true,
		multi 	 = nil
	},
	AOTW = {
		class 	 = "Hunter",
		name     = "Aspect of the Wild",
		selfOnly = true,
		multi 	 = nil
	},
	AOTB = {
		class 	 = "Hunter",
		name     = "Aspect of the Beast",
		selfOnly = true,
		multi 	 = nil
	},
	AOTC = {
		class 	 = "Hunter",
		name     = "Aspect of the Cheetah",
		selfOnly = true,
		multi 	 = nil
	},
	AOTP = {
		class 	 = "Hunter",
		name     = "Aspect of the Pack",
		selfOnly = true,
		multi 	 = nil
	},
	-- Mage
	AI = {
		class 	 = "Mage",
		name     = "Arcane Intellect",
		selfOnly = false,
		multi 	 = "Arcane Brilliance"
	},
	-- Paladin
	BOM = {
		class 	 = "Paladin",
		name     = "Blessing of Might",
		selfOnly = false,
		multi 	 = "Greater Blessing of Might"
	},
	BOW = {
		class 	 = "Paladin",
		name     = "Blessing of Wisdom",
		selfOnly = false,
		multi 	 = "Greater Blessing of Wisdom",
	},
	BOSLV = {
		class 	 = "Paladin",
		name     = "Blessing of Salvation",
		selfOnly = false,
		multi 	 = "Greater Blessing of Salvation"
	},
	BOK = {
		class 	 = "Paladin",
		name     = "Blessing of Kings",
		selfOnly = false,
		multi 	 = "Greater Blessing of Kings"
	},
	BOSNC = {
		class 	 = "Paladin",
		name     = "Blessing of Sanctuary",
		selfOnly = false,
		multi 	 = "Greater Blessing of Sanctuary"
	},
	BOL = {
		class 	 = "Paladin",
		name     = "Blessing of Light",
		selfOnly = false,
		multi 	 = "Greater Blessing of Light"
	},
	-- Priest
	FORT = {
		class 	 = "Priest",
		name     = "Power Word: Fortitude",
		selfOnly = false,
		multi 	 = "Prayer of Fortitude"
	},
	SP = {
		class 	 = "Priest",
		name     = "Shadow Protection",
		selfOnly = false,
		multi    = "Greater Shadow Protection"
	}
	-- Rogue
	-- Shaman
	-- Warlock
	-- Warrior
};


--[[
	Auras
	Used to define an Aura by SpellID
]]--
local EasyBuff_Auras = {
	-- Mark of the Wild
	["1126"] = {
		rank  = 1,
		group = "MOTW"
	},
	["5232"] = {
		rank  = 2,
		group = "MOTW"
	},
	["6756"] = {
		rank  = 3,
		group = "MOTW"
	},
	["5234"] = {
		rank  = 4,
		group = "MOTW"
	},
	["8907"] = {
		rank  = 5,
		group = "MOTW"
	},
	["9884"] = {
		rank  = 6,
		group = "MOTW"
	},
	["9885"] = {
		rank  = 7,
		group = "MOTW"
	},
	-- Gift of the Wild
	["21849"] = {
		rank  = 1,
		group = "MOTW",
		multi = true
	},
	["21850"] = {
		rank  = 2,
		group = "MOTW",
		multi = true
	},
	-- Thorns
	["467"] = {
		rank  = 1,
		group = "Thorns"
	},
	["782"] = {
		rank  = 2,
		group = "Thorns"
	},
	["1075"] = {
		rank  = 3,
		group = "Thorns"
	},
	["8914"] = {
		rank  = 4,
		group = "Thorns"
	},
	["9756"] = {
		rank  = 5,
		group = "Thorns"
	},
	["9910"] = {
		rank  = 6,
		group = "Thorns"
	},
	-- Omen of Clarity
	["16864"] = {
		rank = 1,
		group = "OOC"
	}
};


--[[
	Get Aura Groups for Class
]]--
function EasyBuff:GetClassAuraGroups(className)
	local auras = {};
	for k, v in pairs(EasyBuff_AuraGroups) do
		if (v.class == className) then
			auras[k] = v;
		end
	end

	return auras;
end


--[[
	Get Tracked Spells
]]--
function EasyBuff:GetTrackedSpells()
	return EasyBuff_Auras;
end


--[[
	Get Aura Group by Index
]]--
function EasyBuff:GetAuraGroup(index)
	return EasyBuff_AuraGroups[index];
end


--[[
	Get Aura Group by Spell Id
]]--
function EasyBuff:GetAuraGroupBySpellId(spellId)
	local aura = EasyBuff_Auras[tostring(spellId)];
	if (aura ~= nil) then
		return aura.group, EasyBuff_AuraGroups[aura.group];
	end
	return nil, nil;
end