-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
-- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EasyBuff = E:NewModule("EasyBuff", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0");
-- We use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local EP = LibStub("LibElvUIPlugin-1.0");
-- @see http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2
local addonName, addonTable = ...;

--[[
    Module Constants (if only this language supported such a thing....)
]]--
-- Module Info
EasyBuff.TITLE                  = "Easy Buff";
EasyBuff.VERSION                = GetAddOnMetadata("ElvUI_EasyBuff", "Version");
EasyBuff.COMMAND                = "elveb";
-- Player
EasyBuff.PLAYER                 = "player";
EasyBuff.PLAYER_NAME,
  EasyBuff.PLAYER_REALM         = UnitName(EasyBuff.PLAYER);
EasyBuff.PLAYER_REALM           = GetRealmName();
EasyBuff.PLAYER_CLASS,
  EasyBuff.PLAYER_CLASS_KEY     = UnitClass(EasyBuff.PLAYER);
-- System Logic
EasyBuff.DEBUG_ENABLED          = false;
EasyBuff.EXPIRATION_PERCENT     = .1;  -- notify when buff reaches this percent of buff duration remaining
EasyBuff.EXPIRATION_BUFFER      = 3;   -- seconds to add to percent to account for shorter buffs
EasyBuff.EXPIRATION_MINIMUM     = 180; -- minimum time remaining (in seconds) before notifying about an expiring buff
EasyBuff.BUFF_SCAN_FREQUENCY    = 5;   -- frequency (in seconds) to check for missing buffs
-- Colors
EasyBuff.ERROR_COLOR            = "|cfffa2f47";
EasyBuff.CHAT_COLOR             = "|cffFF4BFC";
EasyBuff.RANGE_COLOR            = "|cff999999";
EasyBuff.COLORS = {
    WHITE                       = "|cffFFFFFF",
    RED                         = "|cffC41E3A",
    ORANGE                      = "|cffFF7D0A",
    YELLOW                      = "|cffFFF569",
    GREEN                       = "|cffABD473",
    CYAN                        = "|cff69CCF0",
    BLUE                        = "|cff0070DE",
    PURPLE                      = "|cff9482C9",
    PINK                        = "|cffF58CBA",
    BROWN                       = "|cffC79C6E"
};
EasyBuff.CLASS_COLOR = {
    DRUID                       = EasyBuff.COLORS.ORANGE,
    DEATHKNIGHT                 = EasyBuff.COLORS.RED,
    HUNTER                      = EasyBuff.COLORS.GREEN,
    MAGE                        = EasyBuff.COLORS.CYAN,
    PALADIN                     = EasyBuff.COLORS.PINK,
    PRIEST                      = EasyBuff.COLORS.WHITE,
    ROGUE                       = EasyBuff.COLORS.YELLOW,
    SHAMAN                      = EasyBuff.COLORS.BLUE,
    WARLOCK                     = EasyBuff.COLORS.PURPLE,
    WARRIOR                     = EasyBuff.COLORS.BROWN
};
-- Config Groups, Params, and Options
EasyBuff.CONTEXT_AUTO           = "auto";
EasyBuff.CONTEXT = {
    SOLO                        = "SOLO",
    PARTY                       = "PARTY",
    RAID                        = "RAID",
    BG                          = "BG"
};
EasyBuff.ROLE = {
    DAMAGER                     = "DAMAGER",
    HEALER                      = "HEALER",
    TANK                        = "TANK"
};
EasyBuff.TALENT_SPEC_PRIMARY    = "primarySpec";
EasyBuff.TALENT_SPEC_SECONDARY  = "secondarySpec";
EasyBuff.TALENT_SPEC = {
    ["1"]                       = EasyBuff.TALENT_SPEC_PRIMARY,
    ["2"]                       = EasyBuff.TALENT_SPEC_SECONDARY
};
EasyBuff.CFG_GROUP = {
    GLOBAL                      = "global",
    GENERAL                     = "general",
    KEYBIND                     = "keybind",
    WANTED                      = "wanted",
    WEAPON                      = "weapon",
    UNWANTED                    = "unwanted",
    TRACKING                    = "tracking"
};
-- Config Options
EasyBuff.CFG_TALENT_EN          = "talentSettingsEnabled";
EasyBuff.CFG_ACTIVITY_EN        = "contextSettingsEnabled";
EasyBuff.CFG_ANN_HUD            = "hud";
EasyBuff.CFG_ANN_CHAT           = "chat";
EasyBuff.CFG_KEY_AUTOBUFF       = "autoBuff";
EasyBuff.CFG_KEY_AUTOREMOVE     = "autoRemove";

EasyBuff.CFG_KEY = {
    ENABLE                      = "enable",
    CONTEXT                     = "context",
    ANN_LOCATION                = "announceLocation",
    ANN_WINDOW                  = "announceWindow",
    ANN_CTX_CHANGE              = "announceContextChange",
    ANN_TLNT_CHANGE             = "announceTalentSpecChange",
    ANN_EARLY                   = "announceEarly",
    SELF_REMOVE_EXIST           = "removeExistingOnSelf",
    BIND_CASTBUFF               = "castBuff",
    BIND_REMOVEBUFF             = "removeBuff",
    BIND_WEAPONBUFF             = "weaponBuff",
    DISABLE_RESTING             = "disableResting",
    DISABLE_NOINSTANCE          = "disableNoInstance",
    SELF_ONLY_CAST              = "selfOnlyCast",
    MONITOR_WEAPONS             = "monitorWeapons",
    CAST_GREATER                = "castGreater",
    CAST_GREATER_MIN            = "castGreaterMin",
    CFG_BY_SPEC                 = "specBasedConfig",
    CFG_BY_CONTEXT              = "activityBasedConfig",
    MAIN_HAND                   = "mainHand",
    OFF_HAND                    = "offHand",
};
EasyBuff.WEAPON_BUFF_TYPE = {
    ITEM                        = "item",
    SPELL                       = "spell"
}
EasyBuff.CONTEXT_LABELS = {
    SOLO                        = L["Solo Activity"],
    PARTY                       = L["Party Activity"],
    RAID                        = L["Raid Activity"],
    BG                          = L["Battleground Activity"]
};
EasyBuff.EQUIPMENT_SLOT = {
    [EasyBuff.CFG_KEY.MAIN_HAND] = 16,
    [EasyBuff.CFG_KEY.OFF_HAND]  = 17
};


--[[
	Initialization Hook
	Registers the Plugin with ElvUI, and Initialize Event Listeners.
]]--
function EasyBuff:Initialize()
    -- Initialize Properties
    EasyBuff.availableSpells      = {};                    -- {object} Contains a list of the spells we can monitor.
    EasyBuff.monitoredSpells      = {};                    -- {object} Contains a list of the spells we are actively monitoring for the current talentSpec and context.
    EasyBuff.availableWeaponBuffs = nil;                   -- {object} Contains a list of weapon buffs that we can monitor.
    EasyBuff.monitoredWeaponBuffs = nil;                   -- {object} Contains a list of the weapon buffs we are actively monitoring for the current talentSpec and context.
    EasyBuff.activeTalentSpec     = nil;                   -- {string} The name of the currently active talent spec.
    EasyBuff.activeContext        = EasyBuff.CONTEXT.SOLO; -- {string} The name of the currently active context.
    EasyBuff.wantedQueue          = nil;                   -- {object} Multi-dimensional list of buffs to apply ["unitName" => ["buffGroup" => MonitoredSpell]]
    EasyBuff.rebuildNextScan      = false;                 -- {bool} semaphor: rebuild the monitored buff queue on next scan
    EasyBuff.TrackingAbilities    = {};                    -- {object} Contains a list of 'spell' type tracking abilities available for this player.
    EasyBuff.activeTracking       = nil;                   -- {int} TextureId of the Active Tracking ability
    EasyBuff.wantedTracking       = nil;                   -- {object} Contains announcement for missing wanted tracking ability.
    EasyBuff.wantedWeaponBuffs    = nil;                   -- {object} Contains announcement for missing wanted weapon buffs.
    EasyBuff.unwatedBuffs         = 0;                     -- {int} The total number of unwanted buffs you currently have

    -- Register plugin so options are properly inserted when config is loaded
    EP:RegisterPlugin(addonName, EasyBuff.InitializeConfig);

    -- Initialize UI Frames
    EasyBuff:InitializeAnnounceFrame();
    EasyBuff:ConfigureKeybinds(
        GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_CASTBUFF),
        GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_REMOVEBUFF),
        GetKeybindSettingsValue(EasyBuff.CFG_KEY.BIND_WEAPONBUFF)
    );

    -- Bind Console Commands.
    EasyBuff:RegisterChatCommand(EasyBuff.COMMAND, "ConsoleCommand");

    -- Bind Event Handlers.
    EasyBuff:RegisterEvents()

    -- Start Monitoring Buffs
    if (GetGlobalSettingsValue(EasyBuff.CFG_KEY.ENABLE)) then
        EasyBuff:StartMonitoring();
    end
