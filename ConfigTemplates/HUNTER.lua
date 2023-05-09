--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a HUNTER
    @param index {int} number from 1-3
    @return {object}
]]--
function EasyBuff.ConfigTemplate.HUNTER(index)
    if (1 == index) then
        -- ["1"]   = L["Dragonhawk"],
        return {
            [EasyBuff.PLAYER] = {
                ["TSA"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["AOTDH"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
            },
            ["WARRIOR"] = {
            },
            ["SHAMAN"] = {
            },
            ["MAGE"] = {
            },
            ["PRIEST"] = {
            },
            ["WARLOCK"] = {
            },
            ["HUNTER"] = {
            },
            ["DRUID"] = {
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
            },
        };
    elseif (2 == index) then
        -- ["2"]   = L["Hawk"],
        return {
            [EasyBuff.PLAYER] = {
                ["TSA"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["AOTH"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
            },
            ["WARRIOR"] = {
            },
            ["SHAMAN"] = {
            },
            ["MAGE"] = {
            },
            ["PRIEST"] = {
            },
            ["WARLOCK"] = {
            },
            ["HUNTER"] = {
            },
            ["DRUID"] = {
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
            },
        };
    elseif (3 == index) then
        -- ["3"]   = L["Monkey"],
        return {
            [EasyBuff.PLAYER] = {
                ["TSA"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["AOTM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
            },
            ["WARRIOR"] = {
            },
            ["SHAMAN"] = {
            },
            ["MAGE"] = {
            },
            ["PRIEST"] = {
            },
            ["WARLOCK"] = {
            },
            ["HUNTER"] = {
            },
            ["DRUID"] = {
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
            },
        };
    end

    return {};
end
