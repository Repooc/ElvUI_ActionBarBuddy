local E, L = unpack(ElvUI)
local ABB = E:GetModule('ElvUI_ActionBarBuddy')
local ABBCL = E:GetModule('ABB-Changelog')
local AB = E.ActionBars
local ACH = E.Libs.ACH

local DONATORS = {
	'None to be displayed at this time.',
}

local DEVELOPERS = {
	'|cff0070DEAzilroka|r',
	'Blazeflack',
	'|cff9482c9Darth Predator|r',
	'|cffFF3333Elv|r',
	'|cffFFC44DHydra|r',
	E:TextGradient('Simpy but my name needs to be longer.', 0.27,0.72,0.86, 0.51,0.36,0.80, 0.69,0.28,0.94, 0.94,0.28,0.63, 1.00,0.51,0.00, 0.27,0.96,0.43),
	'|cffFF8000Tukz|r',
}

local TESTERS = {
	'|cffeb9f24Tukui Community|r',
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(DONATORS, SortList)
sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

local DONATOR_STRING = table.concat(DONATORS, '|n')
local DEVELOPER_STRING = table.concat(DEVELOPERS, '|n')
local TESTER_STRING = table.concat(TESTERS, '|n')

local globalFadeOptions = {
	hasFocus = L["Has Focus"],
	hasTarget = L["Has Target"],
	inCombat = L["In Combat"],
	inVehicle = L["In Vehicle"],
	isPossessed = L["You Possess Target"],
	isDragonRiding = L["Is Dragonriding"],
	mouseover= L["Mouseover"],
	notMaxHealth = L["Not Max Health"],
	playerCasting = L["Player Casting"],
}

local function configTable()
	local abb = ACH:Group('|cFF16C3F2ActionBar|r Buddy', nil, 6, 'tab', nil, nil, function() return not AB.Initialized end)
	E.Options.args.abb = abb

	local ActionBar = E.Options.args.actionbar

	local EnhancedGlobalFade = ACH:Group(L["|cFF16C3F2AB|r |cffFFFFFFBuddy:|r Global Fade"], nil, 21, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end)
	ActionBar.args.general.args.enhancedGlobalFade = EnhancedGlobalFade
	-- EnhancedGlobalFade.inline = true
	ActionBar.args.general.args.globalFadeAlpha = nil
	EnhancedGlobalFade.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB.fadeParent:SetAlpha(1-value) end)
	EnhancedGlobalFade.args.smooth = ACH:Range(L["Smooth"], nil, 4, { min = 0, max = 1, step = 0.01 }, nil, function(info) return E.db.actionbar.abb.enhancedGlobalFade[info[#info]] end, function(info, value) E.db.actionbar.abb.enhancedGlobalFade[info[#info]] = value ABB:FadeParent_OnEvent() end)
	EnhancedGlobalFade.args.spacer = ACH:Spacer(97, 'full')
	EnhancedGlobalFade.args.desc = ACH:Description(L["The default behaviour of Inherit Global Fade would display the bars if any of the following are true.  You can remove the triggers that you want to ignore so the bars only appear when the triggers you have checked are true."], 98, 'medium')
	EnhancedGlobalFade.args.displayTriggers = ACH:MultiSelect(L["Override Display Triggers"], nil, 99, globalFadeOptions, nil, nil, function(info, key) return E.db.actionbar.abb.enhancedGlobalFade[info[#info]][key] end, function(info, key, value) E.db.actionbar.abb.enhancedGlobalFade[info[#info]][key] = value ABB:FadeParent_OnEvent('FAKE_EVENT') end)

	local bar = ActionBar.args.playerBars.args.bar1
	bar.args.abbuddy = ACH:Group(L["|cFF16C3F2AB|r |cffFFFFFFBuddy|r"], nil, 3, nil, nil, nil, nil, not E.Retail)
	bar.args.abbuddy.guiInline = true
	bar.args.abbuddy.args.removeDragonOverride = ACH:Toggle(L["Remove Dragon Override"], nil, 1, nil, nil, nil, function(info) return E.db.actionbar.abb[info[#info]] end, function(info, value) E.db.actionbar.abb[info[#info]] = value ABB:UpdateDragonRiding() end)

	local Help = ACH:Group(L["Help"], nil, 99, nil, nil, nil, false)
	abb.args.help = Help

	local Support = ACH:Group(L["Support"], nil, 1)
	Help.args.support = Support
	Support.inline = true
	Support.args.wago = ACH:Execute(L["Wago Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/addons/elvui-actionbarmasks') end, nil, nil, 140)
	Support.args.curse = ACH:Execute(L["Curseforge Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://www.curseforge.com/wow/addons/actionbar-masks-elvui-plugin') end, nil, nil, 140)
	Support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_ActionBarBuddy/issues') end, nil, nil, 140)
	Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://discord.gg/') end, nil, nil, 140, nil, nil, true)

	local Download = ACH:Group(L["Download"], nil, 2)
	Help.args.download = Download
	Download.inline = true
	Download.args.development = ACH:Execute(L["Development Version"], L["Link to the latest development version."], 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_ActionBarBuddy/archive/refs/heads/main.zip') end, nil, nil, 140)
	Download.args.changelog = ACH:Execute(L["Changelog"], nil, 3, function() if ABB_Changelog and ABB_Changelog:IsShown() then ABB:Print('ActionBar Masks changelog is already being displayed.') else ABBCL:ToggleChangeLog() end end, nil, nil, 140)

	local Credits = ACH:Group(L["Credits"], nil, 5)
	Help.args.credits = Credits
	Credits.inline = true
	Credits.args.string = ACH:Description(E:TextGradient(L["ABB_CREDITS"], 0.27,0.72,0.86, 0.51,0.36,0.80, 0.69,0.28,0.94, 0.94,0.28,0.63, 1.00,0.51,0.00, 0.27,0.96,0.43), 1, 'medium')

	local Coding = ACH:Group(L["Coding"], nil, 6)
	Help.args.coding = Coding
	Coding.inline = true
	Coding.args.string = ACH:Description(DEVELOPER_STRING, 1, 'medium')

	local Testers = ACH:Group(L["Help Testing Development Versions"], nil, 7)
	Help.args.testers = Testers
	Testers.inline = true
	Testers.args.string = ACH:Description(TESTER_STRING, 1, 'medium')

	local Donators = ACH:Group(L["Donators"], nil, 8)
	Help.args.donators = Donators
	Donators.inline = true
	Donators.args.string = ACH:Description(DONATOR_STRING, 1, 'medium')
end

tinsert(ABB.Configs, configTable)
