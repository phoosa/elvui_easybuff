-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Apply Keybind configurations to frame.
]]--
function EasyBuff:ConfigureKeybinds(castBuffBind, removeBuffBind, weaponBuffBind)
    ClearOverrideBindings(ELVUI_EASYBUFF_ANNOUNCE_FRAME);
    if (nil ~= castBuffBind) then
        SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, castBuffBind, "ELVUI_EASYBUFF_PERFORM_BUTTON", castBuffBind);
    end
    if (nil ~= removeBuffBind) then
        SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, removeBuffBind, "ELVUI_EASYBUFF_PERFORM_BUTTON", removeBuffBind);
    end
    if (nil ~= weaponBuffBind) then
        SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, weaponBuffBind, "ELVUI_EASYBUFF_PERFORM_BUTTON", weaponBuffBind);
    end
end


--[[
    Get a list of spellGroups that are 'aura' type spells from the availableSpells list.
]]--
function getAvailableSpellAuras()
    local auras = {};
    for k,spell in pairs(EasyBuff.availableSpells) do
        if (spell:spellGroup().aura == true and not auras[spell.group]) then
            auras[spell.group] = spell.group;
        end
    end
    return auras;
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
    Shuold we Hide the Role-based config toggles for Aura configurations?
    
    @return {boolean}
]]--
function EasyBuff:ShouldHideAuraRoleOption(talentSpec, context, targetClass, spellGroup)
    local savedConfig = GetPlayerConfig()[talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass];
    local checkVal;

    -- If any aura has a mixed config (some roles true, some false), then we shouldn't hide role options.
    if (EasyBuff.PLAYER_CLASS_KEY and EasyBuff.CLASS_SPELLS_GROUPS[EasyBuff.PLAYER_CLASS_KEY]) then
        for group, groupCfg in pairs(EasyBuff.CLASS_SPELLS_GROUPS[EasyBuff.PLAYER_CLASS_KEY]) do
            if (groupCfg.aura and savedConfig[group]) then
                if (nil == GetWantedBuffValue(talentSpec, context, targetClass, group)) then
                    return false;
                end
            end
        end
    end

    return true;
end


--[[
    Get the preferred spell (greater/lesser) for a given available spell.

    @param prefGreater    {boolean}        Do we prefer Greater spells
    @param monitoredSpell {MonitoredSpell} Original spell to use to find a preferred version of

    @return {MonitoredSpell}
]]--
function EasyBuff:GetPreferredMonitoredSpell(prefGreater, availableSpell)
    local found = nil;
    if (prefGreater and not availableSpell.greater) then
        -- Get a Greater version
        found = EasyBuff:GetGreaterMonitoredSpell(availableSpell.group);
    elseif (availableSpell.greater and not prefGreater) then
        -- Get a Lesser version
        found = EasyBuff:GetLesserMonitoredSpell(availableSpell.group);
    elseif (not EasyBuff.monitoredSpells[tostring(availableSpell.spellId)]) then
        -- Get one we can cast, because we don't know this one
        found = EasyBuff:GetMonitoredSpellFor(availableSpell);
    end

    if (found ~= nil) then
        return found;
    end

    return availableSpell;
end


--[[
    Get a castable spell that matches a given available spell.
    Attempt to return the same type (greater/lesser), but if none found then return
    whatever matches the spell group.

    @param availableSpell {MonitoredSpell} availableSpell
    @return {MonitoredSpell|nil}
]]--
function EasyBuff:GetMonitoredSpellFor(availableSpell)
    local alternate = nil;
    for spellId,monitoredSpell in pairs(EasyBuff.monitoredSpells) do
        if (monitoredSpell.group == availableSpell.group) then
            if (availableSpell.greater == monitoredSpell.greater) then
                return monitoredSpell;
            elseif (nil ~= alternate) then
                alternate = monitoredSpell;
            end
        end
    end

    return alternate;
end


--[[
    Search our Monitored Spells list for a Greater version of a given spell group

    @param spellGroup {string}

    @param {MonitoredSpell|nil}
]]--
function EasyBuff:GetGreaterMonitoredSpell(spellGroup)
    for k,v in pairs(EasyBuff.monitoredSpells) do
        if (v.group == spellGroup and v.greater) then
            return v;
        end
    end
    return nil;
end


--[[
    Search our Monitored Spells list for a Lesser version of a given spell group

    @param spellGroup {string}

    @param {MonitoredSpell|nil}
]]--
function EasyBuff:GetLesserMonitoredSpell(spellGroup)
    for k,v in pairs(EasyBuff.monitoredSpells) do
        if (v.group == spellGroup and not v.greater) then
            return v;
        end
    end
    return nil;
end
