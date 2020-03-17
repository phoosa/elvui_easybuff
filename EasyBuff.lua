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
		self:Announce(EasyBuff.ERROR_COLOR..L["NO CONTEXT FOUND!"].."|r");
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
		if (EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE_CC)) then
			EasyBuff:Announce(EasyBuff.CLASS_COLORS["Warrior"]..format(L["Context changed to: %s"], EasyBuff:ContextKeyToLanguage(context)).."|r");
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
	if (EasyBuff:GetGeneralConfigValue("enable")) then
		EasyBuff:CastNextBuff();
	end
end


--[[
	On Global Mousewheel Down Post Action
	Perform the original Mousewheel Down action
]]--
function EasyBuff:OnPostClick(button, down)
	-- Zoom out, because we have taken over this command...
	-- @TODO: Make sure we know that's the command we have overridden.
	CameraZoomOut(1);
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
	if (EasyBuff:GetGeneralConfigValue("enable")) then
		if (unitTarget ~= "target") then
			local unitName = unitTarget;
			if (unitTarget == "player") then
				unitName = EasyBuff.PLAYER_NAME;
			end
			local spellInfo = {GetSpellInfo(spellId)};
			if (spellInfo ~= nil) then
				-- Was this the buff and unit we just queue'd up?
				if (ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("type") == "spell" and ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit") == unitName and ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell") == spellInfo[1]) then
					local auraGroupKey, auraGroup = EasyBuff:GetAuraGroupBySpellId(spellId);
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
						ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", nil);
						ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", nil);
						ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", nil);
						EasyBuff:CastNextBuff();
					end
				end
			end
		end
	end
end


