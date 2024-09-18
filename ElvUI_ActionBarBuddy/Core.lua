local E = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local AB = E.ActionBars
local AddOnName, Engine = ...

local IsPossessBarVisible, HasOverrideActionBar = IsPossessBarVisible, HasOverrideActionBar
local GetOverrideBarIndex, GetVehicleBarIndex, GetTempShapeshiftBarIndex = GetOverrideBarIndex, GetVehicleBarIndex, GetTempShapeshiftBarIndex
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local C_PlayerInfo_GetGlidingInfo = C_PlayerInfo and C_PlayerInfo.GetGlidingInfo
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS or 10

local ABB = E:NewModule(AddOnName, 'AceHook-3.0')
_G[AddOnName] = Engine

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata or GetAddOnMetadata

ABB.Title = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Title')

ABB.Configs = {}

function ABB:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'ActionBar Buddy:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

function ABB:ParseVersionString()
	local version = GetAddOnMetadata(AddOnName, 'Version')
	local prevVersion = GetAddOnMetadata(AddOnName, 'X-PreviousVersion')
	if strfind(version, 'project%-version') then
		return prevVersion, prevVersion..'-git', nil, true
	else
		local release, extra = strmatch(version, '^v?([%d.]+)(.*)')
		return tonumber(release), release..extra, extra ~= ''
	end
end

ABB.version, ABB.versionString, ABB.versionDev, ABB.versionGit = ABB:ParseVersionString()

local function GetOptions()
	for _, func in pairs(ABB.Configs) do
		func()
	end
end

