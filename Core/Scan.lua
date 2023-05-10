--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Scan units for missing buffs, then update our Announcement frame
]]--
function EasyBuff:ScanBuffs()
    if (EasyBuff.rebuildNextScan) then
        EasyBuff:BuildMonitoredSpells();
        EasyBuff.rebuildNextScan = false;
    end

    if (EasyBuff:canScan()) then
        -- Multi-dimensional list of buffs to apply ["unitName" => ["buffGroup" => MonitoredSpell]]
        local buffsToAnnounce = nil;

        -- Check yourself first.
        local missing = EasyBuff:GetMissingBuffs(EasyBuff.PLAYER, EasyBuff:GetUnitRole(EasyBuff.PLAYER), EasyBuff.PLAYER);
        if (missing) then
            if (buffsToAnnounce == nil) then
                buffsToAnnounce = {}
            end
            buffsToAnnounce[EasyBuff.PLAYER] = missing;
        end

        -- Check Party or Raid members.
        if (IsInGroup(LE_PARTY_CATEGORY_HOME) or IsInRaid(LE_PARTY_CATEGORY_HOME)) then
            for groupIndex=1, GetNumGroupMembers() do
                local unitName, groupRank, partyIndex, unitLevel, _, classKey, unitZone, isOnline, isDead, unitRole, unitIsML = GetRaidRosterInfo(groupIndex);
                -- Ignore self, Offline/Dead Group Members
                if (isOnline and not isDead and unitName ~= EasyBuff.PLAYER_NAME) then
                    missing = EasyBuff:GetMissingBuffs(unitName, EasyBuff:GetUnitRole(unitName), classKey);
                    if (missing) then
                        if (buffsToAnnounce == nil) then
                            buffsToAnnounce = {}
                        end
                        buffsToAnnounce[unitName] = missing;
                    end
                end
                groupIndex = groupIndex + 1;
            end
        end

        -- Replace the old buff queue with the new list.
        EasyBuff.wantedQueue = buffsToAnnounce;

        -- Check if we're missing our preffered tracking ability.
        EasyBuff:CheckMissingTrackingAbility();

        -- Announce Unbuffed Units
        EasyBuff:AnnounceUnbuffedUnits();
    end
end


--[[
    Check if we can Announce units in buff queue
]]--
function EasyBuff:canScan()
    local inInstance, instanceType = IsInInstance();

    if (
        (GetContextGeneralSettingsValue(EasyBuff.activeTalentSpec, EasyBuff.activeContext, EasyBuff.CFG_KEY.DISABLE_RESTING) and IsResting())
        or (GetContextGeneralSettingsValue(EasyBuff.activeTalentSpec, EasyBuff.activeContext, EasyBuff.CFG_KEY.DISABLE_NOINSTANCE) and not inInstance)
    ) then
        return false;
    end

    
    return true;
end


--[[
    Update wantedTracking if we're not currently tracking what the config says we should.
]]--
function EasyBuff:CheckMissingTrackingAbility()
    local preferred = GetTrackingConfig(EasyBuff.activeContext, EasyBuff.activeTalentSpec);
    if (preferred ~= nil) then
        preferred = tonumber(preferred);
    end

    if (preferred ~= EasyBuff.activeTracking) then
        for k, track in pairs(EasyBuff.TrackingAbilities) do
            if (track.textureId == preferred) then
                EasyBuff.wantedTracking = track;
                return;
            end
        end
    else
        EasyBuff.wantedTracking = nil;
    end
end


--[[
    Remove Buff from wanted queue
]]--
function EasyBuff:RemoveBuffFromQueue(unit, spellGroup)
    if (EasyBuff.wantedQueue and EasyBuff.wantedQueue[unit] and EasyBuff.wantedQueue[unit][spellGroup]) then
        EasyBuff.wantedQueue[unit][spellGroup] = nil;
    end
end


