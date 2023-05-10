--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    A Buff castable by the player that they can monitor on other players.

    @param id      {int}     Spell ID
    @param rank    {int}     Spell Rank
    @param group   {string}  Spell Group Key, {@see EasyBuff.CLASS_SPELLS_GROUPS}
    @param greater {boolean} This is a "greater" or multi-player version of this spell group
]]--
AvailableSpell = {
    id = nil,
    rank = 0,
    group = nil,
    greater = false
};

--[[
    Constructor
]]--
function AvailableSpell:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

--[[
    Get the Spell Group for this Available Spell
    @see EasyBuff.CLASS_SPELLS_GROUPS
    @return {object} {{int} rank, {string} group, {boolean} grater
]]--
function AvailableSpell:spellGroup()
    return EasyBuff.CLASS_SPELLS_GROUPS[EasyBuff.PLAYER_CLASS_KEY][self.group];
end

--[[
    Check if we're monitoring some other version of this spell

    @return {boolean}
]]--
function AvailableSpell:isMonitoring()
    for spellId,monitoredSpell in pairs(EasyBuff.monitoredSpells) do
        if (monitoredSpell.group == self.group) then
            return true;
        end
    end

    return false;
end
