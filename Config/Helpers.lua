-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Apply Keybind configurations to frame.
]]--
function EasyBuff:ConfigureKeybinds(castBuffBind, removeBuffBind)
    ClearOverrideBindings(ELVUI_EASYBUFF_ANNOUNCE_FRAME);
    if (nil ~= castBuffBind) then
		SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, castBuffBind, "ELVUI_EASYBUFF_PERFORM_BUTTON", castBuffBind);
	end
	if (nil ~= removeBuffBind) then
		SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, removeBuffBind, "ELVUI_EASYBUFF_PERFORM_BUTTON", removeBuffBind);
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
    Get the preferred spell (greater/lesser) for a given monitored spell.

    @param prefGreater    {boolean}        Do we prefer Greater spells
    @param monitoredSpell {MonitoredSpell} Original spell to use to find a preferred version of

    @return {MonitoredSpell}
]]--
function EasyBuff:GetPreferredMonitoredSpell(prefGreater, monitoredSpell)
    local found = nil;
    if (prefGreater and not monitoredSpell.greater) then
        found = EasyBuff:GetGreaterMonitoredSpell(monitoredSpell.group);
    elseif (monitoredSpell.greater and not prefGreater) then
        found = EasyBuff:GetLesserMonitoredSpell(monitoredSpell.group);
    end

    if (found ~= nil) then
        return found;
    end

    return monitoredSpell;
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
