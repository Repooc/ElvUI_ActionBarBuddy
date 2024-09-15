local E = unpack(ElvUI)
local ABB = E:GetModule('ElvUI_ActionBarBuddy')
local S = E:GetModule('Skins')

local module = E:NewModule('ABB-Changelog', 'AceEvent-3.0', 'AceTimer-3.0')
local format, gsub, find = string.format, string.gsub, string.find

local ChangelogTBL = {
	'v|cff00fc002.0|r 9/15/2024',
		' ',
		'|cffFF3300WARNING:|r The addon has been overhauled. The settings were reset due to all the changes that have been done',
		' ',
		'• ActionBar Buddy no longers uses ElvUI\'s Inherit Global Fade option in the bar\'s section in the main ElvUI\'s settings. It now has it\'s own option in the Bar Settings section in ActionBar Buddy\'s settings.',
		'• ActionBar Buddy no longers uses ElvUI\'s Global Fade Transparency slider option in the General section ElvUI\'s ActionBars section to determine the value. It can be found in the Global section in ActionBar Buddy\'s settings.',
		' ',
		' ',
		'|cff00fc00NOTE:|r If you would like to get back to the same functionality before the rewrite, all you have to do is;|r',
		' ',
		'• Open ElvUI Options',
		'• Navigate to: Repooc Reforged Plugins -> ActionBar Buddy -> Bar Settings',
		'• Go to each bar and enable ActionBar Buddy\'s Inherit Global Fade option as ElvUI\'s is no longer used when you enable this one.',
		'• While you are doing the step above, ensure Custom Triggers is disabled. Doing so will ensure the triggers on the Global tab will control the bars visibility, just like it was before the rewrite.',
		'• After you have enabled Inherit Global Fade on the bars that had it before and made sure Custom Triggers are disabled, go to the Global tab and adjust the triggers and Global Fade Transparency slider.',
		'• Congratulation\'s, you now reproduced the same effects as before the rewrite! You should take some time with the Custom Triggers on some bars as it can yield some nice and clean looking UI!',
	' ',
	' ',
	' ',
	'v|cff00fc001.30|r - v|cff00fc001.34|r 9/11/2024',
		'• change the default for new option Hide as Passenger to false by default',
		'• fix more logic errors that were found',
		'• fix dragonriding option if mounted and reloaded while on the ground with option selected',
		'• add Hide as Passenger option which works in conjunction with In Vehicle option',
		'• fix an issue with previous release',
		'• add ability to trigger if you are on a taxi (aka flight path)',
	' ',
	'v|cff00fc001.00|r 4/16/2022',
		'• Initial Release',
		-- "• ''",
	-- ' ',
}

local URL_PATTERNS = {
	'^(%a[%w+.-]+://%S+)',
	'%f[%S](%a[%w+.-]+://%S+)',
	'^(www%.[-%w_%%]+%.(%a%a+))',
	'%f[%S](www%.[-%w_%%]+%.(%a%a+))',
	'(%S+@[%w_.-%%]+%.(%a%a+))',
}

local function formatURL(url)
	url = '|cff'..'149bfd'..'|Hurl:'..url..'|h['..url..']|h|r ';
	return url
end

local function ModifiedLine(string)
	local newString = string
	for _, v in pairs(URL_PATTERNS) do
		if find(string, v) then
			newString = gsub(string, v, formatURL('%1'))
		end
	end
	return newString
end

local changelogLines = {}
local function GetNumLines()
   local index = 1
   for i = 1, #ChangelogTBL do
		local line = ModifiedLine(ChangelogTBL[i])
		changelogLines[index] = line

		index = index + 1
   end
   return index - 1
end

function module:CountDown()
	module.time = module.time - 1

	if module.time == 0 then
		module:CancelAllTimers()
		ABBChangelog.close:Enable()
		ABBChangelog.close:SetText(CLOSE)
	else
		ABBChangelog.close:Disable()
		ABBChangelog.close:SetText(CLOSE..format(' (%s)', module.time))
	end
end

