--Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);
local EasyBuff = E:GetModule("EasyBuff");


-- ========================================== --
--                                            --
-- State Getters/Setters                      --
--                                            --
-- ========================================== --


-- ========================================== --
--                                            --
-- Mouse Wheel Event Pre/Post Processors      --
--                                            --
-- ========================================== --


function EasyBuff:OnUnwantedPostClick(button, down)
	if ("MOUSEWHEELDOWN" == button) then
		CameraZoomOut(1);
	elseif ("MOUSEWHEELUP" == button) then
		CameraZoomIn(1);
	end
end


-- ========================================== --
--                                            --
-- Event Handler Actions                      --
--                                            --
-- ========================================== --


--[[
	Initialize Unwanted Buffs
]]--
function EasyBuff:InitUnwanted()
	EasyBuff:CreateUnwantedActionButton(spellId);
end


--[[
	On Unit Aura
	Check for and Remove Unwanted Buffs (if enabled)
]]--
function EasyBuff:OnUnitAura(event, unitId, c, d, e)
	if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE) and unitId == "player") then
		EasyBuff:Debug(format("Checking for Unwanted Buffs"), 3);
		local bcIndex = 1;
		local buffToCheck;
		local unwanted = EasyBuff:GetUnwantedAuras();
		while (bcIndex == 1 or (buffToCheck ~= nil and buffToCheck[10] ~= nil)) do
			buffToCheck = {UnitBuff("player", bcIndex)};
			if (buffToCheck ~= nil and buffToCheck[10] ~= nil) then
				if (unwanted[tostring(buffToCheck[10])]) then
					if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_AUTOREMOVE) and not InCombatLockdown()) then
						CancelUnitBuff("player", bcIndex);
						EasyBuff:AnnounceUnwanted(format("%s"..L["REMOVING UNWANTED BUFF %s"].."|r", EasyBuff.ERROR_COLOR, buffToCheck[1]));
					else
						EasyBuff:AnnounceUnwanted(format("%s"..L["REMOVE UNWANTED BUFF %s"].."|r", EasyBuff.ERROR_COLOR, buffToCheck[1]));
					end
				end
			end
			bcIndex = bcIndex + 1;
		end
	end
end


-- ========================================== --
--                                            --
-- Where the magic happens...                 --
--                                            --
-- ========================================== --


function EasyBuff:CreateUnwantedActionButton()
	if (InCombatLockdown()) then
		return;
	end

	local macrotext = "";
	if (EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ENABLE)) then
		for spellId, enabled in pairs(EasyBuff:GetUnwantedAuras()) do
			if (enabled) then
				local spellInfo = {GetSpellInfo(spellId)};
				if (spellInfo ~= nil and spellInfo[1] ~= nil) then
					-- if (macrotext ~= "") then
					macrotext = format('%s/cancelaura %s\n', macrotext, spellInfo[1]);
					-- end
				end
			end
		end
	end

	if (EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED] == nil) then
		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED] = 
			CreateFrame("Button", "ELVUI_EASYBUFF_UNWANTED", UIParent, "SecureActionButtonTemplate");
		
		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetWidth(1);
		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetHeight(1);
		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 1, 1);
		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetScript("PostClick", self.OnUnwantedPostClick);

		EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetAttribute("type", "macro");
	end
	
	EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetAttribute("macrotext", macrotext);
end


--[[
	Announce Unwanted Buff Message
]]--
function EasyBuff:AnnounceUnwanted(msg)
	local announce = EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE);
	if (announce == EasyBuff.CFG_ANN_HUD) then
		ELVUI_EASYBUFF_ANNOUNCE_FRAME:AddMessage(msg, 1, 1, 1, 1.0);
	elseif (announce == EasyBuff.CFG_ANN_CHAT) then
		local window = nil;
		local windowName = EasyBuff:GetConfigValue(EasyBuff.CFG_FEATURE_UNWANTED, EasyBuff.CFG_GROUP_GENERAL, EasyBuff.CFG_ANNOUNCE_WINDOW);
		for i = 1, NUM_CHAT_WINDOWS, 1 do
			local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
			if (name) and (name:trim() ~= "") and (tostring(name) == tostring(windowName)) then
				window = i;
				break;
			end
		end
		EasyBuff:PrintToChat(msg, window);
	end
end
