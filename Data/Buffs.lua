local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
EasyBuff = E:GetModule("EasyBuff");

-- Castable_AuraGroups
-- Spells that I can cast, keyed by Group
-- ids and multi ids are keyed by rank
-- Foo = {ids={1=21,2=23,3=764}},multiIds={1=42,2=191},hasMulti=true}
local Castable_AuraGroups = {};
-- Trackable_Auras
-- Spells that my class can cast, keyed by ID
-- {ids={1,23,764}},multiIds={42,191}}
-- 23 = {group="ABC",multi=false,name="Foo",rank=1}
local Trackable_Auras = nil;


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
	},
	InnerFire = {
		class 	 = "Priest",
		name     = "Inner Fire",
		selfOnly = true,
		multi 	 = nil
	},
	-- Rogue
	-- Shaman
	-- Warlock
	DemonArmor = {
		class 	 = "Warlock",
		name	 = "Demon Armor",
		selfOnly = true,
		multi	 = nil
	},
	ShadowWard = {
		class 	 = "Warlock",
		name	 = "Shadow Ward",
		selfOnly = true,
		multi	 = nil
	},
	DetectInvis = {
		class	 = "Warlock",
		name	 = "Detect Invisibility",
		selfOnly = false,
		multi    = nil
	},
	UnendingBreath = {
		class 	 = "Warlock",
		name	 = "Unending Breath",
		selfOnly = false,
		multi    = nil
	}
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
	-- Hunter: Trueshot Aura
	["19506"] = {
		rank  = 1,
		group = "TSA"
	},
	["20905"] = {
		rank  = 2,
		group = "TSA"
	},
	["20906"] = {
		rank  = 3,
		group = "TSA"
	},
	-- Hunter: Aspect of the Hawk
	["13165"] = {
		rank  = 1,
		group = "AOTH"
	},
	["14318"] = {
		rank  = 2,
		group = "AOTH"
	},
	["14319"] = {
		rank  = 3,
		group = "AOTH"
	},
	["14320"] = {
		rank  = 4,
		group = "AOTH"
	},
	["14321"] = {
		rank  = 5,
		group = "AOTH"
	},
	["14322"] = {
		rank  = 6,
		group = "AOTH"
	},
	["25296"] = {
		rank  = 7,
		group = "AOTH"
	},
	-- Hunter: Aspect of the Monkey
	["13163"] = {
		rank  = 1,
		group = "AOTM"
	},
	-- Hunter: Improved Aspect of the Monkey
	["19549"] = {
		rank  = 2,
		group = "AOTM"
	},
	["19550"] = {
		rank  = 3,
		group = "AOTM"
	},
	["19551"] = {
		rank  = 4,
		group = "AOTM"
	},
	["24386"] = {
		rank  = 5,
		group = "AOTM"
	},
	["24387"] = {
		rank  = 6,
		group = "AOTM"
	},
	-- Hunter: Aspect of the Wild
	["20043"] = {
		rank  = 1,
		group = "AOTW"
	},
	["20190"] = {
		rank  = 2,
		group = "AOTW"
	},
	-- Hunter: Aspect of the Cheetah
	["5118"] = {
		rank  = 1,
		group = "AOTC"
	},
	-- Hunter: Aspect of the Pack
	["13159"] = {
		rank  = 1,
		group = "AOTP"
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
	-- Paladin: Blessing of Might
	["19740"] = {
		rank  = 1,
		group = "BOM"
	},
	["19834"] = {
		rank  = 2,
		group = "BOM"
	},
	["19835"] = {
		rank  = 3,
		group = "BOM"
	},
	["19836"] = {
		rank  = 4,
		group = "BOM"
	},
	["19837"] = {
		rank  = 5,
		group = "BOM"
	},
	["19838"] = {
		rank  = 6,
		group = "BOM"
	},
	["25291"] = {
		rank  = 7,
		group = "BOM"
	},
	-- Paladin: Greater Blessing of Might
	["25782"] = {
		rank  = 1,
		group = "BOM",
		multi = true
	},
	["25916"] = {
		rank  = 2,
		group = "BOM",
		multi = true
	},
	-- Paladin: Blessing of Wisdom
	["19742"] = {
		rank  = 1,
		group = "BOW"
	},
	["19850"] = {
		rank  = 2,
		group = "BOW"
	},
	["19852"] = {
		rank  = 3,
		group = "BOW"
	},
	["19853"] = {
		rank  = 4,
		group = "BOW"
	},
	["19854"] = {
		rank  = 5,
		group = "BOW"
	},
	["25290"] = {
		rank  = 6,
		group = "BOW"
	},
	-- Paladin: Greater Blessing of Wisdom
	["25894"] = {
		rank  = 1,
		group = "BOW",
		multi = true
	},
	["25918"] = {
		rank  = 2,
		group = "BOW",
		multi = true
	},
	-- Paladin: Blessing of Salvation
	["1038"] = {
		rank  = 1,
		group = "BOSLV"
	},
	-- Paladin: Greater Blessing of Salvation
	["25895"] = {
		rank  = 1,
		group = "BOSLV",
		multi = true
	},
	-- Paladin: Blessing of Kings
	["20217"] = {
		rank  = 1,
		group = "BOSLV"
	},
	-- Paladin: Greater Blessing of Kings
	["25898"] = {
		rank  = 1,
		group = "BOK",
		multi = true
	},
	-- Paladin: Blessing of Sanctuary
	["20911"] = {
		rank  = 1,
		group = "BOSNC"
	},
	["20912"] = {
		rank  = 2,
		group = "BOSNC"
	},
	["20913"] = {
		rank  = 3,
		group = "BOSNC"
	},
	["20914"] = {
		rank  = 4,
		group = "BOSNC"
	},
	-- Paladin: Greater Blessing of Sanctuary
	["25899"] = {
		rank  = 1,
		group = "BOSNC",
		multi = true
	},
	-- Paladin: Blessing of Light
	["19977"] = {
		rank  = 1,
		group = "BOL"
	},
	["19978"] = {
		rank  = 2,
		group = "BOL"
	},
	["19979"] = {
		rank  = 3,
		group = "BOL"
	},
	-- Paladin: Greater Blessing of Light
	["25890"] = {
		rank  = 1,
		group = "BOL",
		multi = true
	},
	-- Priest: Power Word: Fortitude
	["1243"] = {
		rank  = 1,
		group = "FORT"
	},
	["1244"] = {
		rank  = 2,
		group = "FORT"
	},
	["1245"] = {
		rank  = 3,
		group = "FORT"
	},
	["2791"] = {
		rank  = 4,
		group = "FORT"
	},
	["10937"] = {
		rank  = 5,
		group = "FORT"
	},
	["10938"] = {
		rank  = 6,
		group = "FORT"
	},
	-- Priest: Prayer of Fortitude
	["21562"] = {
		rank  = 1,
		group = "FORT",
		multi = true
	},
	["21564"] = {
		rank  = 2,
		group = "FORT",
		multi = true
	},
	-- Priest: Shadow Protection
	["976"] = {
		rank  = 1,
		group = "SP"
	},
	["10957"] = {
		rank  = 2,
		group = "SP"
	},
	["10958"] = {
		rank  = 3,
		group = "SP"
	},
	-- Priest: Prayer of Shadow Protection
	["27683"] = {
		rank  = 1,
		group = "SP",
		multi = true
	},
	-- Priest: Inner Fire
	["588"] = {
		rank  = 1,
		group = "InnerFire"
	},
	["7128"] = {
		rank  = 2,
		group = "InnerFire"
	},
	["602"] = {
		rank  = 3,
		group = "InnerFire"
	},
	["1006"] = {
		rank  = 4,
		group = "InnerFire"
	},
	["10951"] = {
		rank  = 5,
		group = "InnerFire"
	},
	["10952"] = {
		rank  = 6,
		group = "InnerFire"
	},
	-- Warlock: Demon Armor
	["706"] = {
		rank  = 1,
		group = "DemonArmor"
	},
	["1086"] = {
		rank  = 2,
		group = "DemonArmor"
	},
	["11733"] = {
		rank  = 3,
		group = "DemonArmor"
	},
	["11734"] = {
		rank  = 4,
		group = "DemonArmor"
	},
	["11735"] = {
		rank  = 5,
		group = "DemonArmor"
	},
	-- Warlock: Shadow Ward
	["6229"] = {
		rank  = 1,
		group = "ShadowWard"
	},
	["11739"] = {
		rank  = 2,
		group = "ShadowWard"
	},
	["11740"] = {
		rank  = 3,
		group = "ShadowWard"
	},
	["28610"] = {
		rank  = 4,
		group = "ShadowWard"
	},
	-- Warlock: Detect Invisibility
	["132"] = {
		rank  = 1,
		group = "DetectInvis"
	},
	["2970"] = {
		rank  = 2,
		group = "DetectInvis"
	},
	["11743"] = {
		rank  = 3,
		group = "DetectInvis"
	},
	["5697"] = {
		rank  = 1,
		group = "UnendingBreath"
	}
};


