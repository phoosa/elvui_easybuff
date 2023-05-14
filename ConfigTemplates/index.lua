--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


EasyBuff.ConfigTemplate = {
    KEYS = {
        DEATHKNIGHT = {
            ["1"]   = L["Unholy DPS"],
            ["2"]   = L["Frost DPS"],
            ["3"]   = L["Tank"],
        },
        DRUID       = {
            ["1"]   = L["Feral"],
            ["2"]   = L["Not Feral"],
        },
        HUNTER      = {
            ["1"]   = L["Dragonhawk"],
            ["2"]   = L["Hawk"],
            ["3"]   = L["Monkey"],
        },
        MAGE        = {
            ["1"]   = L["Molten Armor"],
            ["2"]   = L["Mage Armor"],
            ["3"]   = L["Ice Armor"],
        },
        PALADIN     = {
            ["1"]   = L["Holy"],
            ["2"]   = L["Retribution"],
            ["3"]   = L["Protection"],
        },
        PRIEST      = {
            ["1"]   = L["Holy"],
            ["2"]   = L["Discipline"],
            ["3"]   = L["Shadow"],
        },
        ROGUE       = nil,
        SHAMAN      = {
            ["1"]   = L["Restoration"],
            ["2"]   = L["Enhancement"],
            ["3"]   = L["Elemental"],
        },
        WARLOCK     = {
            ["1"]   = L["Fel Armor"],
            ["2"]   = L["Demon Armor"],
        },
        WARRIOR     = nil
    };
};


--[[
    Get the available config templates for a given class.
    @param class {string} Load only templates for this class
    @return {array}
]]--
function EasyBuff:GetConfigTemplateOptions(class)
    if (EasyBuff.ConfigTemplate.KEYS[class] ~= nil) then
        return EasyBuff.ConfigTemplate.KEYS[class];
    end
    return {};
end


--[[
    Overwrite the configuration for all context and a given talentSpec with one of configuration templates.
    @param talentSpec {string} Numeric key for a template
    @param class {string} Load template from this class
    @param key {string} Numeric key for a template
    @return {array}
]]--
function EasyBuff:ApplyConfigTemplate(talentSpec, class, key)
    if (
        EasyBuff.ConfigTemplate.KEYS[class] ~= nil
        and EasyBuff.ConfigTemplate.KEYS[class][key] ~= nil
    ) then
        local config = EasyBuff.ConfigTemplate[class](tonumber(key));
        if (config == nil) then
            EasyBuff:PrintToChat(EasyBuff:Colorize(format(L["Failed to load the Template for [Class: %s] [TalentSpec: %s] [Key: %s]"], tostring(class), tostring(talentSpec), tostring(key)), EasyBuff.ERROR_COLOR));
        else
            EasyBuff:ResetWantedBuffConfigs(talentSpec)
            for _, context in pairs(EasyBuff.CONTEXT) do
                EasyBuff:PrintToChat('Overwriting '..tostring(talentSpec)..' config for context: '..tostring(context));
                for targetClass, auraConfig in pairs(config) do
                    if (
                        context ~= EasyBuff.CONTEXT.SOLO
                        or (context == EasyBuff.CONTEXT.SOLO and targetClass == EasyBuff.PLAYER)
                    ) then
                        if (auraConfig == nil) then
                            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass] = nil;
                        else
                            for spellGroup, roleConfig in pairs(auraConfig) do
                                if (roleConfig == nil) then
                                    E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = nil;
                                else
                                    for role, val in pairs(roleConfig) do
                                        if (E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] == nil) then
                                            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup] = {[role] = val};
                                        else
                                            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass][spellGroup][role] = val;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        EasyBuff:PrintToChat(EasyBuff:Colorize(format(L["No Config Template found for [Class: %s] [TalentSpec: %s] [Key: %s]"], tostring(class), tostring(talentSpec), tostring(key)), EasyBuff.ERROR_COLOR));
    end
end


--[[
    Reset Wanted Buff Configs for a given talent spec
    @param talentSpec {string}
]]--
function EasyBuff:ResetWantedBuffConfigs(talentSpec)
    for _, context in pairs(EasyBuff.CONTEXT) do
        for targetClass, config in pairs(E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED]) do
            E.db.EasyBuff[EasyBuff.PLAYER_REALM][EasyBuff.PLAYER_NAME][talentSpec][context][EasyBuff.CFG_GROUP.WANTED][targetClass] = {};
        end
    end
end
