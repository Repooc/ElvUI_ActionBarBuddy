local _, _, _, P, _ = unpack(ElvUI)

P.actionbar.abb = {
	enhancedGlobalFade = {
		enable = true,
		displayTriggers = {
			playerCasting = true,
			hasTarget = true,
			hasFocus = true,
			inVehicle = true,
			inCombat = true,
			notMaxHealth = true,
		}
	}
}
