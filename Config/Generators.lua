-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Colorize the name of the current context tab
]]--
function EasyBuff:ColorNameForContextTab(context, text)
    if (context == EasyBuff.activeContext) then
        return EasyBuff:Colorize(text, EasyBuff.COLORS.BLUE);
    end
    return text;
end


--[[
    Generate Configuration Table for a given context
    @return {object}
]]--
function EasyBuff:GenerateConfig_Context(context)
    local primaryName = L["Primary Spec"];
    local secondaryName = L["Secondary Spec"];

    if (EasyBuff.activeTalentSpec == EasyBuff.TALENT_SPEC_SECONDARY) then
        secondaryName = EasyBuff:Colorize(secondaryName, EasyBuff.COLORS.BLUE);
    else
        primaryName = EasyBuff:Colorize(primaryName, EasyBuff.COLORS.BLUE);
    end

    return {
        clone = {
            order = 0,
            type = "select",
            name = L["Copy Configuration From:"],
            desc = L["Select another Activity Context to copy it's configuration into this Activity Context."],
            values = function()
                local values = {};
                for k,v in pairs(EasyBuff.CONTEXT) do
                    if (k ~= context) then
                        values[k] = EasyBuff.CONTEXT_LABELS[k];
                    end
                end
                return values;
            end,
            get = function() return; end,
            set = function(info, val) CopyContextConfiguration(context, val); end,
        },
        primarySpec = {
            order = 1,
            type = "group",
            childGroups = "tab",
            name = primaryName,
            args = EasyBuff:GenerateConfig_TalentSpec(context, EasyBuff.TALENT_SPEC_PRIMARY)
        },
        secondarySpec = {
            order = 2,
            type = "group",
            childGroups = "tab",
            disabled = function() return 1 == GetNumTalentGroups(); end,
            name = secondaryName,
            args = EasyBuff:GenerateConfig_TalentSpec(context, EasyBuff.TALENT_SPEC_SECONDARY)
        }
    }
end


--[[
    Generate Configuration Table for a given Talent Spec
    @return {object}
]]--
function EasyBuff:GenerateConfig_TalentSpec(context, talentSpec)
    return {
        general = {
            order = 1,
            type = "group",
            inline = true,
            name = L["General"],
            args = {
                noResting = {
                    order = 1,
                    type = "toggle",
                    name = L["Disable when Resting"],
                    desc = L["Disable Monitoring when character is in a 'resting' area."],
                    get = function(info) return GetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.DISABLE_RESTING); end,
                    set = function(info, val) return SetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.DISABLE_RESTING, val); end
                },
                noInstance = {
                    order = 2,
                    type = "toggle",
                    name = L["Instance Only"],
                    desc = L["Disable Monitoring when not in an instance."],
                    get = function(info) return GetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.DISABLE_NOINSTANCE); end,
                    set = function(info, val) return SetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.DISABLE_NOINSTANCE, val); end
                },
                selfOnly = {
                    order = 3,
                    type = "toggle",
                    name = L["Cast on self only"],
                    desc = L["Disables buff casting on players other than yourself. You will still be notified of other players needed buffs but you will have to manually buff them."],
                    get = function(info) return GetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.SELF_ONLY_CAST); end,
                    set = function(info, val) return SetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.SELF_ONLY_CAST, val); end
                },
                castGreater = {
                    order = 4,
                    type = "toggle",
                    name = L["Cast Greater Buffs"],
                    desc = L["If a 'Greater' version of a buff exists, cast it instead of the 'Lesser'."],
                    get = function(info) return GetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.CAST_GREATER); end,
                    set = function(info, val) return SetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.CAST_GREATER, val); end
                }
            }
        },
        wanted = {
            order = 10,
            type = "group",
            childGroups = "tree",
            name = L["Player Buffs"],
            args = {
                player = {
                    order = 10,
                    name = EasyBuff:Colorize(L["Myself"], EasyBuff.CHAT_COLOR),
                    desc = L["Configure which buffs you would like to monitor on yourself."],
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, EasyBuff.PLAYER, talentSpec)
                },
                DEATHKNIGHT = {
                    order = 11,
                    name = EasyBuff:Colorize(L["Death Knight"], EasyBuff.CLASS_COLOR.DEATHKNIGHT),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'DEATHKNIGHT', talentSpec)
                },
                DRUID = {
                    order = 12,
                    name = EasyBuff:Colorize(L["Druid"], EasyBuff.CLASS_COLOR.DRUID),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'DRUID', talentSpec)
                },
                HUNTER = {
                    order = 13,
                    name = EasyBuff:Colorize(L["Hunter"], EasyBuff.CLASS_COLOR.HUNTER),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'HUNTER', talentSpec)
                },
                MAGE = {
                    order = 14,
                    name = EasyBuff:Colorize(L["Mage"], EasyBuff.CLASS_COLOR.MAGE),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'MAGE', talentSpec)
                },
                PALADIN = {
                    order = 15,
                    name = EasyBuff:Colorize(L["Paladin"], EasyBuff.CLASS_COLOR.PALADIN),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'PALADIN', talentSpec)
                },
                PRIEST = {
                    order = 16,
                    name = EasyBuff:Colorize(L["Priest"], EasyBuff.CLASS_COLOR.PRIEST),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'PRIEST', talentSpec)
                },
                ROGUE = {
                    order = 17,
                    name = EasyBuff:Colorize(L["Rogue"], EasyBuff.CLASS_COLOR.ROGUE),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'ROGUE', talentSpec)
                },
                SHAMAN = {
                    order = 18,
                    name = EasyBuff:Colorize(L["Shaman"], EasyBuff.CLASS_COLOR.SHAMAN),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'SHAMAN', talentSpec)
                },
                WARLOCK = {
                    order = 19,
                    name = EasyBuff:Colorize(L["Warlock"], EasyBuff.CLASS_COLOR.WARLOCK),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'WARLOCK', talentSpec)
                },
                WARRIOR = {
                    order = 20,
                    name = EasyBuff:Colorize(L["Warrior"], EasyBuff.CLASS_COLOR.WARRIOR),
                    desc = L["Configure which buffs you would like to monitor for this class."],
                    hidden = function() return context == EasyBuff.CONTEXT.SOLO; end,
                    type = "group",
                    childGroups = "tab",
                    args = EasyBuff:GenerateConfig_CastBuffs(context, 'WARRIOR', talentSpec)
                }
            }
        },
        weapon = {
            order = 11,
            type = "group",
            name = L["Weapon Buffs"],
            args = EasyBuff:GenerateConfig_WeaponBuffs(context, talentSpec)
        },
        tracking = {
            order = 12,
            type = "group",
            name = L["Tracking Ability"],
            args = {
                tracking = {
                    order = 1,
                    name = L["Tracking Ability"],
                    type = "select",
                    values = function(info)
                        local trackingOptions = {};
                        for id, track in pairs(EasyBuff.TrackingAbilities) do
                            trackingOptions[tostring(track.textureId)] = track.name;
                        end
                        return trackingOptions;
                    end,
                    get = function(info) return GetTrackingConfig(context, talentSpec); end,
                    set = function(info, val) return SetTrackingConfig(context, talentSpec, val); end
                },
            }
        },
        unwanted = {
            order = 13,
            type = "group",
            name = L["Unwanted Buffs"],
            args = GenerateConfig_Unwanted(talentSpec, context)
        }
    };