end

--[[
    Generate availableSpells and availableWeaponBuffs lists
]]--
function EasyBuff:InitAvailableLists()
    local bookTabs = GetNumSpellTabs();
    local totalSpells = 0;
    local available = {};
    -- Init Weapon Buffs
    EasyBuff.availableWeaponBuffs = EasyBuff:GetAvailableWeaponBuffs();

    for bookTabIndex=1, bookTabs do
        local bookTabName, bookTabTexture, bookTabOffset, bookTabSpellCnt, _, _ = GetSpellTabInfo(bookTabIndex);
        totalSpells = totalSpells + bookTabSpellCnt;
	end

    -- build `available` list.
    if (EasyBuff.CLASS_SPELLS[EasyBuff.PLAYER_CLASS_KEY]) then
        for spellIndex=totalSpells, 1, -1 do
            local _, spellId = GetSpellBookItemInfo(spellIndex, BOOKTYPE_SPELL);
            local classSpell = EasyBuff.CLASS_SPELLS[EasyBuff.PLAYER_CLASS_KEY][tostring(spellId)];
            if (classSpell) then
                local name = GetSpellInfo(spellId);
                available[tostring(spellId)] = AvailableSpell:new({
                    id      = spellId,
                    rank    = classSpell.rank,
                    group   = classSpell.group,
                    greater = classSpell.greater,
                    name    = name
                });
            elseif (
                nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL]
                and nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][tostring(spellId)]
            ) then
                EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][tostring(spellId)].known = true;
            end
        end
    end

    -- update global list.
    EasyBuff.availableSpells = available;
