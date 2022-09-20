--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


-- ========================================== --
--                                            --
-- State Getters/Setters                      --
--                                            --
-- ========================================== --


--[[
	Get Current Context
]]--
function EasyBuff:GetContext()
	if (EasyBuff.Context == nil) then
		-- This should never happen...
		self:AnnounceBuff(EasyBuff.ERROR_COLOR..L["NO CONTEXT FOUND!"].."|r");
		return EasyBuff.CONTEXT_SOLO;
	end
	return EasyBuff.Context;
end


--[[
	Set Context
	Also reset tracked units needing buffs
]]--
function EasyBuff:SetContext(context)
	-- Is the new context different from the old?
	if (context ~= EasyBuff.Context) then
		EasyBuff:Debug(format("Context Changing from %s to %s", tostring(EasyBuff.Context), tostring(context)), 1);
		-- Change the context
		EasyBuff.Context = context;
		-- Reset tracked units needing buffs
		EasyBuff.UnitBuffQueue = nil;
		if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_CC)) then
			EasyBuff:AnnounceBuff(EasyBuff.CLASS_COLORS["WARRIOR"]..format(L["Context changed to: %s"], EasyBuff:ContextKeyToLanguage(context)).."|r");
		end
	end
end


--[[
	Is the player current in an active Battleground?
]]--
function EasyBuff:IsInBG()
	local s = UnitInBattleground("player");
	if (s ~= nil) then
		return true;
	else
		return false;
	end
end


-- ========================================== --
--                                            --
-- Mouse Wheel Event Pre/Post Processors      --
--                                            --
-- ========================================== --


--[[
	On Global Mousewheel Down Pre Action
	Prepare and execute Spell Cast on Unit
]]--
function EasyBuff:OnPreClick(button, down)
	EasyBuff:Debug(format("EasyBuff:OnPreClick %s to %s", tostring(button), tostring(down)), 1);
	if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE) and not InCombatLockdown()) then
		EasyBuff:CastNextBuff();
	end
end


--[[
	On Global Mousewheel Down Post Action
	Perform the original Mousewheel Down action and reset the action button
]]--
function EasyBuff:OnPostClick(button, down)
	local unitTarget = ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit");
	local spellName = ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell");
	EasyBuff:UpdateCastButton(nil, nil, nil);
	if ("MOUSEWHEELDOWN" == button) then
		CameraZoomOut(1);
	elseif ("MOUSEWHEELUP" == button) then
		CameraZoomIn(1);
	end
	local spellInfo = {GetSpellInfo(spellName)};
	if (spellInfo ~= nil and spellInfo[7] ~= nil) then
		local spellId = spellInfo[7];
		local auraGroupKey, auraGroup = EasyBuff:GetAuraGroupBySpellId(spellId);
		EasyBuff:Debug(format("EasyBuff:OnPostClick unit=%s spell=%s key=%s", tostring(unitTarget), tostring(spellId), tostring(auraGroupKey)), 1);
		if (auraGroup ~= nil and auraGroupKey ~= nil) then
			EasyBuff:RemoveFromBuffQueue(unitTarget, auraGroupKey);
		end
	end
end


-- ========================================== --
--                                            --
-- Event Handler Actions                      --
--                                            --
-- ========================================== --


