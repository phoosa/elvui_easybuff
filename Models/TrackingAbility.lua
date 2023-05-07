--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


--[[
    A Tracking Ability known and castable by the player.

    @param textureId {int} Texture ID
    @param index     {int} index of tracking ability in tracking list
    @param name      {string} Displayed Name for this tracking ability
]]--
TrackingAbility = {
    textureId = nil,
    index = 0,
    name = nil
};


--[[
    Constructor
]]--
function TrackingAbility:new(o)
    o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

--[[
    Check if this Tracking Ability is the Active one.
    @return {boolean}
]]--
function TrackingAbility:isActive(activeIndex)
    return self.textureId == EasyBuff.activeTracking;
end

--[[
    Activate this Tracking Ability
]]--
function TrackingAbility:activate()
    C_Minimap.SetTracking(self.index, true);
    EasyBuff.activeTracking = self.textureId;
end


--[[
    (re)Build the persisted list of Tracking Abilities, and update the persisted ActiveTrackingAbility
    @return {object} {@see EasyBuff.TrackingAbilities}

    @NOTICE: We cannot do this yet the methods don't exist, let's defer to EasyBuff:InitAvailableSpells() for now
]]--
function BuildTrackingAbilities()
    local allTracking = {};
    local count = C_Minimap.GetNumTrackingTypes();
    local newActive = nil;

    for i=1,count do 
        local name, texture, active, tType = C_Minimap.GetTrackingInfo(i);
        if (tType == 'spell') then
            allTracking[tostring(texture)] = TrackingAbility:new({
                textureId = texture,
                index = i,
                name = name
            });
            if (active) then
                newActive = texture;
            end
        end
    end

    EasyBuff.activeTracking = newActive;
    EasyBuff.TrackingAbilities = allTracking;

    return EasyBuff.TrackingAbilities;
end