end

--[[
    Generate a list of weapon buffs that the player can utilize

    @return {WeaponBuff[]} returns 2 lists of Weapon Buffs; grouped by type (item, spell)
]]--
function EasyBuff:GetAvailableWeaponBuffs()
    if (EasyBuff.WEAPON_BUFFS[EasyBuff.PLAYER_CLASS_KEY] == nil) then
        return {
            [EasyBuff.WEAPON_BUFF_TYPE.ITEM] = nil,
            [EasyBuff.WEAPON_BUFF_TYPE.SPELL] = nil
        };
    end

    local weaponBuffs = {
        [EasyBuff.WEAPON_BUFF_TYPE.ITEM] = {},
        [EasyBuff.WEAPON_BUFF_TYPE.SPELL] = {}
    };

    for effectId, buffConfig in pairs(EasyBuff.WEAPON_BUFFS[EasyBuff.PLAYER_CLASS_KEY]) do
        local buffType = EasyBuff.WEAPON_BUFF_GROUPS[EasyBuff.PLAYER_CLASS_KEY][buffConfig.group].type;
        local name = nil;

        if (buffType == EasyBuff.WEAPON_BUFF_TYPE.ITEM) then
            name = GetItemInfo(buffConfig.id);
        else
            name = GetSpellInfo(buffConfig.id);
        end

        weaponBuffs[buffType][tostring(effectId)] = WeaponBuff:new({
            effectId = effectId,
            type     = buffType,
            typeId   = buffConfig.id,
            rank     = buffConfig.rank,
            group    = buffConfig.group,
            name     = name
        });
    end

    return weaponBuffs;
