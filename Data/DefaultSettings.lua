--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

P.EasyBuff = {
    [EasyBuff.PLAYER_REALM] = {
        [EasyBuff.PLAYER_NAME] = {
            [EasyBuff.CFG_GROUP.GLOBAL] = {
                [EasyBuff.CFG_KEY.ENABLE] = true,
                [EasyBuff.CFG_KEY.CONTEXT] = EasyBuff.CONTEXT_AUTO,
                [EasyBuff.CFG_KEY.ANN_LOCATION] = EasyBuff.CFG_ANN_HUD,
                [EasyBuff.CFG_KEY.ANN_WINDOW] = nil,
                [EasyBuff.CFG_KEY.ANN_CTX_CHANGE] = true,
                [EasyBuff.CFG_KEY.ANN_TLNT_CHANGE] = true,
                [EasyBuff.CFG_KEY.ANN_EARLY] = true,
                [EasyBuff.CFG_KEY.SELF_REMOVE_EXIST] = true,
                [EasyBuff.CFG_KEY.CFG_BY_SPEC] = true,
                [EasyBuff.CFG_KEY.CFG_BY_CONTEXT] = true
            },
            [EasyBuff.CFG_GROUP.KEYBIND] = {
                [EasyBuff.CFG_KEY.BIND_CASTBUFF] = "MOUSEWHEELDOWN",
                [EasyBuff.CFG_KEY.BIND_REMOVEBUFF] = "CTRL-MOUSEWHEELDOWN"
            },
            [EasyBuff.TALENT_SPEC_PRIMARY] = {
                [EasyBuff.CONTEXT.SOLO] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 1
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {}
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.PARTY] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 2
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.RAID] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 3
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.BG] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 1
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                }
            },
            [EasyBuff.TALENT_SPEC_SECONDARY] = {
                [EasyBuff.CONTEXT.SOLO] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 1
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {}
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.PARTY] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 2
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.RAID] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 3
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                },
                [EasyBuff.CONTEXT.BG] = {
                    [EasyBuff.CFG_GROUP.GENERAL] = {
                        [EasyBuff.CFG_KEY.DISABLE_RESTING] = false,
                        [EasyBuff.CFG_KEY.DISABLE_NOINSTANCE] = false,
                        [EasyBuff.CFG_KEY.SELF_ONLY_CAST] = true,
                        [EasyBuff.CFG_KEY.CAST_GREATER] = false,
                        [EasyBuff.CFG_KEY.CAST_GREATER_MIN] = 1
                    },
                    [EasyBuff.CFG_GROUP.UNWANTED] = {
                        
                    },
                    [EasyBuff.CFG_GROUP.WANTED] = {
                        [EasyBuff.PLAYER] = {},
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
                    },
                    [EasyBuff.CFG_GROUP.TRACKING] = {}
                }
            }
        }
    }
};
