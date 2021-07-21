--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
	Config Options
	Initialize Configuration Options using AceConfig.
	@see http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
]]--
function EasyBuff:ConfigOptions()
	-- Build Config Options needed by Sections.
	local buffOptions = EasyBuff.CLASSES;
	buffOptions[EasyBuff.RELATION_SELF] = "|cff03fc07<"..L["Myself"]..">|r";
	local disabledBuffOptions = {};
	for k,v in pairs(buffOptions) do
		disabledBuffOptions[k] = k;
	end
	disabledBuffOptions = {[EasyBuff.RELATION_SELF] = "<"..L["Myself"]..">"};
	local soloAuraOptions, partyAuraOptions, raidAuraOptions, bgAuraOptions,
		selfOnlyOptions, partyMultiOptions, raidMultiOptions, bgMultiOptions = BuildSpellOptions(buffOptions, disabledBuffOptions);
	local trackOptions = BuildTrackingOptions();
	local weaponOptions = nil;
	local consumeOptions = nil;

	-- Generate Config Sections.
	local soloBuffCfg, partyBuffCfg, raidBuffCfg, bgBuffCfg = GenerateSpellBuffConfigSections(
		soloAuraOptions,
		partyAuraOptions,
		raidAuraOptions,
		bgAuraOptions,
		selfOnlyOptions,
		partyMultiOptions,
		raidMultiOptions,
		bgMultiOptions
	);
	local soloTrackingCfg, partyTrackingCfg, raidTrackingCfg, bgTrackingCfg = GenerateTrackingConfigSections(trackOptions);

	-- Set Configuration Options.
	E.Options.args.EasyBuff = {
		order = 100,
		type = "group",
		childGroups = "tab",
		name = EasyBuff.TITLE,
		args = {
			header1 = {
				order = 1,
				type = "header",
				name = format(L["%s (v%s) by %sPhoosa|r"], EasyBuff.TITLE, EasyBuff.VERSION, EasyBuff.CLASS_COLORS["DRUID"]),
			},
			wanted = {
				order = 2,
				type = "group",
				childGroups = "tab",
				name = L["Wanted Buffs"],
				args = {
					general = {
						name = L["General Settings"],
						order = 1,
						type = "group",
						args = {
							header = {
								order = 1,
								type = "description",
								name = format(L["Buff Casting bound to: %s"], EasyBuff:Colorize("Mousewheel Down", EasyBuff.CHAT_COLOR)),
								width = "full"
							},
							enable = {
								name = L["Enable"],
								desc = L["Enables / disables wanted buff monitoring"],
								order = 2,
								-- width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE); end,
								set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE, value); end
							},
							notifyEarly = {
								name = L["Early Monitoring"],
								desc = L["Announce and refresh buffs before they expire."],
								order = 3,
								-- width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_NOTIFY_EARLY); end,
								set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_NOTIFY_EARLY, value); end
							},
							removeExistingBuff = {
								name = L["Auto-Remove before self-buff"],
								desc = L["Automatically remove buff before applying new buff. Lesser buffs cannot overwrite greater, enabling this feature will ensure refreshing a buff doesn't error. This is only necessary with 'Early Monitoring' enabled."],
								order = 4,
								width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_REMOVE_EXISTING); end,
								set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_REMOVE_EXISTING, value); end
							},
							context = {
								name = L["Active Context"],
								desc = L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."],
								order = 5,
								type = "select",
								values = {
									[EasyBuff.CFG_CONTEXT_AUTO] = L["Auto-detect"],
									[EasyBuff.CONTEXT_SOLO]     = L["Solo"],
									[EasyBuff.CONTEXT_PARTY]    = L["Party"],
									[EasyBuff.CONTEXT_RAID]     = L["Raid"],
									[EasyBuff.CONTEXT_BG]       = L["Battleground"],
								},
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_CONTEXT); end,
								set = function(info, value)
									EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_CONTEXT, value);
									EasyBuff:UpdateContext();
								end
							},
							announceContextChange = {
								name = L["Announce Context Change"],
								order = 6,
								width = 2,
								type = "toggle",
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_CC); end,
								set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_CC, value); end
							},
							announce = {
								name = L["Announce To"],
								desc = L["How would you like to be notified of players missing Buffs?"],
								order = 7,
								type = "select",
								values = {
									[EasyBuff.CFG_ANN_HUD]  = L["HUD"],
									[EasyBuff.CFG_ANN_CHAT] = L["Chat Window"]
								},
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE); end,
								set = function(info, value)
									EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE, value);
									E.Options.args.EasyBuff.args.wanted.args.general.args.announceWindow.disabled = (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT);
								end
							},
							announceWindow = {
								name = L["Chat Window"],
								desc = L["Select the Chat Window to display Easy Buff announcements in."],
								order = 8,
								type = "select",
								disabled = (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT),
								values = EasyBuff.GetChatWindows,
								get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW); end,
								set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW, value); end
							}
						}
					},
					solo = {
						order = 2,
						type = "group",
						childGroups = "tab",
						name = L["Solo Context"],
						args = {
							spells = {
								order = 1,
								type = "group",
								name = L["Spell Buffs"],
								disabled = (soloAuraOptions == nil),
								args = soloBuffCfg or {}
							},
							consumes = {
								order = 2,
								type = "group",
								name = L["Food & Potion Buffs"],
								disabled = (consumeOptions == nil),
								hidden = (consumeOptions == nil),
								args = {}
							},
							weapons = {
								order = 3,
								type = "group",
								name = L["Weapon Enhancements"],
								disabled = (weaponOptions == nil),
								hidden = (weaponOptions == nil),
								args = {}
							},
							tracking = {
								order = 4,
								type = "group",
								name = L["Tracking Abilities"],
								disabled = (trackOptions == nil),
								args = soloTrackingCfg
							}
						}
					},
					party = {
						order = 3,
						type = "group",
						childGroups = "tab",
						name = L["Party Context"],
						args = {
							spells = {
								order = 1,
								type = "group",
								name = L["Spell Buffs"],
								disabled = (partyAuraOptions == nil),
								args = partyBuffCfg or {}
							},
							consumes = {
								order = 2,
								type = "group",
								name = L["Food & Potion Buffs"],
								disabled = (consumeOptions == nil),
								hidden = (consumeOptions == nil),
								args = {}
							},
							weapons = {
								order = 3,
								type = "group",
								name = L["Weapon Enhancements"],
								disabled = (weaponOptions == nil),
								hidden = (weaponOptions == nil),
								args = {}
							},
							tracking = {
								order = 4,
								type = "group",
								name = L["Tracking Abilities"],
								disabled = (trackOptions == nil),
								args = partyTrackingCfg or {}
							}
						}
					},
					raid = {
						order = 4,
						type = "group",
						childGroups = "tab",
						name = L["Raid Context"],
						args = {
							spells = {
								order = 1,
								type = "group",
								name = L["Spell Buffs"],
								disabled = (raidAuraOptions == nil),
								args = raidBuffCfg or {}
							},
							consumes = {
								order = 2,
								type = "group",
								name = L["Food & Potion Buffs"],
								disabled = (consumeOptions == nil),
								hidden = (consumeOptions == nil),
								args = {}
							},
							weapons = {
								order = 3,
								type = "group",
								name = L["Weapon Enhancements"],
								disabled = (weaponOptions == nil),
								hidden = (weaponOptions == nil),
								args = {}
							},
							tracking = {
								order = 4,
								type = "group",
								name = L["Tracking Abilities"],
								disabled = (trackOptions == nil),
								args = raidTrackingCfg or {}
							}
						}
					},
					bg = {
						order = 5,
						type = "group",
						childGroups = "tab",
						name = L["Battleground Context"],
						args = {
							spells = {
								order = 1,
								type = "group",
								name = L["Spell Buffs"],
								disabled = (bgAuraOptions == nil),
								args = bgBuffCfg or {}
							},
							consumes = {
								order = 2,
								type = "group",
								name = L["Food & Potion Buffs"],
								disabled = (consumeOptions == nil),
								hidden = (consumeOptions == nil),
								args = {}
							},
							weapons = {
								order = 3,
								type = "group",
								name = L["Weapon Enhancements"],
								disabled = (weaponOptions == nil),
								hidden = (weaponOptions == nil),
								args = {}
							},
							tracking = {
								order = 4,
								type = "group",
								name = L["Tracking Abilities"],
								disabled = (trackOptions == nil),
								args = bgTrackingCfg or {}
							}
						}
					}
				}
			},
			unwanted = {
				order = 3,
				type = "group",
				name = L["Unwanted Buffs"],
				args = {
					header = {
						order = 1,
						type = "description",
						name = format(L["Buff Removal bound to: %s"], EasyBuff:Colorize("Control + Mousewheel Down", EasyBuff.CHAT_COLOR)),
						width = "full"
					},
					enable = {
						name = L["Enable"],
						desc = L["Enables / disables removing unwanted buffs"],
						order = 2,
						width = "full",
						type = "toggle",
						get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE); end,
						set = function(info, value)
							EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE, value);
							EasyBuff:CreateUnwantedActionButton();
						end
					},
					autoRemove = {
						name = L["Auto-Remove"],
						desc = L["Autmatically remove unwanted buffs when OUT OF COMBAT"],
						order = 3,
						width = "full",
						type = "toggle",
						get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_AUTOREMOVE); end,
						set = function(info, value)
							EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_AUTOREMOVE, value);
							EasyBuff:CreateUnwantedActionButton();
						end
					},
					announce = {
						name = L["Announce To"],
						desc = L["How would you like to be notified of unwanted Buffs?"],
						order = 4,
						type = "select",
						values = {
							[EasyBuff.CFG_ANN_HUD]  = L["HUD"],
							[EasyBuff.CFG_ANN_CHAT] = L["Chat Window"]
						},
						get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE); end,
						set = function(info, value)
							EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE, value);
							E.Options.args.EasyBuff.args.unwanted.args.announceWindow.disabled = (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT);
						end
					},
					announceWindow = {
						name = L["Chat Window"],
						desc = L["Select the Chat Window to display Easy Buff Unwanted Buff announcements in."],
						order = 5,
						type = "select",
						disabled = (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT),
						values = EasyBuff.GetChatWindows,
						get = function(info, i) return EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW); end,
						set = function(info, value) EasyBuff:SetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW, value); end
					},
					addremove = {
						name = L["Add/Remove Unwanted Buffs"],
						desc = L["Add/Remove Buffs in the Unwanted Buff List. NOTE: This will force a UI reload."],
						type = "group",
						inline = true,
						order = 6,
						args = {
							addBuff = {
								name = L["Add Buff"],
								usage = L["Type the numeric ID of the buff you would like to add to the list of managed Unwanted Buffs."],
								order = 1,
								type = "input",
								pattern = "^[0-9][0-9]+$",
								get = function(info, i) end,
								set = function(info, i, value) EasyBuff:AddUnwantedBuff(i); end
							},
							removeBuff = {
								name = L["Remove Buff"],
								usage = L["Type the numeric ID of the buff you would like to remove from list of managed Unwanted Buffs."],
								order = 2,
								type = "input",
								pattern = "^[0-9][0-9]+$",
								get = function(info, i) end,
								set = function(info, i, value) EasyBuff:RemoveUnwantedBuff(i); end
							}
						}
					},
					auras = {
						name = L["Unwanted Buffs"],
						desc = L["Select which buffs you want to automatically remove when cast on you."],
						order = 7,
						type = "multiselect",
						width = "full",
						values = EasyBuff:GetUnwantedConfigAuras(),
						get = function(info, i) return EasyBuff:GetUnwantedAuraConfigValue(i); end,
						set = function(info, i, value) EasyBuff:SetUnwantedAuraConfigValue(i, value); end
					}
				}
			}
		}
	};
