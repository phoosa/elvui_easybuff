--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Class Spell Groups
    Each group represents all ranks of a given spell, and defines a few attributes about each spell group to define it's
    limitations and options.

    - multi     {boolean} There are multiple versions of this spell, ie a "lesser" and "greater" or multi-player version
    - aura      {boolean} This spell behaves like an aura, the caster may only apply one aura type spell per player
    - selfOnly  {boolean} This spell may only be cast on the player themself
    - stacks    {int|nil} This spell applies a stacking buff, and we should track the stack count in addition to the expiration
]]--
EasyBuff.CLASS_SPELLS_GROUPS = {
    DEATHKNIGHT = {
        -- Bone Shield
        BONSHI  = {multi = false, aura = false, selfOnly = true, stacks = 3},
        -- Blood Presence
        BLOODP  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Frost Presence
        FROSTP  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Unholy Presence
        UNHOLP  = {multi = false, aura = true, selfOnly = true, stacks = nil}
    },
    DRUID       = {
        -- Mark of the Wild
        MOTW    = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Thorns
        THORNS  = {multi = true, aura = false, selfOnly = false, stacks = nil}
    },
    HUNTER      = {
        -- Trueshot Aura
        TSA     = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Aspect of the Hawk
        AOTH    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Aspect of the Dragonhawk
        AOTDH   = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Aspect of the Monkey
        AOTM    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Aspect of the Wild
        AOTW    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Aspect of the Cheetah
        AOTC    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Aspect of the Pack
        AOTP    = {multi = false, aura = true, selfOnly = true, stacks = nil}
    },
    MAGE        = {
        -- Arcane Intellect
        AI      = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Ice Armor
        ICEARM  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Frost Armor
        FROARM  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Mage Armor
        MAGARM  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Molten Armor
        MOLARM  = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Ice Barrier
        ICEBAR  = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Frost Ward
        FROWAR  = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Fire Ward
        FIRWAR  = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Mana Shield
        MANSHI  = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Dampen Magic
        DAMMAG  = {multi = false, aura = false, selfOnly = false, stacks = nil},
        -- Amplify Magic
        AMPMAG  = {multi = false, aura = false, selfOnly = false, stacks = nil}
    },
    PALADIN     = {
        -- Blessing of Might
        BOM     = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Blessing of Wisdom
        BOW     = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Blessing of Kings
        BOK     = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Blessing of Sanctuary
        BOS     = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Righteous Fury
        RF      = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Devotion Aura
        DEVO    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Concentration Aura
        CONC    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Retribution Aura
        RETR    = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Fire Resistance Aura
        FIRER   = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Frost Resistance Aura
        FROSR   = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Shadow Resistance Aura
        SHADR   = {multi = false, aura = true, selfOnly = true, stacks = nil}
    },
    PRIEST      = {
        -- Power Word: Fortitude
        FORT    = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Shadow Protection
        SHADP   = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Divine Spirit
        DS      = {multi = true, aura = false, selfOnly = false, stacks = nil},
        -- Inner Fire
        IF      = {multi = false, aura = false, selfOnly = true, stacks = 20},
        -- Shadowform
        SHADF   = {multi = false, aura = false, selfOnly = true, stacks = nil}
    },
    ROGUE       = nil,
    SHAMAN      = {
        -- Lightning Shield
        LIGSHI   = {multi = false, aura = true, selfOnly = true, stacks = 3},
        -- Earth Shield
        EARSHI   = {multi = false, aura = true, selfOnly = false, stacks = 6},
        -- Water Shield
        WATSHI   = {multi = false, aura = true, selfOnly = false, stacks = 3},
        -- Water Breathing
        WATBRE   = {multi = false, aura = false, selfOnly = false, stacks = nil}
    },
    WARLOCK     = {
        -- Demon Armor
        DEMARM   = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Fel Armor
        FELARM   = {multi = false, aura = true, selfOnly = true, stacks = nil},
        -- Shadow Ward
        SHAWAR   = {multi = false, aura = false, selfOnly = true, stacks = nil},
        -- Detect Invisibility
        DETINV   = {multi = false, aura = false, selfOnly = false, stacks = nil},
        -- Unending Breath
        UNEBRE   = {multi = false, aura = false, selfOnly = false, stacks = nil}
    },
    WARRIOR     = nil
};


