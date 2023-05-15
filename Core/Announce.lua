--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");
local LSM = E.Libs.LSM;

--[[
    Notify the player of the buffs missing from units.
]]--
function EasyBuff:AnnounceUnbuffedUnits()
    local textColor = "";
    ELVUI_EASYBUFF_ANNOUNCE_FRAME:Clear();

    if (EasyBuff.wantedWeaponBuffs ~= nil) then
        if (not EasyBuff:CanCastOnUnit(EasyBuff.PLAYER)) then
            textColor = EasyBuff.RANGE_COLOR;
        end
        if (EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND] ~= nil) then
            EasyBuff:AnnounceMessage(format(
                L["%s needs %s on %s"].."|r",
                EasyBuff:Colorize(EasyBuff.PLAYER_NAME, EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY])..textColor,
                tostring(EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.MAIN_HAND].name),
                EasyBuff:Colorize(L["Main Hand"], EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY])
            ));
        end
        if (EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND] ~= nil) then
            EasyBuff:AnnounceMessage(format(
                L["%s needs %s on %s"].."|r",
                EasyBuff:Colorize(EasyBuff.PLAYER_NAME, EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY])..textColor,
                tostring(EasyBuff.wantedWeaponBuffs[EasyBuff.CFG_KEY.OFF_HAND].name),
                EasyBuff:Colorize(L["Off Hand"], EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY])
            ));
        end
    end

    if (EasyBuff.wantedQueue ~= nil) then
        for unitName, buffGroup in pairs(EasyBuff.wantedQueue) do
            textColor = "";
            if (unitName == EasyBuff.PLAYER) then
                unitName = EasyBuff.PLAYER_NAME;
            elseif (not EasyBuff:CanCastOnUnit(unitName)) then
                textColor = EasyBuff.RANGE_COLOR;
            end
            for groupKey, monitored in pairs(buffGroup) do
                local _, enClass = UnitClass(unitName);
                EasyBuff:AnnounceMessage(format(L["%s needs %s"].."|r", EasyBuff:Colorize(unitName, EasyBuff.CLASS_COLOR[enClass])..textColor, tostring(monitored.name)));
            end
        end
    end
    if (EasyBuff.wantedTracking ~= nil) then
        EasyBuff:AnnounceMessage(format(L["%s needs %s"].."|r", EasyBuff:Colorize(EasyBuff.PLAYER_NAME, EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY]), tostring(EasyBuff.wantedTracking.name)));
    end

    if (EasyBuff.unwatedBuffs > 0) then
        EasyBuff:AnnounceMessage(EasyBuff:Colorize(format(L["YOU HAVE %d UNWANTED BUFFS!"], EasyBuff.unwatedBuffs), EasyBuff.COLORS.RED));
    end
end

--[[
    Announce Buff Message
]]--
function EasyBuff:AnnounceMessage(msg)
    local location = GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_LOCATION);
    if (location == EasyBuff.CFG_ANN_HUD) then
        ELVUI_EASYBUFF_ANNOUNCE_FRAME:AddMessage(msg, 1, 1, 1, 1.0);
    elseif (location == EasyBuff.CFG_ANN_CHAT) then
        EasyBuff:PrintToChat(msg);
    end
end

--[[
    Colorize Text
]]--
function EasyBuff:Colorize(text, color)
    return format("%s%s%s", tostring(color), tostring(text), "|r") ;
end

--[[
    Initialize Announce Frame
]]--
function EasyBuff:InitializeAnnounceFrame()
    ELVUI_EASYBUFF_ANNOUNCE_FRAME:FontTemplate(LSM:Fetch("font"));

    E:CreateMover(ELVUI_EASYBUFF_ANNOUNCE_FRAME, "EasyBuff_Announce_Mover", "Easy Buff "..L["Announcements"]);
end

--[[
    Print Message to Chat Frame
    @param msg    {string} The message to print
    @param window {string} The window to print the message in
]]--
function EasyBuff:PrintToChat(msg, window)
    if (window == nil) then
        local windowName = GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_WINDOW);
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
    Print a Console Message
]]--
function EasyBuff:ConsolePrint(msg)
    print(format("%s %s", EasyBuff:Colorize("[EasyBuff]", EasyBuff.CHAT_COLOR), tostring(msg)));
end

--[[
    Print a Debug Message if Debug is Enabled
]]--
function EasyBuff:TryDebug(event, msg)
    if (EasyBuff.DEBUG_ENABLED) then
        print(EasyBuff:Colorize('[DEBUG] ', EasyBuff.COLORS.RED)..EasyBuff:Colorize(event, EasyBuff.COLORS.BLUE)..' '..msg);
    end
end
