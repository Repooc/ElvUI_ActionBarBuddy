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
local VIGOR_BAR_ID = 631 -- this is the oval & diamond variant

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

function ABB:UpdateDragonRiding()
	local fullConditions = format('[overridebar] %d; [vehicleui][possessbar] %d;', GetOverrideBarIndex(), GetVehicleBarIndex()) or ''
	if E.db.abb.removeDragonOverride then
		AB.barDefaults.bar1.conditions = fullConditions..format('[shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	else
		AB.barDefaults.bar1.conditions = fullConditions..format('[bonusbar:5] 11; [shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	end
	AB:PositionAndSizeBar('bar1')
end

function ABB:UpdateOptions()
	local db = E.db.abb

	-- AB.fadeParent:RegisterEvent('PLAYER_REGEN_DISABLED')
	-- AB.fadeParent:RegisterEvent('PLAYER_REGEN_ENABLED')
	-- AB.fadeParent:RegisterEvent('PLAYER_TARGET_CHANGED')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_HEALTH', 'player')

	-- if not E.Classic then
	-- 	AB.fadeParent:RegisterEvent('PLAYER_FOCUS_CHANGED')
	-- end

	-- if E.Retail or E.Wrath then
	-- 	AB.fadeParent:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
	-- 	AB.fadeParent:RegisterEvent('UPDATE_POSSESS_BAR')
	-- 	AB.fadeParent:RegisterEvent('VEHICLE_UPDATE')
	-- 	AB.fadeParent:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	-- 	AB.fadeParent:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	-- end

	-- ABB.fadeParent:SetScript('OnEvent', ABB.FadeParent_OnEvent)
	if db.enhancedGlobalFade.enable then
		AB.fadeParent:SetScript('OnEvent', ABB.FadeParent_OnEvent)

		for i = 1, 10 do
			AB:Unhook(AB.handledBars['bar'..i], 'OnEnter')
			AB:Unhook(AB.handledBars['bar'..i], 'OnLeave')
			if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnEnter') then
				ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
			end
			if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnLeave') then
				ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')
			end

			for x = 1, 12 do
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
				if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnEnter') then
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnLeave') then
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
				end
			end
			AB:PositionAndSizeBar('bar'..i)
		end
		if E.Retail then
			for i = 13, 15 do
				AB:Unhook(AB.handledBars['bar'..i], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i], 'OnLeave')
				if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnEnter') then
					ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
				end
				if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnLeave') then
					ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')
				end

				for x = 1, 12 do
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
					if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnEnter') then
						ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
					end
					if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnLeave') then
						ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
					end
				end
				AB:PositionAndSizeBar('bar'..i)
			end
		end

		-- if E.Retail then
		-- 	local ZoneAbilityFrame = _G.ZoneAbilityFrame
		-- 	ZoneAbilityFrame.SpellButtonContainer:UnhookScript('OnEnter', AB.ExtraButtons_OnEnter)
		-- 	ZoneAbilityFrame.SpellButtonContainer:HookScript('OnLeave', AB.ExtraButtons_OnLeave)
		-- end
	else
		AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)
	end

	if E.Retail then
		ABB:UpdateDragonRiding()
	end
end

function ABB:Bar_OnEnter(bar)
	local db = E.db.abb.enhancedGlobalFade
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Bar_OnLeave(bar)
	local db = E.db.abb.enhancedGlobalFade
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function ABB:Button_OnEnter(button)
	local db = E.db.abb.enhancedGlobalFade
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Button_OnLeave(button)
	local db = E.db.abb.enhancedGlobalFade
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
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
		local isGliding = C_PlayerInfo.GetGlidingInfo()
		local bonusbar = SecureCmdOptionParse('[bonusbar:5] 1; 0')

		return isGliding or bonusbar == '1'
	end

	local canGlide = false
	local inInstance = false
	function ABB:FadeParent_OnEvent(event, arg1, _, arg3)
		if event == 'PLAYER_CAN_GLIDE_CHANGED' then
			canGlide = arg1 and not IsPassenger()
		end

		inInstance = select(2, GetInstanceInfo()) ~= 'none'

		local db = E.db.abb.enhancedGlobalFade
		local possessbar = SecureCmdOptionParse('[possessbar] 1; 0')

		if (db.displayTriggers.inInstance == 2 and inInstance or db.displayTriggers.inInstance == 1 and not inInstance)
		or (db.displayTriggers.playerCasting and (UnitCastingInfo('player') or UnitChannelInfo('player')))
		or (db.displayTriggers.hasTarget and UnitExists('target'))
		or (db.displayTriggers.hasFocus and UnitExists('focus'))
		or (db.displayTriggers.isPossessed and possessbar == '1')
		or (db.displayTriggers.inCombat == 2 and UnitAffectingCombat('player') or db.displayTriggers.inCombat == 1 and not UnitAffectingCombat('player'))
		or (db.displayTriggers.notMaxHealth and (UnitHealth('player') ~= UnitHealthMax('player')))
		or (db.displayTriggers.onTaxi == 2 and UnitOnTaxi('player') or db.displayTriggers.onTaxi == 1 and not UnitOnTaxi('player'))
		or (E.Retail and ((db.displayTriggers.isDragonRiding and (canGlide or CanGlide())))
		or (E.Retail and (db.displayTriggers.inVehicle and (IsPossessBarVisible() or HasOverrideActionBar() or UnitExists('vehicle')) and (not db.displayTriggers.hideAsPassenger or db.displayTriggers.hideAsPassenger and not IsPassenger())))) then
			-- E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
			AB.fadeParent.mouseLock = true
			E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
			AB:FadeBlings(1)
		else
			local a = 1 - AB.db.globalFadeAlpha
			E:UIFrameFadeOut(AB.fadeParent, db.smooth, AB.fadeParent:GetAlpha(), a)
			AB.fadeParent.mouseLock = false
			AB:FadeBlings(a)
		end
	end
end

function ABB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not AB.Initialized then return end

	AB.fadeParent:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR')
	AB.fadeParent:RegisterEvent('ZONE_CHANGED_NEW_AREA')

	hooksecurefunc(E, 'UpdateDB', ABB.UpdateOptions)
	ABB:UpdateOptions()

	if not ABBDB then
		_G.ABBDB = {}
	end
end

E.Libs.EP:HookInitialize(ABB, ABB.Initialize)
