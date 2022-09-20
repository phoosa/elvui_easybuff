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
EasyBuff.COMMAND        = "elveb";
EasyBuff.DEBUG_STATUS   = 0;
EasyBuff.CAST_DELAY     = 1.2; -- seconds

EasyBuff.ERROR_COLOR 	= "|cfffa2f47";
EasyBuff.CHAT_COLOR 	= "|cffFF4BFC";
EasyBuff.RANGE_COLOR 	= "|cff999999";

EasyBuff.PLAYER_NAME, EasyBuff.PLAYER_REALM = UnitName("player");
EasyBuff.PLAYER_REALM = GetRealmName();
EasyBuff.PLAYER_CLASS, EasyBuff.PLAYER_CLASS_ENGLISH = UnitClass("player");

EasyBuff.EXPIRATION_PERCENT = .1;  -- notify when buff reaches percent of buff duration left
EasyBuff.EXPIRATION_BUFFER  = 3;   -- seconds to add to percent to account for shorter buffs
EasyBuff.EXPIRATION_MINIMUM = 180; -- minimum seconds remaining before notifying

EasyBuff.RELATION_SELF      = "self";
EasyBuff.RELATION_MAIN_TANK = "main_tank";

EasyBuff.CONTEXT_SOLO   = "solo";
EasyBuff.CONTEXT_PARTY  = "party";
EasyBuff.CONTEXT_RAID   = "raid";
EasyBuff.CONTEXT_BG     = "bg";

EasyBuff.CFG_KEYBINDING = "keybinding";

EasyBuff.CFG_FEATURE_WANTED   = "wanted";
EasyBuff.CFG_FEATURE_UNWANTED = "unwanted";
EasyBuff.CFG_FEATURE_TRACKING = "tracking";
EasyBuff.CFG_FEATURE_CONSUMES = "consumes";
EasyBuff.CFG_FEATURE_WEAPONS  = "weapons";

EasyBuff.CFG_GROUP_GENERAL   = "general";
EasyBuff.CFG_GROUP_CONTEXT   = "context";
EasyBuff.CFG_GROUP_AURAS     = "auras";

EasyBuff.CFG_ENABLE          = "enable";
EasyBuff.CFG_CONTEXT  		 = "context";
EasyBuff.CFG_CONTEXT_AUTO 	 = "auto";
EasyBuff.CFG_ANNOUNCE     	 = "announce";
EasyBuff.CFG_ANNOUNCE_CC     = "announceContextChange";
EasyBuff.CFG_ANNOUNCE_WINDOW = "announceWindow";
EasyBuff.CFG_ANN_HUD      	 = "hud";
EasyBuff.CFG_ANN_CHAT     	 = "chat";
EasyBuff.CFG_NOTIFY_EARLY    = "notifyEarly";
EasyBuff.CFG_REMOVE_EXISTING = "removeExistingBuff";
EasyBuff.CFG_AUTOREMOVE      = "autoRemove";

EasyBuff.CLASS_COLORS = {
	["DRUID"]       = "|cffFF7D0A",
	["DEATHKNIGHT"] = "|cffC41E3A",
	["HUNTER"]      = "|cffABD473",
	["MAGE"]        = "|cff69CCF0",
	["PALADIN"]     = "|cffF58CBA",
	["PRIEST"]      = "|cffFFFFFF",
	["ROGUE"]       = "|cffFFF569",
	["SHAMAN"]      = "|cff0070DE",
	["WARLOCK"]     = "|cff9482C9",
	["WARRIOR"]     = "|cffC79C6E"
};
EasyBuff.CLASSES = {
	["DRUID"]       = EasyBuff.CLASS_COLORS["DRUID"].."Druid".."|r",
	["DEATHKNIGHT"] = EasyBuff.CLASS_COLORS["DEATHKNIGHT"].."Death Knight".."|r",
	["HUNTER"]      = EasyBuff.CLASS_COLORS["HUNTER"].."Hunter".."|r",
	["MAGE"]        = EasyBuff.CLASS_COLORS["MAGE"].."Mage".."|r",
	["PALADIN"]     = EasyBuff.CLASS_COLORS["PALADIN"].."Paladin".."|r",
	["PRIEST"]      = EasyBuff.CLASS_COLORS["PRIEST"].."Priest".."|r",
	["ROGUE"]       = EasyBuff.CLASS_COLORS["ROGUE"].."Rogue".."|r",
	["SHAMAN"]      = EasyBuff.CLASS_COLORS["SHAMAN"].."Shaman".."|r",
	["WARLOCK"]     = EasyBuff.CLASS_COLORS["WARLOCK"].."Warlock".."|r",
	["WARRIOR"]     = EasyBuff.CLASS_COLORS["WARRIOR"].."Warrior".."|r"
};

