--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Scan units for missing buffs, then update our Announcement frame
]]--
function EasyBuff:ScanBuffs()
    EasyBuff:TryDebug('SCAN', 'rebuild monitor:'..tostring(EasyBuff.rebuildNextScan));
    if (EasyBuff.rebuildNextScan) then
        EasyBuff:BuildMonitoredSpells();
        EasyBuff:BuildMonitoredWeaponBuffs();
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
            EasyBuff:TryDebug('SCAN PLAYER DONE', 'Player missing buffs');
        else
            EasyBuff:TryDebug('SCAN PLAYER DONE', 'Player not missing buffs');
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
                        EasyBuff:TryDebug('SCAN PLAYER DONE', tostring(unitName)..' missing buffs');
                    else
                        EasyBuff:TryDebug('SCAN PLAYER DONE', tostring(unitName)..' not missing buffs');
                    end
                end
                groupIndex = groupIndex + 1;
            end
        end

        -- Replace the old buff queue with the new list.
        EasyBuff.wantedQueue = buffsToAnnounce;

        -- Check if we're missing weapon buffs.
        EasyBuff:CheckMissingWeaponBuffs();

        -- Check if we're missing our preffered tracking ability.
        EasyBuff:CheckMissingTrackingAbility();

        -- Check for unwanted buffs.
        EasyBuff:CheckUnwatedBuffs();

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
        or (nil ~= UnitCastingInfo(EasyBuff.PLAYER))
    ) then
        return false;
    end

    return true;
end


--[[
    Update the Unwanted Buff count
]]--
function EasyBuff:CheckUnwatedBuffs()
    local allUnwanted = GetUnwantedBuffs(EasyBuff.activeTalentSpec, EasyBuff.activeContext);

    local count = 0;

    if (allUnwanted) then
        -- Iterate over the units current buffs.
        local index = 1;
        local buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
        while (buff ~= nil) do
            -- Is this a spell we're trying to remove?
            if (allUnwanted[tostring(buff.name)]) then
                count = count + 1;
            end
            -- get next buff
            index = index + 1;
            buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
        end
    end

    EasyBuff.unwatedBuffs = count;
end


--[[
    Update wantedTracking if we're not currently tracking what the config says we should.
]]--
function EasyBuff:CheckMissingTrackingAbility()
    EasyBuff:TryDebug('SCAN TRACKING', '');
    local preferred = GetTrackingConfig(EasyBuff.activeContext, EasyBuff.activeTalentSpec);
    if (preferred ~= nil) then
        preferred = tonumber(preferred);
    end

    if (preferred ~= EasyBuff.activeTracking) then
        for k, track in pairs(EasyBuff.TrackingAbilities) do
            if (track.textureId == preferred) then
                EasyBuff.wantedTracking = track;
                EasyBuff:TryDebug('SCAN TRACKING DONE', 'missing/incorrect tracking');
                return;
            end
        end
    else
        EasyBuff:TryDebug('SCAN TRACKING DONE', 'correct tracking');
        EasyBuff.wantedTracking = nil;
    end
end


--[[
    Update wantedWeapon if we're missing or losing our weapon buffs soon.
]]--
function EasyBuff:CheckMissingWeaponBuffs()
    EasyBuff:TryDebug('SCAN WEAPONS', '');
    local wantedMH = nil;
    local wantedOH = nil;

    if (EasyBuff.monitoredWeaponBuffs ~= nil) then
        if (
            EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND] ~= nil
            or EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND] ~= nil
        ) then
            local currentBuffs = EasyBuff:CurrentWeaponBuffs();

            if (EasyBuff:isTimeToNotifyWeapon(currentBuffs[EasyBuff.CFG_KEY.MAIN_HAND], EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND])) then
                -- main hand missing buff or expiring soon
                wantedMH = EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND];
                EasyBuff:TryDebug('SCAN MH-WEAPON DONE', 'missing/incorrect buff');
            else
                EasyBuff:TryDebug('SCAN MH-WEAPON DONE', 'correct buff');
            end

            if (EasyBuff:isTimeToNotifyWeapon(currentBuffs[EasyBuff.CFG_KEY.OFF_HAND], EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND])) then
                -- off hand missing buff or expiring soon
                wantedOH = EasyBuff.monitoredWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND];
                EasyBuff:TryDebug('SCAN OH-WEAPON DONE', 'missing/incorrect buff');
            else
                EasyBuff:TryDebug('SCAN OH-WEAPON DONE', 'correct buff');
            end
        end
    end
    
    local wanted = nil;
    if (wantedMH ~= nil or wantedOH ~= nil) then
        wanted = {
            [EasyBuff.CFG_KEY.MAIN_HAND] = wantedMH,
            [EasyBuff.CFG_KEY.OFF_HAND] = wantedOH
        };
    end

    EasyBuff.wantedWeaponBuffs = wanted;
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
    Remove Weapon Buff from weapon queue
]]--
function EasyBuff:RemoveWeaponBuffFromQueue(weaponSlot)
    if (weaponSlot ~= nil and EasyBuff.wantedWeaponBuffs[weaponSlot] ~= nil) then
        EasyBuff.wantedWeaponBuffs[weaponSlot] = nil;
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
    Get information about weapon enchants
    Wrapper for GetWeaponEnchantInfo
]]--
function EasyBuff:CurrentWeaponBuffs()
    local hasMainHandEnchant,
        mainHandExpiration,
        mainHandCharges,
        mainHandEnchantID,
        hasOffHandEnchant,
        offHandExpiration,
        offHandCharges,
        offHandEnchantID = GetWeaponEnchantInfo();

    return {
        [EasyBuff.CFG_KEY.MAIN_HAND] = {
            isBuffed      = hasMainHandEnchant,
            effectId      = mainHandEnchantID,
            remainingTime = mainHandExpiration,
            charges       = mainHandCharges,
            -- itemInfo      = EasyBuff:GetWeaponBuffItemInfo(mainHandEnchantID)
        },
        [EasyBuff.CFG_KEY.OFF_HAND] = {
            isBuffed      = hasOffHandEnchant,
            effectId      = offHandEnchantID,
            remainingTime = offHandExpiration,
            charges       = offHandCharges,
            -- itemInfo      = EasyBuff:GetWeaponBuffItemInfo(offHandEnchantID)
        }
    }
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


--[[
    Evaluate the unitBuff to determine if it qualifies for early notification.
    - Is the buff expiring soon? (@see EasyBuff.EXPIRATION_MINIMUM)
    - Is it a stacking buff and has lost two-thirds of it's stacks?

    @param weaponInfo {object}          @see return value from EasyBuff:CurrentWeaponBuffs
    @param weaponBuff {WeaponBuff|nil} Weapon Buff we expect to have
]]--
function EasyBuff:isTimeToNotifyWeapon(weaponInfo, weaponBuff)
    if (weaponBuff == nil) then
        return false;
    elseif (weaponBuff ~= nil and not weaponInfo.isBuffed) then
        return true;
    elseif (tonumber(weaponInfo.effectId) ~= tonumber(weaponBuff.effectId)) then
        return true;
    elseif (
        GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_EARLY)
        and weaponInfo.remainingTime <= EasyBuff.EXPIRATION_MINIMUM
        -- TODO: Add support for `charges` if necessary
    ) then
        return true;
    end

    return false;
end
