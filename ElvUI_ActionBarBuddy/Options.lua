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
		order = 5,
	},
	hasOverridebar = {
		name = L["Have Overridebar"],
		order = 5,
	},
	hasTarget = {
		name = L["Has Target"],
		order = 5,
	},
	hideAsPassenger = {
		name = L["Hide As Passenger"],
		order = 99,
		disabled = function(info) return info[#info-2] ~= 'global' and (not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers) or not E.db.abb[info[#info-2]][info[#info-1]].inVehicle end,
		hidden = function() return E.Classic end
	},
	inCombat = {
		name = function(info) local text = L["Combat (|cff%s%s|r)"] local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return format(text, '00FF00', L["In Combat"]) elseif value == 1 then return format(text, 'FF0000', L["Not In Combat"]) else return format(text, 'FFFF00', L["Ignore Combat"]) end end,
		order = 5,
		tristate = true,
		get = function(info) local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = (value and 2) or (value == nil and 1) or 0 ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end,
	},
	inInstance = {
		name = function(info) local text = L["Instance (|cff%s%s|r)"] local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return format(text, '00FF00', L["In Instance"]) elseif value == 1 then return format(text, 'FF0000', L["Not In Instance"]) else return format(text, 'FFFF00', L["Ignore Instance"]) end end,
		order = 5,
		tristate = true,
		get = function(info) local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = (value and 2) or (value == nil and 1) or 0 ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end,
	},
	inVehicle = {
		name = L["In Vehicle"],
		order = 98,
		hidden = function() return E.Classic end,
	},
	onTaxi = {
		name = function(info) local text = L["Taxi (|cff%s%s|r)"] local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return format(text, '00FF00', L["On Taxi"]) elseif value == 1 then return format(text, 'FF0000', L["Not On Taxi"]) else return format(text, 'FFFF00', L["Ignore Taxi"]) end end,
		order = 5,
		tristate = true,
		get = function(info) local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = (value and 2) or (value == nil and 1) or 0 ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end,
	},
	isDragonRiding = {
		name = L["Is Dragonriding"],
		order = 5,
		hidden = function() return not E.Retail end,
	},
	isPossessed = {
		name = L["You Possess Target"],
		order = 5,
	},
	mouseover = {
		name = L["Mouseover"],
		order = 5,
	},
	notMaxHealth = {
		name = L["Not Max Health"],
		order = 5,
	},
	playerCasting = {
		name = L["Player Casting"],
		order = 5,
	},
}

local function CreateBarOptions(barNumber)
	local options = ACH:Group(format(L["Bar %s"], barNumber), nil, barNumber, 'tab', function(info) return E.db.abb[info[#info-1]][info[#info]] end, function(info, value) E.db.abb[info[#info-1]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-1]) end)
	options.args.displayTriggers = ACH:Group(L["Override Display Triggers"], nil, 99, nil, function(info) return E.db.abb[info[#info-2]][info[#info-1]][info[#info]] end, function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end, function(info) return not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers end)
	options.args.displayTriggers.inline = true
	options.args.inheritGlobalFade = ACH:Toggle(L["Inherit Global Fade"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.abb[info[#info-1]][info[#info]] = value ABB:ToggleFade(info[#info-1]) AB:PositionAndSizeBar(info[#info-1]) ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-1]) end)
	options.args.spacer1 = ACH:Spacer(4, 'full')
	options.args.customTriggers = ACH:Toggle(L["Custom Triggers"], L["This will override the options found in the Global tab with the options found in the Override Display Triggers section below."], 5, nil, nil, nil, nil, nil, function(info) return E.db.abb[info[#info-1]].inheritGlobalFade and false or not E.db.abb[info[#info-1]].inheritGlobalFade end)
	for option, info in next, globalFadeOptions do
		options.args.displayTriggers.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
	end

	return options
end

local function configTable()
    --* Repooc Reforged Plugin section
    local rrp = E.Options.args.rrp
    if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

	--* Plugin Section
	local ActionBarBuddy = ACH:Group('|cff00FF98ActionBar|r |cffA330C9Buddy|r', nil, 6, 'tab', nil, nil, function() return not AB.Initialized end)
	rrp.args.abb = ActionBarBuddy
	ActionBarBuddy.args.version = ACH:Header(format('|cff99ff33%s|r', ABB.Version), 1)

	local Global = ACH:Group(L["Global"], nil, 1, 'tree', nil, nil)
	ActionBarBuddy.args.global = Global

	Global.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function(info) return E.db.abb.global[info[#info]] end, function(info, value) E.db.abb.global[info[#info]] = value for barName in pairs(AB.handledBars) do ABB.fadeParentTable[barName]:SetAlpha(1-value) end end)
	Global.args.spacer = ACH:Spacer(97, 'full')
	Global.args.desc = ACH:Description(L["The Display Triggers that are enabled by default are the triggers that ElvUI uses by default and should behave as you would expect the Inherit Global Fade option to work in ElvUI itself.  You can add or remove the triggers that you want to effect the bars visibility."], 98, 'medium')

	Global.args.displayTriggers = ACH:Group(L["Override Display Triggers"], nil, 99, nil, function(info)
		return E.db.abb[info[#info-2]][info[#info-1]][info[#info]]
	end,
	function(info, value)
		E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = value
		for barName in pairs(AB.handledBars) do
			AB:PositionAndSizeBar(barName)
			ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName)
		end

		end)
	Global.args.displayTriggers.inline = true
	for option, info in next, globalFadeOptions do
		Global.args.displayTriggers.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
	end

	ActionBarBuddy.args.barSettings = ACH:Group(L["Bar Settings"], nil, 10, 'tree', nil, nil, nil)

	for i = 1, 10 do
		ActionBarBuddy.args.barSettings.args['bar'..i] = CreateBarOptions(i)
		-- E.Options.args.actionbar.args.playerBars.args['bar'..i].args.generalOptions.values['inheritGlobalFade'] = nil
	end

	for i = 13, 15 do
		ActionBarBuddy.args.barSettings.args['bar'..i] = CreateBarOptions(i)
		-- E.Options.args.actionbar.args.playerBars.args['bar'..i].args.generalOptions.values['inheritGlobalFade'] = nil
	end

	local bar = E.Options.args.actionbar.args.playerBars.args.bar1
	bar.args.abbuddy = ACH:Group(L["|cff00FF98ActionBar|r |cffA330C9Buddy|r"], nil, 3, nil, nil, nil, nil, not E.Retail)
	bar.args.abbuddy.guiInline = true
	bar.args.abbuddy.args.removeDragonOverride = ACH:Toggle(L["Remove Dragon Override"], nil, 1, nil, nil, nil, function(info) return E.db.abb[info[#info]] end, function(info, value) E.db.abb[info[#info]] = value ABB:UpdateDragonRiding() end)

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