-- TODO: Refactor to use: https://wowwiki-archive.fandom.com/wiki/API_GetProfessionInfo
-- until then, this only works in english

EasyBuff.PROFESSIONS = {
	["Herbalism"] = "Herbalism", -- 182
	["Mining"]    = "Mining",    -- 186
	["Fishing"]   = "Fishing"    -- 356
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

-- Persist the last time easybuff cast was successful, used for throttling
EasyBuff.LastCastTime = 0;

-- Action Buttons used to cast spells in combat.
EasyBuff.ActionButtons = {};

-- Persist which Professions the current character has.
EasyBuff.PlayerProfessions = {};

-- ========================================== --
--                                            --
-- Load Additional Libraries                  --
--                                            --
-- ========================================== --


-- local LCD = LibStub and LibStub("LibClassicDurations");
-- if LCD then LCD:Register(EasyBuff.TITLE) end


-- ========================================== --
--                                            --
-- Event Handlers                             --
--                                            --
-- ========================================== --


--[[
	Initialize Player Data
]]--
function EasyBuff:InitializePlayerData()
	local faction, _ = UnitFactionGroup("player");
	EasyBuff:InitializeForFaction(faction);
	EasyBuff:UpdateProfessions();
	EasyBuff:InitAuras();
	EasyBuff:InitUnwanted();
	EasyBuff:SetKeybindings(
		EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_KEYBINDING),
		EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_KEYBINDING));
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
	if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_WANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE)) then
		-- Check and Refresh Unbuffed Units
		EasyBuff:RebuildBuffQueue();
		-- Announce Unbuffed Units
		EasyBuff:AnnounceUnbuffedUnits();
	end
end


-- ========================================== --
--                                            --
-- Slash Command                              --
--                                            --
-- ========================================== --


