local _, _, _, P, _ = unpack(ElvUI)

P.abb = {
	removeDragonOverride = false,
	enhancedGlobalFade = {
		enable = true,
		displayTriggers = {
			hasFocus = true,
			hasTarget = true,
			inCombat = 2,
			onTaxi = 2,
			inVehicle = true,
			isPossessed = true,
			isDragonRiding = true,
			hideAsPassenger = true,
			mouseover = true,
			notMaxHealth = true,
			playerCasting = true,
			inInstance = 2,
		},
		smooth = 0.33
	}
}
