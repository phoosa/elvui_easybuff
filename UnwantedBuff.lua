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


-- function EasyBuff:OnUnwantedPreClick(button, down)
-- 	if (self ~= nil and self.GetAttribute ~= nil) then
-- 		local spellId = self:GetAttribute('spell');
-- 		if (spellId ~= nil) then
-- 			local bcIndex = 1;
-- 			local buffToCheck;
-- 			while (bcIndex == 1 or (buffToCheck ~= nil and buffToCheck[10] ~= nil)) do
-- 				buffToCheck = {UnitBuff("player", bcIndex)};
-- 				if (buffToCheck ~= nil and tostring(buffToCheck[10]) == tostring(spellId)) then
-- 					CancelUnitBuff("player", bcIndex);
-- 				end
-- 				bcIndex = bcIndex + 1;
-- 			end
-- 		end
-- 	end
-- end


function EasyBuff:OnUnwantedPostClick(button, down)
	--	EasyBuff:ChangeMouseWheelAction("ELVUI_EASYBUFF_PERFORM_BUTTON");
	CameraZoomOut(1);
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
	-- for spellId, enabled in pairs(EasyBuff:GetUnwantedAuras()) do
	-- 	print(format('Initialize Unwanted %s as %s', spellId, tostring(enabled)));
	-- 	if (enabled) then
	-- 		EasyBuff:CreateUnwantedActionButton(spellId);
	-- 	end
	-- end
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
						-- EasyBuff:ChangeMouseWheelAction("ELVUI_EASYBUFF_UNWANTED_"..buffToCheck[10]);
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


function EasyBuff:ChangeMouseWheelAction(buttonName)
	-- print(EasyBuff.ERROR_COLOR..'Change MOUSEWHEEL Action: |r'..buttonName);
	-- SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, "MOUSEWHEELDOWN", buttonName, "MOUSEWHEELDOWN");
end


function EasyBuff:CreateUnwantedActionButton()
	-- EasyBuff:Debug(format("Unwanted:CreateButton %s", spellId), 3);
	-- print(format("Unwanted:CreateButton %s", spellId));
	-- if (EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED] == nil) then
	-- 	EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED] = {};
	-- end
	-- if (EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId] ~= nil) then
	-- 	-- Don't recreate what we already have
	-- 	print(format("Unwanted:CreateButton %s ALREADY EXISTS", spellId))
	-- 	return
	-- end

	--
	-- This works for 1 buff
	--
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId] = 
	-- 	CreateFrame("Button", "ELVUI_EASYBUFF_UNWANTED_"..spellId, UIParent, "SecureActionButtonTemplate");
	-- local spellInfo = {GetSpellInfo(spellId)};
	-- print("Cancel Aura "..spellInfo[1]);

	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetAttribute("type", "cancelaura");
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetAttribute("spell", spellInfo[1]);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetWidth(25);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetHeight(25);
	-- -- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetPoint("CENTER", math.random(-80, 80), math.random(-80, 80));
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetPoint("CENTER", "UIParent", "CENTER", math.random(-80, 80), math.random(-80, 80));
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:SetScript("PostClick", self.OnUnwantedPostClick);

	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId].texture = EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]:CreateTexture(nil, "BACKGROUND");
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId].texture:SetAllPoints(EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId]);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED][spellId].texture:SetColorTexture(1, 0, 0, 1);



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

		SetOverrideBindingClick(ELVUI_EASYBUFF_ANNOUNCE_FRAME, false, "CTRL-MOUSEWHEELDOWN", "ELVUI_EASYBUFF_UNWANTED", "CTRL-MOUSEWHEELDOWN");
	end
	
	EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetAttribute("macrotext", macrotext);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetWidth(25);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetHeight(25);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:SetPoint("CENTER", "UIParent", "CENTER", math.random(-80, 80), math.random(-80, 80));
	

	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED].texture = EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]:CreateTexture(nil, "BACKGROUND");
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED].texture:SetAllPoints(EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED]);
	-- EasyBuff.ActionButtons[EasyBuff.CFG_FEATURE_UNWANTED].texture:SetColorTexture(1, 0, 0, 1);

	
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