ABB.fadeParentTable = {}
local bars = {
	barPet = _G.ElvUI_BarPet,
	stanceBar = _G.ElvUI_StanceBar,
}
function ABB:UpdateDragonRiding()
	local fullConditions = format('[overridebar] %d; [vehicleui][possessbar] %d;', GetOverrideBarIndex(), GetVehicleBarIndex()) or ''
	if E.db.abb.removeDragonOverride then
		AB.barDefaults.bar1.conditions = fullConditions..format('[shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	else
		AB.barDefaults.bar1.conditions = fullConditions..format('[bonusbar:5] 11; [shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	end
	AB:PositionAndSizeBar('bar1')
end

function ABB:ToggleFade(barName)
	if not barName then return end
	local isPet = barName == 'barPet'
	local isStance = barName == 'stanceBar'

	local bar = (isPet and _G.ElvUI_BarPet) or (isStance and _G.ElvUI_StanceBar) or AB.handledBars[barName]
	local numButtons = (isPet and NUM_PET_ACTION_SLOTS) or (isStance and NUM_STANCE_SLOTS) or 12

	if bar then
		local db = E.db.abb[barName]
		if db.inheritGlobalFade then
			AB:Unhook(bar, 'OnEnter')
			AB:Unhook(bar, 'OnLeave')
			if not isPet and not ABB:IsHooked(bar, 'OnEnter') then
				ABB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
			end
			if not isPet and not ABB:IsHooked(bar, 'OnLeave') then
				ABB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')
			end
			for x = 1, numButtons do
				AB:Unhook(bar.buttons[x], 'OnEnter')
				AB:Unhook(bar.buttons[x], 'OnLeave')
				if not ABB:IsHooked(bar.buttons[x], 'OnEnter') then
					ABB:HookScript(bar.buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not ABB:IsHooked(bar.buttons[x], 'OnLeave') then
					ABB:HookScript(bar.buttons[x], 'OnLeave', 'Button_OnLeave')
				end
			end
			if isPet then
				AB:PositionAndSizeBarPet()
			elseif isStance then
				AB:PositionAndSizeBarShapeShift()
			else
				AB:PositionAndSizeBar(barName)
			end
		elseif not db.inheritGlobalFade then
			if not AB:IsHooked(bar, 'OnEnter') then
				AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
			end
			if not AB:IsHooked(bar, 'OnLeave') then
				AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')
			end
			if ABB:IsHooked(bar, 'OnEnter') then
				ABB:Unhook(bar, 'OnEnter')
			end
			if ABB:IsHooked(bar, 'OnLeave') then
				ABB:Unhook(bar, 'OnLeave')
			end
			for x = 1, numButtons do
				if not AB:IsHooked(bar.buttons[x], 'OnEnter') then
					AB:HookScript(bar.buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not AB:IsHooked(bar.buttons[x], 'OnLeave') then
					AB:HookScript(bar.buttons[x], 'OnLeave', 'Button_OnLeave')
				end
				if ABB:IsHooked(bar.buttons[x], 'OnEnter') then
					ABB:Unhook(bar.buttons[x], 'OnEnter')
				end
				if ABB:IsHooked(bar.buttons[x], 'OnLeave') then
					ABB:Unhook(bar.buttons[x], 'OnLeave')
				end
			end
			if isPet then
				AB:PositionAndSizeBarPet()
			elseif isStance then
				AB:PositionAndSizeBarShapeShift()
			else
				AB:PositionAndSizeBar(barName)
			end
		end
	end
end

function ABB:UpdateOptions()
	for i = 1, 10 do
		local barName = 'bar'..i
		ABB:ToggleFade(barName)
	end

	for i = 13, 15 do
		local barName = 'bar'..i
		ABB:ToggleFade(barName)
	end

	for barName in pairs(bars) do
		ABB:ToggleFade(barName)
	end

	if E.Retail then
		ABB:UpdateDragonRiding()
	end
end

function ABB:Bar_OnEnter(bar)
	local currentBarName = bar:GetParent().bar
	local currentBarDB = E.db.abb[currentBarName].customTriggers and E.db.abb[currentBarName] or E.db.abb.global
	do
		if bar:GetParent() == ABB.fadeParentTable[currentBarName] and currentBarDB.displayTriggers.mouseover and (not ABB.fadeParentTable[currentBarName].mouseLock or ABB.fadeParentTable[currentBarName]:GetAlpha() == 1) then
			E:UIFrameFadeIn(ABB.fadeParentTable[currentBarName], 0.2, ABB.fadeParentTable[currentBarName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end

	for barName, barToCheck in pairs(bars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end
end

function ABB:Bar_OnLeave(bar)
	local currentBarName = bar:GetParent().bar
	local currentBarDB = E.db.abb[currentBarName].customTriggers and E.db.abb[currentBarName] or E.db.abb.global
	do
		local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
		if bar:GetParent() == ABB.fadeParentTable[currentBarName] and currentBarDB.displayTriggers.mouseover and (not ABB.fadeParentTable[currentBarName].mouseLock or ABB.fadeParentTable[currentBarName]:GetAlpha() == a) then
			E:UIFrameFadeOut(ABB.fadeParentTable[currentBarName], 0.2, ABB.fadeParentTable[currentBarName]:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(1)
			end
		end
	end

	for barName, barToCheck in pairs(bars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(1)
			end
		end
	end
end

function ABB:Button_OnEnter(button)
	local bar = button:GetParent()
	local currentBarName = bar:GetParent().bar
	local currentBarDB = E.db.abb[currentBarName].customTriggers and E.db.abb[currentBarName] or E.db.abb.global
	do
		if bar:GetParent() == ABB.fadeParentTable[currentBarName] and currentBarDB.displayTriggers.mouseover and (not ABB.fadeParentTable[currentBarName].mouseLock or ABB.fadeParentTable[currentBarName]:GetAlpha() == 1) then
			E:UIFrameFadeIn(ABB.fadeParentTable[currentBarName], 0.2, ABB.fadeParentTable[currentBarName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end

	for barName, barToCheck in pairs(bars) do
			if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if _G.ElvUI_BarPet:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end
end

function ABB:Button_OnLeave(button)
	local bar = button:GetParent()
	local currentBarName = bar:GetParent().bar
	local currentBarDB = E.db.abb[currentBarName].customTriggers and E.db.abb[currentBarName] or E.db.abb.global

	do
		local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
		if bar:GetParent() == ABB.fadeParentTable[currentBarName] and currentBarDB.displayTriggers.mouseover and (not ABB.fadeParentTable[currentBarName].mouseLock or ABB.fadeParentTable[currentBarName]:GetAlpha() == a) then
			E:UIFrameFadeOut(ABB.fadeParentTable[currentBarName], 0.2, ABB.fadeParentTable[currentBarName]:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(a)
			end
		end
	end

	for barName, barToCheck in pairs(bars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if _G.ElvUI_BarPet:GetParent() == ABB.fadeParentTable[barName] and currentBarDB.displayTriggers.mouseover and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(a)
			end
		end
	end
end

do
	local function IsPassenger()
		if UnitInVehicle('player') and not UnitInVehicleControlSeat('player') then
			return true
		else
			return false
		end
	end

	local function CanGlide(event)
		local isGliding, canGlide = C_PlayerInfo.GetGlidingInfo()
		local dragonbar = SecureCmdOptionParse('[bonusbar:5] 1; 0')

		if event == 'UPDATE_OVERRIDE_ACTIONBAR' or event == 'UNIT_EXITED_VEHICLE' or event == 'UNIT_ENTERED_VEHICLE' then
			if (canGlide and (dragonbar == '0')) or (not canGlide and (dragonbar == '1')) then
				canGlide = false
			end
		end

		return isGliding or canGlide
	end

	local canGlide = false
	local inInstance = false
	function ABB:FadeParent_OnEvent(event, arg1)
		if not E.db.abb then return end
		local barName = self.bar

		if event == 'UPDATING_OPTIONS' then
			barName = arg1
		end

		if event == 'PLAYER_CAN_GLIDE_CHANGED' then
			local dragonbar = SecureCmdOptionParse('[bonusbar:5] 1; 0')
			if (arg1 and (dragonbar == '0')) or (not arg1 and (dragonbar == '1')) then
				arg1 = false
			end

			canGlide = arg1 and not IsPassenger()
		end

		if event == 'LOADING_SCREEN_DISABLED' or event == 'TAXIMAP_OPENED' or event == 'TAXIMAP_CLOSED' then
			canGlide = false
		end

		inInstance = select(2, GetInstanceInfo()) ~= 'none'

		local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
		local possessbar = SecureCmdOptionParse('[possessbar] 1; 0')

		if (db.displayTriggers.inInstance == 2 and inInstance or db.displayTriggers.inInstance == 1 and not inInstance)
		or (db.displayTriggers.playerCasting and (UnitCastingInfo('player') or UnitChannelInfo('player')))
		or (db.displayTriggers.hasTarget and UnitExists('target'))
		or (db.displayTriggers.hasFocus and UnitExists('focus'))
		or (db.displayTriggers.isPossessed and possessbar == '1')
		or (db.displayTriggers.hasOverridebar and HasOverrideActionBar())
		or (db.displayTriggers.inCombat == 2 and UnitAffectingCombat('player') or db.displayTriggers.inCombat == 1 and not UnitAffectingCombat('player'))
		or (db.displayTriggers.notMaxHealth and (UnitHealth('player') ~= UnitHealthMax('player')))
		or (db.displayTriggers.onTaxi == 2 and UnitOnTaxi('player') or db.displayTriggers.onTaxi == 1 and not UnitOnTaxi('player'))
		or (E.Retail and (db.displayTriggers.isDragonRiding and not IsPassenger() and (canGlide or CanGlide(event))))
		or (not E.Classic and (db.displayTriggers.inVehicle and UnitExists('vehicle') and (not db.displayTriggers.hideAsPassenger or db.displayTriggers.hideAsPassenger and not IsPassenger()))) then
			ABB.fadeParentTable[barName].mouseLock = true
			E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		else
			ABB.fadeParentTable[barName].mouseLock = false
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0.5)
			E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end
end

local function CreateFadeParents(barNum)
	if not barNum then return end
	local barName = bars[barNum] and barNum or 'bar'..barNum

	local frame = CreateFrame('Frame', 'ABB_FadeParent_'..barName, UIParent)
	ABB.fadeParentTable[barName] = frame
	frame:SetAlpha(1 - (E.db.abb.global.globalFadeAlpha or 0))
	frame:RegisterEvent('PLAYER_REGEN_DISABLED')
	frame:RegisterEvent('PLAYER_REGEN_ENABLED')
	frame:RegisterEvent('PLAYER_TARGET_CHANGED')
	frame:RegisterEvent('LOADING_SCREEN_DISABLED')
	frame:RegisterEvent('TAXIMAP_OPENED')
	frame:RegisterEvent('TAXIMAP_CLOSED')
	frame:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
	frame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
	frame:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
	frame:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
	frame:RegisterUnitEvent('UNIT_HEALTH', 'player')

	if not E.Classic then
		frame:RegisterEvent('PLAYER_FOCUS_CHANGED')
	end

	if E.Retail then
		frame:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_START', 'player')
		frame:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_STOP', 'player')
		frame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
		frame:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
		frame:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
		frame:RegisterEvent('UPDATE_POSSESS_BAR')
		frame:RegisterEvent('PLAYER_CAN_GLIDE_CHANGED')
	end

	if E.Retail or E.Cata then
		frame:RegisterEvent('VEHICLE_UPDATE')
		frame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
		frame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	end

	frame:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR')
	frame:RegisterEvent('ZONE_CHANGED_NEW_AREA')

	frame.bar = barName

	frame:SetScript('OnEvent', ABB.FadeParent_OnEvent)
end
local function SetupFadeParents()
	for i = 1, 10 do CreateFadeParents(i) end
	for i = 13, 15 do CreateFadeParents(i) end
	for barName in pairs(bars) do CreateFadeParents(barName) end
end

function ABB:PositionAndSizeBar(barNum)
	if not barNum then return end
	local db = E.db.abb[barNum]
	if not db or not db.inheritGlobalFade then return end

	local bar = AB.handledBars[barNum]
	if not bar or not db then return end
	bar:SetParent((db.inheritGlobalFade and ABB.fadeParentTable[barNum]) or E.UIParent)
	bar:SetAlpha(1)
end

function ABB:PositionAndSizeBarPet()
	local db = E.db.abb.barPet
	local barDB = AB.db.barPet
	if not db or not barDB or not db.inheritGlobalFade then return end

	local bar = _G.ElvUI_BarPet
	if not bar then return end
	bar:SetParent((db.inheritGlobalFade and ABB.fadeParentTable.barPet) or E.UIParent)
	bar:SetAlpha(1)
end

function ABB:PositionAndSizeBarShapeShift()
	local db = E.db.abb.stanceBar
	local barDB = AB.db.stanceBar
	if not db or not barDB or not db.inheritGlobalFade then return end

	local bar = _G.ElvUI_StanceBar
	if not bar then return end
	bar:SetParent((db.inheritGlobalFade and ABB.fadeParentTable.stanceBar) or E.UIParent)
	bar:SetAlpha(1)
end

function ABB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions, nil, ABB.versionString)
	if not AB.Initialized then return end

	SetupFadeParents()

	ABB:SecureHook(AB, 'PositionAndSizeBar', ABB.PositionAndSizeBar)
	ABB:SecureHook(AB, 'PositionAndSizeBarPet', ABB.PositionAndSizeBarPet)
	ABB:SecureHook(AB, 'PositionAndSizeBarShapeShift', ABB.PositionAndSizeBarShapeShift)

	for barName in pairs(AB.handledBars) do
		AB:PositionAndSizeBar(barName)
	end
	AB:PositionAndSizeBarPet()
	AB:PositionAndSizeBarShapeShift()

	hooksecurefunc(E, 'UpdateDB', ABB.UpdateOptions)
	ABB:UpdateOptions()

	if not ABBDB then
		_G.ABBDB = {}
	end
end

E.Libs.EP:HookInitialize(ABB, ABB.Initialize)
