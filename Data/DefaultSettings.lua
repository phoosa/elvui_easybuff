local E, L, V, P, G = unpack(ElvUI);

P["EasyBuff"] = {
	general = {
		enable = true,
		context = EasyBuff.CFG_CONTEXT_AUTO,
		announce = EasyBuff.CFG_ANN_HUD,
		announceWindow = nil,
		announceContextChange = true
	},
	context = {
		solo = {
			-- This will be auto-populated with your characters buff abilities
		},
		party = {
			-- This will be auto-populated with your characters buff abilities
		},
		raid = {
			-- This will be auto-populated with your characters buff abilities
		},
		bg = {
			-- This will be auto-populated with your characters buff abilities
		}
	}
};
