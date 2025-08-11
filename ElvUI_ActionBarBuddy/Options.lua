local E, L, _, P = unpack(ElvUI)
local ABB = E:GetModule('ElvUI_ActionBarBuddy')
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
	':) vint',						-- Discord User
	'Niix',							-- Discord User
	'Trenchy',
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
		order = 50,
	},
	hasOverridebar = {
		name = L["Have Overridebar"],
		order = 50,
	},
	hasTarget = {
		name = L["Has Target"],
		order = 50,
	},
	hideAsPassenger = {
		name = L["Hide As Passenger"],
		order = 20,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inVehicle end,
		hidden = function() return E.Classic end,
		modifier = true,
	},
	inCombat = {
		name = function(info) local text = L["Combat (|cff%s%s|r)"] local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return format(text, '00FF00', L["In Combat"]) elseif value == 1 then return format(text, 'FF0000', L["Not In Combat"]) else return format(text, 'FFFF00', L["Ignore Combat"]) end end,
		order = 50,
		tristate = true,
		get = function(info) local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = (value and 2) or (value == nil and 1) or 0 if info[#info-2] == 'global' then for barName in pairs(AB.handledBars) do ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end else ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end end,
	},
	inVehicle = {
		name = L["In Vehicle"],
		order = 50,
		hidden = function() return E.Classic end,
	},
	inInstance = {						--* Modifier Parent
		name = L["Instance"],
		order = 50,
	},
	inDungeon = {						--* Modifier
		name = L["In Dungeon"],
		order = 40,
		modifier = true,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inInstance end,
	},
	inNone = {							--* Modifier
		name = L["None"],
		order = 40,
		modifier = true,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inInstance end,
	},
	inPvP = {							--* Modifier
		name = L["In PvP"],
		order = 40,
		modifier = true,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inInstance end,
	},
	inRaid = {							--* Modifier
		name = L["In Raid"],
		order = 40,
		modifier = true,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inInstance end,
	},
	inScenario = {						--* Modifier
		name = L["In Scenario"],
		order = 40,
		modifier = true,
		disabled = function(info) return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or not E.db.abb[info[#info-3]][info[#info-2]].inInstance end,
	},
	isPlayerSpellsFrameOpen = {							--* Modifier Parent
		name = L["Player Spells Opened"],
		order = 50,
		hidden = function() return not E.Retail end,
	},
	isSpellsBookOpen = {								--* Modifier
		name = L["Spellbook Open"],
		order = 30,
		modifier = E.Retail,
		disabled = function(info)
			if E.Retail then
				return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or E.Retail and not E.db.abb[info[#info-3]][info[#info-2]].isPlayerSpellsFrameOpen
			else
				return info[#info-2] ~= 'global' and (not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers)
			end
		end,
	},
	isSpecTabOpen = { --* Used in Retail so far			--* Modifier
		name = L["Spec Tab/Frame Open"],
		order = 30,
		modifier = E.Retail,
		disabled = function(info) --* Come back to this after cata/classic compatibility
			if E.Retail then
				return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or E.Retail and not E.db.abb[info[#info-3]][info[#info-2]].isPlayerSpellsFrameOpen
			else
				return info[#info-2] ~= 'global' and (not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers)
			end
		end,
		hidden = function() return not E.Retail end,
	},
	isTalentTabOpen = {									--* Modifier
		name = L["Talent Tab/Frame Open"],
		order = 30,
		modifier = E.Retail,
		disabled = function(info)
			if E.Retail then
				return info[#info-3] ~= 'global' and (not E.db.abb[info[#info-3]].inheritGlobalFade or not E.db.abb[info[#info-3]].customTriggers) or E.Retail and not E.db.abb[info[#info-3]][info[#info-2]].isPlayerSpellsFrameOpen
			else
				return info[#info-2] ~= 'global' and (not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers)
			end
		end,
	},
	onTaxi = {
		name = function(info) local text = L["Taxi (|cff%s%s|r)"] local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return format(text, '00FF00', L["On Taxi"]) elseif value == 1 then return format(text, 'FF0000', L["Not On Taxi"]) else return format(text, 'FFFF00', L["Ignore Taxi"]) end end,
		order = 50,
		tristate = true,
		get = function(info) local value = E.db.abb[info[#info-2]][info[#info-1]][info[#info]] if value == 2 then return true elseif value == 1 then return nil else return false end end,
		set = function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = (value and 2) or (value == nil and 1) or 0 if info[#info-2] == 'global' then for barName in pairs(AB.handledBars) do ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end else ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end end,
	},
	isDragonRiding = {
		name = L["Is Dragonriding"],
		order = 50,
		hidden = function() return not E.Retail end,
	},
	isPossessed = {
		name = L["You Possess Target"],
		order = 50,
	},
	isProfessionBookOpen = {
		name = L["Profession Book Open"],
		order = 50,
		hidden = function() return E.Classic end,
	},
	mouseover = {
		name = L["Mouseover"],
		order = 50,
	},
	notMaxHealth = {
		name = L["Not Max Health"],
		order = 50,
	},
	playerCasting = {
		name = L["Player Casting"],
		order = 50,
	},
}

local bars = { 'barPet', 'stanceBar' }
local ToggleTriggers = function(bar, overRide)
	if not bar then return end
	local db = E.db.abb[bar]
	local tbl = P.abb[bar]
	if not db or not tbl then return end
	db = db.displayTriggers
	tbl = tbl.displayTriggers

	for triggerKey, defaultValue in pairs(tbl) do
		local value
		if overRide == 'default' then
			value = defaultValue
		else
			value = (globalFadeOptions[triggerKey].tristate and (overRide and 2)) or (globalFadeOptions[triggerKey].tristate and 0) or overRide
		end

		db[triggerKey] = value
	end
	for barName in pairs(AB.handledBars) do ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end
	for _, barName in pairs(bars) do ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end
end

local function CreateBarOptions(barKey)
	if not barKey then return end
	local isPet = barKey == 'barPet'
	local isStance = barKey == 'stanceBar'
	local bar = (isPet or isStance) and barKey or 'bar'..barKey
	if not E.db.abb[bar] then return end

	local barName = isPet and L["Pet Bar"] or isStance and L["Stance Bar"] or format(L["Bar %s"], barKey)
	local barIndex = (isPet or isStance) and 20 or barKey

	local options = ACH:Group(barName, nil, barIndex, 'tab', function(info) return E.db.abb[info[#info-1]][info[#info]] end, function(info, value) E.db.abb[info[#info-1]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-1]) end)
	options.args.displayTriggers = ACH:Group(L["Override Display Triggers"], nil, 99, nil, function(info) return E.db.abb[info[#info-2]][info[#info-1]][info[#info]] end, function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end, function(info) return not E.db.abb[info[#info-2]].inheritGlobalFade or not E.db.abb[info[#info-2]].customTriggers end)
	options.args.displayTriggers.inline = true

	options.args.inheritGlobalFade = ACH:Toggle(L["Inherit Global Fade"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.abb[info[#info-1]][info[#info]] = value ABB:ToggleFade(info[#info-1]) if isPet then AB:PositionAndSizeBarPet() elseif isStance then AB:PositionAndSizeBarShapeShift() else AB:PositionAndSizeBar(info[#info-1]) end ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-1]) end)
	options.args.spacer1 = ACH:Spacer(2, 'full')

	--* Bar Alpha Section
	local BarAlpha = ACH:Group(L["Bar Alpha"], nil, 3, nil, function(info) return E.db.abb[info[#info-2]][info[#info]] end, function(info, value) E.db.abb[info[#info-2]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-2]) end)
	options.args.barAlpha = BarAlpha
	BarAlpha.inline = true
	BarAlpha.args.followBarAlpha = ACH:Toggle(L["Use Bar Alpha"], L["When a trigger would normally show the bar fully, this option will instead use the alpha setting that is configured in ElvUI for that bar."], 1, nil, nil, nil, nil, nil, function(info) return not E.db.abb[info[#info-2]].inheritGlobalFade end)
	BarAlpha.args.spacer1 = ACH:Spacer(2, 'full')
	BarAlpha.args.goToBar = ACH:Execute(format(L["%sElvUI|r %s Settings"], E.media.hexvaluecolor, barName), nil, 99, function() local playerBar = (not isPet and not isStance) if playerBar then E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'actionbar', 'playerBars', bar, 'barGroup') else E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'actionbar', bar, 'barGroup') end end)

	options.args.spacer2 = ACH:Spacer(4, 'full')

	--* Custom Triggers
	options.args.customTriggers = ACH:Toggle(L["Custom Triggers"], L["This will override the options found in the Global tab with the options found in the Override Display Triggers section below."], 5, nil, nil, nil, nil, nil, function(info) return not E.db.abb[info[#info-1]].inheritGlobalFade end)

	--* Modifiers
	options.args.displayTriggers.args['modifier'] = ACH:Group(L["Modifiers"], nil, 90, nil, function(info) return E.db.abb[info[#info-3]][info[#info-2]][info[#info]] end, function(info, value) E.db.abb[info[#info-3]][info[#info-2]][info[#info]] = value ABB:FadeParent_OnEvent('UPDATING_OPTIONS', info[#info-3]) end, nil, function() return E.Classic end)
	options.args.displayTriggers.args['modifier'].inline = true

	--* This populates the Custom Triggers and their Modifiers
	for option, info in next, globalFadeOptions do
		if not info.modifier then
			options.args.displayTriggers.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
		else
			options.args.displayTriggers.args.modifier.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
		end
	end
	options.args.displayTriggers.args.modifier.args.spacer1 = ACH:Spacer(25, 'full') --* Spacer between Hide As Passenger and Spell Book/Talent/Spect tabs (this is prob needed for retail only wip)
	options.args.displayTriggers.args.modifier.args.spacer2 = ACH:Spacer(35, 'full') --* Spacer between Spell Book/Talent/Spect tabs (this is prob needed for retail only wip) and In Dungeon/PvP/Raid/Scenario

	options.args.displayTriggers.args.spacer1 = ACH:Spacer(101, 'full')
	options.args.displayTriggers.args.selectDefaults = ACH:Execute(L["Select Defaults"], nil, 102, function(info) ToggleTriggers(info[#info-2], 'default') end)
	options.args.displayTriggers.args.selectAll = ACH:Execute(L["Select All"], nil, 103, function(info) ToggleTriggers(info[#info-2], true) end)
	options.args.displayTriggers.args.selectNone = ACH:Execute(L["Select None"], nil, 104, function(info) ToggleTriggers(info[#info-2], false) end)

	return options
end

local function configTable()
    --* Repooc Reforged Plugin section
    local rrp = E.Options.args.rrp
    if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

	--* Plugin Section
	local ActionBarBuddy = ACH:Group(gsub(ABB.Title, "^.-|r%s", ""), nil, 6, 'tab', nil, nil, function() return not AB.Initialized end)
	rrp.args.abb = ActionBarBuddy
	ActionBarBuddy.args.version = ACH:Header(format('|cff99ff33%s|r', ABB.versionString), 1)

	--! Global Tab
	local Global = ACH:Group(L["Global"], nil, 1, 'tree', nil, nil)
	ActionBarBuddy.args.global = Global

	Global.args.globalFadeAlpha = ACH:Range(L["Global Fade Transparency"], L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."], 3, { min = 0, max = 1, step = 0.01, isPercent = true }, nil, function(info) return E.db.abb.global[info[#info]] end, function(info, value) E.db.abb.global[info[#info]] = value for barName in pairs(AB.handledBars) do ABB.fadeParentTable[barName]:SetAlpha(1-value) end ABB.fadeParentTable.barPet:SetAlpha(1-value) end)
	Global.args.spacer1 = ACH:Spacer(10, 'full')
	Global.args.desc = ACH:Description(L["The options that are enabled by default, that can be found in the |cffFFD100Override Display Triggers|r section, are the triggers that ElvUI uses by default. As long as you enable |cffFFD100Inherit Global Fade|r for each bar in the |cffFFD100Bar Settings|r section, the bars should behave as they do with ElvUI's |cffFFD100Inherit Global Fade|r option."], 11, 'medium')

	Global.args.displayTriggers = ACH:Group(L["Override Display Triggers"], nil, 20, nil, function(info) return E.db.abb[info[#info-2]][info[#info-1]][info[#info]] end, function(info, value) E.db.abb[info[#info-2]][info[#info-1]][info[#info]] = value for barName in pairs(AB.handledBars) do AB:PositionAndSizeBar(barName) ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end end)
	Global.args.displayTriggers.inline = true

	Global.args.displayTriggers.args['modifier'] = ACH:Group(L["Modifiers"], nil, 90, nil, function(info) return E.db.abb[info[#info-3]][info[#info-2]][info[#info]] end, function(info, value) E.db.abb[info[#info-3]][info[#info-2]][info[#info]] = value for barName in pairs(AB.handledBars) do ABB:FadeParent_OnEvent('UPDATING_OPTIONS', barName) end end, nil, function() return E.Classic end)
	Global.args.displayTriggers.args['modifier'].inline = true

	for option, info in next, globalFadeOptions do
		if not info.modifier then
			Global.args.displayTriggers.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
		else
			Global.args.displayTriggers.args.modifier.args[option] = ACH:Toggle(info.name, nil, info.order, info.tristate, nil, nil, info.get, info.set, info.disabled, info.hidden)
		end
	end
	Global.args.displayTriggers.args.modifier.args.spacer1 = ACH:Spacer(25, 'full') --* Spacer between Hide As Passenger and Spell Book/Talent/Spect tabs (this is prob needed for retail only wip)
	Global.args.displayTriggers.args.modifier.args.spacer2 = ACH:Spacer(35, 'full') --* Spacer between Spell Book/Talent/Spect tabs (this is prob needed for retail only wip) and In Dungeon/PvP/Raid/Scenario

	Global.args.displayTriggers.args.spacer1 = ACH:Spacer(101, 'full')
	Global.args.displayTriggers.args.selectDefaults = ACH:Execute(L["Select Defaults"], nil, 102, function() ToggleTriggers('global', 'default') end)
	Global.args.displayTriggers.args.selectAll = ACH:Execute(L["Select All"], nil, 103, function() ToggleTriggers('global', true) end)
	Global.args.displayTriggers.args.selectNone = ACH:Execute(L["Select None"], nil, 104, function() ToggleTriggers('global', false) end)

	--! Bar Settings Tab
	ActionBarBuddy.args.barSettings = ACH:Group(L["Bar Settings"], nil, 10, 'tree', nil, nil, nil)
	for i = 1, 10 do ActionBarBuddy.args.barSettings.args['bar'..i] = CreateBarOptions(i) end
	for i = 13, 15 do ActionBarBuddy.args.barSettings.args['bar'..i] = CreateBarOptions(i) end
	for _, bar in pairs(bars) do ActionBarBuddy.args.barSettings.args[bar] = CreateBarOptions(bar) end

	--! Help Tab
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

	--! ElvUI Bar 1 Modification
	local bar = E.Options.args.actionbar.args.playerBars.args.bar1
	bar.args.abbuddy = ACH:Group(L["|cff00FF98ActionBar|r |cffA330C9Buddy|r"], nil, 3, nil, nil, nil, nil, not E.Retail)
	bar.args.abbuddy.guiInline = true
	bar.args.abbuddy.args.removeDragonOverride = ACH:Toggle(L["Remove Dragon Override"], nil, 1, nil, nil, nil, function(info) return E.db.abb[info[#info]] end, function(info, value) E.db.abb[info[#info]] = value ABB:UpdateDragonRiding() end)
end

tinsert(ABB.Configs, configTable)