--[[
	On Spell Cast Succeeded
	Remove the unit/buff from the queue if we just performed a queue action.
]]--
function EasyBuff:OnSpellCastSucceeded(event, unitTarget, castGUID, spellId)
	if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE)) then
		if (unitTarget ~= "target") then
			local unitName = unitTarget;
			if (unitTarget == "player") then
				unitName = EasyBuff.PLAYER_NAME;
			end
			local spellInfo = {GetSpellInfo(spellId)};

			EasyBuff:Debug(format("OnSpellCastSucceeded[actual:button] - unit[%s==%s] spell[%s==%s] type[spell==%s] - spellInfo[isNil:%s]",
				tostring(unitName),tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit")),
				tostring(spellInfo[1]),tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell")),
				tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("type")),
				tostring((spellInfo == nil))
			), 2);
			if (spellInfo ~= nil) then
				-- Was this the buff and unit we just queue'd up?
				if (ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("type") == "spell" and ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit") == unitName and ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell") == spellInfo[1]) then
					local auraGroupKey, auraGroup = EasyBuff:GetAuraGroupBySpellId(spellId);
					EasyBuff:Debug(format("OnSpellCastSucceeded:RemoveFromBuffQueue - spellId[%s] auraGroupKey[%s] auraGroup[isNil:%s]",
						tostring(spellId),
						tostring(auraGroupKey),
						tostring(nil == auraGroup)
					), 2);

					EasyBuff:UpdateCastButton();

					if (auraGroup ~= nil and auraGroupKey ~= nil) then
						-- Remove the buff from the table.
						EasyBuff:RemoveFromBuffQueue(unitTarget, auraGroupKey);
					end

					EasyBuff:Debug(format("CastButton:Cleanup -Lockdown(%s)- %s[%s] for %s",
						tostring(InCombatLockdown()),
						tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("type")),
						tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell")),
						tostring(ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit"))
					), 2);
					if (not InCombatLockdown()) then
						EasyBuff:CastNextBuff();
					end
				end
			end
		end
	end
end

--[[
	On Combat End
	Cleanup the Cast Button if it's stale
]]--
function EasyBuff:OnCombatEnd(event)
	if (EasyBuff.UnitBuffQueue == nil) then
		EasyBuff:UpdateCastButton();
	end
end