end


-- ========================================== --
--                                            --
-- Config Section Generators                  --
--                                            --
-- ========================================== --


--[[
	Generate Spell Buff Configuration
]]--
function GenerateSpellBuffConfigSections(soloAuraOptions,partyAuraOptions,raidAuraOptions,bgAuraOptions,selfOnlyOptions,partyMultiOptions,raidMultiOptions,bgMultiOptions)
	if (partyAuraOptions ~= nil) then
		partyAuraOptions["_h1"] = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		};
	end
	if (raidAuraOptions ~= nil) then
		raidAuraOptions["_h1"] = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		};
	end
	if (bgAuraOptions ~= nil) then
		bgAuraOptions["_h1"] = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		};
	end

	-- Prepare the Buff Config Sections.
	local soloBuffCfg = {
		general = {
			type = "group",
			name = L["General Context Settings"],
			order = 1,
			inline = true,
			args = {
				instanceOnly = {
					name = L["Disable when Resting"],
					desc = L["Disable Announcements and buffing when character is in a 'resting' area."],
					type = "toggle",
					order = 1,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, "notResting", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_SOLO, "notResting", EasyBuff.CFG_GROUP_GENERAL, value); end
				}
			}
		},
		selfBuffs = {
			name = L["Buffs to monitor on myself"],
			desc = L["Select the buffs that you want to monitor on yourself."],
			type = "multiselect",
			values = soloAuraOptions or {},
			hidden = (soloAuraOptions == nil),
			order = 2,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_SOLO, i, EasyBuff.RELATION_SELF, value); end
		}
	};
	local partyBuffCfg = {
		general = {
			type = "group",
			name = L["General Context Settings"],
			order = 1,
			inline = true,
			args = {
				selfOnlyCast = {
					name = L["Cast on self only"],
					desc = L["Disables mousewheel buff casting on players other than yourself. You will still be notified of other players needed buffs, but you will have to manually buff them."],
					type = "toggle",
					order = 1,
					width = 1,
					disabled = (selfOnlyOptions == nil),
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL, value); end
				},
				instanceOnly = {
					name = L["Instance Only"],
					desc = L["Disable Announcements and buffing when not in an instance."],
					type = "toggle",
					order = 2,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL, value); end
				}
			}
		},
		partyBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Party"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 11,
			inline = true,
			args =  partyAuraOptions or {}
		}
	};
	local raidBuffCfg = {
		general = {
			type = "group",
			name = L["General Context Settings"],
			order = 1,
			inline = true,
			args = {
				selfOnlyCast = {
					name = L["Cast on self only"],
					desc = L["Disables mousewheel buff casting on players other than yourself. You will still be notified of other players needed buffs, but you will have to manually buff them."],
					type = "toggle",
					order = 1,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL, value); end
				},
				instanceOnly = {
					name = L["Instance Only"],
					desc = L["Disable Announcements and buffing when not in an instance."],
					type = "toggle",
					order = 2,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL, value); end
				}
			}
		},
		raidBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Raid"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 11,
			inline = true,
			args =  raidAuraOptions or {}
		}
	};
	local bgBuffCfg = {
		general = {
			type = "group",
			name = L["General Context Settings"],
			order = 1,
			inline = true,
			args = {
				selfOnlyCast = {
					name = L["Cast on self only"],
					desc = L["Disables mousewheel buff casting on players other than yourself. You will still be notified of other players needed buffs, but you will have to manually buff them."],
					type = "toggle",
					order = 1,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL, value); end
				},
				instanceOnly = {
					name = L["Instance Only"],
					desc = L["Disable Announcements and buffing when not in an instance."],
					type = "toggle",
					order = 2,
					width = 1,
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL, value); end
				}
			}
		},
		bgBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Team"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 11,
			inline = true,
			args =  bgAuraOptions or {}
		}
	};
	if (selfOnlyOptions ~= nil) then
		partyBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyOptions,
			order = 10,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, i, EasyBuff.RELATION_SELF, value); end
		};
		raidBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyOptions,
			order = 10,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, i, EasyBuff.RELATION_SELF, value); end
		};
		bgBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyOptions,
			order = 10,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, i, EasyBuff.RELATION_SELF, value); end
		};
	end
	if (partyMultiOptions ~= nil) then
		partyBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 12,
			inline = true,
			args = partyMultiOptions
		};
	end
	if (raidMultiOptions ~= nil) then
		raidBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 12,
			inline = true,
			args = raidMultiOptions
		};
	end
	if (bgMultiOptions ~= nil) then
		bgBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 12,
			inline = true,
			args = bgMultiOptions
		};
	end

	return soloBuffCfg, partyBuffCfg, raidBuffCfg, bgBuffCfg;
