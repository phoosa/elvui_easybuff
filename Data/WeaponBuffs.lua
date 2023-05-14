-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Weapon Buff Groups
    Some weapon buffs can be applied by anyone, these are in the OTHER group.

    - type {string} Weapon buffs are applied by a using an item or casting a spell
]]--
EasyBuff.WEAPON_BUFF_GROUPS = {
    ROGUE = {
        DEADLY  = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
        INSTANT = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
        WOUND   = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
        CRIPPL  = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
        MIND    = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM }
    },
    SHAMAN = {
        FLAME   = { type = EasyBuff.WEAPON_BUFF_TYPE.SPELL },
        WINDF   = { type = EasyBuff.WEAPON_BUFF_TYPE.SPELL },
        ROCKB   = { type = EasyBuff.WEAPON_BUFF_TYPE.SPELL },
        FROST   = { type = EasyBuff.WEAPON_BUFF_TYPE.SPELL },
        EARTH   = { type = EasyBuff.WEAPON_BUFF_TYPE.SPELL }

    }
    -- OTHER = {
    --     MANAOIL = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
    --     WIZOIL  = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
    --     SHARPEN = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM },
    --     WEIGHTS = { type = EasyBuff.WEAPON_BUFF_TYPE.ITEM }
    -- }
};



--[[
    All Supported Weapon Buffs by Class (indexed by enchant effect id)
    Some weapon buffs can be applied by anyone, these are in the OTHER group.

    - rank  {int}    Enchant rank
    - group {string} Weapon Buff Group Key, see EasyBuff.WEAPON_BUFF_GROUPS
    - id    {int}    ID of the Spell or Item used to apply by buff, see `type` in EasyBuff.WEAPON_BUFF_GROUPS
]]--
EasyBuff.WEAPON_BUFFS = {
    ROGUE = {
        -- Deadly Poison
        ["d1"] = { rank = 1, group = "DEADLY", id = 2892 },
        ["d2"] = { rank = 2, group = "DEADLY", id = 2893 },
        ["d3"] = { rank = 3, group = "DEADLY", id = 8984 },
        ["d4"] = { rank = 4, group = "DEADLY", id = 8985 },
        ["d5"] = { rank = 5, group = "DEADLY", id = 20844 },
        ["d6"] = { rank = 6, group = "DEADLY", id = 22053 },
        ["d7"] = { rank = 7, group = "DEADLY", id = 22054 },
        ["d8"] = { rank = 8, group = "DEADLY", id = 43232 },
        ["d9"] = { rank = 9, group = "DEADLY", id = 43233 },
        -- Instant Poison
        ["323"] = { rank = 1, group = "INSTANT", id = 6947 },
        ["h1"] = { rank = 2, group = "INSTANT", id = 6949 },
        ["h2"] = { rank = 3, group = "INSTANT", id = 6950 },
        ["h3"] = { rank = 4, group = "INSTANT", id = 8926 },
        ["h4"] = { rank = 5, group = "INSTANT", id = 8927 },
        ["h5"] = { rank = 6, group = "INSTANT", id = 8928 },
        ["h6"] = { rank = 7, group = "INSTANT", id = 21927 },
        ["h7"] = { rank = 8, group = "INSTANT", id = 43230 },
        ["h8"] = { rank = 9, group = "INSTANT", id = 43231 },
        -- Wound Poison
        ["w1"] = { rank = 1, group = "WOUND", id = 10918 },
        ["w2"] = { rank = 2, group = "WOUND", id = 10920 },
        ["w3"] = { rank = 3, group = "WOUND", id = 10921 },
        ["w4"] = { rank = 4, group = "WOUND", id = 10922 },
        ["w5"] = { rank = 5, group = "WOUND", id = 22055 },
        ["w6"] = { rank = 6, group = "WOUND", id = 43234 },
        ["w7"] = { rank = 7, group = "WOUND", id = 43235 },
        -- Crippling Poison
        ["c1"] = { rank = 1, group = "CRIPPL", id = 3775 },
        ["c2"] = { rank = 2, group = "CRIPPL", id = 3776 },
        -- Mind-numbing Poison
        ["m1"] = { rank = 1, group = "MIND", id = 5237 },
        ["m2"] = { rank = 2, group = "MIND", id = 6951 },
        ["m3"] = { rank = 3, group = "MIND", id = 9186 }
    },
    SHAMAN = {
        -- Flametongue
        ["5"] = { rank = 1, group = "FLAME", id = 8024 },
        ["4"] = { rank = 2, group = "FLAME", id = 8027 },
        ["3"] = { rank = 3, group = "FLAME", id = 8030 },
        ["523"] = { rank = 4, group = "FLAME", id = 16339 },
        ["1665"] = { rank = 5, group = "FLAME", id = 16341 },
        ["1666"] = { rank = 6, group = "FLAME", id = 16342 },
        ["2634"] = { rank = 7, group = "FLAME", id = 25489 },
        ["3779"] = { rank = 8, group = "FLAME", id = 58785 },
        ["3780"] = { rank = 9, group = "FLAME", id = 58789 },
        ["3781"] = { rank = 10, group = "FLAME", id = 58790 },
        -- Windfury
        ["283"] = { rank = 1, group = "WINDF", id = 8232 },
        ["284"] = { rank = 2, group = "WINDF", id = 8235 },
        ["525"] = { rank = 3, group = "WINDF", id = 10486 },
        ["1669"] = { rank = 4, group = "WINDF", id = 16362 },
        ["2636"] = { rank = 5, group = "WINDF", id = 25505 },
        ["3785"] = { rank = 6, group = "WINDF", id = 58801 },
        ["3786"] = { rank = 7, group = "WINDF", id = 58803 },
        ["3787"] = { rank = 8, group = "WINDF", id = 58804 },
        -- Rockbiter
        ["29"] = { rank = 1, group = "ROCKB", id = 8017 },
        ["r2"] = { rank = 2, group = "ROCKB", id = 8018 },
        ["r3"] = { rank = 3, group = "ROCKB", id = 8019 },
        ["r4"] = { rank = 4, group = "ROCKB", id = 10399 },
        -- Frostbrand
        ["2"] = { rank = 1, group = "FROST", id = 8033 },
        ["12"] = { rank = 2, group = "FROST", id = 8038 },
        ["524"] = { rank = 3, group = "FROST", id = 10456 },
        ["1667"] = { rank = 4, group = "FROST", id = 16355 },
        ["1668"] = { rank = 5, group = "FROST", id = 16356 },
        ["2635"] = { rank = 6, group = "FROST", id = 25500 },
        ["3782"] = { rank = 7, group = "FROST", id = 58794 },
        ["3783"] = { rank = 8, group = "FROST", id = 58795 },
        ["3784"] = { rank = 9, group = "FROST", id = 58796 },
        -- Earthliving
        ["3345"] = { rank = 1, group = "FROST", id = 51730 },
        ["3346"] = { rank = 2, group = "FROST", id = 51988 },
        ["3347"] = { rank = 3, group = "FROST", id = 51991 },
        ["3348"] = { rank = 4, group = "FROST", id = 51992 },
        ["3349"] = { rank = 5, group = "FROST", id = 51993 },
        ["3350"] = { rank = 6, group = "FROST", id = 51994 }
    }
    -- OTHER = {
    --     -- Mana Oil
    --     [""] = { rank = 1, group = "MANAOIL", id = 20745 },
    --     [""] = { rank = 2, group = "MANAOIL", id = 20747 },
    --     [""] = { rank = 3, group = "MANAOIL", id = 20748 },
    --     [""] = { rank = 4, group = "MANAOIL", id = 22521 },
    --     [""] = { rank = 5, group = "MANAOIL", id = 36899 },
    --     [""] = { rank = 6, group = "MANAOIL", id = 36899 },
    --     -- Wizard Oil
    --     [""] = { rank = 1, group = "WIZOIL", id = 20744 },
    --     [""] = { rank = 2, group = "WIZOIL", id = 20746 },
    --     [""] = { rank = 3, group = "WIZOIL", id = 20750 },
    --     [""] = { rank = 4, group = "WIZOIL", id = 20749 },
    --     [""] = { rank = 5, group = "WIZOIL", id = 22522 },
    --     [""] = { rank = 6, group = "WIZOIL", id = 36900 },
    --     -- Sharpening Stone
    --     [""] = { rank = 1, group = "SHARPEN", id = 2862 },
    --     [""] = { rank = 2, group = "SHARPEN", id = 2863 },
    --     [""] = { rank = 3, group = "SHARPEN", id = 2871 },
    --     [""] = { rank = 4, group = "SHARPEN", id = 7964 },
    --     [""] = { rank = 5, group = "SHARPEN", id = 12404 },
    --     [""] = { rank = 6, group = "SHARPEN", id = 23122 },
    --     [""] = { rank = 7, group = "SHARPEN", id = 23528 },
    --     [""] = { rank = 8, group = "SHARPEN", id = 18262 },
    --     [""] = { rank = 9, group = "SHARPEN", id = 23529 },
    --     -- Weight Stone
    --     [""] = { rank = 1, group = "WEIGHTS", id = 3239 },
    --     [""] = { rank = 2, group = "WEIGHTS", id = 3240 },
    --     [""] = { rank = 3, group = "WEIGHTS", id = 3241 },
    --     [""] = { rank = 4, group = "WEIGHTS", id = 7965 },
    --     [""] = { rank = 5, group = "WEIGHTS", id = 12643 },
    --     [""] = { rank = 6, group = "WEIGHTS", id = 28420 },
    --     [""] = { rank = 7, group = "WEIGHTS", id = 28421 }
    -- }
};

EasyBuff.WEAPON_BUFF_SORT = {
    ROGUE = {
        -- Deadly Poison
        "d1",
        "d2",
        "d3",
        "d4",
        "d5",
        "d6",
        "d7",
        "d8",
        "d9",
        -- Instant Poison
        "323",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "h7",
        "h8",
        -- Wound Poison
        "w1",
        "w2",
        "w3",
        "w4",
        "w5",
        "w6",
        "w7",
        -- Crippling Poison
        "c1",
        "c2",
        -- Mind-numbing Poison
        "m1",
        "m2",
        "m3"
    },
    SHAMAN = {
        -- Flametongue
        "5",
        "4",
        "3",
        "523",
        "1665",
        "1666",
        "2634",
        "3779",
        "3780",
        "3781",
        -- Windfury
        "283",
        "284",
        "525",
        "1669",
        "2636",
        "3785",
        "3786",
        "3787",
        -- Rockbiter
        "29",
        "r2",
        "r3",
        "r4",
        -- Frostbrand
        "2",
        "12",
        "524",
        "1667",
        "1668",
        "2635",
        "3782",
        "3783",
        "3784",
        -- Earthliving
        "3345",
        "3346",
        "3347",
        "3348",
        "3349",
        "3350"
    }
};