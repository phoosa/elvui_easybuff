--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

EasyBuff.LastCastTime = 0;



--[[
    Find the next castable buff in the queue and attempt to cast it
]]--
function EasyBuff:CastNextBuffInQueue()
    local buffToCast = nil;
    local castTarget = nil;

    if (nil ~= EasyBuff.wantedQueue) then
        local castSelfOnly = GetContextGeneralSettingsValue(EasyBuff.activeTalentSpec, EasyBuff.activeContext, EasyBuff.CFG_KEY.SELF_ONLY_CAST);
        for unitName,spells in pairs(EasyBuff.wantedQueue) do
            if (unitName == EasyBuff.PLAYER or (not castSelfOnly and EasyBuff:CanCastOnUnit(unitName))) then
                for spellGroup,monitoredSpell in pairs(spells) do
                    buffToCast = monitoredSpell;
                    castTarget = unitName;
                    break;
                end
            end
        end
    end

    if (buffToCast ~= nil and castTarget ~= nil) then
        if (castTarget == EasyBuff.PLAYER and GetGlobalSettingsValue(EasyBuff.CFG_KEY.SELF_REMOVE_EXIST)) then
            EasyBuff:RemovePlayerBuff(buffToCast);
        end
        if (EasyBuff:CastSpellOnTarget(buffToCast.name, castTarget)) then
            return {
                unit = castTarget,
                spellGroup = buffToCast.group
            };
        end
    end

    return nil;
end

--[[
    Find and remove all unwanted buffs.
]]--
function EasyBuff:RemoveAllUnwantedBuffs()
    local allUnwanted = GetUnwantedBuffs(EasyBuff.activeTalentSpec, EasyBuff.activeContext);

    if (allUnwanted) then
        -- Iterate over the units current buffs.
        local index = 1;
        local buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
        while (buff ~= nil) do
            -- Is this a spell we're trying to remove?
            if (allUnwanted[tostring(buff.name)]) then
                CancelUnitBuff(EasyBuff.PLAYER, index);
            end
            -- get next buff
            index = index + 1;
            buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
        end
    end
end

--[[
    Remove any existing buffs on the player for this spell group

    @param spell {MonitoredSpell}
]]--
function EasyBuff:RemovePlayerBuff(spell)
    local spellIds = {};

    for sid, classSpell in pairs(EasyBuff.CLASS_SPELLS[EasyBuff.PLAYER_CLASS_KEY]) do
        if (classSpell.group == spell.group) then
            spellIds[sid] = true;
        end
    end

    -- Iterate over the units current buffs.
    local index = 1;
    local buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
    while (buff ~= nil) do
        -- Is this a spell we're trying to remove?
        if (spellIds[tostring(buff.spellId)]) then
            CancelUnitBuff(EasyBuff.PLAYER, index);
            -- set buff to nil so we stop looking.
            buff = nil;
        end
        -- get next buff
        index = index + 1;
        buff = EasyBuff:UnitBuff(EasyBuff.PLAYER, index);
    end
end


--[[
    Find the next weapon buff in the queue and attempt to cast it
    @return {string|nil}  identifier for weapon buffed (@see EasyBuff.CFG_KEY) or nil if none buffed
]]--
function EasyBuff:BuffNextWeaponInQueue()
    if (EasyBuff.wantedWeaponBuffs ~= nil) then
        if (EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND] ~= nil) then
            if (EasyBuff:WeaponBuff(
                EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND].type,
                EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND].typeId,
                EasyBuff.EQUIPMENT_SLOT[EasyBuff.CFG_KEY.MAIN_HAND])
            ) then
                return EasyBuff.CFG_KEY.MAIN_HAND;
            end
        elseif (EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND] ~= nil) then
            if (EasyBuff:WeaponBuff(
                EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND].type,
                EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND].typeId,
                EasyBuff.EQUIPMENT_SLOT[EasyBuff.CFG_KEY.OFF_HAND])
            ) then
                return EasyBuff.CFG_KEY.OFF_HAND;
            end
        end
    end

    return nil;
end


--[[
    Attempt to execute a macro to buff a weapon

    @param buffType {string} How the buff is applied (one of: EasyBuff.WEAPON_BUFF_TYPE)
    @param id       {int} ID of the item (in your bag) that you want to use, or spellId (determined by type)
    @param gearSlot {int} Equipment slot you want to buff (ie: weapons are 16 & 17)
]]--
function EasyBuff:WeaponBuff(buffType, id, gearSlot)
    local success = false;
    if (buffType == EasyBuff.WEAPON_BUFF_TYPE.ITEM) then
        success = EasyBuff:UpdatePerformCastButton(
            "macro",
            "/use item:"..tostring(id).."\n/use "..tostring(gearSlot).."\n/click StaticPopup1Button1",
            nil,
            nil);
    elseif (buffType == EasyBuff.WEAPON_BUFF_TYPE.SPELL) then
        success = EasyBuff:UpdatePerformCastButton("spell", id, nil, gearSlot);
    end

    if (success) then
        EasyBuff.LastCastTime = GetServerTime();
        return true;
    end

    return false;
end


--[[
    Attempt to cast a Spell (id or name) on a unit

    @param spell {string|int} Name or ID of spell to cast
    @param unit  {string}     Name of unit to cast the spell on
]]--
function EasyBuff:CastSpellOnTarget(spell, unit)
    if (EasyBuff:UpdatePerformCastButton("spell", spell, unit, nil)) then
        EasyBuff.LastCastTime = GetServerTime();
        return true;
    end
    return false;
end


--[[
    Update the action that our PERFORM button will execute.

    @param type     {string}      Type of action to perform (ie: "spell", "macro")
    @param spell    {string|int}  Name or ID of spell to cast (or macrotext if type is macro)
    @param unit     {string|null} Name of unit to cast the spell on (ignored if macro)
    @param unitAttr {string|nil}  Value for the target-slot attribute (ie 16, 17)

    @return {boolean}
]]--
function EasyBuff:UpdatePerformCastButton(type, spell, unit, targetSlot)
    if (not isCastingSpell() and not InCombatLockdown()) then
        if (unitAttr == nil) then
            unitAttr = "unit";
        end
        if (type == "spell") then
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", type);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", spell);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", unit);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("target-slot", targetSlot);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("macrotext", nil);
            return true;
        elseif (type == "macro") then
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", type);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("macrotext", spell);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", nil);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", nil);
            ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("target-slot", nil);
            return true;
        end
    end
    return false;
end


--[[
    Reset the Preform Cast Button
]]--
function EasyBuff:ResetPerformCastButton()
    ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("type", nil);
    ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("spell", nil);
    ELVUI_EASYBUFF_PERFORM_BUTTON:SetAttribute("unit", nil);
end


--[[
    Get cast button attributes
]]--
function EasyBuff:getCastButtonData()
    return {
        type = ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("type");
        unit = ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("unit");
        spell = ELVUI_EASYBUFF_PERFORM_BUTTON:GetAttribute("spell");
    };
end

--[[
    Determine if the player is currently casting a spell, or if the GCD is active
]]--
function isCastingSpell()
    local start, _ = GetSpellCooldown(61304);
    return start ~= 0;
end