end


--[[
	Generate Tracking Configuration
]]--
function GenerateTrackingConfigSections(trackOptions)
	if (trackOptions ~= nil) then
		local retVal = {};
		local cfgSets = {
			EasyBuff.CONTEXT_SOLO,
			EasyBuff.CONTEXT_PARTY,
			EasyBuff.CONTEXT_RAID,
			EasyBuff.CONTEXT_BG
		};
		for k, c in ipairs(cfgSets) do
			retVal[c] = {
				trackingType = {
					name = L["Tracking Type"],
					type = "select",
					desc = L["Select the tracking type that you want to monitor.\n"],
					style = "radio",
					values = trackOptions,
					get = function(info, i) return EasyBuff:GetContextTrackingValue(c); end,
					set = function(info, i, value) EasyBuff:SetContextTrackingValue(c, i, value); end
				}
			};
		end
		return retVal[EasyBuff.CONTEXT_SOLO], retVal[EasyBuff.CONTEXT_PARTY], retVal[EasyBuff.CONTEXT_RAID], retVal[EasyBuff.CONTEXT_BG];
	end

	return {}, {}, {}, {};
end


-- ========================================== --
--                                            --
-- Config Option Generators                   --
--                                            --
-- ========================================== --


function BuildSpellOptions(buffOptions, disabledBuffOptions)
	local soloAuras, partyAuras, raidAuras, bgAuras = nil;
	local selfOnlyBuffs, partyMulti, raidMulti, bgMulti = nil;

	-- Load Player Supported Buffs.
	local myAuras = EasyBuff:GetAvailableAuraGroups(EasyBuff.PLAYER_CLASS_ENGLISH);
	for k, v in pairs(myAuras) do
		local bo = buffOptions;
		local position = 10;
		local _, _, spellIcon, _, _, _, spellId = GetSpellInfo(v.name);
		local appendName = "";
		local appendMulti = "";

		-- Can we cast this buff?
		if (spellId == nil) then
			appendName = format(" %s(%s)|r", EasyBuff.ERROR_COLOR, L["not learned"]);
			if (not v.selfOnly) then
				bo = disabledBuffOptions;
			end
		end

		-- Add Buff Config Item to solo auras group.
		if (soloAuras == nil) then
			soloAuras = {};
		end
		soloAuras[k] = v.name..appendName;

		-- Add Buff Config Item to other groups.
		if (v.selfOnly) then
			if (selfOnlyBuffs == nil) then
				selfOnlyBuffs = {};
			end
			selfOnlyBuffs[k] = v.name..appendName;
		else
			if (partyAuras == nil) then
				partyAuras = {};
				raidAuras = {};
				bgAuras = {};
			end
			partyAuras[k] = {
				name = v.name..appendName,
				type = "multiselect",
				desc = L["Select the classes that you want to monitor for this buff.\n"],
				values = bo,
				disabled = (spellId == nil),
				order = position,
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, i); end,
				set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, i, value); end
			};
			raidAuras[k]  = {
				name = v.name..appendName,
				type = "multiselect",
				desc = L["Select the classes that you want to monitor for this buff.\n"],
				values = bo,
				disabled = (spellId == nil),
				order = position,
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, k, i); end,
				set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, k, i, value); end
			};
			bgAuras[k]    = {
				name = v.name..appendName,
				type = "multiselect",
				desc = L["Select the classes that you want to monitor for this buff.\n"],
				values = bo,
				disabled = (spellId == nil),
				order = position,
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, k, i); end,
				set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, k, i, value); end
			};

			-- Does this buff have a multi option?
			if (v.multiId ~= nil) then
				local _, _, multiIcon, _, _, _, multiId = GetSpellInfo(v.multiId);
				if (multiId == nil) then
					appendMulti = format(" %s(%s)|r", EasyBuff.ERROR_COLOR, L["not learned"]);
				end
				if (partyMulti == nil) then
					partyMulti = {};
					raidMulti = {};
					bgMulti = {};
				end
				-- Add the "Multi" config option
				partyMulti[k] = {
					name = v.multi..appendMulti,
					desc = format(L["Cast this instead of %s"], v.name),
					type = "toggle",
					disabled = (v.multiId == nil),
					width = "double",
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi"); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi", value); end
				};
				raidMulti[k] = {
					name = v.multi..appendMulti,
					desc = format(L["Cast this instead of %s"], v.name),
					type = "toggle",
					disabled = (v.multiId == nil),
					width = "double",
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi"); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi", value); end
				};
				bgMulti[k] = {
					name = v.multi..appendMulti,
					desc = format(L["Cast this instead of %s"], v.name),
					type = "toggle",
					disabled = (v.multiId == nil),
					width = "double",
					get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi"); end,
					set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi", value); end
				};
			end
		end
	end

	return soloAuras, partyAuras, raidAuras, bgAuras, selfOnlyBuffs, partyMulti, raidMulti, bgMulti;
