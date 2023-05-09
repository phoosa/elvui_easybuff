--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a MAGE
    @param index {int} number from 1-3
    @return {object}
]]--
function EasyBuff.ConfigTemplate.MAGE(index)
    if (1 == index) then
        -- ["1"]   = L["Molten Armor"],
        return {
            [EasyBuff.PLAYER] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["MOLARM"] = {
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
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["HEALER"] = true,
                },
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
        };
    elseif (2 == index) then
        -- ["2"]   = L["Mage Armor"],
        return {
            [EasyBuff.PLAYER] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["MAGARM"] = {
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
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["HEALER"] = true,
                },
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
        };
    elseif (3 == index) then
        -- ["3"]   = L["Ice Armor"],
        return {
            [EasyBuff.PLAYER] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["ICEARM"] = {
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
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["HEALER"] = true,
                },
            },
            ["ROGUE"] = {
            },
            ["PALADIN"] = {
                ["AI"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
        };
    end

    return {};
end
