--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local PLAYER_NAME, PLAYER_REALM = UnitName("player");
local PLAYER_REALM = GetRealmName();

P.EasyBuff = {
	[PLAYER_REALM] = {
		[PLAYER_NAME] = {
			wanted = {
				general = {
					enable = true,
					context = EasyBuff.CFG_CONTEXT_AUTO,
					announceContextChange = true,
					announce = EasyBuff.CFG_ANN_HUD,
					announceWindow = nil,
					notifyEarly = true,
					removeExistingBuff = true,
					keybinding = "MOUSEWHEELDOWN"
				},
				context = {
					solo = {
						-- This will be auto-populated with your characters buff abilities
						general = {
							notResting = false
						}
					},
					party = {
						general = {
							selfOnlyCast = false,
							instanceOnly = false
						},
                        role_tank = {
                            -- This will be auto-populated with your characters buff abilities
                        },
                        role_heal = {
                            -- This will be auto-populated with your characters buff abilities
                        },
                        role_dps = {
                            -- This will be auto-populated with your characters buff abilities
                        }
						-- This will be auto-populated with your characters buff abilities
					},
					raid = {
						general = {
							selfOnlyCast = false,
							instanceOnly = false
						},
                        role_tank = {
                            -- This will be auto-populated with your characters buff abilities
                        },
                        role_heal = {
                            -- This will be auto-populated with your characters buff abilities
                        },
                        role_dps = {
                            -- This will be auto-populated with your characters buff abilities
                        }
						-- This will be auto-populated with your characters buff abilities
					},
					bg = {
						general = {
							selfOnlyCast = false,
							instanceOnly = false
						}
						-- This will be auto-populated with your characters buff abilities
					}
				}
			},
			unwanted = {
				general = {
					enable = false,
					autoRemove = true,
					announce = EasyBuff.CFG_ANN_HUD,
					announceWindow = nil,
					removeInCombat = false,
					keybinding = "CTRL-MOUSEWHEELDOWN"
				},
				auras = {
					-- This list will be populated with additional aura's that you want to be notified about
					["25895"] = false,
					["1038"] = false
				}
			},
			tracking = {
				context = {
					solo = {
						-- This will be auto-populated with your characters buff abilities
					},
					party = {
						-- This will be auto-populated with your characters buff abilities
					},
					raid = {
						-- This will be auto-populated with your characters buff abilities
					},
					bg = {
						-- This will be auto-populated with your characters buff abilities
					}
				}
			},
			consumes = {},
			weapons = {}
		}
	}
};