end

--[[
    Iterate over availableSpells and build a list of monitoredSpells from user configuration
]]--
function EasyBuff:BuildMonitoredSpells()
    local monitored = {};

    local classConfigs = GetPlayerConfig()[EasyBuff.activeTalentSpec][EasyBuff.activeContext][EasyBuff.CFG_GROUP.WANTED];

    -- Get the spell monitoring rules from config.
    local rulesBySpellGroup = {};
    for className, classConfig in pairs(classConfigs) do
        for spellGroup, roleConfig in pairs(classConfig) do
            local thisCfg = nil;
            for roleId, roleVal in pairs(roleConfig) do
                if (roleVal == true) then
                    if (thisCfg == nil) then thisCfg = {}; end
                    thisCfg[roleId] = roleVal;
                end
            end
            if (thisCfg ~= nil) then
                if (rulesBySpellGroup[spellGroup] == nil) then
                    rulesBySpellGroup[spellGroup] = {
                        [className] = thisCfg
                    };
                else
                    rulesBySpellGroup[spellGroup][className] = thisCfg;
                end
            end
        end
    end

    -- find matching "available" spells and create "monitoring" list
    for spellId,avail in pairs(EasyBuff.availableSpells) do
        if (rulesBySpellGroup[avail.group] and not monitored[spellId]) then
            monitored[spellId] = MonitoredSpell:new({
                id      = avail.id,
                rank    = avail.rank,
                group   = avail.group,
                greater = avail.greater,
                name    = avail.name,
                rules   = rulesBySpellGroup[avail.group]
            });
        end
    end

    EasyBuff.monitoredSpells = monitored;
end

--[[
    Build monitoredWeaponBuffs containing WeaponBuff objects for currently tracked Main Hand and Off Hand
]]--
function EasyBuff:BuildMonitoredWeaponBuffs()
    local canMonitor = GetGlobalSettingsValue(EasyBuff.CFG_KEY.MONITOR_WEAPONS);
    if (not canMonitor or
        (nil == EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL]
        and nil == EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM])
    ) then
        EasyBuff.monitoredWeaponBuffs = nil;
    else
        local monitoredCfg = GetPlayerConfig()[EasyBuff.activeTalentSpec][EasyBuff.activeContext][EasyBuff.CFG_GROUP.WEAPON];

        local monitor = {
            [EasyBuff.CFG_KEY.MAIN_HAND] = nil,
            [EasyBuff.CFG_KEY.OFF_HAND] = nil
        };

        if (nil ~= monitoredCfg[EasyBuff.CFG_KEY.MAIN_HAND]) then
            if (nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][monitoredCfg[EasyBuff.CFG_KEY.MAIN_HAND]]) then
                monitor[EasyBuff.CFG_KEY.MAIN_HAND] = EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][monitoredCfg[EasyBuff.CFG_KEY.MAIN_HAND]];
            elseif (nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM][monitoredCfg[EasyBuff.CFG_KEY.MAIN_HAND]]) then
                monitor[EasyBuff.CFG_KEY.MAIN_HAND] = EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM][monitoredCfg[EasyBuff.CFG_KEY.MAIN_HAND]];
            end
        end

        if (nil ~= monitoredCfg[EasyBuff.CFG_KEY.OFF_HAND]) then
            if (nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][monitoredCfg[EasyBuff.CFG_KEY.OFF_HAND]]) then
                monitor[EasyBuff.CFG_KEY.OFF_HAND] = EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.SPELL][monitoredCfg[EasyBuff.CFG_KEY.OFF_HAND]];
            elseif (nil ~= EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM][monitoredCfg[EasyBuff.CFG_KEY.OFF_HAND]]) then
                monitor[EasyBuff.CFG_KEY.OFF_HAND] = EasyBuff.availableWeaponBuffs[EasyBuff.WEAPON_BUFF_TYPE.ITEM][monitoredCfg[EasyBuff.CFG_KEY.OFF_HAND]];
            end
        end

        EasyBuff.monitoredWeaponBuffs = monitor;
    end
