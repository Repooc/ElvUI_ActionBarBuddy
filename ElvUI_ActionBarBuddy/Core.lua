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

local ABB = E:NewModule(AddOnName, 'AceHook-3.0')
_G[AddOnName] = Engine

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata or GetAddOnMetadata

ABB.Title = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Title')
ABB.Version = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Version')
ABB.Configs = {}

function ABB:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'ActionBar Buddy:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

local function GetOptions()
	for _, func in pairs(ABB.Configs) do
		func()
	end
end

ABB.fadeParentTable = {}

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
	if barName and AB.handledBars[barName] then
		local db = E.db.abb[barName]
		if db.inheritGlobalFade then
			AB:Unhook(AB.handledBars[barName], 'OnEnter')
			AB:Unhook(AB.handledBars[barName], 'OnLeave')
			if not ABB:IsHooked(AB.handledBars[barName], 'OnEnter') then
				ABB:HookScript(AB.handledBars[barName], 'OnEnter', 'Bar_OnEnter')
			end
			if not ABB:IsHooked(AB.handledBars[barName], 'OnLeave') then
				ABB:HookScript(AB.handledBars[barName], 'OnLeave', 'Bar_OnLeave')
			end
			for x = 1, 12 do
				AB:Unhook(AB.handledBars[barName].buttons[x], 'OnEnter')
				AB:Unhook(AB.handledBars[barName].buttons[x], 'OnLeave')
				if not ABB:IsHooked(AB.handledBars[barName].buttons[x], 'OnEnter') then
					ABB:HookScript(AB.handledBars[barName].buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not ABB:IsHooked(AB.handledBars[barName].buttons[x], 'OnLeave') then
					ABB:HookScript(AB.handledBars[barName].buttons[x], 'OnLeave', 'Button_OnLeave')
				end
			end
			AB:PositionAndSizeBar(barName)
		elseif not db.inheritGlobalFade then
			if not AB:IsHooked(AB.handledBars[barName], 'OnEnter') then
				AB:HookScript(AB.handledBars[barName], 'OnEnter', 'Bar_OnEnter')
			end
			if not AB:IsHooked(AB.handledBars[barName], 'OnLeave') then
				AB:HookScript(AB.handledBars[barName], 'OnLeave', 'Bar_OnLeave')
			end
			if ABB:IsHooked(AB.handledBars[barName], 'OnEnter') then
				ABB:Unhook(AB.handledBars[barName], 'OnEnter')
			end
			if ABB:IsHooked(AB.handledBars[barName], 'OnLeave') then
				ABB:Unhook(AB.handledBars[barName], 'OnLeave')
			end
			for x = 1, 12 do
				if not AB:IsHooked(AB.handledBars[barName].buttons[x], 'OnEnter') then
					AB:HookScript(AB.handledBars[barName].buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not AB:IsHooked(AB.handledBars[barName].buttons[x], 'OnLeave') then
					AB:HookScript(AB.handledBars[barName].buttons[x], 'OnLeave', 'Button_OnLeave')
				end
				if ABB:IsHooked(AB.handledBars[barName].buttons[x], 'OnEnter') then
					ABB:Unhook(AB.handledBars[barName].buttons[x], 'OnEnter')
				end
				if ABB:IsHooked(AB.handledBars[barName].buttons[x], 'OnLeave') then
					ABB:Unhook(AB.handledBars[barName].buttons[x], 'OnLeave')
				end
			end
			AB:PositionAndSizeBar(barName)
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

	-- if E.Retail then
	-- 	local ZoneAbilityFrame = _G.ZoneAbilityFrame
	-- 	ZoneAbilityFrame.SpellButtonContainer:UnhookScript('OnEnter', AB.ExtraButtons_OnEnter)
	-- 	ZoneAbilityFrame.SpellButtonContainer:HookScript('OnLeave', AB.ExtraButtons_OnLeave)
	-- end

	if E.Retail then
		ABB:UpdateDragonRiding()
	end
end

function ABB:Bar_OnEnter(bar)
	do
		local barName = 'bar'..bar.id
		local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
		if bar:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
			E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Bar_OnLeave(bar)
	do
		local barName = 'bar'..bar.id
		local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
		local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
		if bar:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
			E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(1)
			end
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function ABB:Button_OnEnter(button)
	local bar = button:GetParent()
	do
		local barName = 'bar'..bar.id
		local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
		if bar:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
			E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == 1) then
				E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
				AB:FadeBlings(1)
			end
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Button_OnLeave(button)
	local bar = button:GetParent()

	do
		local barName = 'bar'..bar.id
		local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
		local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
		if bar:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
			E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end

	for barName, barToCheck in pairs(AB.handledBars) do
		if bar ~= barToCheck then
			local db = E.db.abb[barName].customTriggers and E.db.abb[barName] or E.db.abb.global
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0)
			if barToCheck:GetParent() == ABB.fadeParentTable[barName] and db.displayTriggers.mouseover and (not ABB.fadeParentTable[barName].mouseLock or ABB.fadeParentTable[barName]:GetAlpha() == a) then
				E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
				AB:FadeBlings(a)
			end
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
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

	local function CanGlide()
		local isGliding, canGlide = C_PlayerInfo.GetGlidingInfo()
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
			canGlide = arg1 and not IsPassenger()
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
		or (E.Retail and ((db.displayTriggers.isDragonRiding and (canGlide or CanGlide())))
		or (not E.Classic and (db.displayTriggers.inVehicle and (UnitExists('vehicle')) and (not db.displayTriggers.hideAsPassenger or db.displayTriggers.hideAsPassenger and not IsPassenger())))) then
			ABB.fadeParentTable[barName].mouseLock = true
			E:UIFrameFadeIn(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), 1)
			AB:FadeBlings(1)
		else
			local a = 1 - (E.db.abb.global.globalFadeAlpha or 0.5)
			E:UIFrameFadeOut(ABB.fadeParentTable[barName], 0.2, ABB.fadeParentTable[barName]:GetAlpha(), a)
			ABB.fadeParentTable[barName].mouseLock = false
			AB:FadeBlings(a)
		end
	end
