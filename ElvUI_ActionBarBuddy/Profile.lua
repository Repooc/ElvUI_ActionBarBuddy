local _, _, _, P, _ = unpack(ElvUI)

local CopyTable = CopyTable

local ElvUIDefaultValues = {
	hasFocus = true,
	hasOverridebar = true,
	hasTarget = true,
	hideAsPassenger = false,
	inCombat = 2,
	inInstance = 0,
	inVehicle = true,
	isDragonRiding = true,
	isPossessed = true,
	mouseover = true,
	notMaxHealth = true,
	onTaxi = 0,
	playerCasting = true,
}

P.abb = {
	removeDragonOverride = false,
	global = {
		displayTriggers = CopyTable(ElvUIDefaultValues),
		globalFadeAlpha = 0.5,
	}
}

for i = 1, 10 do
	P.abb['bar'..i] = {
		inheritGlobalFade = false,
		customTriggers = false,
		displayTriggers = CopyTable(ElvUIDefaultValues),
	}
end

for i = 13, 15 do
	P.abb['bar'..i] = {
		inheritGlobalFade = false,
		customTriggers = false,
		displayTriggers = CopyTable(ElvUIDefaultValues),
	}
end