--[[
    Scan the Buffs on a unit and return a list of the buffs they are missing

    @param unit  {string} Character name, relation, or "player"
    @param role  {string} Party role designation (@see EasyBuff.ROLE)
    @param class {string} All caps english key for a class (ie: a key from EasyBuff.CLASS_ORDER)
]]--
function EasyBuff:GetMissingBuffs(unit, role, class)
    local index = 1;
    local buffsToAnnounce = {};
    local buffsFound = {};

    local castGreater = GetContextGeneralSettingsValue(EasyBuff.activeTalentSpec, EasyBuff.activeContext, EasyBuff.CFG_KEY.CAST_GREATER);

    -- Iterate over the units current buffs.
    local buff = EasyBuff:UnitBuff(unit, index);
    while (buff ~= nil) do
        -- Is this a spell that we can cast, and are we monitoring it?
        local availableSpell = EasyBuff.availableSpells[tostring(buff.spellId)];
        if (availableSpell and availableSpell:isMonitoring()) then
            buffsFound[availableSpell.group] = availableSpell;
            -- Is it expiring soon?
            if (EasyBuff:isTimeToNotifyBuff(buff)) then
                buffsToAnnounce[availableSpell.group] = EasyBuff:GetPreferredMonitoredSpell(castGreater, availableSpell);
                local spellName, _, _, _, _, _ = GetSpellInfo(buffsToAnnounce[availableSpell.group].id);
                buffsToAnnounce[availableSpell.group]:setName(spellName);
            end
        end
        -- get next buff
        index = index + 1;
        buff = EasyBuff:UnitBuff(unit, index);
    end

    -- Iterate over all monitored spells, those we didn't already find should be added to the announce list.
    for k,v in pairs(EasyBuff.monitoredSpells) do
        if (not buffsFound[v.group] and not buffsToAnnounce[v.group] and v:isMonitoringForRole(class, role)) then
            if (not buffsToAnnounce[v.group]) then
                buffsToAnnounce[v.group] = EasyBuff:GetPreferredMonitoredSpell(castGreater, v);
                local spellName, _, _, _, _, _ = GetSpellInfo(buffsToAnnounce[v.group].id);
                buffsToAnnounce[v.group]:setName(spellName);
            end
        end
    end

    return buffsToAnnounce;
end

--[[
	Helper function to get a valid party Role for a given unit
    Defaults to EasyBuff.ROLE.DAMAGER
]]--
function EasyBuff:GetUnitRole(unit)
    -- one of: TANK, HEALER, DAMAGER, NONE
    local role = UnitGroupRolesAssigned(unit);
    if (role == 'NONE') then
        role = EasyBuff.ROLE.DAMAGER;
    end
    return role;
end

--[[
    Get Unit Buff
    Wrapper for UnitBuff so I don't have to keep looking up the index values
]]--
function EasyBuff:UnitBuff(unit, index, filter)
    local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
        nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
        = UnitBuff(unit, index, filter);

    if (name == nil and spellId == nil) then
        return nil;
    end

    local maxCount = 1;
    if (EasyBuff.availableSpells[tostring(spellId)] and EasyBuff.availableSpells[tostring(spellId)].group.stacks) then
        maxCount = EasyBuff.availableSpells[tostring(spellId)].group.stacks;
    end

    local curTime = GetTime();

    return {
        name = name,
        icon = icon,
        count = count,
        maxCount = maxCount,
        debuffType = debuffType,
        duration = duration,
        expirationTime = expirationTime,
        remainingTime = (expirationTime - curTime),
        source = source,
        isStealable = isStealable,
        nameplateShowPersonal = nameplateShowPersonal,
        spellId = spellId,
        canApplyAura = canApplyAura,
        isBossDebuff = isBossDebuff,
        castByPlayer = castByPlayer,
        nameplateShowAll = nameplateShowAll,
        timeMod = timeMod
    };
end

--[[
    Evaluate the unitBuff to determine if it qualifies for early notification.
    - Is the buff expiring soon? (@see EasyBuff.EXPIRATION_MINIMUM)
    - Is it a stacking buff and has lost two-thirds of it's stacks?

    @param buff {object}  @see return value from EasyBuff:UnitBuff
]]--
function EasyBuff:isTimeToNotifyBuff(buff)
    if (GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_EARLY)) then
        if (buff.expirationTime > 0
            and buff.remainingTime <= (buff.duration * EasyBuff.EXPIRATION_PERCENT) + EasyBuff.EXPIRATION_BUFFER
            and buff.remainingTime <= EasyBuff.EXPIRATION_MINIMUM
        ) then
            return true;
        elseif (buff.maxCount > 1 and (3 * buff.count) <= buff.maxCount) then
            return true;
        end
    end

    return false;
end