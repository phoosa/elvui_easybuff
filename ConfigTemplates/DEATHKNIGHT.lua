--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a DEATHKNIGHT
    @param index {int} number from 1-3
    @return {object}
]]--
function EasyBuff.ConfigTemplate.DEATHKNIGHT(index)
    if (1 == index) then
        -- ["1"]   = L["Unholy DPS"],
        return {
            [EasyBuff.PLAYER] = {
                ["BLOODP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["BONSHI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["UNHOLP"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["FROSTP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
            },
            DEATHKNIGHT = {},
            DRUID = {},
            HUNTER = {},
            MAGE = {},
            PALADIN = {},
            PRIEST = {},
            ROGUE = {},
            SHAMAN = {},
            WARLOCK = {},
            WARRIOR = {}
        };
    elseif (2 == index) then
        -- ["2"]   = L["Frost DPS"],
        return {
            [EasyBuff.PLAYER] = {
                ["BLOODP"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["BONSHI"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["UNHOLP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["FROSTP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
            },
            DEATHKNIGHT = {},
            DRUID = {},
            HUNTER = {},
            MAGE = {},
            PALADIN = {},
            PRIEST = {},
            ROGUE = {},
            SHAMAN = {},
            WARLOCK = {},
            WARRIOR = {}
        };
    elseif (3 == index) then
        -- ["3"]   = L["Tank"],
        return {
            [EasyBuff.PLAYER] = {
                ["BLOODP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["BONSHI"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["UNHOLP"] = {
                    ["DAMAGER"] = false,
                    ["TANK"] = false,
                    ["HEALER"] = false,
                },
                ["FROSTP"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            DEATHKNIGHT = {},
            DRUID = {},
            HUNTER = {},
            MAGE = {},
            PALADIN = {},
            PRIEST = {},
            ROGUE = {},
            SHAMAN = {},
            WARLOCK = {},
            WARRIOR = {}
        };
    end

    return {};
end