end


--[[
    Generate Configuration Table for Castable Buffs
    @return {object}
]]--
function EasyBuff:GenerateConfig_CastBuffs(context, targetClass, talentSpec)
    local config = {
        auraHeader = {
            order = 2,
            type = "header",
            name = L["Armor/Aura/Shield"],
            desc = L["Linked buffs that a player may only have one of."]
        },
        auras = {
            order = 3,
            name = "",
            type = "group",
            inline = true,
            args = {}
        },
        buffHeader = {
            order = 4,
            type = "header",
            name = L["Available Buffs"]
        },
        buffs = {
            order = 5,
            name = "",
            type = "group",
            inline = true,
            args = {}
        }
    };

    -- Load Spells
    local canCastGreater = GetContextGeneralSettingsValue(talentSpec, context, EasyBuff.CFG_KEY.CAST_GREATER);
    for index, spell in pairs(EasyBuff.availableSpells) do
        -- exclude selfOnly casts to other players
        if (targetClass == EasyBuff.PLAYER or (targetClass ~= EasyBuff.PLAYER and not spell:spellGroup().selfOnly)) then
            -- skip greater?
            if (
                not spell:spellGroup().multi
                or (spell:spellGroup().multi and ((canCastGreater and spell.greater) or (not canCastGreater and not spell.greater)))
            ) then
                -- Add spell to aura or group config if it hasn't already been added
                if (spell:spellGroup().aura and not config.auras.args[spell.group]) then
                    local name, _, _, _, _, _ = GetSpellInfo(spell.id);
                    config.auras.args[spell.group] = {
                        name = name,
                        type = "group",
                        inline = true,
                        args = {
                            all = {
                                name = L["Any Role"],
                                type = "toggle",
                                tristate = true,
                                get = function(info) return GetWantedBuffValue(talentSpec, context, targetClass, spell.group); end,
                                set = function(info, val) return SetWantedAuraValue(talentSpec, context, targetClass, spell.group, nil, val); end
                            },
                            tank = {
                                name = L["Tank"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return EasyBuff:ShouldHideAuraRoleOption(talentSpec, context, targetClass, spell.group); end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.TANK); end,
                                set = function(info, val) return SetWantedAuraValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.TANK, val); end
                            },
                            heal = {
                                name = L["Heal"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return EasyBuff:ShouldHideAuraRoleOption(talentSpec, context, targetClass, spell.group); end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.HEALER); end,
                                set = function(info, val) return SetWantedAuraValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.HEALER, val); end
                            },
                            dps = {
                                name = L["DPS"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return EasyBuff:ShouldHideAuraRoleOption(talentSpec, context, targetClass, spell.group); end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.DAMAGER); end,
                                set = function(info, val) return SetWantedAuraValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.DAMAGER, val); end
                            }
                        }
                    }
                elseif (not spell:spellGroup().aura and not config.buffs.args[spell.group]) then
                    local name, _, _, _, _, _ = GetSpellInfo(spell.id);
                    config.buffs.args[spell.group] = {
                        name = name,
                        type = "group",
                        inline = true,
                        args = {
                            all = {
                                name = L["Any Role"],
                                type = "toggle",
                                tristate = true,
                                get = function(info) return GetWantedBuffValue(talentSpec, context, targetClass, spell.group); end,
                                set = function(info, val) return SetWantedBuffValue(talentSpec, context, targetClass, spell.group, nil, val); end
                            },
                            tank = {
                                name = L["Tank"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return GetWantedBuffValue(talentSpec, context, targetClass, spell.group) ~= nil; end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.TANK); end,
                                set = function(info, val) return SetWantedBuffValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.TANK, val); end
                            },
                            heal = {
                                name = L["Heal"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return GetWantedBuffValue(talentSpec, context, targetClass, spell.group) ~= nil; end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.HEALER); end,
                                set = function(info, val) return SetWantedBuffValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.HEALER, val); end
                            },
                            dps = {
                                name = L["DPS"],
                                type = "toggle",
                                width = "half",
                                hidden = function() return GetWantedBuffValue(talentSpec, context, targetClass, spell.group) ~= nil; end,
                                get = function(info) return GetWantedBuffRoleValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.DAMAGER); end,
                                set = function(info, val) return SetWantedBuffValue(talentSpec, context, targetClass, spell.group, EasyBuff.ROLE.DAMAGER, val); end
                            }
                        }
                    }
                end
            end
        end
    end

    return config;
