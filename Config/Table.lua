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
                            announceContextChange = {
                                name = L["Announce Activity Context Change"],
                                desc = L["Enable / disable Activity Context Change announcements."],
                                order = 3,
                                width = 6,
                                type = "toggle",
                                get = function(info) return GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_CTX_CHANGE); end,
                                set = function(info, val) SetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_CTX_CHANGE, val); end
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
                                width = "double",
                                type = "keybinding",
                                get = function(info) return GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF); end,
                                set = function(info, val) SetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF, val); end
                            },
                            [EasyBuff.CFG_KEY.BIND_REMOVEBUFF] = {
                                name = EasyBuff:Colorize(L["Buff Removal bound to key:"], EasyBuff.CHAT_COLOR),
                                desc = L["Change which key to use to remove unwanted buffs."],
                                order = 2,
                                width = "double",
                                type = "keybinding",
                                get = function(info) return GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_REMOVEBUFF); end,
                                set = function(info, val) return SaveKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_REMOVEBUFF, val); end
                            }
                        }
                    }
                }
            },
            SOLO = {
                order = 10,
                type = "group",
                childGroups = "tab",
                name = L["Solo Activity"],
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.SOLO)
            },
            PARTY = {
                order = 11,
                type = "group",
                childGroups = "tab",
                name = L["Party Activity"],
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.PARTY)
            },
            RAID = {
                order = 12,
                type = "group",
                childGroups = "tab",
                name = L["Raid Activity"],
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.RAID)
            },
            BG = {
                order = 13,
                type = "group",
                childGroups = "tab",
                name = L["Battleground Activity"],
                args = EasyBuff:GenerateConfig_Context(EasyBuff.CONTEXT.BG)
            }
        }
    };
end
