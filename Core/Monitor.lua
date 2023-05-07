--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");

EasyBuff.MonitorTimerId = nil;

--[[
    Start Monitoring buffs.
]]--
function EasyBuff:StartMonitoring()
    if (not EasyBuff.MonitorTimerId) then
        EasyBuff.MonitorTimerId = self:ScheduleRepeatingTimer(EasyBuff.ScanBuffs, EasyBuff.BUFF_SCAN_FREQUENCY);
    end
end

--[[
    Stop Monitoring buffs.
]]--
function EasyBuff:StopMonitoring()
    if (EasyBuff.MonitorTimerId) then
        self:CancelTimer(EasyBuff.MonitorTimerId);
        EasyBuff.MonitorTimerId = nil;
    end
end

--[[
    Toggle Monitoring off/on
    @param {boolean}
]]--
function EasyBuff:ToggleMonitoring(val)
    if (val) then
        EasyBuff:StartMonitoring();
    else
        EasyBuff:StopMonitoring();
    end
end