--[[
	Update Context
	Figure out which context to operate in, and set this as the current context.
]]--
function EasyBuff:UpdateContext()
	-- Is Auto-Context Switching Enabled?
	local contextCfg = EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_CONTEXT);
	if (contextCfg == EasyBuff.CFG_CONTEXT_AUTO) then
		-- Is the player in a BG or Group?
		if (EasyBuff:IsInBG()) then
			EasyBuff:SetContext(EasyBuff.CONTEXT_BG);
		elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
			if (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
			-- elseif (GetNumGroupMembers() > 5) then
				EasyBuff:SetContext(EasyBuff.CONTEXT_RAID);
			else
				EasyBuff:SetContext(EasyBuff.CONTEXT_PARTY);
			end
		else
			EasyBuff:SetContext(EasyBuff.CONTEXT_SOLO);
		end
	elseif (contextCfg ~= nil) then
		EasyBuff:SetContext(contextCfg);
	else
		-- This should never happen
		EasyBuff:SetContext(EasyBuff.CONTEXT_SOLO);
	end
end


-- ========================================== --
--                                            --
-- Where the magic happens...                 --
--                                            --
-- ========================================== --


--[[
	Check if we config case allows us to cast the next buff
]]--
function EasyBuff:IsConfigCaseMetToCast()
	local context = EasyBuff:GetContext();
	if (context == EasyBuff.CONTEXT_SOLO) then
		if (IsResting() and EasyBuff:GetContextConfigValue(EasyBuff.CONTEXT_SOLO, "notResting", EasyBuff.CFG_GROUP_GENERAL)) then
			EasyBuff:Debug(format("Cannot cast while resting (context=%s)", tostring(context)), 3);
			return false;
		end
	else
		local inInstance, instanceType = IsInInstance();
		if (false == inInstance and EasyBuff:GetContextConfigValue(context, "instanceOnly", EasyBuff.CFG_GROUP_GENERAL)) then
			EasyBuff:Debug(format("Cannot cast unless in an instance (context=%s)", tostring(context)), 3);
			return false;
		end
	end
	return true;
end


--[[
	Check if we can cast the next buff
	Returns:
	   -2 - throttled
	   -1 - no buff in queue to cast
	    0 - cannot cast the next buff
	    1 - can cast the next buff, but only on self
	    2 - can cast the next buff, no conditions
]]--
function EasyBuff:CanCastNextBuff()
	if (EasyBuff.UnitBuffQueue == nil) then
		EasyBuff:Debug("Cast Prevented - QueueEmpty", 2);
		return -1;
	elseif ((EasyBuff.LastCastTime + EasyBuff.CAST_DELAY) > GetServerTime()) then
		EasyBuff:Debug("Cast Prevented - Throttled", 3);
		return -2;
	elseif (InCombatLockdown() or IsMounted() or false == EasyBuff:IsConfigCaseMetToCast()) then
		EasyBuff:Debug("Cast Prevented - In Combat or Mounted or Config Disabled", 3);
		return 0;
	end
	-- Can cast only on self?
	local selfOnlyCast = EasyBuff:GetContextConfigValue(EasyBuff:GetContext(), "selfOnlyCast", EasyBuff.CFG_GROUP_GENERAL);
	if (selfOnlyCast == true) then
		return 1;
	end
	-- no conditions, can cast next buff
	return 2;
end


--[[
	Cast Next Buff.
	Get the next unit/buff in the queue, and attempt to cast it
]]--
function EasyBuff:CastNextBuff()
	local canCastRule = EasyBuff:CanCastNextBuff();
	if (canCastRule > 0) then
		local canCast = false;
		-- Get the next unit to buff
		for unitName,auraGroupKeys in pairs(EasyBuff.UnitBuffQueue) do
			-- Are there buffs to cast on this unit?
			if (table.getn(auraGroupKeys) > 0) then
				local agType = auraGroupKeys[1].type;
				local agValue = auraGroupKeys[1].value;
				-- Can we cast on this unit?
				canCast = EasyBuff:CanCastOnUnit(unitName);
				if (unitName == "player") then
					unitName = EasyBuff.PLAYER_NAME;
				end
				if (unitName ~= EasyBuff.PLAYER_NAME and canCastRule == 1) then
					-- may only cast on self
					canCast = false;
				end
				EasyBuff:Debug(format("Attempting Cast canCast[%s] unitName[%s] %s[%s]",
					tostring(canCast),
					unitName,
					agType,
					tostring(agValue)
				), 1);
				if (canCast) then
					-- Get the next spell to cast
					if (agType ~= nil and agValue ~= nil) then
						local spellId = nil;
						if (agType == EasyBuff.CFG_FEATURE_WANTED) then
							spellId = EasyBuff:GetCastableGroupSpell(agValue, EasyBuff:GetContextConfigValue(EasyBuff:GetContext(), agValue, EasyBuff:GetAuraGroupConfigKey(agValue)));
						elseif (agType == EasyBuff.CFG_FEATURE_TRACKING) then
							spellId = EasyBuff:GetSpellIdForTracking(agValue);
						end
						if (spellId) then
							local spellInfo = {GetSpellInfo(spellId)};
							if (spellInfo ~= nil) then
								-- Remove existing buff?
								if (EasyBuff.CFG_FEATURE_WANTED == agType and EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_REMOVE_EXISTING) and unitName == EasyBuff.PLAYER_NAME) then
									local ag = EasyBuff:GetAuraGroup(agValue);
									local checkSpellIds = {};
									for _k, _v in pairs(ag.ids) do
										if (_v ~= nil) then
											checkSpellIds[_v] = true;
										end
									end
									if (ag ~= nil and ag.ids) then
										local bcIndex = 1;
										local buffToCheck;
										while (bcIndex == 1 or (buffToCheck ~= nil and buffToCheck.spellId ~= nil)) do
											buffToCheck = EasyBuff:UnitBuff(unitName, bcIndex);
											-- buffToCheck = {UnitBuff(unitName, bcIndex)};
											if (buffToCheck ~= nil and buffToCheck[10] ~= nil) then
												if (checkSpellIds[buffToCheck[10]]) then
													EasyBuff:Debug(format("Remove Existing Buff unitName[%s] buff[%s]",
														unitName,
														buffToCheck.spellId
													), 2);
													CancelUnitBuff("player", buffToCheck[10]);
												break end
											end
											bcIndex = bcIndex + 1;
										end
									end
								end
								-- Finally, buff the target
								EasyBuff:CastSpellOnTarget(spellInfo[1], unitName);
							end
						end
						break
					end
				end
			end
		end
	end
end


--[[
	Update Cast Button
]]--
function EasyBuff:UpdateCastButton(type, spell, unit)
	if (not InCombatLockdown()) then
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", type);
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", spell);
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", unit);
		return true;
	else
		EasyBuff:Debug("CANNOT UPDATE CAST BUTTON WHILE IN COMBAT", 1);
		return false;
	end
