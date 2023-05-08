--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Register Callbacks to events used by EasyBuff.
]]--
function EasyBuff:RegisterEvents()

    self:RegisterEvent("PLAYER_ENTERING_WORLD",   "OnEnterWorld");
    self:RegisterEvent("SPELLS_CHANGED",          "OnSpellsChanged");
    self:RegisterEvent("GROUP_JOINED",            "OnGroupStatusChange");
    self:RegisterEvent("GROUP_FORMED",            "OnGroupStatusChange");
    self:RegisterEvent("GROUP_LEFT",              "OnGroupStatusChange");
    self:RegisterEvent("GROUP_ROSTER_UPDATE",     "OnGroupRosterChange");
    self:RegisterEvent("PLAYER_TALENT_UPDATE",    "OnTalentUpdate"); -- fired on talent spec change
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING", "OnTrackingAbilityChanged"); -- fired on tracking ability change, and enter instance

	-- self:RegisterEvent("SPELLS_CHANGED", "InitializePlayerData");
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateContext");
	-- self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateContext");
	-- self:RegisterEvent("GROUP_JOINED", "UpdateContext");
	-- self:RegisterEvent("GROUP_FORMED", "UpdateContext");
	-- self:RegisterEvent("GROUP_LEFT", "UpdateContext");
	-- self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateContext");
	-- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellCastSucceeded");
	-- self:RegisterEvent("UNIT_AURA", "OnUnitAura");
	-- self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd");

     -- fired on login, and enter dungeon
    -- self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChangeNewArea"); -- fired on enter dungeon
    -- self:RegisterEvent("ZONE_CHANGED", "OnZoneChange"); -- fired on tiny area change (like changing a room)

    -- self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatStart"); -- verified
    -- self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd"); -- verified

    

    -- Context / Roster Changes

    -- self:RegisterEvent("CONVERT_TO_RAID_CONFIRMATION", "OnGroupStatusChange");
    --self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupChange"); -- fired when dungeon difficulty changes, or player changes role

    -- Living/Dead Changes
    -- self:RegisterEvent("PLAYER_DEAD", "OnLivingStateChange");
    -- self:RegisterEvent("PLAYER_ALIVE", "OnLivingStateChange");
    -- self:RegisterEvent("PLAYER_UNGHOST", "OnLivingStateChange");

    -- Mount/Dismount
    -- self:RegisterEvent("COMPANION_UPDATE", "OnCompanionUpdate");

    -- Spell/Ability changes
    -- LEARNED_SPELL_IN_TAB
    -- CHARACTER_POINTS_CHANGED

    -- Button Hooks
    ELVUI_EASYBUFF_PERFORM_BUTTON:SetScript("PreClick", EasyBuff.OnPreClick);
    ELVUI_EASYBUFF_PERFORM_BUTTON:SetScript("PostClick", EasyBuff.OnPostClick);
end


--[[
    Before execute button click
]]--
function EasyBuff:OnPreClick(button, down)
    if (EasyBuff:canCast() and GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF) == button) then
        local result = EasyBuff:CastNextBuffInQueue();
        if (result ~= nil) then
            EasyBuff:RemoveBuffFromQueue(result.unit, result.spellGroup);
        end
    elseif (GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_REMOVEBUFF) == button) then
        EasyBuff:RemoveAllUnwantedBuffs();
    end
end


--[[
    After execute button click
]]--
function EasyBuff:OnPostClick(button, down)
    EasyBuff:ResetPerformCastButton();
    EasyBuff:activateCorrectTracking();

    local isMousewheelDown = string.find(button, "MOUSEWHEELDOWN");
    local isMousewheelUp = string.find(button, "MOUSEWHEELDOWN");
    if (isMousewheelDown ~= nil) then
        CameraZoomOut(1);
    elseif (isMousewheelUp ~= nil) then
        CameraZoomIn(1);
    end
end


--[[
    On Player Enter World
    verified: fired on login, and enter dungeon
]]--
function EasyBuff:OnEnterWorld(event)
    -- Ensure we have the correct player identity.
    EasyBuff.PLAYER_NAME, EasyBuff.PLAYER_REALM      = UnitName(EasyBuff.PLAYER);
    EasyBuff.PLAYER_REALM                            = GetRealmName();
    EasyBuff.PLAYER_CLASS, EasyBuff.PLAYER_CLASS_KEY = UnitClass(EasyBuff.PLAYER);

    EasyBuff:SetActiveTalentGroup();
    EasyBuff:SetActiveContext();

    EasyBuff:InitAvailableSpells();
    EasyBuff:BuildMonitoredSpells();

    BuildTrackingAbilities();
end


--[[
    On Player Spells Changed
]]--
function EasyBuff:OnSpellsChanged(event)
    EasyBuff:SetActiveTalentGroup();
    EasyBuff:SetActiveContext();

    EasyBuff:InitAvailableSpells();
    EasyBuff:BuildMonitoredSpells();

    BuildTrackingAbilities();
end


--[[
    Handle updates to the Tracking ability
]]--
function EasyBuff:OnTrackingAbilityChanged(event)
    BuildTrackingAbilities();
end


--[[
    On active Talent Spec change
    verified: talent points change, active spec change
]]--
function EasyBuff:OnTalentUpdate(event)
    EasyBuff:SetActiveTalentGroup();
    EasyBuff.rebuildNextScan = true;
end


--[[
    On party/raid roster change
    verified: start a group, join a group, leave a group, group size change
]]--
function EasyBuff:OnGroupRosterChange(event)
    EasyBuff:SetActiveContext();
    EasyBuff.rebuildNextScan = true;
end


--[[
    On party/raid type change
    verified: start a group, join a group, leave a group, group type converted
]]--
function EasyBuff:OnGroupStatusChange(event)
    EasyBuff:refreshActiveContext();
    EasyBuff.rebuildNextScan = true;
end
