local E = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local AB = E.ActionBars
local AddOnName, Engine = ...

local ABB = E:NewModule(AddOnName, 'AceHook-3.0')
_G[AddOnName] = Engine

ABB.Title = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Title')
ABB.Version = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Version')
ABB.Configs = {}

function ABB:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'ActionBar Masks:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

local function GetOptions()
	for _, func in pairs(ABB.Configs) do
		func()
	end
end

function ABB:UpdateOptions()
	local db = E.db.actionbar.abb
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
			ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
			ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')

			for x = 1, 12 do
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
				ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
				ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
			end
		end
		if E.Retail then
			for i = 13, 15 do
				AB:Unhook(AB.handledBars['bar'..i], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i], 'OnLeave')
				ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
				ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')

				for x = 1, 12 do
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
				end
			end
		end
	else
		AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)
	end
end

function ABB:Bar_OnEnter(bar, bb)
	local db = AB.db.abb.enhancedGlobalFade
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
	local db = AB.db.abb.enhancedGlobalFade
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
	local db = AB.db.abb.enhancedGlobalFade
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
	local db = AB.db.abb.enhancedGlobalFade
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

function ABB:FadeParent_OnEvent()
	local db = AB.db.abb.enhancedGlobalFade
	if (db.displayTriggers.playerCasting and (UnitCastingInfo('player') or UnitChannelInfo('player'))) or (db.displayTriggers.hasTarget and UnitExists('target')) or (db.displayTriggers.hasFocus and UnitExists('focus')) or (db.displayTriggers.inVehicle and UnitExists('vehicle'))
	or (db.displayTriggers.inCombat and UnitAffectingCombat('player')) or (db.displayTriggers.notMaxHealth and (UnitHealth('player') ~= UnitHealthMax('player'))) or E.Retail and (db.displayTriggers.inVehicle and (IsPossessBarVisible() or HasOverrideActionBar())) then
		AB.fadeParent.mouseLock = true
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	else
		AB.fadeParent.mouseLock = false
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end
end

function ABB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not AB.Initialized then return end

	hooksecurefunc(E, 'UpdateDB', ABB.UpdateOptions)
	ABB:UpdateOptions()

	if not ABBDB then
		_G.ABBDB = {}
	end
end

E.Libs.EP:HookInitialize(ABB, ABB.Initialize)