end


--[[
    Generate Configuration Table for Weapon Buffs
]]--
function EasyBuff:GenerateConfig_WeaponBuffs(context, talentSpec)
    if (
        EasyBuff.availableWeaponBuffs == nil
        or (EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL] == nil
        and EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM] == nil)
    ) then
        return {
            NONE = {
                type = "description",
                name = L["There are no trackable weapon buffs for your character at this time."]
            }
        };
    end

    local getWeaponBuffValues = function()
        local weaponBuffOptions = {};
        for buffType, weaponBuffs in pairs(EasyBuff.availableWeaponBuffs) do
            if (nil ~= weaponBuffs) then
                for k, weaponBuff in pairs(weaponBuffs) do
                    local name = weaponBuff.name;
                    if (weaponBuff.type == EasyBuff.WEAPON_BUFF_TYPE.SPELL) then
                        name = format("%s (%s)", weaponBuff.name, tostring(weaponBuff.rank));
                    end
                    weaponBuffOptions[weaponBuff.effectId] = name;
                end
            end
        end
        return weaponBuffOptions;
    end

    return {
        mainHand = {
            order = 1,
            type = "select",
            name = L["Main Hand"],
            desc = L["Configure which buffs you would like to monitor on your weapons."],
            disabled = function() return GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS) ~= true; end,
            width = 2,
            values = getWeaponBuffValues,
            sorting = EasyBuff.WEAPON_BUFF_SORT[EasyBuff.PLAYER_CLASS_KEY],
            get = function(info) return GetWantedWeaponBuffValue(talentSpec, context, EasyBuff.CFG_KEY.MAIN_HAND); end,
            set = function(info, val) SetWantedWeaponBuffValue(talentSpec, context, EasyBuff.CFG_KEY.MAIN_HAND, val); end
        },
        offHand = {
            order = 2,
            type = "select",
            name = L["Off Hand"],
            desc = L["Configure which buffs you would like to monitor on your weapons."],
            disabled = function() return GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS) ~= true; end,
            width = 2,
            values = getWeaponBuffValues,
            sorting = EasyBuff.WEAPON_BUFF_SORT[EasyBuff.PLAYER_CLASS_KEY],
            get = function(info) return GetWantedWeaponBuffValue(talentSpec, context, EasyBuff.CFG_KEY.OFF_HAND); end,
            set = function(info, val) SetWantedWeaponBuffValue(talentSpec, context, EasyBuff.CFG_KEY.OFF_HAND, val); end
        }
    }
end


--[[
    Generate Configuration Table for Unwanted Buffs
]]--
function GenerateConfig_Unwanted(talentSpec, context)
    return {
        addToList = {
            order = 0,
            type = "input",
            name = L["Add Unwanted Buff"],
            desc = L["Insert Spell name or id"],
            get = function(info) return ''; end,
            set = function(info, val) return SetNewUnwatedBuff(talentSpec, context, val); end
        },
        manage = {
            order = 11,
            type = "multiselect",
            name = L["Unwanted Buffs"],
            desc = L["Click to remove"],
            values = function(info) return GetUnwantedBuffs(talentSpec, context); end,
            get = function(info) return GetUnwantedBuffs(talentSpec, context); end,
            set = function(info, val) return SetUnwantedBuffs(talentSpec, context, val); end
        }
    };
end