--[[
	Init Auras
	Initialize the Castable and Trackable Auras for the current player
]]--
function EasyBuff:InitAuras()
	EasyBuff:Debug("EasyBuff:InitAuras", 1);
	local bookTabs = GetNumSpellTabs();
	local totalSpells = 0;

	-- Get the Spells I can cast, and create the Trackable_Auras list.
	for bookTabIndex=1, bookTabs do
		local bookTabName, bookTabTexture, bookTabOffset, bookTabSpellCnt, _, _ = GetSpellTabInfo(bookTabIndex);
		totalSpells = totalSpells + bookTabSpellCnt;
	end

	for spellIndex=1, totalSpells do
		local spellName, spellSubName = GetSpellBookItemName(spellIndex, BOOKTYPE_SPELL);
		local testName = spellName;
		if (spellSubName ~= nil and spellSubName ~= "") then
			testName = format("%s(%s)", spellName, spellSubName);
		end
		local spellName, _, spellIcon, castTime, minRange, maxRange, spellId = GetSpellInfo(testName);
		
		local aura = EasyBuff_Auras[tostring(spellId)];
		if (aura) then
			local auraGroup = EasyBuff_AuraGroups[aura.group];
			if (auraGroup ~= nil) then
				if (Trackable_Auras == nil) then
					Trackable_Auras = {}
				end
				Trackable_Auras[tostring(spellId)] = {
					group = aura.group,
					multi = aura.multi,
					name = spellName,
					rank = aura.rank
				};
			end
		end
	end

	-- Create the Castable_AuraGroups list from AuraGroups for my class
	for k, v in pairs(EasyBuff_Auras) do
		if (v ~= nil) then
			-- Get the AuraGroup for this Spell.
			auraGroup = EasyBuff_AuraGroups[v.group];
			if (auraGroup ~= nil) then
				-- Get the Spell Info
				local spellName, _, spellIcon, castTime, minRange, maxRange, spellId = GetSpellInfo(k);
				-- Can my class cast this spell?
				if (EasyBuff.PLAYER_CLASS == L[auraGroup.class]) then
					if (Castable_AuraGroups[v.group] == nil) then
						Castable_AuraGroups[v.group] = {ids={},multiIds={},hasMulti=false};
					end
					if (v.multi) then
						Castable_AuraGroups[v.group].hasMulti = true;
						Castable_AuraGroups[v.group].multiIds[v.rank] = spellId;
					else
						Castable_AuraGroups[v.group].ids[v.rank] = spellId;
					end
					Castable_AuraGroups[v.group].selfOnly = auraGroup.selfOnly
				end
			end
		end
	end
