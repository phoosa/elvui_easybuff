--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    Roles
]]--
MonitorRules = {
    [EasyBuff.ROLE.DAMAGER] = false,
    [EasyBuff.ROLE.HEALER]  = false,
    [EasyBuff.ROLE.TANK]    = false
};

--[[
    Constructor
]]--
function MonitorRules:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

--[[
    Get the Spell Group for this Monitored Spell
    @see EasyBuff.CLASS_SPELLS_GROUPS
    @return {object} {{int} rank, {string} group, {boolean} grater
]]--
function MonitorRules:spellGroup()
    return EasyBuff.CLASS_SPELLS_GROUPS[EasyBuff.PLAYER_CLASS_KEY][self.group];
end


--[[
    A Buff castable by the player that they are currently monitoring on other players.

    @param id      {int}          Spell ID
    @param rank    {int}          Spell Rank
    @param group   {string}       Spell Group Key, {@see EasyBuff.CLASS_SPELLS_GROUPS}
    @param greater {boolean}      This is a "greater" or multi-player version of this spell group
    @param rules   {MonitorRules} Roles to monitor this spell on, keyed by Class
    @param name    {string}       Name of spell to cast
]]--
MonitoredSpell = {
    id = nil,
    rank = 0,
    group = nil,
    greater = false,
    rules = nil,
    name = nil
};

--[[
    Constructor
]]--
function MonitoredSpell:new(o)
    o = o or {};
    if (o.rules) then
        local r = {};
        for k,v in pairs(o.rules) do
            r[k] = MonitorRules:new(v);
        end
        o.rules = r;
    end
    setmetatable(o, self);
    self.__index = self;

    return o;
end

--[[
    Is this spell monitored for a given class and role?

    @param class {string} All caps english key for a class (ie: a key from EasyBuff.CLASS_ORDER)
    @param role  {string} One of EasyBuff.ROLE

    @return {boolean}
]]--
function MonitoredSpell:isMonitoring(class, role)
    if (not role or role == "NONE") then
        role = EasyBuff.ROLE.DAMAGER;
    end

    return self.rules[class] and self.rules[class][role];
end

--[[
    Set the castable name of the spell
    
    @param name {string}
]]--
function MonitoredSpell:setName(name)
    self.name = name;
end

--[[
    Get the Spell Group for this Available Spell
    @see EasyBuff.CLASS_SPELLS_GROUPS
    @return {object} {{int} rank, {string} group, {boolean} grater
]]--
function MonitoredSpell:spellGroup()
    return EasyBuff.CLASS_SPELLS_GROUPS[EasyBuff.PLAYER_CLASS_KEY][self.group];
end
