--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Get one of the configuration templates for a DRUID
    @param index {int} number from 1-2
    @return {object}
]]--
function EasyBuff.ConfigTemplate.DRUID(index)
    if (1 == index) then
        -- ["1"]   = L["Feral"],
        return {
            [EasyBuff.PLAYER] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["WARRIOR"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["SHAMAN"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["ROGUE"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PALADIN"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
        };
    elseif (2 == index) then
        -- ["2"]   = L["Not Feral"],
        return {
            [EasyBuff.PLAYER] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DEATHKNIGHT"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["WARRIOR"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["SHAMAN"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["MAGE"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PRIEST"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["WARLOCK"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["HUNTER"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["DRUID"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
            ["ROGUE"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
            },
            ["PALADIN"] = {
                ["MOTW"] = {
                    ["DAMAGER"] = true,
                    ["TANK"] = true,
                    ["HEALER"] = true,
                },
                ["THORNS"] = {
                    ["TANK"] = true,
                },
            },
        };
    end

    return {};
end