end


--[[
	Cast Spell on Target
	@NOTE: We can't simply execute a cast directly via a command, we have to route it through a button
]]--
function EasyBuff:CastSpellOnTarget(spellToCast, unitName)
	local type = "spell";
	if (not spellToCast) or (not unitName) then
		type = nil;
	end
	EasyBuff:Debug(format("Cast %s[%s] on Unit[%s] CombatLockdown:%s",
		tostring(type),
		spellToCast,
		unitName,
		tostring((InCombatLockdown()))
	), 3);
	if (EasyBuff:UpdateCastButton(type, spellToCast, unitName)) then
		EasyBuff.LastCastTime = GetServerTime();
	end
end


--[[
	Remove Unit/Buff from Queue
	Unit No Longer Needs the Buff
]]--
function EasyBuff:RemoveFromBuffQueue(unitTarget, auraGroupKey)
	EasyBuff:Debug(format("BuffQueue:Remove [%s] from [%s]", tostring(auraGroupKey), unitTarget), 2);

	if (EasyBuff.PLAYER_NAME == unitTarget) then
		unitTarget = "player";
	end

	local found = false;
	EasyBuff:Debug(format("BuffQueue:Remove check UNIT [%s]: Result: %s", tostring(unitTarget), tostring(EasyBuff.UnitBuffQueue[unitTarget] ~= nil)),3) ;
	if (EasyBuff.UnitBuffQueue[unitTarget] ~= nil) then
		local newList = {};
		for k,v in pairs(EasyBuff.UnitBuffQueue[unitTarget]) do
			EasyBuff:Debug(format("BuffQueue:Remove check[%s]: %s == %s", tostring(unitTarget), tostring(v.value), tostring(auraGroupKey)), 3);
			if (v.value ~= auraGroupKey) then
				table.insert(newList, v);
			else
				found = true;
			end
		end
		EasyBuff.UnitBuffQueue[unitTarget] = newList;
	end
	if (found) then
		EasyBuff:Debug(format("BuffQueue:Remove successful: %s", tostring(found)), 2);
	else
		EasyBuff:Debug(format("BuffQueue:Remove NOT successful: %s", tostring(found)), 2);
	end
end


--[[
	Check if we can Announce units in buff queue
]]--
function EasyBuff:CanAnnounce()
	return EasyBuff:IsConfigCaseMetToCast();
end


--[[
	Announce units in buff queue
]]--
function EasyBuff:AnnounceUnbuffedUnits()
	ELVUI_EASYBUFF_ANNOUNCE_FRAME:Clear();
	if (EasyBuff:CanAnnounce()) then
		if (EasyBuff.UnitBuffQueue ~= nil) then
			for unitName,auraGroupKeys in pairs(EasyBuff.UnitBuffQueue) do
				local textColor = "";
				if (auraGroupKeys ~= nil and auraGroupKeys ~= {} and auraGroupKeys[1] ~= nil) then
					local agType = auraGroupKeys[1].type;
					local agValue = auraGroupKeys[1].value;
					if (unitName == "player") then
						unitName = EasyBuff.PLAYER_NAME;
					elseif (not EasyBuff:CanCastOnUnit(unitName)) then
						textColor = EasyBuff.RANGE_COLOR;
					end
					local spellId = nil;
					if (agType == EasyBuff.CFG_FEATURE_WANTED) then
						spellId = EasyBuff:GetCastableGroupSpell(agValue, EasyBuff:GetContextConfigValue(EasyBuff:GetContext(), agValue, EasyBuff:GetAuraGroupConfigKey(agValue)));
					elseif (agType == EasyBuff.CFG_FEATURE_TRACKING) then
						spellId = EasyBuff:GetSpellIdForTracking(agValue);
					end
					if (spellId ~= nil) then
						local spellInfo = {GetSpellInfo(spellId)};
						if (spellInfo ~= nil) then
							_, enClass = UnitClass(unitName);
							EasyBuff:AnnounceBuff(format(L["%s needs %s"].."|r", EasyBuff:Colorize(unitName, EasyBuff.CLASS_COLORS[enClass])..textColor, tostring(spellInfo[1])));
						end
					end
				end
			end
		end
	end