end


--[[
	Build a Table of Selectable Tracking Options
]]--
function BuildTrackingOptions()
	local trackingAbilities = EasyBuff:GetAvailableTrackingAbilities();
	local trackOptions = nil;
	for k, v in pairs(trackingAbilities) do
		if (trackOptions == nil) then
			trackOptions = {};
		end
		trackOptions[k] = v.name;
	end

	return trackOptions;
end


-- ========================================== --
--                                            --
-- Configuration Getters/Setters              --
--                                            --
-- ========================================== --


--[[
	Get General Config Value
]]--
function EasyBuff:GetConfigValue(feature, group, setting)
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][feature][group][setting];
end


--[[
	Set General Config Value
]]--
function EasyBuff:SetConfigValue(feature, group, setting, value)
	E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][feature][group][setting] = value;
end


--[[
	Get Context Config Value
]]--
function EasyBuff:GetContextConfigValue(context, spell, key)
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context][key] ~= nil) then
		return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context][key][spell];
	end

	return nil;
end


--[[
	Set Context Config Value
]]--
function EasyBuff:SetContextConfigValue(context, spell, key, value)
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context][key] == nil) then
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context][key] = {};
	end

	E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context][key][spell] = value;
end


--[[
	Get Context Config Value
]]--
function EasyBuff:GetContextTrackingValue(context)
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_TRACKING][EasyBuff.CFG_GROUP_CONTEXT][context] ~= nil) then
		return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_TRACKING][EasyBuff.CFG_GROUP_CONTEXT][context];
	end

	return nil;
