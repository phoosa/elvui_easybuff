--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");



--[[
	Config Options
	Initialize Configuration Options using AceConfig.
	@see http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
]]--
function EasyBuff:ConfigOptions()
	local soloAuras = {};
		
	
	local partyAuras = {
		_h1 = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		}
	};
	local raidAuras = {
		_h1 = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		}
	}
	local bgAuras = {
		_h1 = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		}
	};
	local selfOnlyBuffs = {};
	local partyMulti = {};
	local raidMulti = {};
	local bgMulti = {};
	local buffOptions = EasyBuff.CLASSES;
	buffOptions[EasyBuff.RELATION_SELF] = "|cff03fc07<"..L["Myself"]..">|r";
	local disabledBuffOptions = {[EasyBuff.RELATION_SELF] = "<"..L["Myself"]..">"};
	for k,v in pairs(buffOptions) do
		disabledBuffOptions[k] = k;
	end

	-- Load Player Supported Buffs.
	local myAuras = EasyBuff:GetClassAuraGroups(EasyBuff.PLAYER_CLASS);
	for k, v in pairs(myAuras) do
		local bo = buffOptions;
		local position = 10;
		local _, _, spellIcon, _, _, _, spellId = GetSpellInfo(v.name);
		local appendName = "";
		local appendMulti = "";

		-- Does this buff have a multi option?
		if (v.multi ~= nil) then
			local _, _, multiIcon, _, _, _, multiId = GetSpellInfo(v.multi);
			if (multiId == nil) then
				appendMulti = format(" %s(%s)|r", EasyBuff.ERROR_COLOR, L["not learned"]);
			end
			-- Add the "Multi" config option
			partyMulti[k] = {
				name = v.multi..appendMulti,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				disabled = (multiId == nil),
				width = "double",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi", value); end
			};
			raidMulti[k] = {
				name = v.multi..appendMulti,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				disabled = (multiId == nil),
				width = "double",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi", value); end
			};
			bgMulti[k] = {
				name = v.multi..appendMulti,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				disabled = (multiId == nil),
				width = "double",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi", value); end
			};
		end

		-- Can we cast this buff?
		if (spellId == nil) then
			appendName = format(" %s(%s)|r", EasyBuff.ERROR_COLOR, L["not learned"]);
			if (not v.selfOnly) then
				bo = disabledBuffOptions;
			end
		end

		-- Add Buff Config Item to each group.
		soloAuras[k] = v.name..appendName;
		if (v.selfOnly) then
			selfOnlyBuffs[k] = v.name..appendName;
		else
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
		end
	end

	-- Prepare the Party Buff Config Options
	local partyBuffCfg = {
		partyBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Party"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 3,
			inline = true,
			args =  partyAuras
		}
	};
	local raidBuffCfg = {
		raidBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Raid"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 3,
			inline = true,
			args =  raidAuras
		}
	};
	local bgBuffCfg = {
		bgBuffs = {
			type = "group",
			name = L["Buffs to Monitor on my Team"],
			desc = L["Select the buffs that you want to monitor, and who you would like to monitor for each buff."],
			order = 3,
			inline = true,
			args =  bgAuras
		}
	};
	if (selfOnlyBuffs) then
		partyBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyBuffs,
			order = 2,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, i, EasyBuff.RELATION_SELF, value); end
		};
		raidBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyBuffs,
			order = 2,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, i, EasyBuff.RELATION_SELF, value); end
		};
		bgBuffCfg["selfBuffs"] = {
			name = L["Self-Only Buffs to Monitor"],
			desc = L["Select the buffs that you want to keep on yourself when playing.\n"],
			type = "multiselect",
			values = selfOnlyBuffs,
			order = 2,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, i, EasyBuff.RELATION_SELF); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, i, EasyBuff.RELATION_SELF, value); end
		};
	end
	if (partyMulti) then
		partyBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 4,
			inline = true,
			args = partyMulti
		};
	end
	if (raidMulti) then
		raidBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 4,
			inline = true,
			args = raidMulti
		};
	end
	if (bgMulti) then
		bgBuffCfg["partyGroup"] = {
			type = "group",
			name = L["Greater Buffs"],
			desc = L["To cast the greater/multi version of a buff instead of the individual version, select it here. You must still have the lesser/individual version selected in order for the buff to be monitored."],
			order = 4,
			inline = true,
			args = bgMulti
		};
	end


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
				name = format(L["%s (v%s) by %sPhoosa|r"], EasyBuff.TITLE, EasyBuff.VERSION, EasyBuff.CLASS_COLORS["Druid"]),
			},
			general = {
				order = 2,
				type = "group",
				-- inline = true,
				name = L["General"],
				args = {
					enable = {
						name = L["Enable"],
						desc = L["Enables / disables the addon"],
						order = 1,
						width = 3.5,
						type = "toggle",
						get = function(info, i) return EasyBuff:GetGeneralConfigValue("enable"); end,
						set = function(info, value) EasyBuff:SetGeneralConfigValue("enable", value); end
					},
					context = {
						name = L["Active Context"],
						desc = L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."],
						order = 2,
						type = "select",
						values = {
							[EasyBuff.CFG_CONTEXT_AUTO] = L["Auto-detect"],
							[EasyBuff.CONTEXT_SOLO]     = L["Solo"],
							[EasyBuff.CONTEXT_PARTY]    = L["Party"],
							[EasyBuff.CONTEXT_RAID]     = L["Raid"],
							[EasyBuff.CONTEXT_BG]       = L["Battleground"],
						},
						get = function(info, i) return EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_CONTEXT); end,
						set = function(info, value)
							EasyBuff:SetGeneralConfigValue(EasyBuff.CFG_CONTEXT, value);
							EasyBuff:UpdateContext();
						end
					},
					_sp1 = {
						type = "header",
						order = 3,
						width = "full",
						name = ""
					},
					_announceGroup = {
						type = "group",
						order = 10,
						inline = true,
						name = L["Announcements"],
						args = {
							announceContextChange = {
								name = L["Announce Context Change"],
								order = 10,
								width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE_CC); end,
								set = function(info, value) EasyBuff:SetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE_CC, value); end
							},
							announce = {
								name = L["Announce To"],
								desc = L["How would you like to be notified of players missing Buffs?"],
								order = 11,
								type = "select",
								values = {
									[EasyBuff.CFG_ANN_HUD]  = L["HUD"],
									[EasyBuff.CFG_ANN_CHAT] = L["Chat Window"]
								},
								get = function(info, i) return EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE); end,
								set = function(info, value) 
									EasyBuff:SetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE, value);
									E.Options.args.EasyBuff.args.general.args.announceWindow.disabled = (EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT);
								end
							},
							announceWindow = {
								name = L["Chat Window"],
								desc = L["Select the Chat Window to display Easy Buff announcements in."],
								order = 12,
								type = "select",
								disabled = (EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE) ~= EasyBuff.CFG_ANN_CHAT),
								values = EasyBuff.GetChatWindows,
								get = function(info, i) return EasyBuff:GetGeneralConfigValue("announceWindow"); end,
								set = function(info, value) EasyBuff:SetGeneralConfigValue("announceWindow", value); end
							}
						}
					},
					_miscSettings = {
						type = "group",
						order = 15,
						inline = true,
						name = L["Miscellaneous"],
						args = {
							notifyEarly = {
								name = L["Early Monitoring"],
								desc = L["Announce and refresh buffs before they expire."],
								order = 10,
								width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_NOTIFY_EARLY); end,
								set = function(info, value) EasyBuff:SetGeneralConfigValue(EasyBuff.CFG_NOTIFY_EARLY, value); end
							},
							removeExistingBuff = {
								name = L["Auto-Remove before self-buff"],
								desc = L["Automatically remove buff before applying new buff. Lesser buffs cannot overwrite greater, enabling this feature will ensure refreshing a buff doesn't error. This is only necessary with 'Early Monitoring' enabled."],
								order = 10,
								width = "full",
								type = "toggle",
								get = function(info, i) return EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_REMOVE_EXISTING); end,
								set = function(info, value) EasyBuff:SetGeneralConfigValue(EasyBuff.CFG_REMOVE_EXISTING, value); end
							},
						}
					}
				}
			},
			solo = {
				order = 100,
				type = "group",
				-- childGroups = "tree",
				name = L["Solo Context"],
				args = {
					buffs = {
						type = "group",
						name = L["Buffs"],
						order = 2,
						inline = true,
						args = {
							selfBuffs = {
								name = L["Buffs to monitor on myself"],
								desc = L["Select the buffs that you want to monitor on yourself."],
								type = "multiselect",
								values = soloAuras,
								order = 4,
								get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, i, EasyBuff.RELATION_SELF); end,
								set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_SOLO, i, EasyBuff.RELATION_SELF, value); end
							}
						-- 	-- get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, k, i); end,
						-- 	-- set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_SOLO, k, i, value); end
						-- 	-- EasyBuff:GetContextConfigValue(context, spell, key)
						-- 	-- E.db.EasyBuff[EasyBuff.PLAYER_NAME].context[context][key][spell]
						-- 	-- return E.db.EasyBuff[EasyBuff.PLAYER_NAME].context[context][key][spell];
						-- 	-- Returns list of Classes
						-- 	-- Needs to return list of Buffs (ie: [MOTW, OOC])
							
						}
					}
				}
			},
			party = {
				order = 101,
				type = "group",
				name = L["Party Context"],
				args = partyBuffCfg
			},
			raid = {
				order = 102,
				type = "group",
				name = L["Raid Context"],
				args = raidBuffCfg
			},
			bg = {
				order = 103,
				type = "group",
				name = L["Battleground Context"],
				args = bgBuffCfg
			}
		}
	};