end


--[[
	Announce Buff Message
]]--
function EasyBuff:AnnounceBuff(msg)
	local announce = EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE);
	if (announce == EasyBuff.CFG_ANN_HUD) then
		ELVUI_EASYBUFF_ANNOUNCE_FRAME:AddMessage(msg, 1, 1, 1, 1.0);
	elseif (announce == EasyBuff.CFG_ANN_CHAT) then
		EasyBuff:PrintToChat(msg);
	end
end


--[[
	Print Message to Chat Frame
]]--
function EasyBuff:PrintToChat(msg, window)
	if (window == nil) then
		local windowName = EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW);
		for i = 1, NUM_CHAT_WINDOWS, 1 do
			local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
			if (name) and (name:trim() ~= "") and (tostring(name) == tostring(windowName)) then
				window = i;
				break;
			end
		end
	end

	if (window ~= nil) then
		-- @NOTICE: Bypassing Ace:Print because it prepends the addon name
		_G["ChatFrame"..window]:AddMessage(format("%s %s", EasyBuff:Colorize("[EasyBuff]", EasyBuff.CHAT_COLOR), tostring(msg)));
	end
end


--[[
	Rebuild Buff Queue
	Iterate over the tracked units, and rebuild the buff queue
	@NOTE: LUA doesn't support removing named keys from a table, so we will rebuild the whole EasyBuff.UnitBuffQueue table each time
]]--
function EasyBuff:RebuildBuffQueue()
	EasyBuff:Debug(format("Rebuild Buff Queue"), 3);
	local unitName, groupRank, partyIndex, unitLevel, unitClass, classFileName, unitZone, unitOnline, unitIsDead, unitRole, unitIsML = nil;
	-- Temporary table used to rebuild EasyBuff.UnitBuffQueue
	local UnitsToBuff = {};
	local curTime = GetTime();

	local curContext = EasyBuff:GetContext();
	-- Get Buffs/Tracking monitored for the current context.
	local currentConfig = EasyBuff:GetContextConfigValues(curContext);
	local trackingAbility = EasyBuff:GetContextTrackingValue(curContext);

	-- Get the Buffs that I can monitor
	local monitoredSpells = EasyBuff:GetTrackedSpells();
	-- Reload the Tracked spells if for some reason we don't have any.
	-- I don't know why this sometimes happens.. but this should fix it
	if (monitoredSpells == nil) then
		EasyBuff:InitAuras();
		monitoredSpells = EasyBuff:GetTrackedSpells();
	end

	-- Closure, returns the keys from EasyBuff_AuraGroups for missing buffs
	local checkNeedsBuff = function(group, unit)
		local missingAuraGroupKeys = {};
		if (currentConfig[group] == nil) then
			-- No Config for this group.
			EasyBuff:Debug(format("BuffQueue: NO CONFIG FOR GROUP: %s", tostring(group)), 2);
			return nil;
		end
		-- Can we cast on this unit?
		if (EasyBuff:CanCastOnUnit(unit)) then
			-- Iterate over the buffs we track for this group
			for auraGroupKey,tracked in pairs(currentConfig[group]) do
				-- Only check for tracked buffs
				if (tracked == true) then
					-- Loop over the units buffs to see if they have this buff
					local buffFound = false;
					for index=1,40 do
						local buff = EasyBuff:UnitBuff(unit, index);
						-- local buff = {UnitBuff(unit, index)};
						if (buff ~= nil and buff.spellId ~= nil) then
							EasyBuff:Debug(format("RebuildBuffQueue:Check [%s] Buff [%s]", unit, buff.spellId), 3);
							-- Do we know this spellId, and is it part of the auragroup we are currently checking?
							local a = monitoredSpells[tostring(buff.spellId)];
							if (a ~= nil and a.group == auraGroupKey) then
								buffFound = true;
								-- Is it expiring soon?
								if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_NOTIFY_EARLY)) then
									if (buff.expirationTime > 0
										and buff.remainingTime <= (buff.duration*EasyBuff.EXPIRATION_PERCENT)+EasyBuff.EXPIRATION_BUFFER
										and buff.remainingTime <= EasyBuff.EXPIRATION_MINIMUM
									) then
										-- almost out of time
										EasyBuff:Debug(format("BuffQueue:Add [%s] to [%s] Almost out of Time", tostring(auraGroupKey), unit), 3);
										table.insert(missingAuraGroupKeys, {
											value = auraGroupKey,
											type = EasyBuff.CFG_FEATURE_WANTED
										});
									elseif (buff.maxCount > 2 and (3 * buff.count) <= buff.maxCount) then
										-- only 1 stack left
										EasyBuff:Debug(format("BuffQueue:Add [%s] to [%s] Almost out of Stacks", tostring(auraGroupKey), unit), 3);
										table.insert(missingAuraGroupKeys, {
											value = auraGroupKey,
											type = EasyBuff.CFG_FEATURE_WANTED
										});
									end
								end
								break
							elseif (a ~= nil) then
								EasyBuff:Debug(format("-- No Match [%s] Buff [%s]", auraGroupKey, a.group), 4);
							end
						end
					end
					-- Did we find the buff?
					if (buffFound == false) then
						EasyBuff:Debug(format("BuffQueue:Add [%s] to [%s] Buff not found after scanning [%d] Buffs", tostring(auraGroupKey), unit, 40), 3);
						table.insert(missingAuraGroupKeys, {
							value = auraGroupKey,
							type = EasyBuff.CFG_FEATURE_WANTED
						});
					end
				end
			end
		end
		
		if (table.getn(missingAuraGroupKeys) == 0) then
			missingAuraGroupKeys = nil;
		end
		return missingAuraGroupKeys;
	end

	-- Check yourself First.
	local missingBuffs = checkNeedsBuff(EasyBuff.RELATION_SELF, "player");
	if (missingBuffs ~= nil and table.getn(missingBuffs)) then
		UnitsToBuff["player"] = missingBuffs;
	end

	-- Check Party or Raid members.
	if (IsInGroup(LE_PARTY_CATEGORY_HOME) or IsInRaid(LE_PARTY_CATEGORY_HOME)) then
		for groupIndex=1,GetNumGroupMembers() do
			unitName, groupRank, partyIndex, unitLevel, _, classFileName, unitZone, isOnline, isDead, unitRole, unitIsML = GetRaidRosterInfo(groupIndex);
			-- Ignore Offline Group Members and self
			if (isOnline) and (not isDead) and (unitName ~= EasyBuff.PLAYER_NAME) then
				-- Check Unit Buffs
				missingBuffs = checkNeedsBuff(classFileName, unitName);
				if (missingBuffs ~= nil and table.getn(missingBuffs)) then
					UnitsToBuff[unitName] = missingBuffs;
				end
			end
		end
	end

	-- Check Pets.
	-- TODO

	-- Check Tracking Ability.
	if (trackingAbility ~= nil) then
		local count = GetNumTrackingTypes();
		for i=1,count do 
			local _, texture, active, _ = GetTrackingInfo(i);
			if (trackingAbility == texture and active ~= true) then
				if (UnitsToBuff["player"] == nil) then
					UnitsToBuff["player"] = {};
				end
				table.insert(UnitsToBuff["player"], {
					value = trackingAbility,
					type = EasyBuff.CFG_FEATURE_TRACKING
				});
			end
		end
	end

	-- Rebuild persisted Units needing Buffs.
	if (next(UnitsToBuff) == nil) then
		EasyBuff.UnitBuffQueue = nil;
	else
		EasyBuff.UnitBuffQueue = UnitsToBuff;
	end
end


--[[
	Helper function to determine if we can cast on a unit
]]--
function EasyBuff:CanCastOnUnit(unitName)
	local isSelf = (unitName == EasyBuff.PLAYER_NAME or unitName == "player");
	EasyBuff:Debug(format("CanCastOnUnit:%s self:%s range:%s visible:%s dead:%s", tostring(unitName), tostring(isSelf), tostring(UnitInRange(unitName)), tostring(UnitIsVisible(unitName)), tostring(UnitIsDead(unitName))), 2);

	return isSelf or (UnitInRange(unitName) and UnitIsVisible(unitName) and not UnitIsDead(unitName));
end
