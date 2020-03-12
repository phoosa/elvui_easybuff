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
	IceArmor = {
		class 	 = "Mage",
		name     = "Ice Armor",
		selfOnly = true,
		multi 	 = nil
	},
	FrostArmor = {
		class 	 = "Mage",
		name     = "Frost Armor",
		selfOnly = true,
		multi 	 = nil
	},
	MageArmor = {
		class 	 = "Mage",
		name     = "Mage Armor",
		selfOnly = true,
		multi 	 = nil
	},
	IceBarrier = {
		class 	 = "Mage",
		name     = "Ice Barrier",
		selfOnly = true,
		multi 	 = nil
	},
	FrostWard = {
		class 	 = "Mage",
		name     = "Frost Ward",
		selfOnly = true,
		multi 	 = nil
	},
	FireWard = {
		class 	 = "Mage",
		name     = "Fire Ward",
		selfOnly = true,
		multi 	 = nil
	},
	ManaShield = {
		class 	 = "Mage",
		name     = "Mana Shield",
		selfOnly = true,
		multi 	 = nil
	},
	DampenMagic = {
		class 	 = "Mage",
		name     = "Dampen Magic",
		selfOnly = true,
		multi 	 = nil
	},
	AmplifyMagic = {
		class 	 = "Mage",
		name     = "Amplify Magic",
		selfOnly = true,
		multi 	 = nil
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
	-- Druid: Mark of the Wild
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
	-- Druid: Gift of the Wild
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
	-- Druid: Thorns
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
	-- Druid: Omen of Clarity
	["16864"] = {
		rank = 1,
		group = "OOC"
	},
	-- Mage: Arcane Intellect
	["1459"] = {
		rank  = 1,
		group = "AI"
	},
	["1460"] = {
		rank  = 2,
		group = "AI"
	},
	["1461"] = {
		rank  = 3,
		group = "AI"
	},
	["10156"] = {
		rank  = 4,
		group = "AI"
	},
	["10157"] = {
		rank  = 5,
		group = "AI"
	},
	-- Mage: Arcane Brilliance
	["23028"] = {
		rank  = 1,
		group = "AI",
		multi = true
	},
	-- Mage: Ice Armor
	["7302"] = {
		rank  = 1,
		group = "IceArmor"
	},
	["7320"] = {
		rank  = 2,
		group = "IceArmor"
	},
	["10219"] = {
		rank  = 3,
		group = "IceArmor"
	},
	["10220"] = {
		rank  = 4,
		group = "IceArmor"
	},
	-- Mage: Frost Armor
	["168"] = {
		rank  = 1,
		group = "FrostArmor"
	},
	["7300"] = {
		rank  = 2,
		group = "FrostArmor"
	},
	["7301"] = {
		rank  = 3,
		group = "FrostArmor"
	},
	-- Mage: Mage Armor
	["6117"] = {
		rank  = 1,
		group = "MageArmor"
	},
	["22782"] = {
		rank  = 2,
		group = "DampMageArmorenMagic"
	},
	["22783"] = {
		rank  = 3,
		group = "MageArmor"
	},
	-- Mage: Ice Barrier
	["11426"] = {
		rank  = 1,
		group = "IceBarrier"
	},
	["13031"] = {
		rank  = 2,
		group = "IceBarrier"
	},
	["13032"] = {
		rank  = 3,
		group = "IceBarrier"
	},
	["13033"] = {
		rank  = 4,
		group = "IceBarrier"
	},
	-- Mage: Frost Ward
	["6143"] = {
		rank  = 1,
		group = "FrostWard"
	},
	["8461"] = {
		rank  = 2,
		group = "FrostWard"
	},
	["8462"] = {
		rank  = 3,
		group = "FrostWard"
	},
	["10177"] = {
		rank  = 4,
		group = "FrostWard"
	},
	-- Mage: Fire Ward
	["543"] = {
		rank  = 1,
		group = "FireWard"
	},
	["8457"] = {
		rank  = 2,
		group = "FireWard"
	},
	["8458"] = {
		rank  = 3,
		group = "FireWard"
	},
	["10223"] = {
		rank  = 4,
		group = "FireWard"
	},
	["10225"] = {
		rank  = 5,
		group = "FireWard"
	},
	-- Mage: Mana Shield
	["1463"] = {
		rank  = 1,
		group = "ManaShield"
	},
	["8494"] = {
		rank  = 2,
		group = "ManaShield"
	},
	["8495"] = {
		rank  = 3,
		group = "ManaShield"
	},
	["10191"] = {
		rank  = 4,
		group = "ManaShield"
	},
	["10192"] = {
		rank  = 5,
		group = "ManaShield"
	},
	["10193"] = {
		rank  = 6,
		group = "ManaShield"
	},
	-- Mage: Dampen Magic
	["604"] = {
		rank  = 1,
		group = "DampenMagic"
	},
	["8450"] = {
		rank  = 2,
		group = "DampenMagic"
	},
	["8451"] = {
		rank  = 3,
		group = "DampenMagic"
	},
	["10173"] = {
		rank  = 4,
		group = "DampenMagic"
	},
	["10174"] = {
		rank  = 5,
		group = "DampenMagic"
	},
	-- Mage: Amplify Magic
	["1008"] = {
		rank  = 1,
		group = "AmplifyMagic"
	},
	["8455"] = {
		rank  = 2,
		group = "AmplifyMagic"
	},
	["10169"] = {
		rank  = 3,
		group = "AmplifyMagic"
	},
	["10170"] = {
		rank  = 4,
		group = "AmplifyMagic"
	},
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