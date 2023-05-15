-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Create Configuration Table
    @see http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
]]--
function EasyBuff:InitializeConfig()
    E.Options.args.EasyBuff = {
        type = "group",
        childGroups = "tab",
        name = EasyBuff.TITLE,
        args = {
            header = {
                order = 0,
                type = "header",
                name = format(L["%s (v%s) by %sFoosader|r"], EasyBuff.TITLE, EasyBuff.VERSION, EasyBuff.CLASS_COLOR.PALADIN)
            },
            enable = {
                order = 1,
                name = L["Enable"],
                desc = L["Enables / disables the addon"],
                type = "toggle",
                width = 1,
                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ENABLE); end,
                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ENABLE, val); EasyBuff:ToggleMonitoring(val); end
            },
            activeContext = {
                order = 2,
                name = L["Activity Context"],
                desc = L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."],
                type = "select",
                values = {
                    [EasyBuff.CONTEXT_AUTO]     = L["Auto-detect"],
                    [EasyBuff.CONTEXT.SOLO]     = L["Solo"],
                    [EasyBuff.CONTEXT.PARTY]    = L["Party"],
                    [EasyBuff.CONTEXT.RAID]     = L["Raid"],
                    [EasyBuff.CONTEXT.BG]       = L["Battleground"]
                },
                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.CONTEXT); end,
                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.CONTEXT, val); EasyBuff:SetActiveContext(); end
            },
            general = {
                order = 9,
                name = L["General"],
                type = "group",
                args = {
                    monitor = {
                        order = 10,
                        name = L["Monitoring"],
                        type = "group",
                        inline = true,
                        args = {
                            notifyEarly = {
                                name = L["Early Monitoring"],
                                desc = L["Announce and refresh buffs before they expire."],
                                order = 2,
                                width = 1,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_EARLY); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_EARLY, val); end
                            },
                            autoRemove = {
                                name = L["Auto-Remove before self-buff"],
                                desc = L["Automatically remove buff before applying new buff. Lesser buffs cannot overwrite greater, enabling this feature will ensure refreshing a buff doesn't error. This is only necessary with 'Early Monitoring' enabled."],
                                order = 3,
                                width = 3,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.SELF_REMOVE_EXIST); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.SELF_REMOVE_EXIST, val); end
                            },
                            weaponMonitoring = {
                                name = L["Enable Weapon Buff Monitoring"],
                                desc = L["Rogue and Shaman classes maintain buffs on their weapons, enable this feature to configure and track weapon buff monitoring."],
                                order = 4,
                                width = 2,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS, val); EasyBuff:BuildMonitoredWeaponBuffs(); end
                            }
                        }
                    },
                    announce = {
                        order = 11,
                        type = "group",
                        inline = true,
                        name = L["Announcements"],
                        args = {
                            announceLocation = {
                                name = L["Announce To"],
                                desc = L["How would you like to be notified of players missing Buffs?"].." "..L["HUD is a moveable frame, click 'Toggle Anchors' and move the frame labeled:"].."'Easy Buff Announcements'.",
                                order = 1,
                                type = "select",
                                values = {
                                    [EasyBuff.CFG_ANN_HUD]  = L["HUD"],
                                    [EasyBuff.CFG_ANN_CHAT] = L["Chat Window"]
                                },
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_LOCATION); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_LOCATION, val); end
                            },
                            announceWindow = {
                                name = L["Chat Window"],
                                desc = L["Select the Chat Window to display EasyBuff announcements in."],
                                order = 2,
                                type = "select",
                                disabled = function() return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_LOCATION) ~= EasyBuff.CFG_ANN_CHAT end,
                                values = EasyBuff.GetChatWindows,
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_WINDOW); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_WINDOW, val); end
                            },
                            spacer = {
                                order = 3,
                                name = "",
                                type = "description",
                                width = 2
                            },
                            announceContextChange = {
                                name = L["Announce Activity Context Change"],
                                desc = L["Enable / disable Activity Context Change announcements."],
                                order = 4,
                                width = 2,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_CTX_CHANGE); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_CTX_CHANGE, val); end
                            },
                            announceTalentSpecChange = {
                                name = L["Announce Talent Spec Context Change"],
                                desc = L["Enable / disable Talent Spec Context Change announcements."],
                                order = 5,
                                width = 2,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_TLNT_CHANGE); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_TLNT_CHANGE, val); end
                            }
                        }
                    },
                    keybind = {
                        order = 12,
                        type = "group",
                        inline = true,
                        name = L["Keybinds"],
                        args = {
                            [EasyBuff.CFG_KEY.BIND_CASTBUFF] = {
                                name = EasyBuff:Colorize(L["Buff Casting bound to key:"], EasyBuff.CHAT_COLOR),
                                desc = L["Change which key to use to apply buffs."],
                                order = 1,
                                width = 2,
                                type = "keybinding",
                                get = function(info) return GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF); end,
                                set = function(info, val) SetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF, val); end
                            },
                            [EasyBuff.CFG_KEY.BIND_WEAPONBUFF] = {
                                name = EasyBuff:Colorize(L["Weapon Buff bound to key:"], EasyBuff.CHAT_COLOR),
                                desc = L["Change which key to use to buff your weapons."],
                                disabled = function() return GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS) ~= true; end,
                                order = 2,
                                width = 2,
                                type = "keybinding",
                                get = function(info) return GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_WEAPONBUFF); end,
                                set = function(info, val) return SaveKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_WEAPONBUFF, val); end
                            },
                            [EasyBuff.CFG_KEY.BIND_REMOVEBUFF] = {
                                name = EasyBuff:Colorize(L["Buff Removal bound to key:"], EasyBuff.CHAT_COLOR),
                                desc = L["Change which key to use to remove unwanted buffs."],
                                order = 3,
                                width = 2,
                                type = "keybinding",
                                get = function(info) return GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_REMOVEBUFF); end
                            }
                              
                        }
                    },
                    quickSetup = {
                        order = 20,
                        type = "group",
                        inline = true,
                        name = L["Quick Setup"],
                        args = {
                            desc = {
                                order = 1,
                                type = "description",
                                width = "full",
                                name = L["Use the field below to apply a preset 'Player Buff Monitoring' configuration for all Activity Contexts."],
                            },
                            warn = {
                                order = 2,
                                type = "description",
                                width = "full",
                                fontSize = "medium",
                                name = EasyBuff:Colorize(L["WARNING: Selecting a Template will erase your current 'Player Buff Monitoring' configuration for ALL Activity Contexts and the selected Talent Spec!"], EasyBuff.COLORS.RED),
                            },
                            primaryTemplate = {
                                order = 3,
                                type = "select",
                                width = "double",
                                name = L["Select a Template to load for your 'Primary Talent Spec':"],
                                values = function() return EasyBuff:GetConfigTemplateOptions(EasyBuff.PLAYER_CLASS_KEY); end,
                                get = function() return ''; end,
                                set = function(info, val) return EasyBuff:ApplyConfigTemplate(EasyBuff.TALENT_SPEC_PRIMARY, EasyBuff.PLAYER_CLASS_KEY, val); end
                            },
                            secondaryTemplate = {
                                order = 4,
                                type = "select",
                                width = "double",
                                name = L["Select a Template to load for your 'Secondary Talent Spec':"],
                                values = function() return EasyBuff:GetConfigTemplateOptions(EasyBuff.PLAYER_CLASS_KEY); end,
                                get = function() return ''; end,
                                set = function(info, val) return EasyBuff:ApplyConfigTemplate(EasyBuff.TALENT_SPEC_SECONDARY, EasyBuff.PLAYER_CLASS_KEY, val); end
                            },
                        }
                    }
                }
            },
            SOLO = {
                order = 10,
                type = "group",
                childGroups = "tab",
                name = EasyBuff:ColorNameForContextTab(EasyBuff.CONTEXT.SOLO, L["Solo Activity"]),
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.SOLO)
            },
            PARTY = {
                order = 11,
                type = "group",
                childGroups = "tab",
                name = EasyBuff:ColorNameForContextTab(EasyBuff.CONTEXT.PARTY, L["Party Activity"]),
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.PARTY)
            },
            RAID = {
                order = 12,
                type = "group",
                childGroups = "tab",
                name = EasyBuff:ColorNameForContextTab(EasyBuff.CONTEXT.RAID, L["Raid Activity"]),
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.RAID)
            },
            BG = {
                order = 13,
                type = "group",
                childGroups = "tab",
                name = EasyBuff:ColorNameForContextTab(EasyBuff.CONTEXT.BG, L["Battleground Activity"]),
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.BG)
            }
        }
    };
end
