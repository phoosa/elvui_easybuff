--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");
local LSM = E.Libs.LSM;

--[[
    Notify the player of the buffs missing from units.
]]--
function EasyBuff:AnnounceUnbuffedUnits()
    ELVUI_EASYBUFF_ANNOUNCE_FRAME:Clear();

    if (EasyBuff:CanAnnounce()) then
        if (EasyBuff.wantedQueue ~= nil) then
            for unitName, buffGroup in pairs(EasyBuff.wantedQueue) do
                local textColor = "";
                if (unitName == EasyBuff.PLAYER) then
                    unitName = EasyBuff.PLAYER_NAME;
                elseif (not EasyBuff:CanCastOnUnit(unitName)) then
                    textColor = EasyBuff.RANGE_COLOR;
                end
                for groupKey, monitored in pairs(buffGroup) do
                    local _, enClass = UnitClass(unitName);
                    EasyBuff:AnnounceBuff(format(L["%s needs %s"].."|r", EasyBuff:Colorize(unitName, EasyBuff.CLASS_COLOR[enClass])..textColor, tostring(monitored.name)));
                end
            end
        end
        if (EasyBuff.wantedTracking ~= nil) then
            EasyBuff:AnnounceBuff(format(L["%s needs %s"].."|r", EasyBuff:Colorize(EasyBuff.PLAYER_NAME, EasyBuff.CLASS_COLOR[EasyBuff.PLAYER_CLASS_KEY]), tostring(EasyBuff.wantedTracking.name)));
        end
    end
end

--[[
    Check if we can Announce units in buff queue
]]--
function EasyBuff:CanAnnounce()
    return true;
end

--[[
    Announce Buff Message
]]--
function EasyBuff:AnnounceBuff(msg)
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