--[[
	Chat Command
	Process Command Line Input
]]--
function EasyBuff:ChatCommand(input)
	local wid = 1;
	local opt = nil;
	local args = {};
	local commands = {
		["debug"] = function(args)
			local level = tonumber(args[1]);
			local status = "";
			local color = EasyBuff.CLASS_COLORS["SHAMAN"];

			if (level == nil) then
				level = 0;
			else
				status = "level "..level;
			end

			EasyBuff.DEBUG_STATUS = level;
			if (EasyBuff.DEBUG_STATUS == 0) then
				status = "disabled";
				color = EasyBuff.ERROR_COLOR;
			end
			EasyBuff:PrintToChat(format("Debugging %s", EasyBuff:Colorize(status, color)), wid);
		end,
		["queue"] = function()
			if (EasyBuff.UnitBuffQueue ~= nil) then
				local combined = "";
				for unitName,auraGroupKeys in pairs(EasyBuff.UnitBuffQueue) do
					local unitBuffs = "";
					for i=1, table.getn(auraGroupKeys), 1 do
						unitBuffs = format("%s  %d-[%s:%s]", unitBuffs, i, auraGroupKeys[i].type, auraGroupKeys[i].value);
					end
					combined = format(combined.."\n%s: %s", unitName, unitBuffs);
				end
				EasyBuff:PrintToChat("Unit Buff Queue: "..combined, wid);
			else
				EasyBuff:PrintToChat("No Units/Buffs in the queue", wid);
			end
		end,
		["context"] = function()
			EasyBuff:PrintToChat("Current Context: "..EasyBuff:GetContext(), wid);
		end,
		["buffs"] = function()
			local monitoredSpells = EasyBuff:GetTrackedSpells();
			
			if (monitoredSpells == nil) then
				EasyBuff:PrintToChat("There are currently NO spells being tracked... type: "..EasyBuff:Colorize("/rl", EasyBuff.CLASS_COLORS["MAGE"]), wid);
			else
				for spellId, group in pairs(monitoredSpells) do
					EasyBuff:PrintToChat(format("  [%s] %s (%s)", group.group, group.name, spellId), wid);
				end
			end
		end,
		["help"] = function()
			EasyBuff:PrintToChat(format("Available Commands:\n%s %s - %s\n%s %s - %s\n%s %s - %s\n%s %s - %s",

				EasyBuff:Colorize("/"..EasyBuff.COMMAND, EasyBuff.CLASS_COLORS["MAGE"]),
				EasyBuff:Colorize("debug", EasyBuff.CLASS_COLORS["MAGE"]),
				"Set Debug Level (0=off) (1=info) (2=events) (3=verbose)",

				EasyBuff:Colorize("/"..EasyBuff.COMMAND, EasyBuff.CLASS_COLORS["MAGE"]),
				EasyBuff:Colorize("context", EasyBuff.CLASS_COLORS["MAGE"]),
				"Show the current EasyBuff Context",

				EasyBuff:Colorize("/"..EasyBuff.COMMAND, EasyBuff.CLASS_COLORS["MAGE"]),
				EasyBuff:Colorize("buffs", EasyBuff.CLASS_COLORS["MAGE"]),
				"Show the buffs currently being monitored",

				EasyBuff:Colorize("/"..EasyBuff.COMMAND, EasyBuff.CLASS_COLORS["MAGE"]),
				EasyBuff:Colorize("queue", EasyBuff.CLASS_COLORS["MAGE"]),
				"Show the current Buff Queue"
			), wid);
		end
	};

	if (input ~= nil) then
		if (string.match(input, "%s")) then
			for str in string.gmatch(input, "([^%s]+)") do
				if (opt == nil) then
					opt = str;
				else
					table.insert(args, str);
				end
			end
		else
			opt = input;
		end
	end

	if (opt == nil or commands[opt] == nil) then
		commands["help"]();
	else
		commands[opt](args);
	end
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
	return format("%s%s%s", tostring(color), tostring(text), "|r") ;
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

	return map[context];
end


--[[
	Print Debug Message
]]--
function EasyBuff:Debug(msg, lvl)
	if (lvl and EasyBuff.DEBUG_STATUS and (lvl <= EasyBuff.DEBUG_STATUS)) then
		EasyBuff:PrintToChat(EasyBuff:Colorize(lvl, EasyBuff.RANGE_COLOR).." "..date('%H:%M:%S', GetServerTime()).." - "..msg, 1);
	end
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

	-- Bind Console Commands.
	self:RegisterChatCommand(EasyBuff.COMMAND, "ChatCommand");
	-- Bind Event Handlers.
	self:RegisterEvent("SPELLS_CHANGED", "InitializePlayerData");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateContext");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateContext");
	self:RegisterEvent("GROUP_JOINED", "UpdateContext");
	self:RegisterEvent("GROUP_FORMED", "UpdateContext");
	self:RegisterEvent("GROUP_LEFT", "UpdateContext");
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateContext");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellCastSucceeded");
	self:RegisterEvent("UNIT_AURA", "OnUnitAura");
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd");
	
	-- Start Monitoring Buffs
	EasyBuff:ScheduleRepeatingTimer(EasyBuff.MonitorBuffs, 3);
end


--[[
	Set/Change Keybindings
]]--
function EasyBuff:SetKeybindings(wantedKey, unwantedKey)
	ClearOverrideBindings(ELVUI_EASYBUFF_ANNOUNCE_FRAME);
	if (nil ~= wantedKey) then
		SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, wantedKey, "ELVUI_EASYBUFF_PERFORM_BUTTON", wantedKey);
	end
	if (nil ~= unwantedKey) then
		SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, unwantedKey, "ELVUI_EASYBUFF_UNWANTED", unwantedKey);
	end
end


-- Register the module with ElvUI.
-- ElvUI will now call EasyBuff:Initialize() when ElvUI is ready to load our plugin.
E:RegisterModule(EasyBuff:GetName());