end

local function SetupFadeParents()
	for i = 1, 10 do
		-- AB:CreateBar(i)
		local frame = CreateFrame('Frame', 'ABB_ABFadeBar'..i, UIParent)
		ABB.fadeParentTable['bar'..i] = frame
		frame:SetAlpha(1 - (E.db.abb.global.globalFadeAlpha or 0))
		frame:RegisterEvent('PLAYER_REGEN_DISABLED')
		frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		frame:RegisterEvent('PLAYER_TARGET_CHANGED')
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

		frame.bar = 'bar'..i

		frame:SetScript('OnEvent', ABB.FadeParent_OnEvent)
	end

	for i = 13, 15 do
		-- AB:CreateBar(i)
		local frame = CreateFrame('Frame', 'ABB_ABFadeBar'..i, UIParent)
		ABB.fadeParentTable['bar'..i] = frame
		frame:SetAlpha(1 - (E.db.abb.global.globalFadeAlpha or 0))
		frame:RegisterEvent('PLAYER_REGEN_DISABLED')
		frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		frame:RegisterEvent('PLAYER_TARGET_CHANGED')
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

		frame.bar = 'bar'..i

		frame:SetScript('OnEvent', ABB.FadeParent_OnEvent)
	end
end

function ABB:PositionAndSizeBar(barNum)
	if not barNum then return end

	local bar = AB.handledBars[barNum]
	local db = E.db.abb[barNum]
	if not bar or not db then return end
	local elvDB = E.db.actionbar[barNum]
	bar:SetParent((db.inheritGlobalFade and ABB.fadeParentTable[barNum]) or (elvDB.inheritGlobalFade and AB.fadeParent) or E.UIParent)
end

function ABB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not AB.Initialized then return end

	SetupFadeParents()

	ABB:SecureHook(AB, 'PositionAndSizeBar', ABB.PositionAndSizeBar)

	for barName in pairs(AB.handledBars) do
		AB:PositionAndSizeBar(barName)
	end

	hooksecurefunc(E, 'UpdateDB', ABB.UpdateOptions)
	ABB:UpdateOptions()

	if not ABBDB then
		_G.ABBDB = {}
	end
end

E.Libs.EP:HookInitialize(ABB, ABB.Initialize)
