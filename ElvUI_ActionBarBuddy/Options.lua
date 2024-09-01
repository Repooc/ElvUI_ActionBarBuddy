local E, L = unpack(ElvUI)
local ABB = E:GetModule('ElvUI_ActionBarBuddy')
local ABBCL = E:GetModule('ABB-Changelog')
local RRP = LibStub('RepoocReforged-1.0'):LoadMainCategory()
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
	hasFocus = {
		name = L["Has Focus"],
	},
	hasTarget = {
		name = L["Has Target"],
	},
	inCombat = {
		name = function(info) local text = L["Combat (|cff%s%s|r)"] local value = E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] if value == 2 then return format(text, '00FF00', L["In Combat"]) elseif value == 1 then return format(text, 'FF0000', L["Not In Combat"]) else return format(text, 'FFFF00', L["Ignore Combat"]) end end,
		tristate = true,
		get = function(info) local value = E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] = (value and 2) or (value == nil and 1) or 0 ABB:FadeParent_OnEvent('FAKE_EVENT') end,
	},
	inInstance = {
		name = L["In Instance"],
		tristate = true,
		get = function(info) local value = E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] = (value and 2) or (value == nil and 1) or 0 ABB:FadeParent_OnEvent('FAKE_EVENT') end,
	},
	inVehicle = {
		name = L["In Vehicle"],
	},
	isDragonRiding = {
		name = L["Is Dragonriding"],
	},
	isPossessed = {
		name = L["You Possess Target"],
	},
	mouseover = {
		name = L["Mouseover"],
	},
	notMaxHealth = {
		name = L["Not Max Health"],
	},
	playerCasting = {
		name = L["Player Casting"],
	},
}

local function configTable()
    --* Repooc Reforged Plugin section
    local rrp = E.Options.args.rrp
    if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

	--* Add/Update ElvUI Options
	local ActionBar = E.Options.args.actionbar
	local EnhancedGlobalFade = ACH:Group(L["|cff00FF98AB|r |cffA330C9Buddy|r|cffF48CBA:|r Global Fade"], nil, 21, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end)
	ActionBar.args.general.args.enhancedGlobalFade = EnhancedGlobalFade
	-- EnhancedGlobalFade.inline = true
	ActionBar.args.general.args.globalFadeAlpha = nil
	EnhancedGlobalFade.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function(info) return E.db.actionbar[info[#info]] end, function(info, value) E.db.actionbar[info[#info]] = value AB.fadeParent:SetAlpha(1-value) end)
	EnhancedGlobalFade.args.smooth = ACH:Range(L["Smooth"], nil, 4, { min = 0, max = 1, step = 0.01 }, nil, function(info) return E.db.abb.enhancedGlobalFade[info[#info]] end, function(info, value) E.db.abb.enhancedGlobalFade[info[#info]] = value ABB:FadeParent_OnEvent() end)
	EnhancedGlobalFade.args.spacer = ACH:Spacer(97, 'full')
	EnhancedGlobalFade.args.desc = ACH:Description(L["The default behaviour of Inherit Global Fade would display the bars if any of the following are true.  You can remove the triggers that you want to ignore so the bars only appear when the triggers you have checked are true."], 98, 'medium')

	EnhancedGlobalFade.args.displayTriggers = ACH:Group(L["Override Display Triggers"], nil, 99, nil, function(info) return E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] end, function(info, value) E.db.abb.enhancedGlobalFade.displayTriggers[info[#info]] = value ABB:FadeParent_OnEvent() end)
	EnhancedGlobalFade.args.displayTriggers.inline = true
	for option, info in next, globalFadeOptions do
		EnhancedGlobalFade.args.displayTriggers.args[option] = ACH:Toggle(info.name, nil, nil, info.tristate, nil, nil, info.get, info.set)
	end

	local bar = ActionBar.args.playerBars.args.bar1
	bar.args.abbuddy = ACH:Group(L["|cff00FF98ActionBar|r |cffA330C9Buddy|r"], nil, 3, nil, nil, nil, nil, not E.Retail)
	bar.args.abbuddy.guiInline = true
	bar.args.abbuddy.args.removeDragonOverride = ACH:Toggle(L["Remove Dragon Override"], nil, 1, nil, nil, nil, function(info) return E.db.abb[info[#info]] end, function(info, value) E.db.abb[info[#info]] = value ABB:UpdateDragonRiding() end)

	--* Plugin Section
	local ActionBarBuddy = ACH:Group('|cff00FF98ActionBar|r |cffA330C9Buddy|r', nil, 6, 'tab', nil, nil, function() return not AB.Initialized end)
	rrp.args.abb = ActionBarBuddy

	ActionBarBuddy.args.version = ACH:Header(format('|cff99ff33%s|r', ABB.Version), 1)
	local Help = ACH:Group(L["Help"], nil, 99, nil, nil, nil, false)
	ActionBarBuddy.args.help = Help

	local Support = ACH:Group(L["Support"], nil, 1)
	Help.args.support = Support
	Support.inline = true
	Support.args.wago = ACH:Execute(L["Wago Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/addons/actionbar-buddy-elvui-plugin') end, nil, nil, 140)
	Support.args.curse = ACH:Execute(L["Curseforge Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://www.curseforge.com/wow/addons/actionbar-buddy-elvui-plugin') end, nil, nil, 140)
	Support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_ActionBarBuddy/issues') end, nil, nil, 140)
	Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://repoocreforged.dev/discord') end, nil, nil, 140)

	local Download = ACH:Group(L["Download"], nil, 2)
	Help.args.download = Download
	Download.inline = true
	Download.args.development = ACH:Execute(L["Development Version"], L["Link to the latest development version."], 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_ActionBarBuddy/archive/refs/heads/main.zip') end, nil, nil, 140)
	Download.args.changelog = ACH:Execute(L["Changelog"], nil, 3, function() if ABB_Changelog and ABB_Changelog:IsShown() then ABB:Print('|cff00FF98ActionBar|r |cffA330C9Buddy|r changelog is already being displayed.') else ABBCL:ToggleChangeLog() end end, nil, nil, 140)

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