end


--[[
	Set Context Tracking Value
]]--
function EasyBuff:SetContextTrackingValue(context, key, value)
	if (value ~= true) then
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_TRACKING][EasyBuff.CFG_GROUP_CONTEXT][context] = nil;
	else
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_TRACKING][EasyBuff.CFG_GROUP_CONTEXT][context] = key;
	end
end


--[[
	Get Unwanted Auras
]]--
function EasyBuff:GetUnwantedAuras()
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS];
end


--[[
	Get Unwanted Aura Config Value
]]--
function EasyBuff:GetUnwantedAuraConfigValue(spellId)
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS][spellId];
end


--[[
	Set Unwanted Aura Config Value
]]--
function EasyBuff:SetUnwantedAuraConfigValue(spellId, value)
	E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS][spellId] = value;
	EasyBuff:CreateUnwantedActionButton();
end


--[[
	Add Unwanted Buff
]]--
function EasyBuff:AddUnwantedBuff(spellId)
	-- Check if spell is valid
	local spellInfo = {GetSpellInfo(spellId)};
	if (spellInfo[1] ~= nil) then
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS][spellId] = true;
		-- ReloadUI();
		E.Options.args.EasyBuff.args.unwanted.args.auras.values = EasyBuff:GetUnwantedConfigAuras();
	end
