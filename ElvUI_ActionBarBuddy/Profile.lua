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

local function CreateBar(barNum)
	local barName = (barNum == 'barPet' or barNum == 'stanceBar') and barNum or 'bar'..barNum
	P.abb[barName] = {
		inheritGlobalFade = false,
		customTriggers = false,
		displayTriggers = CopyTable(ElvUIDefaultValues),
	}
end

for i = 1, 10 do
	CreateBar(i)
end

for i = 13, 15 do
	CreateBar(i)
end

local bars = { 'barPet', 'stanceBar' }
for _, barName in pairs(bars) do CreateBar(barName) end
