local _, _, _, P, _ = unpack(ElvUI)

P.actionbar.abb = {
	removeDragonOverride = false,
	enhancedGlobalFade = {
		enable = true,
		displayTriggers = {
			hasFocus = true,
			hasTarget = true,
			inCombat = true,
			inVehicle = true,
			isPossessed = true,
			isDragonRiding = true,
			mouseover = true,
			notMaxHealth = true,
			playerCasting = true,
		},
		smooth = 0.33
	}
}
