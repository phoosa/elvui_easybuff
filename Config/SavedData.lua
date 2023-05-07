-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    Get base-configuration object for all configurations
]]--
function GetPlayerConfig()
    return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME];
end


--[[
    Get Configuration Value for a given Global key.
]]--
function GetGlobalSettingsValue(key)
    return GetPlayerConfig()[EasyBuff.CFG_GROUP.GLOBAL][key];
end


--[[
    Set Configuration Value for a given Global key.
]]--
function SetGlobalSettingsValue(key, value)
    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_GROUP.GLOBAL][key] = value;
end


--[[
    Get Configuration Value for a given Global key.
]]--
function GetKeybindSettingsValue(key)
    return GetPlayerConfig()[EasyBuff.CFG_GROUP.KEYBIND][key];
end


--[[
    Set Configuration Value for a given Global key.
]]--
function SetKeybindSettingsValue(key, value)
    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][EasyBuff.CFG_GROUP.KEYBIND][key] = value;
    EasyBuff:ConfigureKeybinds(GetKeybindSettingsValue(BIND_CASTBUFF), GetKeybindSettingsValue(BIND_REMOVEBUFF));
end


--[[
    Get value for a General Setting for Context and Talent Spec
]]--
function GetContextGeneralSettingsValue(talentSpec, context, key)
    local config = GetPlayerConfig()[talentSpec][context];

    if (config and config[EasyBuff.CFG_GROUP.GENERAL]) then
        return config[EasyBuff.CFG_GROUP.GENERAL][key];
    end

    return false;
end


--[[
    Set value for a General Setting for Context and Talent Spec
]]--
function SetContextGeneralSettingsValue(talentSpec, context, key, value)
    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.GENERAL][key] = value;
    EasyBuff.rebuildNextScan = true;
end


--[[
    Get "wanted" spell configuration for a given active talent spec, target class, and target role
]]--
function GetWantedBuffRoleValue(talentSpec, context, targetClass, spellGroup, role)
    local config = GetPlayerConfig()[talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass];

    if (config and config[spellGroup]) then
        return config[spellGroup][role];
    end

    return false;
end


--[[
    Get "wanted" spell configuration for all roles of a given active talent spec, and target class
    @param talentSpec  {string|nil} (defaults to primarySpec)
    @param context     {string|nil} (defaults to solo)
    @param targetClass {string}
    @param spellGroup  {string}
    @return {boolean|nil} nil if partially true
]]--
function GetWantedBuffValue(talentSpec, context, targetClass, spellGroup)
    local config = GetPlayerConfig()[talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass];

    if (config ~= nil and config[spellGroup] ~= nil) then
        -- compare all role values for spell group, if any differ then return nil.
        for k,role in pairs(EasyBuff.ROLE) do
            if (config[spellGroup][role] ~= config[spellGroup].DAMAGER) then
                return nil;
            end
        end
        return config[spellGroup].DAMAGER;
    else
        return false;
    end
end


--[[
    Set "wanted" spell configuration for all roles of a given active talent spec and target class
    @param talentSpec  {string|nil} (set value for all specs if nil)
    @param context     {string|nil} (set value for all context if nil)
    @param targetClass {string}
    @param spellGroup  {string}
    @param value       {boolean|nil}
]]--
function SetWantedBuffValue(talentSpec, context, targetClass, spellGroup, role, value)
    if (role == nil) then
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = {
            [EasyBuff.ROLE.DAMAGER] = value,
            [EasyBuff.ROLE.HEALER] = value,
            [EasyBuff.ROLE.TANK] = value
        };
    else
        if (nil == E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup]) then
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = {
                [EasyBuff.ROLE.DAMAGER] = false,
                [EasyBuff.ROLE.HEALER] = false,
                [EasyBuff.ROLE.TANK] = false
            };
        end
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup][role] = value;
    end
    EasyBuff.rebuildNextScan = true;
end


--[[
    Set "wanted" aura-type spell configuration for a given active talent spec and target class
    Only one aura may be active per class/role, so all other aura's will be deactivated if we are activating this one
]]--
function SetWantedAuraValue(talentSpec, context, targetClass, spellGroup, role, value)
    if (role == nil) then
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = {
            [EasyBuff.ROLE.DAMAGER] = value,
            [EasyBuff.ROLE.HEALER] = value,
            [EasyBuff.ROLE.TANK] = value
        };
    else
        if (nil == E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup]) then
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = {
                [EasyBuff.ROLE.DAMAGER] = false,
                [EasyBuff.ROLE.HEALER] = false,
                [EasyBuff.ROLE.TANK] = false
            };
        end
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup][role] = value;
    end

    -- Deactivate other aura's for this role if we are activating this one.
    if (value == true) then
        local spellGroups = getAvailableSpellAuras();
        for _, group in pairs(spellGroups) do
            if (group ~= spellGroup) then
                if (nil == role or nil == E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][group]) then
                    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][group] = {
                        [EasyBuff.ROLE.DAMAGER] = false,
                        [EasyBuff.ROLE.HEALER] = false,
                        [EasyBuff.ROLE.TANK] = false
                    };
                else
                    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][group][role] = false;
                end
            end
        end
    end
    EasyBuff.rebuildNextScan = true;
end


--[[
    Get the list of Unwanted buffs for a given talentSpec and context
]]--
function GetUnwantedBuffs(talentSpec, context)
    return E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.UNWANTED];
end


--[[
    Update an Unwanted buffs for a given talentSpec and context
]]--
function SetUnwantedBuffs(talentSpec, context, val)
    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.UNWANTED][val] = nil;
end


--[[
    Add a new buff to the Unwanted list
]]--
function SetNewUnwatedBuff(talentSpec, context, val)
    if (val) then
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(val);
        local spellLink = GetSpellLink(val);
        if (spellId and spellLink) then
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.UNWANTED][name] = spellLink;
        end
    end
end


--[[
    Copy configuration from one context to another
    There's no object cloning wihout reference, so we do it to long way...
]]
function CopyContextConfiguration(toContext, fromContext)
    for tsId, talentSpec in pairs(EasyBuff.TALENT_SPEC) do
        -- General Config
        for genK,genV in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.GENERAL]) do
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.GENERAL][genK] = genV;
        end
        -- Unwanted Buffs
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.UNWANTED] = {};
        for uwK,uwV in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.UNWANTED]) do
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.GENERAL][uw] = uwV;
        end
        -- Wanted Buffs (iterate classes in TO context so we don't copy unsupported class configs)
        for classK,classV in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.WANTED]) do
            -- Empty class configs in TO context
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.WANTED][classK] = {};
            -- iterate over spells to copy them in
            if ("table" == type(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.WANTED][classK])) then
                for spellK,spellV in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.WANTED][classK]) do
                    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.WANTED][classK][spellK] = spellV;
                end
            end
        end
        -- Tracking Ability
        -- E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.TRACKING] = nil;
        E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][toContext][EasyBuff.CFG_GROUP.TRACKING] = E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][fromContext][EasyBuff.CFG_GROUP.TRACKING];
    end
end


--[[
    Get Monitored Tracking Configuration
]]--
function GetTrackingConfig(context, talentSpec)
    return GetPlayerConfig()[talentSpec][context][EasyBuff.CFG_GROUP.TRACKING];
end


--[[
    Set Monitored Tracking Configuration
]]--
function SetTrackingConfig(context, talentSpec, value)
    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.TRACKING] = value;
end