--[[
    All Supported Spells by Class (indexed by spellId)
    Each group represents all ranks of a given spell, and defines a few attributes about each spell group to define it's
    limitations and options.

    Each class spell is represented as an object with the  following properties:
    - rank    {int}     Spell Rank
    - group   {string}  Spell Group Key, see EasyBuff.CLASS_SPELLS_GROUPS
    - greater {boolean} This is a "greater" or multi-player version of this spell group
]]--
EasyBuff.CLASS_SPELLS = {
    DEATHKNIGHT = {
        -- Bone Shield
        ["49222"] = { rank = 1, group = "BONSHI", greater = false},
        ["57210"] = { rank = 1, group = "BONSHI", greater = false}, -- TODO: this could be just the glyph and not the new spell id when glyphed
        -- Blood Presence
        ["48266"] = { rank = 1, group = "BLOODP", greater = false},
        -- Frost Presence
        ["48263"] = { rank = 1, group = "FROSTP", greater = false},
        -- Unholy Presence
        ["48265"] = { rank = 1, group = "UNHOLP", greater = false}
    },
    DRUID       = {
        -- Mark of the Wild
        ["1126"] = { rank = 1, group = "MOTW", greater = false},
        ["5232"] = { rank = 2, group = "MOTW", greater = false},
        ["6756"] = { rank = 3, group = "MOTW", greater = false},
        ["5234"] = { rank = 4, group = "MOTW", greater = false},
        ["8907"] = { rank = 5, group = "MOTW", greater = false},
        ["9884"] = { rank = 6, group = "MOTW", greater = false},
        ["9885"] = { rank = 7, group = "MOTW", greater = false},
        ["26990"] = { rank = 8, group = "MOTW", greater = false},
        ["48469"] = { rank = 9, group = "MOTW", greater = false},
        -- Gift of the Wild
        ["21849"] = { rank = 1, group = "MOTW", greater = true},
        ["21850"] = { rank = 2, group = "MOTW", greater = true},
        ["26991"] = { rank = 3, group = "MOTW", greater = true},
        ["48470"] = { rank = 4, group = "MOTW", greater = true},
        -- Thorns
        ["467"] = { rank = 1, group = "THORNS", greater = false},
        ["782"] = { rank = 2, group = "THORNS", greater = false},
        ["1075"] = { rank = 3, group = "THORNS", greater = false},
        ["8914"] = { rank = 4, group = "THORNS", greater = false},
        ["9756"] = { rank = 5, group = "THORNS", greater = false},
        ["9910"] = { rank = 6, group = "THORNS", greater = false},
        ["26992"] = { rank = 7, group = "THORNS", greater = false},
        ["53307"] = { rank = 8, group = "THORNS", greater = false}
    },
    HUNTER      = {
        -- Trueshot Aura
        ["19506"] = { rank = 1, group = "TSA", greater = false},
        ["20905"] = { rank = 2, group = "TSA", greater = false},
        ["20906"] = { rank = 3, group = "TSA", greater = false},
        ["27066"] = { rank = 4, group = "TSA", greater = false},
        -- Aspect of the Hawk
        ["13165"] = { rank = 1, group = "AOTH", greater = false},
        ["14318"] = { rank = 2, group = "AOTH", greater = false},
        ["14319"] = { rank = 3, group = "AOTH", greater = false},
        ["14320"] = { rank = 4, group = "AOTH", greater = false},
        ["14321"] = { rank = 5, group = "AOTH", greater = false},
        ["14322"] = { rank = 6, group = "AOTH", greater = false},
        ["25296"] = { rank = 7, group = "AOTH", greater = false},
        ["27044"] = { rank = 8, group = "AOTH", greater = false},
        -- Aspect of the Dragonhawk
        ["61846"] = { rank = 1, group = "AOTDH", greater = false},
        ["61847"] = { rank = 2, group = "AOTDH", greater = false},
        -- Aspect of the Monkey
        ["13163"] = { rank = 1, group = "AOTM", greater = false},
        ["19549"] = { rank = 2, group = "AOTM", greater = false},
        ["19550"] = { rank = 3, group = "AOTM", greater = false},
        ["19551"] = { rank = 4, group = "AOTM", greater = false},
        ["24386"] = { rank = 5, group = "AOTM", greater = false},
        ["24387"] = { rank = 6, group = "AOTM", greater = false},
        -- Aspect of the Wild
        ["20043"] = { rank = 1, group = "AOTW", greater = false},
        ["20190"] = { rank = 2, group = "AOTW", greater = false},
        ["27045"] = { rank = 3, group = "AOTW", greater = false},
        -- Aspect of the Cheetah
        ["5118"] = { rank = 1, group = "AOTC", greater = false},
        -- Aspect of the Pack
        ["13159"] = { rank = 1, group = "AOTP", greater = false}
    },
    MAGE        = {
        -- Arcane Intellect
        ["61024"] = { rank = 7, group = "AI", greater = false}, -- Dalaran Intellect
        ["61316"] = { rank = 3, group = "AI", greater = true}, -- Dalaran Brilliance
        ["1459"] = { rank = 1, group = "AI", greater = false},
        ["1460"] = { rank = 2, group = "AI", greater = false},
        ["1461"] = { rank = 3, group = "AI", greater = false},
        ["10156"] = { rank = 4, group = "AI", greater = false},
        ["10157"] = { rank = 5, group = "AI", greater = false},
        ["27126"] = { rank = 6, group = "AI", greater = false},
        ["42995"] = { rank = 7, group = "AI", greater = false},
        ["23028"] = { rank = 1, group = "AI", greater = true},
        ["27127"] = { rank = 2, group = "AI", greater = true},
        ["43002"] = { rank = 3, group = "AI", greater = true},
        -- Ice Armor
        ["7302"] = { rank = 1, group = "ICEARM", greater = false},
        ["7320"] = { rank = 2, group = "ICEARM", greater = false},
        ["10219"] = { rank = 3, group = "ICEARM", greater = false},
        ["10220"] = { rank = 4, group = "ICEARM", greater = false},
        ["27124"] = { rank = 5, group = "ICEARM", greater = false},
        ["43008"] = { rank = 6, group = "ICEARM", greater = false},
        -- Frost Armor
        ["168"] = { rank = 1, group = "FROARM", greater = false},
        ["7300"] = { rank = 2, group = "FROARM", greater = false},
        ["7301"] = { rank = 3, group = "FROARM", greater = false},
        -- Mage Armor
        ["6117"] = { rank = 1, group = "MAGARM", greater = false},
        ["22782"] = { rank = 2, group = "MAGARM", greater = false},
        ["22783"] = { rank = 3, group = "MAGARM", greater = false},
        ["27125"] = { rank = 4, group = "MAGARM", greater = false},
        ["43023"] = { rank = 5, group = "MAGARM", greater = false},
        ["43024"] = { rank = 6, group = "MAGARM", greater = false},
        -- Molten Armor
        ["30482"] = { rank = 1, group = "MOLARM", greater = false},
        ["43045"] = { rank = 2, group = "MOLARM", greater = false},
        ["43046"] = { rank = 3, group = "MOLARM", greater = false},
        -- Ice Barrier
        ["11426"] = { rank = 1, group = "ICEBAR", greater = false},
        ["13031"] = { rank = 2, group = "ICEBAR", greater = false},
        ["13032"] = { rank = 3, group = "ICEBAR", greater = false},
        ["13033"] = { rank = 4, group = "ICEBAR", greater = false},
        ["27134"] = { rank = 5, group = "ICEBAR", greater = false},
        ["33405"] = { rank = 6, group = "ICEBAR", greater = false},
        ["43038"] = { rank = 7, group = "ICEBAR", greater = false},
        ["43039"] = { rank = 8, group = "ICEBAR", greater = false},
        -- Frost Ward
        ["6143"] = { rank = 1, group = "FROWAR", greater = false},
        ["8461"] = { rank = 2, group = "FROWAR", greater = false},
        ["8462"] = { rank = 3, group = "FROWAR", greater = false},
        ["10177"] = { rank = 4, group = "FROWAR", greater = false},
        ["28609"] = { rank = 5, group = "FROWAR", greater = false},
        ["23796"] = { rank = 6, group = "FROWAR", greater = false},
        ["43012"] = { rank = 7, group = "FROWAR", greater = false},
        -- Fire Ward
        ["543"] = { rank = 1, group = "FIRWAR", greater = false},
        ["8457"] = { rank = 2, group = "FIRWAR", greater = false},
        ["8458"] = { rank = 3, group = "FIRWAR", greater = false},
        ["10223"] = { rank = 4, group = "FIRWAR", greater = false},
        ["10225"] = { rank = 5, group = "FIRWAR", greater = false},
        ["27128"] = { rank = 6, group = "FIRWAR", greater = false},
        ["43010"] = { rank = 7, group = "FIRWAR", greater = false},
        -- Mana Shield
        ["1463"] = { rank = 1, group = "MANSHI", greater = false},
        ["8494"] = { rank = 2, group = "MANSHI", greater = false},
        ["8495"] = { rank = 3, group = "MANSHI", greater = false},
        ["10191"] = { rank = 4, group = "MANSHI", greater = false},
        ["10192"] = { rank = 5, group = "MANSHI", greater = false},
        ["10193"] = { rank = 6, group = "MANSHI", greater = false},
        ["27131"] = { rank = 7, group = "MANSHI", greater = false},
        ["43019"] = { rank = 8, group = "MANSHI", greater = false},
        ["43020"] = { rank = 9, group = "MANSHI", greater = false},
        -- Dampen Magic
        ["604"] = { rank = 1, group = "DAMMAG", greater = false},
        ["8450"] = { rank = 2, group = "DAMMAG", greater = false},
        ["8451"] = { rank = 3, group = "DAMMAG", greater = false},
        ["10173"] = { rank = 4, group = "DAMMAG", greater = false},
        ["10174"] = { rank = 5, group = "DAMMAG", greater = false},
        ["33944"] = { rank = 6, group = "DAMMAG", greater = false},
        ["43015"] = { rank = 7, group = "DAMMAG", greater = false},
        -- Amplify Magic
        ["1008"] = { rank = 1, group = "AMPMAG", greater = false},
        ["8455"] = { rank = 2, group = "AMPMAG", greater = false},
        ["10169"] = { rank = 3, group = "AMPMAG", greater = false},
        ["10170"] = { rank = 4, group = "AMPMAG", greater = false},
        ["27130"] = { rank = 5, group = "AMPMAG", greater = false},
        ["33946"] = { rank = 6, group = "AMPMAG", greater = false},
        ["43017"] = { rank = 7, group = "AMPMAG", greater = false}
    },
    PALADIN     = {
        -- Blessing of Might
        ["19740"] = {rank = 1, group = "BOM", greater = false},
        ["19834"] = {rank = 2, group = "BOM", greater = false},
        ["19835"] = {rank = 3, group = "BOM", greater = false},
        ["19836"] = {rank = 4, group = "BOM", greater = false},
        ["19837"] = {rank = 5, group = "BOM", greater = false},
        ["19838"] = {rank = 6, group = "BOM", greater = false},
        ["25291"] = {rank = 7, group = "BOM", greater = false},
        ["27140"] = {rank = 8, group = "BOM", greater = false},
        ["48931"] = {rank = 9, group = "BOM", greater = false},
        ["48932"] = {rank = 10, group = "BOM", greater = false},
        -- Greater Blessing of Might
        ["25782"] = {rank = 1, group = "BOM", greater = true},
        ["25916"] = {rank = 2, group = "BOM", greater = true},
        ["27141"] = {rank = 3, group = "BOM", greater = true},
        ["48933"] = {rank = 4, group = "BOM", greater = true},
        ["48934"] = {rank = 5, group = "BOM", greater = true},
        -- Blessing of Wisdom
        ["19742"] = {rank = 1, group = "BOW", greater = fase},
        ["19850"] = {rank = 2, group = "BOW", greater = fase},
        ["19852"] = {rank = 3, group = "BOW", greater = fase},
        ["19853"] = {rank = 4, group = "BOW", greater = fase},
        ["19854"] = {rank = 5, group = "BOW", greater = fase},
        ["25290"] = {rank = 6, group = "BOW", greater = fase},
        ["27142"] = {rank = 7, group = "BOW", greater = fase},
        ["48935"] = {rank = 8, group = "BOW", greater = fase},
        ["48936"] = {rank = 9, group = "BOW", greater = fase},
        -- Greater Blessing of Wisdom
        ["25894"] = {rank = 1, group = "BOW", greater = true},
        ["25918"] = {rank = 2, group = "BOW", greater = true},
        ["27143"] = {rank = 3, group = "BOW", greater = true},
        ["48937"] = {rank = 4, group = "BOW", greater = true},
        ["48938"] = {rank = 5, group = "BOW", greater = true},
        -- Blessing of Kings
        ["20217"] = {rank = 1, group = "BOK", greater = false},
        -- Greater Blessing of Kings
        ["25898"] = {rank = 1, group = "BOK", greater = true},
        -- Blessing of Sanctuary
        ["20911"] = {rank = 1, group = "BOS", greater = false},
        ["20912"] = {rank = 2, group = "BOS", greater = false},
        ["20913"] = {rank = 3, group = "BOS", greater = false},
        ["20914"] = {rank = 4, group = "BOS", greater = false},
        ["27168"] = {rank = 5, group = "BOS", greater = false},
        -- Greater Blessing of Sanctuary
        ["25899"] = {rank = 1, group = "BOS", greater = true},
        ["27169"] = {rank = 2, group = "BOS", greater = true},
        -- Righteous Fury
        ["25780"] = {rank = 1, group = "RF", greater = false},
        -- Devotion Aura
        ["465"] = {rank = 1, group = "DEVO", greater = false},
        ["10290"] = {rank = 2, group = "DEVO", greater = false},
        ["643"] = {rank = 3, group = "DEVO", greater = false},
        ["10291"] = {rank = 4, group = "DEVO", greater = false},
        ["1032"] = {rank = 5, group = "DEVO", greater = false},
        ["10292"] = {rank = 6, group = "DEVO", greater = false},
        ["10293"] = {rank = 7, group = "DEVO", greater = false},
        ["27149"] = {rank = 8, group = "DEVO", greater = false},
        ["48941"] = {rank = 9, group = "DEVO", greater = false},
        ["48942"] = {rank = 10, group = "DEVO", greater = false},
        -- Concentration Aura
        ["19746"] = {rank = 1, group = "CONC", greater = false},
        -- Retribution Aura
        ["7294"] = {rank = 1, group = "RETR", greater = false},
        ["10298"] = {rank = 2, group = "RETR", greater = false},
        ["10299"] = {rank = 3, group = "RETR", greater = false},
        ["10300"] = {rank = 4, group = "RETR", greater = false},
        ["10301"] = {rank = 5, group = "RETR", greater = false},
        ["27150"] = {rank = 6, group = "RETR", greater = false},
        ["54043"] = {rank = 7, group = "RETR", greater = false},
        -- Fire Resistance Aura
        ["19891"] = {rank = 1, group = "FIRER", greater = false},
        ["19899"] = {rank = 2, group = "FIRER", greater = false},
        ["19900"] = {rank = 3, group = "FIRER", greater = false},
        ["27153"] = {rank = 4, group = "FIRER", greater = false},
        ["48947"] = {rank = 5, group = "FIRER", greater = false},
        -- Frost Resistance Aura
        ["19888"] = {rank = 1, group = "FROSR", greater = false},
        ["19897"] = {rank = 2, group = "FROSR", greater = false},
        ["19898"] = {rank = 3, group = "FROSR", greater = false},
        ["27152"] = {rank = 4, group = "FROSR", greater = false},
        ["48945"] = {rank = 5, group = "FROSR", greater = false},
        -- Shadow Resistance Aura
        ["19876"] = {rank = 1, group = "SHADR", greater = false},
        ["19895"] = {rank = 2, group = "SHADR", greater = false},
        ["19896"] = {rank = 3, group = "SHADR", greater = false},
        ["27151"] = {rank = 4, group = "SHADR", greater = false},
        ["48943"] = {rank = 5, group = "SHADR", greater = false}
    },
    PRIEST      = {
        -- Power Word: Fortitude
        ["1243"] = {rank = 1, group = "FORT", greater = false},
        ["1244"] = {rank = 2, group = "FORT", greater = false},
        ["1245"] = {rank = 3, group = "FORT", greater = false},
        ["2791"] = {rank = 4, group = "FORT", greater = false},
        ["10937"] = {rank = 5, group = "FORT", greater = false},
        ["10938"] = {rank = 6, group = "FORT", greater = false},
        ["25389"] = {rank = 7, group = "FORT", greater = false},
        ["48161"] = {rank = 8, group = "FORT", greater = false},
        -- Prayer of Fortitude
        ["21562"] = {rank = 1, group = "FORT", greater = true},
        ["21564"] = {rank = 2, group = "FORT", greater = true},
        ["25392"] = {rank = 3, group = "FORT", greater = true},
        ["48162"] = {rank = 4, group = "FORT", greater = true},
        -- Shadow Protection
        ["976"] = {rank = 1, group = "SHADP", greater = false},
        ["10957"] = {rank = 2, group = "SHADP", greater = false},
        ["10958"] = {rank = 3, group = "SHADP", greater = false},
        ["25433"] = {rank = 4, group = "SHADP", greater = false},
        -- Prayer of Shadow Protection
        ["27683"] = {rank = 1, group = "SHADP", greater = true},
        ["39374"] = {rank = 2, group = "SHADP", greater = true},
        ["48170"] = {rank = 2, group = "SHADP", greater = true},
        -- Inner Fire
        ["588"] = {rank = 1, group = "IF", greater = false},
        ["7128"] = {rank = 2, group = "IF", greater = false},
        ["602"] = {rank = 3, group = "IF", greater = false},
        ["1006"] = {rank = 4, group = "IF", greater = false},
        ["10951"] = {rank = 5, group = "IF", greater = false},
        ["10952"] = {rank = 6, group = "IF", greater = false},
        ["25431"] = {rank = 7, group = "IF", greater = false},
        ["48040"] = {rank = 8, group = "IF", greater = false},
        ["48168"] = {rank = 9, group = "IF", greater = false},
        -- Shadowform
        ["15473"] = {rank = 1, group = "SHADF", greater = false},
        -- Divine Spirit
        ["14752"] = {rank = 1, group = "DS", greater = false},
        ["14818"] = {rank = 2, group = "DS", greater = false},
        ["14819"] = {rank = 3, group = "DS", greater = false},
        ["27841"] = {rank = 4, group = "DS", greater = false},
        ["25312"] = {rank = 5, group = "DS", greater = false},
        ["48073"] = {rank = 6, group = "DS", greater = false},
        ["27681"] = {rank = 1, group = "DS", greater = false},
        ["32999"] = {rank = 2, group = "DS", greater = false},
        ["48074"] = {rank = 3, group = "DS", greater = false}
    },
    ROGUE       = nil,
    SHAMAN      = {
        -- Lightning Shield
        ["324"] = {rank = 1, group = "LIGSHI", greater = false},
        ["325"] = {rank = 2, group = "LIGSHI", greater = false},
        ["905"] = {rank = 3, group = "LIGSHI", greater = false},
        ["945"] = {rank = 4, group = "LIGSHI", greater = false},
        ["8134"] = {rank = 5, group = "LIGSHI", greater = false},
        ["10431"] = {rank = 6, group = "LIGSHI", greater = false},
        ["10432"] = {rank = 7, group = "LIGSHI", greater = false},
        ["25469"] = {rank = 8, group = "LIGSHI", greater = false},
        ["25472"] = {rank = 9, group = "LIGSHI", greater = false},
        ["49280"] = {rank = 10, group = "LIGSHI", greater = false},
        ["49281"] = {rank = 11, group = "LIGSHI", greater = false},
        -- Earth Shield
        ["974"] = {rank = 1, group = "EARSHI", greater = false},
        ["32593"] = {rank = 2, group = "EARSHI", greater = false},
        ["32594"] = {rank = 3, group = "EARSHI", greater = false},
        -- Water Shield
        ["52127"] = {rank = 1, group = "WATSHI", greater = false},
        ["52129"] = {rank = 2, group = "WATSHI", greater = false},
        ["52131"] = {rank = 3, group = "WATSHI", greater = false},
        ["52134"] = {rank = 4, group = "WATSHI", greater = false},
        ["52136"] = {rank = 5, group = "WATSHI", greater = false},
        ["52138"] = {rank = 6, group = "WATSHI", greater = false},
        ["24398"] = {rank = 7, group = "WATSHI", greater = false},
        ["33736"] = {rank = 8, group = "WATSHI", greater = false},
        ["57960"] = {rank = 9, group = "WATSHI", greater = false},
        -- Water Breathing
        ["131"] = {rank = 1, group = "WATBRE", greater = false}
    },
    WARLOCK     = {
        -- Demon Armor
        ["706"] = {rank = 1, group = "DEMARM", greater = false},
        ["1086"] = {rank = 2, group = "DEMARM", greater = false},
        ["11733"] = {rank = 3, group = "DEMARM", greater = false},
        ["11734"] = {rank = 4, group = "DEMARM", greater = false},
        ["11735"] = {rank = 5, group = "DEMARM", greater = false},
        ["27260"] = {rank = 6, group = "DEMARM", greater = false},
        ["47793"] = {rank = 7, group = "DEMARM", greater = false},
        ["47889"] = {rank = 8, group = "DEMARM", greater = false},
        -- Fel Armor
        ["28176"] = {rank = 1, group = "FELARM", greater = false},
        ["28189"] = {rank = 2, group = "FELARM", greater = false},
        ["47892"] = {rank = 3, group = "FELARM", greater = false},
        ["47893"] = {rank = 4, group = "FELARM", greater = false},
        -- Shadow Ward
        ["6229"] = {rank = 1, group = "SHAWAR", greater = false},
        ["11739"] = {rank = 2, group = "SHAWAR", greater = false},
        ["11740"] = {rank = 3, group = "SHAWAR", greater = false},
        ["28610"] = {rank = 4, group = "SHAWAR", greater = false},
        ["47890"] = {rank = 5, group = "SHAWAR", greater = false},
        ["47891"] = {rank = 6, group = "SHAWAR", greater = false},
        -- Detect Invisibility
        ["132"] = {rank = 1, group = "DETINV", greater = false},
        ["2970"] = {rank = 2, group = "DETINV", greater = false},
        ["11743"] = {rank = 3, group = "DETINV", greater = false},
        -- Unending Breath
        ["5697"] = {rank = 1, group = "UNEBRE", greater = false}
    },
    WARRIOR     = nil
}