function module:CreateChangelog()
	local Size = 500
	local frame = CreateFrame('Frame', 'ABBChangelog', E.UIParent)
	tinsert(_G.UISpecialFrames, 'ABBChangelog')
	frame:SetTemplate('Transparent')
	frame:Size(Size, Size)
	frame:Point('CENTER', 0, 0)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true)
	frame:SetResizeBounds(350, 100)
	frame:SetScript('OnMouseDown', function(changelog, button)
		if button == 'LeftButton' and not changelog.isMoving then
			changelog:StartMoving()
			changelog.isMoving = true
		elseif button == 'RightButton' and not changelog.isSizing then
			changelog:StartSizing()
			changelog.isSizing = true
		end
	end)
	frame:SetScript('OnMouseUp', function(changelog, button)
		if button == 'LeftButton' and changelog.isMoving then
			changelog:StopMovingOrSizing()
			changelog.isMoving = false
		elseif button == 'RightButton' and changelog.isSizing then
			changelog:StopMovingOrSizing()
			changelog.isSizing = false
		end
	end)
	frame:SetScript('OnHide', function(changelog)
		if changelog.isMoving or changelog.isSizing then
			changelog:StopMovingOrSizing()
			changelog.isMoving = false
			changelog.isSizing = false
		end
	end)
	frame:SetFrameStrata('DIALOG')

	local header = CreateFrame('Frame', 'ABBChangeLogHeader', frame, 'BackdropTemplate')
	header:Point('TOPLEFT', frame, 0, 0)
	header:Point('TOPRIGHT', frame, 0, 0)
	header:Point('TOP')
	header:SetHeight(25)
	header:SetTemplate('Transparent')
	header.text = header:CreateFontString(nil, 'OVERLAY')
	header.text:FontTemplate(nil, 15, 'OUTLINE')
	header.text:SetHeight(header.text:GetStringHeight()+30)
	header.text:SetText(format('%s - Changelog |cff00c0fa%s|r', ABB.Title, ABB.Version))
	header.text:SetTextColor(1, 0.8, 0)
	header.text:Point('CENTER', header, 0, -1)

	local footer = CreateFrame('Frame', 'ABBChangeLogFooter', frame)
	footer:Point('BOTTOMLEFT', frame, 0, 0)
	footer:Point('BOTTOMRIGHT', frame, 0, 0)
	footer:Point('BOTTOM')
	footer:SetHeight(30)
	footer:SetTemplate('Transparent')

	local close = CreateFrame('Button', nil, footer, 'UIPanelButtonTemplate, BackdropTemplate')
	close:Point('CENTER')
	close:SetText(CLOSE)
	close:Size(80, 20)
	close:SetScript('OnClick', function()
		_G.ABBDB['Version'] = ABB.Version
		frame:Hide()
	end)
	S:HandleButton(close)
	close:Disable()
	frame.close = close

	local scrollArea = CreateFrame('ScrollFrame', 'ABBChangelogScrollFrame', frame, 'UIPanelScrollFrameTemplate')
	scrollArea:Point('TOPLEFT', header, 'BOTTOMLEFT', 8, -3)
	scrollArea:Point('BOTTOMRIGHT', footer, 'TOPRIGHT', -25, 3)

	local scrollBar = _G.ABBChangelogScrollFrameScrollBar
	S:HandleScrollBar(scrollBar, nil, nil, 'Transparent')
	ABBChangelogScrollFrameScrollBarScrollUpButton:SetTemplate('Transparent')
	ABBChangelogScrollFrameScrollBarScrollDownButton:SetTemplate('Transparent')
	scrollArea:HookScript('OnVerticalScroll', function(scroll, offset)
		_G.ABBChangelogFrameEditBox:SetHitRectInsets(0, 0, offset, (_G.ABBChangelogFrameEditBox:GetHeight() - offset - scroll:GetHeight()))
	end)

	local editBox = CreateFrame('EditBox', 'ABBChangelogFrameEditBox', frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject('ChatFontNormal')
	editBox:SetTextColor(1, 0.8, 0)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(scrollArea:GetHeight())
	-- editBox:SetScript('OnEscapePressed', function() _G.ABBChangelog:Hide() end)
	scrollArea:SetScrollChild(editBox)
end

function module:ToggleChangeLog()
	local lineCt = GetNumLines(frame)
	local text = table.concat(changelogLines, ' \n', 1, lineCt)
	_G.ABBChangelogFrameEditBox:SetText(text)

	PlaySound(888)

	local fadeInfo = {}
	fadeInfo.mode = 'IN'
	fadeInfo.timeToFade = 0.5
	fadeInfo.startAlpha = 0
	fadeInfo.endAlpha = 1
	ABBChangelog:Show()
	E:UIFrameFade(ABBChangelog, fadeInfo)

	module.time = 6
	module:CancelAllTimers()
	module:CountDown()
	module:ScheduleRepeatingTimer('CountDown', 1)
end

function module:CheckVersion()
	if not InCombatLockdown() then
		if not ABBDB['Version'] or (ABBDB['Version'] and ABBDB['Version'] ~= ABB.Version) then
			module:ToggleChangeLog()
		end
	else
		module:RegisterEvent('PLAYER_REGEN_ENABLED', function(event)
			module:CheckVersion()
			module:UnregisterEvent(event)
		end)
	end

end

function module:Initialize()
	if not ABBChangelog then
		module:CreateChangelog()
	end
	module:RegisterEvent('PLAYER_REGEN_DISABLED', function()
		if ABBChangelog and not ABBChangelog:IsVisible() then return end
		module:RegisterEvent('PLAYER_REGEN_ENABLED', function(event) ABBChangelog:Show() module:UnregisterEvent(event) end)
		ABBChangelog:Hide()
	end)
	E:Delay(6, function() module:CheckVersion() end)
end

E:RegisterModule(module:GetName())
