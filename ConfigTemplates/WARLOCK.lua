--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a WARLOCK
    @param index {int} number from 1-2
    @return {object}
]]--
function EasyBuff.ConfigTemplate.WARLOCK(index)
    if (1 == index) then
        -- ["1"]   = L["Fel Armor"],
        return {
            [EasyBuff.PLAYER] = {
                ["FELARM"] = {
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
        -- ["2"]   = L["Demon Armor"],
        return {
            [EasyBuff.PLAYER] = {
                ["DEMARM"] = {
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
