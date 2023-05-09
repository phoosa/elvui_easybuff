--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a PALADIN
    @param index {int} number from 1-3
    @return {object}
]]--
function EasyBuff.ConfigTemplate.PALADIN(index)
    if (1 == index) then
        -- ["1"]   = L["Holy"],
        return {
            [EasyBuff.PLAYER] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["CONC"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARRIOR"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["SHAMAN"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["ROGUE"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PALADIN"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
        };
    elseif (2 == index) then
        -- ["2"]   = L["Retribution"],
        return {
            [EasyBuff.PLAYER] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["RETR"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARRIOR"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["SHAMAN"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["BOW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["ROGUE"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PALADIN"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
        };
    elseif (3 == index) then
        -- ["3"]   = L["Protection"],
        return {
            [EasyBuff.PLAYER] = {
                ["BOS"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["DEVO"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["BOS"] = {
                    ["TANK"] = true,
                },
                ["BOM"] = {
                    ["DAMAGER"] = true,
                },
            },
            ["WARRIOR"] = {
                ["BOS"] = {
                    ["TANK"] = true,
                },
                ["BOM"] = {
                    ["DAMAGER"] = true,
                },
            },
            ["SHAMAN"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["BOK"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["BOS"] = {
                    ["TANK"] = true,
                },
                ["BOM"] = {
                    ["DAMAGER"] = true,
                },
            },
            ["ROGUE"] = {
                ["BOM"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PALADIN"] = {
                ["BOS"] = {
                    ["TANK"] = true,
                },
                ["BOM"] = {
                    ["DAMAGER"] = true,
                },
            },
        };
    end

    return {};
end
