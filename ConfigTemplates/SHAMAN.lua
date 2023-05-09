--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a SHAMAN
    @param index {int} number from 1-3
    @return {object}
]]--
function EasyBuff.ConfigTemplate.SHAMAN(index)
    if (1 == index) then
        -- ["1"]   = L["Restoration"],
        return {
            [EasyBuff.PLAYER] = {
                ["WATSHI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["EARSHI"] = {
                    ["TANK"] = true,
                },
            },
            ["WARRIOR"] = {
                ["EARSHI"] = {
                    ["TANK"] = true,
                },
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
                ["EARSHI"] = {
                    ["TANK"] = true,
                },
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
                ["EARSHI"] = {
                    ["TANK"] = true,
                },
            },
        };
    elseif (2 == index) then
        -- ["2"]   = L["Enhancement"],
        return {
            [EasyBuff.PLAYER] = {
                ["LIGSHI"] = {
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
        -- ["3"]   = L["Elemental"],
        return {
            [EasyBuff.PLAYER] = {
                ["WATSHI"] = {
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
