-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Handle console commands
]]--
function EasyBuff:ConsoleCommand(input)

    -- Handle request:
    if (type(input) == "string" and string.len(input) > 0) then

        local args = {};
        for substring in input:gmatch("%S+") do
            table.insert(args, substring);
        end

        if (#args) then
            local cmd = table.remove(args, 1);
            if (EasyBuff.ConsoleCommands[cmd] ~= nil) then
                return EasyBuff.ConsoleCommands[cmd]['func'](args);
            end
        end
    end
    return ConsoleHelp();
end


--[[
    Display the 'Help' Command info
]]--
function ConsoleHelp()
    EasyBuff:ConsolePrint(EasyBuff:Colorize('COMMAND OPTIONS:', EasyBuff.CHAT_COLOR));
    for k,v in pairs(EasyBuff.ConsoleCommands) do
        EasyBuff:ConsolePrint(format('    %s     %s', EasyBuff:Colorize(k, EasyBuff.COLORS.ORANGE), v.desc));
    end
    EasyBuff:ConsolePrint('Example: '..EasyBuff:Colorize(format('/%s mon', EasyBuff.COMMAND), EasyBuff.COLORS.ORANGE));
end


--[[
    Display the 'Help' Command info
]]--
function ConsoleDebug(args)
    local opt = nil;
    local enable = not EasyBuff.DEBUG_ENABLED;

    if (args ~= nil and #args > 0) then

        opt = table.remove(args, 1);
        enable = (tonumber(opt) == 1);
    end
    EasyBuff.DEBUG_ENABLED = enable;

    if (EasyBuff.DEBUG_ENABLED) then
        EasyBuff:ConsolePrint(EasyBuff:Colorize('DEBUG MODE: ', EasyBuff.COLORS.RED)..EasyBuff:Colorize('enabled', EasyBuff.COLORS.GREEN));
    else
        EasyBuff:ConsolePrint(EasyBuff:Colorize('DEBUG MODE: ', EasyBuff.COLORS.RED)..EasyBuff:Colorize('disabled', EasyBuff.COLORS.RED));
    end
end


--[[
    Display the 'Available' Command info
]]--
function ConsoleAvail()
    EasyBuff:ConsolePrint(EasyBuff:Colorize('AVAILABLE TRACKING:', EasyBuff.CHAT_COLOR));
    for tid,track in pairs(EasyBuff.TrackingAbilities) do
        EasyBuff:ConsolePrint(format("[id:%s] Name:%s", EasyBuff:Colorize(tostring(tid), EasyBuff.COLORS.ORANGE), EasyBuff:Colorize(tostring(track.name), EasyBuff.COLORS.ORANGE)));
    end

    EasyBuff:ConsolePrint(EasyBuff:Colorize('AVAILABLE BUFFS:', EasyBuff.CHAT_COLOR));
    for sid,spell in pairs(EasyBuff.availableSpells) do
        local name = GetSpellInfo(spell.id);
        local rank = EasyBuff:Colorize(tostring(spell.rank), EasyBuff.COLORS.BLUE);
        local great = EasyBuff:Colorize("Yes", EasyBuff.COLORS.GREEN);
        if (not spell.greater) then
            great = EasyBuff:Colorize("No", EasyBuff.COLORS.RED);
        end
        local group = EasyBuff:Colorize(tostring(spell.group), EasyBuff.COLORS.BLUE);
        EasyBuff:ConsolePrint(format("[id:%s] Rank:%s Greater:%s Group:%s Name:%s",  EasyBuff:Colorize(tostring(sid), EasyBuff.COLORS.ORANGE), rank, great, group, EasyBuff:Colorize(tostring(name), EasyBuff.COLORS.ORANGE)));
    end
end


--[[
    Display the 'Monitor' Command info
]]--
function ConsoleMonitor()
    local preferred = nil;
    local active = nil;

    local preferredId = GetTrackingConfig(EasyBuff.activeContext, EasyBuff.activeTalentSpec);
    if (nil ~= preferredId) then
        preferred = EasyBuff.TrackingAbilities[tostring(preferredId)];
        if (nil ~= preferred) then
            preferred = format("[id:%s] Name: %s", EasyBuff:Colorize(tostring(preferred.textureId), EasyBuff.COLORS.ORANGE), EasyBuff:Colorize(tostring(preferred.name), EasyBuff.COLORS.ORANGE));
        end
    end
    if (nil == preferred) then
        preferred = EasyBuff.Colorize('NONE', EasyBuff.COLORS.RED);
    end

    if (nil ~= EasyBuff.activeTracking) then
        active = EasyBuff.TrackingAbilities[tostring(EasyBuff.activeTracking)];
        if (nil ~= active) then
            active = format("[id:%s] Name: %s", EasyBuff:Colorize(tostring(active.textureId), EasyBuff.COLORS.ORANGE), EasyBuff:Colorize(tostring(active.name), EasyBuff.COLORS.ORANGE));
        end
    end
    if (nil == active) then
        active = EasyBuff.Colorize('NONE', EasyBuff.COLORS.RED);
    end

    EasyBuff:ConsolePrint(EasyBuff:Colorize('MONITORED TRACKING:', EasyBuff.CHAT_COLOR));
    EasyBuff:ConsolePrint(format("Active Tracking: %s", active));
    EasyBuff:ConsolePrint(format("Preferred Tracking: %s", preferred));

    EasyBuff:ConsolePrint(EasyBuff:Colorize('MONITORED BUFFS:', EasyBuff.CHAT_COLOR));
    for sid,spell in pairs(EasyBuff.monitoredSpells) do
        local name = GetSpellInfo(spell.id);
        local rank = EasyBuff:Colorize(tostring(spell.rank), EasyBuff.COLORS.BLUE);
        local great = EasyBuff:Colorize("Yes", EasyBuff.COLORS.GREEN);
        if (not spell.greater) then
            great = EasyBuff:Colorize("No", EasyBuff.COLORS.RED);
        end
        local group = EasyBuff:Colorize(tostring(spell.group), EasyBuff.COLORS.BLUE);
        EasyBuff:ConsolePrint(format("[id:%s] Rank:%s Greater:%s Group:%s Name:%s",  EasyBuff:Colorize(tostring(sid), EasyBuff.COLORS.ORANGE), rank, great, group, EasyBuff:Colorize(tostring(name), EasyBuff.COLORS.ORANGE)));
    end
end


--[[
    Display the 'Status' Command info
]]--
function ConsoleStatus()
    EasyBuff:ConsolePrint(EasyBuff:Colorize('STATUS INFORMATION:', EasyBuff.CHAT_COLOR));
    local curMon  = EasyBuff:canScan();
    local enabled = GetGlobalSettingsValue(EasyBuff.CFG_KEY.ENABLE);
    local weapon  = GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS);
    local early   = GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_EARLY);
    local context = EasyBuff.activeContext;
    local talent  = EasyBuff.activeTalentSpec;
    local resting = GetContextGeneralSettingsValue(talent, context, EasyBuff.CFG_KEY.DISABLE_RESTING);
    local isRest  = IsResting();
    local instance= GetContextGeneralSettingsValue(talent, context, EasyBuff.CFG_KEY.DISABLE_NOINSTANCE);
    local inInstance, instanceType = IsInInstance();

    if (curMon) then
        curMon = EasyBuff:Colorize('Yes', EasyBuff.COLORS.GREEN);
    else
        curMon = EasyBuff:Colorize('No', EasyBuff.COLORS.RED);
    end

    if (enabled) then
        enabled = EasyBuff:Colorize('enabled', EasyBuff.COLORS.GREEN);
    else
        enabled = EasyBuff:Colorize('disabled', EasyBuff.COLORS.RED);
    end

    if (weapon) then
        weapon = EasyBuff:Colorize('enabled', EasyBuff.COLORS.GREEN);
    else
        weapon = EasyBuff:Colorize('disabled', EasyBuff.COLORS.RED);
    end

    if (early) then
        early = EasyBuff:Colorize('enabled', EasyBuff.COLORS.GREEN);
    else
        early = EasyBuff:Colorize('disabled', EasyBuff.COLORS.RED);
    end

    if (resting) then
        resting = EasyBuff:Colorize('No', EasyBuff.COLORS.RED);
    else
        resting = EasyBuff:Colorize('Yes', EasyBuff.COLORS.GREEN);
    end

    if (instance) then
        instance = EasyBuff:Colorize('Yes', EasyBuff.COLORS.GREEN);
    else
        instance = EasyBuff:Colorize('No', EasyBuff.COLORS.RED);
    end

    if (inInstance) then
        inInstance = EasyBuff:Colorize('Yes ['..tostring(instanceType)..']', EasyBuff.COLORS.GREEN);
    else
        inInstance = EasyBuff:Colorize('No', EasyBuff.COLORS.RED);
    end

    EasyBuff:ConsolePrint('Currently Monitoring: '..tostring(curMon));
    EasyBuff:ConsolePrint('Activity Context: '..EasyBuff:Colorize(tostring(context), EasyBuff.COLORS.GREEN));
    EasyBuff:ConsolePrint('Talent Spec Context: '..EasyBuff:Colorize(tostring(talent), EasyBuff.COLORS.GREEN));
    EasyBuff:ConsolePrint('Currently Resting: '..tostring(isRest));
    EasyBuff:ConsolePrint('Currently in Instance: '..tostring(inInstance));

    EasyBuff:ConsolePrint(EasyBuff:Colorize('CONFIG INFORMATION:', EasyBuff.COLORS.RED));
    EasyBuff:ConsolePrint('Character Buff Monitoring: '..tostring(enabled));
    EasyBuff:ConsolePrint('Player Weapon Monitoring: '..tostring(weapon));
    EasyBuff:ConsolePrint('Early Notifications: '..tostring(early));
    EasyBuff:ConsolePrint('Monitor when Resting: '..tostring(early));
    EasyBuff:ConsolePrint('Only Monitor in Instances: '..tostring(instance));
end


--
-- Command Map
--
EasyBuff.ConsoleCommands = {
    help = {
        desc = "Show this menu.",
        func = ConsoleHelp
    },
    debug = {
        desc = "Toggle debug mode to see events and processing",
        func = ConsoleDebug
    },
    avail = {
        desc = "Show the list of Spells, Tracking, and Weapon Buffs that are available for monitoring for you character",
        func = ConsoleAvail
    },
    mon = {
        desc = "Show the list of Spells, Tracking, and Weapon Buffs that are currently being monitored",
        func = ConsoleMonitor
    },
    stat = {
        desc = "Show current Status information, such as Context, Talent Spec, etc.",
        func = ConsoleStatus
    }
};