end

--[[
    Set the current active talent group
]]--
function EasyBuff:SetActiveTalentGroup()
    local curTalentGroupId = GetActiveTalentGroup();
    if (EasyBuff.activeTalentSpec ~= EasyBuff.TALENT_SPEC[tostring(curTalentGroupId)]) then
        EasyBuff.activeTalentSpec = EasyBuff.TALENT_SPEC[tostring(curTalentGroupId)];

        if (GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_TLNT_CHANGE)) then
            local text = L["Primary Spec"];
            if (curTalentGroupId == 2) then
                text = L["Secondary Spec"];
            end
            EasyBuff:AnnounceMessage(EasyBuff:Colorize(format(L["Talent Spec context changed to %s"], EasyBuff:Colorize(tostring(text), EasyBuff.CHAT_COLOR)), EasyBuff.RANGE_COLOR));
        end
    end
end

--[[
    Set the current active context from the config
]]--
function EasyBuff:SetActiveContext()
    local context = GetGlobalSettingsValue(EasyBuff.CFG_KEY.CONTEXT);

    if (context == EasyBuff.CONTEXT_AUTO or not EasyBuff.CONTEXT[context]) then
        local isInBg = UnitInBattleground("player");
        if (UnitInBattleground(EasyBuff.PLAYER) ~= nil) then
            context = EasyBuff.CONTEXT.BG;
        elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
            context = EasyBuff.CONTEXT.RAID;
        elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
            context = EasyBuff.CONTEXT.PARTY;
        else
            context = EasyBuff.CONTEXT.SOLO;
        end
    end

    if (EasyBuff.activeContext ~= context and GetGlobalSettingsValue(EasyBuff.CFG_KEY.ANN_CTX_CHANGE)) then
        EasyBuff:AnnounceMessage(EasyBuff:Colorize(format(L["Activity context changed to %s"], EasyBuff:Colorize(tostring(context), EasyBuff.CHAT_COLOR)), EasyBuff.RANGE_COLOR));
    end

    EasyBuff.activeContext = context;
end

--[[
    Get Default Talent Spec if one is not provided.
]]--
function EasyBuff:GetDefaultTalentSpec(spec)
    if (not spec) then
        return EasyBuff.TALENT_SPEC_PRIMARY;
    end
    return spec;
end

--[[
    Get Default Context if one is not provided.
]]--
function EasyBuff:GetDefaultContext(context)
    if (not context) then
        return EasyBuff.CONTEXT.PARTY;
    end
    return context;
end

--[[
    Check if we can cast a buff
]]--
function EasyBuff:canCast()
    return not InCombatLockdown()
        and not IsMounted()
        and not UnitIsDeadOrGhost(EasyBuff.PLAYER)
        and not UnitInVehicle(EasyBuff.PLAYER);
end

--[[
    Can we currently cast on a given unit
]]--
function EasyBuff:CanCastOnUnit(unitName)
    return
        (unitName == EasyBuff.PLAYER_NAME or unitName == EasyBuff.PLAYER or UnitInRange(unitName))
        and UnitIsVisible(unitName) and not UnitIsDead(unitName);
end

--[[
    Identify and set the current activity context
]]--
function EasyBuff:refreshActiveContext()
    -- if (IsInGroup(LE_PARTY_CATEGORY_HOME) or IsInRaid(LE_PARTY_CATEGORY_HOME)) then
end

--[[
    Activate the preferred Tracking ability if it's not already active
]]--
function EasyBuff:activateCorrectTracking()
    if (EasyBuff.wantedTracking ~= nil) then
        EasyBuff.wantedTracking:activate();
    end
end

-- Register the module with ElvUI.
-- ElvUI will now call EasyBuff:Initialize() when ElvUI is ready to load our plugin.
E:RegisterModule(EasyBuff:GetName());