end


--[[
	Remove Unwanted Buff
]]--
function EasyBuff:RemoveUnwantedBuff(spellId)
	-- Check if spell is valid
	local spellInfo = {GetSpellInfo(spellId)};
	if (spellInfo[1] ~= nil) then
		if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS][spellId] ~= nil) then
			local newSpells = {};
			for k,v in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS]) do
				if (spellId ~= k) then
					newSpells[k] = v;
				end
			end
			E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_UNWANTED][EasyBuff.CFG_GROUP_AURAS] = newSpells;
			-- ReloadUI();
			E.Options.args.EasyBuff.args.unwanted.args.auras.values = EasyBuff:GetUnwantedConfigAuras();
		end
	end
end


--[[
	Get Config for Context
]]--
function EasyBuff:GetContextConfigValues(context)
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_FEATURE_WANTED][EasyBuff.CFG_GROUP_CONTEXT][context];
end


-- ========================================== --
--                                            --
-- Event Driven                               --
--                                            --
-- ========================================== --


--[[
	Initialize Config for Faction
]]--
function EasyBuff:InitializeForFaction(faction)
	-- NOTICE: No longer applicable in TBC
	-- if ("Alliance" == faction) then
	-- 	EasyBuff.CLASSES["SHAMAN"] = nil;
	-- else
	-- 	EasyBuff.CLASSES["PALADIN"] = nil;
	-- end

	EasyBuff:UpdateContext();
