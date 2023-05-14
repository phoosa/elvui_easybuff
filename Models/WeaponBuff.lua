--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

--[[
    A Weapon Buff castable by the player that they can monitor on their own weapons.

    @param type     {string}  Buff is applied by an item or a spell (one of: EasyBuff.WEAPON_BUFF_TYPE)
    @param typeId   {int}     ID of Spell or Item used to apply the buff
    @param effectId {int}     Effect ID detected as an enhancement when the weapon is inspected
    @param rank     {int}     Buff Rank
    @param group    {string}  Weapon Buff Group Key, {@see EasyBuff.WEAPON_BUFF_GROUPS}
    @param name     {string}  Localized name of item/spell
    @param known    {bool}    Whether the spell is know or item is owned
]]--
WeaponBuff = {
    effectId = nil,
    type = nil,
    typeId = nil,
    rank = 0,
    group = nil,
    name = nil,
    known = false
};

--[[
    Constructor
]]--
function WeaponBuff:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end
