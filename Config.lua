local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");



--[[
	Config Options
	Initialize Configuration Options using AceConfig.
	@see http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
]]--
function EasyBuff:ConfigOptions()
	local soloAuras = {
		_h1 = {
			name = L["Select who should be monitored for each Buff.  If none are selected, the Buff will not be monitored.\n"],
			type = "description",
			order = 1
		}
	};
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
	local partyMulti = {};
	local raidMulti = {};
	local bgMulti = {};
	local buffOptions = EasyBuff.CLASSES;
	buffOptions["self"] = "|cff03fc07<Myself>|r";
	local divider = {
		name = "",
		type = "header",
		order = 9
	};
	local isNotSelfOnly = false;

	-- Load Player Supported Buffs.
	local myAuras = EasyBuff:GetClassAuraGroups(EasyBuff.PLAYER_CLASS);
	for k, v in pairs(myAuras) do
		local bo = buffOptions;
		local position = 10;

		-- Is this a self-only buff?
		if (v.selfOnly ~= true) then
			isNotSelfOnly = true;
			-- Change the "order" so this buff displays at the top of the list.
			position = 5;
		end

		-- Does this buff have a multi option?
		if (v.multi ~= nil) then
			-- Add the "Multi" config option
			partyMulti[k] = {
				name = v.multi,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, "multi", value); end
			};
			raidMulti[k] = {
				name = v.multi,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, k, "multi", value); end
			};
			bgMulti[k] = {
				name = v.multi,
				desc = format(L["Cast this instead of %s"], v.name),
				type = "toggle",
				get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi"); end,
				set = function(info, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, k, "multi", value); end
			};
		end
		if (v.selfOnly) then
			bo = {["self"] = buffOptions[EasyBuff.RELATION_SELF]};
		end
		soloAuras[k]  = {
			name = v.name,
			type = "multiselect",
			values = {["self"] = buffOptions[EasyBuff.RELATION_SELF]},
			order = position,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, k, i); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_SOLO, k, i, value); end
		};
		partyAuras[k] = {
			name = v.name,
			type = "multiselect",
			values = bo,
			order = position,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, i); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_PARTY, k, i, value); end
		};
		raidAuras[k]  = {
			name = v.name,
			type = "multiselect",
			values = bo,
			order = position,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_RAID, k, i); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_RAID, k, i, value); end
		};
		bgAuras[k]    = {
			name = v.name,
			type = "multiselect",
			values = bo,
			order = position,
			get = function(info, i) return EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_BG, k, i); end,
			set = function(info, i, value) EasyBuff:SetContextConfigValue(EasyBuff.CONTEXT_BG, k, i, value); end
		};
	end

	-- Add Divider between Group buffs and Self-Only Buffs
	if (isNotSelfOnly) then
		partyAuras["_divider"] = divider;
		raidAuras["_divider"] = divider;
		bgAuras["_divider"] = divider;
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
						width = "full",
						type = "toggle",
						get = function(info, i) return EasyBuff:GetGeneralConfigValue("enable"); end,
						set = function(info, value) EasyBuff:SetGeneralConfigValue("enable", value); end
					},
					_sp1 = {
						type = "description",
						order = 2,
						width = "full",
						name = "\n"
					},
					context = {
						name = L["Active Context"],
						desc = L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."],
						order = 3,
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
					_sp2 = {
						type = "description",
						order = 4,
						width = "full",
						name = "\n"
					},
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
			solo = {
				order = 100,
				type = "group",
				-- childGroups = "tree",
				name = L["Solo Context"],
				args = {
					partyBuffs = {
						type = "group",
						name = L["Buffs"],
						order = 2,
						inline = true,
						args =  soloAuras
					}
				}
			},
			party = {
				order = 101,
				type = "group",
				name = L["Party Context"],
				args = {
					partyGroup = {
						type = "group",
						name = L["General Party Settings"],
						order = 1,
						inline = true,
						args = partyMulti
					},
					partyBuffs = {
						type = "group",
						name = L["Buffs"],
						order = 2,
						inline = true,
						args =  partyAuras
					}
				}
			},
			raid = {
				order = 102,
				type = "group",
				name = L["Raid Context"],
				args = {
					raidGroup = {
						type = "group",
						name = L["General Raid Settings"],
						order = 1,
						inline = true,
						args = raidMulti
					},
					raidBuffs = {
						type = "group",
						name = L["Buffs"],
						order = 2,
						inline = true,
						args =  raidAuras
					}
				}
			},
			bg = {
				order = 103,
				type = "group",
				name = L["Battleground Context"],
				args = {
					bgGroup = {
						type = "group",
						name = L["General Battleground Settings"],
						order = 1,
						inline = true,
						args = bgMulti
					},
					bgBuffs = {
						type = "group",
						name = L["Buffs"],
						order = 2,
						inline = true,
						args =  bgAuras
					}
				}
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
	return E.db.EasyBuff.general[key];
end


--[[
	Set General Config Value
]]--
function EasyBuff:SetGeneralConfigValue(key, value)
	E.db.EasyBuff.general[key] = value;
end


--[[
	Get Context Config Value
]]--
function EasyBuff:GetContextConfigValue(context, spell, key)
	if (E.db.EasyBuff.context[context][key] ~= nil) then
		return E.db.EasyBuff.context[context][key][spell];
	else
		return nil;
	end
end


--[[
	Set Context Config Value
]]--
function EasyBuff:SetContextConfigValue(context, spell, key, value)
	if (E.db.EasyBuff.context[context] == nil) then
		E.db.EasyBuff.context[context] = {};
	end
	if (E.db.EasyBuff.context[context][key] == nil) then
		E.db.EasyBuff.context[context][key] = {};
	end
	E.db.EasyBuff.context[context][key][spell] = value;
end


--[[
	Get Config for Context
]]--
function EasyBuff:GetContextConfigValues(context)
	if (E.db.EasyBuff.context[context] ~= nil) then
		return E.db.EasyBuff.context[context];
	else
		return nil;
	end
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