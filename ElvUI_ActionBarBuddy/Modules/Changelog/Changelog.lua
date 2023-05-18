local E = unpack(ElvUI)
local ABB = E:GetModule('ElvUI_ActionBarBuddy')
local S = E:GetModule('Skins')

local module = E:NewModule('ABB-Changelog', 'AceEvent-3.0', 'AceTimer-3.0')
local format, gsub, find = string.format, string.gsub, string.find

local ChangelogTBL = {
	'v1.11 5/18/2023',
		'• Update to account for dragonriding and give an option to remove the trigger',
		'• Prevent some errors with hooking functions',
	' ',
	'v1.10 1/25/2023',
		'• toc bump',
	' ',
	'v1.09 12/12/2022',
		'• add ability to adjust the smoothness of fade out of the bars',
	' ',
	'v1.08 11/30/2022',
		'• disable new option added in previous version by default',
	' ',
	'v1.07 11/30/2022',
		'• add ability to make bar 1 not page to dragon riding (this will also not allow the keybinds from bar 1 to be used for the abilitie as well)',
	' ',
	'v1.06 11/1/2022',
		'• updates for DF changes in ElvUI',
	' ',
	'v1.05 9/31/2022',
		'• toc bump for retail 9.2.7',
	' ',
	'v1.04 9/31/2022',
		'• toc bump for wrath prepatch',
	' ',
	'v1.03 7/1/2022',
		'• updated some locales',
	' ',
	'v1.02 6/22/2022',
		'• add the ability to remove the mouseover trigger with inherit global fade',
	' ',
	'v1.01 4/16/2022',
		'• Move the options a bit',
	' ',
	'v1.00 4/16/2022',
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
	if E.Retail then
		frame:SetResizeBounds(350, 100)
	else
		frame:SetMinResize(350, 100)
	end
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

	local header = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
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

	local footer = CreateFrame('Frame', nil, frame)
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
	S:HandleScrollBar(_G.ABBChangelogScrollFrameScrollBar, nil, nil, 'Transparent')
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