end


--[[
	Update/Set Player Professions
]]--
function EasyBuff:UpdateProfessions()
	-- Get my Professions
	local numSkills = GetNumSkillLines();
	for i = 1, numSkills do
		-- TODO: This will only work in english.
		-- refactor to use: https://wowwiki-archive.fandom.com/wiki/API_GetProfessionInfo
		local skillName, header = GetSkillLineInfo(i);
		if (EasyBuff.PROFESSIONS[skillName] ~= nil) then
			EasyBuff.PlayerProfessions[skillName] = true;
		end
	end
end


--[[
	Create Moveable Anchor Frame.
]]--
function EasyBuff:CreateAnchorFrame()
	E:CreateMover(ELVUI_EASYBUFF_ANNOUNCE_FRAME, "EasyBuff_Announce_Mover", "Easy Buff"..L["Announcements"]);
end


-- ========================================== --
--                                            --
-- Helpers                                    --
--                                            --
-- ========================================== --


--[[
	Get Config Key for Aura Group
]]--
function EasyBuff:GetAuraGroupConfigKey(auraGroupKey)
	local ag = EasyBuff:GetAuraGroup(auraGroupKey);
	if (ag == nil) then
		EasyBuff:Debug(format("!! Failed to find Aura Group for Key: %s", tostring(auraGroupKey)), 1);
		return nil;
	end
	local cfgKey = "multi";
	if (ag.selfOnly) then
		cfgKey = "self";
	end
	return cfgKey;
end


--[[
	Get Chat Windows
]]--
function EasyBuff:GetChatWindows()
	local ChatWindows = {};
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (tostring(name) ~= COMBAT_LOG) and (name:trim() ~= "") then
			ChatWindows[tostring(name)] = tostring(name);
		end
	end
	return ChatWindows;
end


--[[
	Generate multiselect config values for Unwanted Buffs
]]--
function EasyBuff:GetUnwantedConfigAuras()
	local unwanted = EasyBuff:GetUnwantedAuras();
	local unwantedDisplay = {};
	
	for auraId, auraEnabled in pairs(unwanted) do
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(auraId);
		if (name ~= nil) then
			unwantedDisplay[tostring(auraId)] = format("%s %s", name, EasyBuff:Colorize("("..auraId..")", EasyBuff.CHAT_COLOR));
		end
	end

	return unwantedDisplay;
end