end


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
	return Trackable_Auras;
	-- return EasyBuff_Auras;
end


--[[
	Get Tracked Spell by ID
]]--
function EasyBuff:GetTrackedSpell(id)
	return Trackable_Auras[tostring(id)];
end


--[[
	Get Castable Aura Group by Group Name
]]--
function EasyBuff:GetAuraGroup(groupName)
	return Castable_AuraGroups[groupName];
end


--[[
	Get Castable Group Spell
]]--
function EasyBuff:GetCastableGroupSpell(groupName, multi)
	local group = Castable_AuraGroups[groupName];
	local highestRank = 1;
	if (group ~= nil) then
		if (multi and group.hasMulti) then
			highestRank = table.getn(group.multiIds);
			return group.multiIds[highestRank];
		else
			highestRank = table.getn(group.ids);
			return group.ids[highestRank];
		end
	end
	return nil;
end


--[[
	Get Aura Group by Spell Id
]]--
function EasyBuff:GetAuraGroupBySpellId(spellId)
	local aura = EasyBuff:GetTrackedSpell(spellId);
	if (aura ~= nil) then
		return aura.group, EasyBuff:GetAuraGroup(aura.group);
	end
	return nil, nil;
end


--[[
	Get Unit Buff
	Wrapper for UnitBuff so I don't have to keep looking up the index values
]]--
function EasyBuff:UnitBuff(unit, index, filter)
	local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
  		nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
		= UnitBuff(unit, index, filter);
	if (name == nil and spellId == nil) then
		return nil;
	end

	local curTime = GetTime();

	return {
		name = name,
		icon = icon,
		count = count,
		debuffType = debuffType,
		duration = duration,
		expirationTime = expirationTime,
		remainingTime = (expirationTime - curTime),
		source = source,
		isStealable = isStealable,
		nameplateShowPersonal = nameplateShowPersonal,
		spellId = spellId,
		canApplyAura = canApplyAura,
		isBossDebuff = isBossDebuff,
		castByPlayer = castByPlayer,
		nameplateShowAll = nameplateShowAll,
		timeMod = timeMod
	};
end