--[[
	Update Context
	Figure out which context to operate in, and set this as the current context.
]]--
function EasyBuff:UpdateContext()
	-- Is Auto-Context Switching Enabled?
	local contextCfg = EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_CONTEXT);
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
	Cast Next Buff.
	Get the next unit/buff in the queue, and attempt to cast it
]]--
function EasyBuff:CastNextBuff(combatLockdown)
	-- Can we cast, and do we have buffs to cast?
	if (InCombatLockdown() or IsMounted() or EasyBuff.UnitBuffQueue == nil) then
		EasyBuff:Debug(format("Cast Prevented - InCombat:%s or IsMounted:%s or QueueEmpty:%s",
			tostring(InCombatLockdown()),
			tostring(IsMounted()),
			tostring(EasyBuff.UnitBuffQueue == nil)
		), 2);
	return end
	-- Throttle?
	if ((EasyBuff.LAST_CAST_TIME + EasyBuff.CAST_DELAY) > GetServerTime()) then
		EasyBuff:Debug("Cast Prevented - Throttled", 2);
	return end

	local canCast = false;
	if (not combatLockdown) then
		-- Perform the next Buff
		if (EasyBuff.UnitBuffQueue) then
			-- Get the next unit to buff
			for unitName,auraGroupKeys in pairs(EasyBuff.UnitBuffQueue) do
				-- Are there buffs to cast on this unit?
				if (table.getn(auraGroupKeys) > 0) then
					-- Can we cast on this unit?
					canCast = false;
					if (unitName == "player") then
						unitName = EasyBuff.PLAYER_NAME;
						canCast = true;
					else
						canCast = UnitInRange(unitName) and UnitIsVisible(unitName);
					end
					EasyBuff:Debug(format("Attempting Cast canCast[%s] unitName[%s] buff[%s]",
						tostring(canCast),
						unitName,
						auraGroupKeys[1]
					), 1);
					if (canCast) then
						-- Get the next spell to cast
						if (auraGroupKeys ~= nil and auraGroupKeys ~= {} and auraGroupKeys[1] ~= nil) then
							local spellId = EasyBuff:GetCastableGroupSpell(auraGroupKeys[1], EasyBuff:GetContextConfigValue(EasyBuff:GetContext(), auraGroupKeys[1], EasyBuff:GetAuraGroupConfigKey(auraGroupKeys[1])));
							if (spellId) then
								local spellInfo = {GetSpellInfo(spellId)};
								if (spellInfo ~= nil) then
									-- Remove existing buff?
									if (EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_REMOVE_EXISTING) and unitName == EasyBuff.PLAYER_NAME) then
										local ag = EasyBuff:GetAuraGroup(auraGroupKeys[1]);
										local checkSpellIds = {};
										for _k, _v in pairs(ag.ids) do
											if (_v ~= nil) then
												checkSpellIds[_v] = true;
											end
										end
										if (ag ~= nil and ag.ids) then
											local bcIndex = 1;
											local buffToCheck;
											while (bcIndex == 1 or (buffToCheck ~= nil and buffToCheck[10] ~= nil)) do
												buffToCheck = {UnitBuff(unitName, bcIndex)};
												if (buffToCheck ~= nil and buffToCheck[10] ~= nil) then
													if (checkSpellIds[buffToCheck[10]]) then
														-- print("Removing "..spellInfo[1]);
														EasyBuff:Debug(format("Remove Existing Buff unitName[%s] buff[%s]",
															unitName,
															buffToCheck[10]
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
	if (not InCombatLockdown()) then
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", type);
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", spellToCast);
		ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", unitName);
		EasyBuff.LAST_CAST_TIME = GetServerTime();
	end
end


--[[
	Remove Unit/Buff from Queue
	Unit No Longer Needs the Buff
]]--
function EasyBuff:RemoveFromBuffQueue(unitTarget, auraGroupKey)
	EasyBuff:Debug(format("BuffQueue:Remove [%s] from [%s]", tostring(auraGroupKey), unitTarget), 2);

	local found = false;
	if (EasyBuff.UnitBuffQueue[unitTarget] ~= nil) then
		local newList = {};
		for k,v in pairs(EasyBuff.UnitBuffQueue[unitTarget]) do
			if (v ~= auraGroupKey) then
				table.insert(newList, v);
			else
				found = true;
			end
		end
		EasyBuff.UnitBuffQueue[unitTarget] = newList;
	end
	EasyBuff:Debug(format("BuffQueue:Remove successful: %s", tostring(found)), 3);
end


--[[
	Announce units in buff queue
]]--
function EasyBuff:AnnounceUnbuffedUnits()
	if (EasyBuff.UnitBuffQueue ~= nil) then
		for unitName,auraGroupKeys in pairs(EasyBuff.UnitBuffQueue) do
			local textColor = "";
			if (auraGroupKeys ~= nil and auraGroupKeys ~= {} and auraGroupKeys[1] ~= nil) then
				if (unitName == "player") then
					unitName = EasyBuff.PLAYER_NAME;
				elseif (not UnitInRange(unitName)) then
					textColor = EasyBuff.RANGE_COLOR;
				end
				local spellId = EasyBuff:GetCastableGroupSpell(auraGroupKeys[1], EasyBuff:GetContextConfigValue(EasyBuff:GetContext(), auraGroupKeys[1], EasyBuff:GetAuraGroupConfigKey(auraGroupKeys[1])));
				if (spellId ~= nil) then
					local spellInfo = {GetSpellInfo(spellId)};
					if (spellInfo ~= nil) then
						EasyBuff:Announce(format(L["%s needs %s"].."|r", EasyBuff:Colorize(unitName, EasyBuff.CLASS_COLORS[UnitClass(unitName)])..textColor, tostring(spellInfo[1])));
					end
				end
			end
		end
	end
end


--[[
	Announce Message
]]--
function EasyBuff:Announce(msg)
	local announce = EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE);
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
		local windowName = EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_ANNOUNCE_WINDOW);
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

	-- Get Buffs monitored for the current context.
	local currentConfig = EasyBuff:GetContextConfigValues(EasyBuff:GetContext());

	-- Get the Buffs that I can monitor
	local monitoredSpells = EasyBuff:GetTrackedSpells();

	-- Closure, returns the keys from EasyBuff_AuraGroups for missing buffs
	local checkNeedsBuff = function(group, unit)
		local missingAuraGroupKeys = {};
		if (currentConfig[group] == nil) then
			-- No Config for this group.
			return nil;
		end
		-- Iterate over the buffs we track for this group
		for auraGroupKey,tracked in pairs(currentConfig[group]) do
			-- Only check for tracked buffs
			if (tracked == true) then
				-- Loop over the units buffs to see if they have this buff
				local buffFound = false;
				local index = 1;
				local buff = {UnitBuff(unit, 1)};
				while (buff ~= nil and buff[10] ~= nil) do
					-- Do we know this spellId, and is it part of the auragroup we are currently checking?
					local a = monitoredSpells[tostring(buff[10])];
					-- for z,b in pairs(a) do print(format("Key[%s] %s", z, tostring(b))) end
					if (a ~= nil and a.group == auraGroupKey) then
						buffFound = true;
						-- Is it expiring soon?
						if (EasyBuff:GetGeneralConfigValue(EasyBuff.CFG_NOTIFY_EARLY)) then
							if (buff[6] > 0 and (buff[5]*EasyBuff.EXPIRATION_PERCENT)+EasyBuff.EXPIRATION_BUFFER >= (buff[6]-curTime)) then
								table.insert(missingAuraGroupKeys, auraGroupKey);
							end
						end
					break end
					index = index + 1;
					buff = {UnitBuff(unit, index)};
				end
				-- Did we find the buff?
				if (buffFound == false) then
					table.insert(missingAuraGroupKeys, auraGroupKey);
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
			unitName, groupRank, partyIndex, unitLevel, unitClass, classFileName, unitZone, isOnline, isDead, unitRole, unitIsML = GetRaidRosterInfo(groupIndex);
			-- Ignore Offline Group Members and self
			if (isOnline) and (not isDead) and (unitName ~= EasyBuff.PLAYER_NAME) then
				-- Check Unit Buffs
				missingBuffs = checkNeedsBuff(unitClass, unitName);
				if (missingBuffs ~= nil and table.getn(missingBuffs)) then
					UnitsToBuff[unitName] = missingBuffs;
				end
			end
		end
	end

	-- Check Pets.
	-- TODO

	-- Rebuild persisted Units needing Buffs.
	if (next(UnitsToBuff) == nil) then
		EasyBuff.UnitBuffQueue = nil;
	else
		EasyBuff.UnitBuffQueue = UnitsToBuff;
	end
end
