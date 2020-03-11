--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
--Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EasyBuff = E:NewModule("EasyBuff", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0");
--We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local EP = LibStub("LibElvUIPlugin-1.0");
--Lib Shared Media
local LSM = E.Libs.LSM;
--See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2
local addonName, addonTable = ...;


-- ========================================== --
--                                            --
-- Module Constants                           --
--                                            --
-- ========================================== --


EasyBuff.TITLE 			= "Easy Buff";
EasyBuff.VERSION 		= GetAddOnMetadata("ElvUI_EasyBuff", "Version");

EasyBuff.ERROR_COLOR 	= "|cfffa2f47";
EasyBuff.CHAT_COLOR 	= "|cffFF4BFC";

EasyBuff.PLAYER_NAME, EasyBuff.PLAYER_REALM = UnitName("player");
EasyBuff.PLAYER_CLASS = UnitClass("player");

EasyBuff.RELATION_SELF  = "self";

EasyBuff.CONTEXT_SOLO   = "solo";
EasyBuff.CONTEXT_PARTY  = "party";
EasyBuff.CONTEXT_RAID   = "raid";
EasyBuff.CONTEXT_BG     = "bg";

EasyBuff.CFG_CONTEXT  		 = "context";
EasyBuff.CFG_CONTEXT_AUTO 	 = "auto";
EasyBuff.CFG_ANNOUNCE     	 = "announce";
EasyBuff.CFG_ANNOUNCE_CC     = "announceContextChange";
EasyBuff.CFG_ANNOUNCE_WINDOW = "announceWindow";
EasyBuff.CFG_ANN_HUD      	 = "hud";
EasyBuff.CFG_ANN_CHAT     	 = "chat";

EasyBuff.CLASS_COLORS = {
	["Druid"]    = "|cffFF7D0A",
	["Hunter"]   = "|cffABD473",
	["Mage"]     = "|cff69CCF0",
	["Paladin"]  = "|cffF58CBA",
	["Priest"]   = "|cffFFFFFF",
	["Rogue"]    = "|cffFFF569",
	["Shaman"]   = "|cff0070DE",
	["Warlock"]  = "|cff9482C9",
	["Warrior"]  = "|cffC79C6E"
};
EasyBuff.CLASSES = {
	["Druid"]    = EasyBuff.CLASS_COLORS["Druid"].."Druid|r",
	["Hunter"]   = EasyBuff.CLASS_COLORS["Hunter"].."Hunter|r",
	["Mage"]     = EasyBuff.CLASS_COLORS["Mage"].."Mage|r",
	["Paladin"]  = EasyBuff.CLASS_COLORS["Paladin"].."Paladin|r",
	["Priest"]   = EasyBuff.CLASS_COLORS["Priest"].."Priest|r",
	["Rogue"]    = EasyBuff.CLASS_COLORS["Rogue"].."Rogue|r",
	["Shaman"]   = EasyBuff.CLASS_COLORS["Shaman"].."Shaman|r",
	["Warlock"]  = EasyBuff.CLASS_COLORS["Warlock"].."Warlock|r",
	["Warrior"]  = EasyBuff.CLASS_COLORS["Warrior"].."Warrior|r"
};


-- ========================================== --
--                                            --
-- Module Properties                          --
--                                            --
-- ========================================== --


-- Persist Which Units need Buffs
EasyBuff.UnitBuffQueue = nil;

-- Persist our current Buff Context
EasyBuff.Context = nil;


-- ========================================== --
--                                            --
-- Load Additional Libraries                  --
--                                            --
-- ========================================== --


local LCD = LibStub and LibStub("LibClassicDurations");
if LCD then LCD:Register(EasyBuff.TITLE) end


-- ========================================== --
--                                            --
-- Event Handlers                             --
--                                            --
-- ========================================== --


--[[
	On Player Enter World
]]--
function EasyBuff:OnPlayerEnterWorld()
	local faction, _ = UnitFactionGroup("player");
	EasyBuff:InitializeForFaction(faction)
end


-- ========================================== --
--                                            --
-- Timer Callbacks                            --
--                                            --
-- ========================================== --


--[[
	Monitor Buffs
	Checks for units that need to be buffed.
	This manages our EasyBuff UnitBuffQueue state, and triggers alerts.
]]--
function EasyBuff:MonitorBuffs()
	-- Check and Refresh Unbuffed Units
	EasyBuff:RebuildBuffQueue();
	-- Announce Unbuffed Units
	EasyBuff:AnnounceUnbuffedUnits();
end


-- ========================================== --
--                                            --
-- Misc Helpers                               --
--                                            --
-- ========================================== --


--[[
	Colorize Text
]]--
function EasyBuff:Colorize(text, color)
	return format("%s%s%s", color, text, "|r") 
end


--[[
	Get Language (Display Text) for Context Key
]]--
function EasyBuff:ContextKeyToLanguage(context)
	local map = {
		[EasyBuff.CONTEXT_SOLO]   = L["Solo"],
		[EasyBuff.CONTEXT_PARTY]  = L["Party"],
		[EasyBuff.CONTEXT_RAID]   = L["Raid"],
		[EasyBuff.CONTEXT_BG]     = L["Battleground"],
	};

	return map[context]
end


-- ========================================== --
--                                            --
-- Module Registration                        --
--                                            --
-- ========================================== --


--[[
	Initialization Hook
	Registers the Plugin with ElvUI, and Initialize Event Listeners.
]]--
function EasyBuff:Initialize()
	-- Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, EasyBuff.ConfigOptions);

	-- Initialize Frame Settings
	ELVUI_EASYBUFF_ANNOUNCE_FRAME:FontTemplate(LSM:Fetch("font"));

	EasyBuff:CreateAnchorFrame();

	-- Bind Event Handlers.
	self:RegisterEvent("PLAYER_LOGIN", "UpdateContext");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnterWorld");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateContext");
	self:RegisterEvent("GROUP_JOINED", "UpdateContext");
	self:RegisterEvent("GROUP_FORMED", "UpdateContext");
	self:RegisterEvent("GROUP_LEFT", "UpdateContext");
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateContext");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellCastSucceeded");

	-- Bind Buffing Units to Mouse Wheel Down
	SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, "MOUSEWHEELDOWN", "ELVUI_EASYBUFF_PERFORM_BUTTON", "MOUSEWHEELDOWN");
	
	-- Start Monitoring Buffs
	EasyBuff:ScheduleRepeatingTimer(EasyBuff.MonitorBuffs, 5);
end


-- Register the module with ElvUI.
-- ElvUI will now call EasyBuff:Initialize() when ElvUI is ready to load our plugin.
E:RegisterModule(EasyBuff:GetName());