end


-- ========================================== --
--                                            --
-- Configuration Getters/Setters              --
--                                            --
-- ========================================== --


--[[
	Get General Config Value
]]--
function EasyBuff:GetGeneralConfigValue(key)
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].general[key];
end


--[[
	Set General Config Value
]]--
function EasyBuff:SetGeneralConfigValue(key, value)
	EasyBuff:Debug(format("SetConfig:General %s=%s", tostring(key), tostring(value)), 1);
	E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].general[key] = value;
end


--[[
	Get Context Config Value
]]--
function EasyBuff:GetContextConfigValue(context, spell, key)
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context][key] ~= nil) then
		return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context][key][spell];
	else
		return nil;
	end
end


--[[
	Set Context Config Value
]]--
function EasyBuff:SetContextConfigValue(context, spell, key, value)
	EasyBuff:Debug(format("SetConfig:Context %s-%s-%s=%s", tostring(context), tostring(key), tostring(spell), tostring(value)), 1);
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context] == nil) then
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context] = {};
	end
	if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context][key] == nil) then
		E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context][key] = {};
	end
	E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context][key][spell] = value;
end


--[[
	Get Config for Context
]]--
function EasyBuff:GetContextConfigValues(context)
	return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME].context[context];
end


-- ========================================== --
--                                            --
-- Event Handlers                             --
--                                            --
-- ========================================== --


--[[
	On Player Enter World
]]--
function EasyBuff:InitializeForFaction(faction)
	if ("Alliance" == faction) then
		EasyBuff.CLASSES["Shaman"] = nil;
	else
		EasyBuff.CLASSES["Paladin"] = nil;
	end

	EasyBuff:UpdateContext();
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