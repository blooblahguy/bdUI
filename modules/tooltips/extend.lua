local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

------------------------------------
-- Enhanced Gametooltip - credit to RantTooltip
------------------------------------
local wrapText = function(text)
	if text:len() >= 45 then
		for str in text:gmatch("..%s..") do
			local last = text:gsub("(.*\n)(.*)", "%2")
			local startPos = last:find(str)
			if startPos and startPos >= 45 then
				local newText = last:sub(1, startPos + 1) .. "\n" .. last:sub(startPos + 3, last:len())
				text = text:gsub(last, newText)
			end
		end
	end
	return text
end

-- last line
GameTooltip["LastLine"] = function(self)
	local lines = self:NumLines(true)

	for i = 10, 1, -1 do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line and line:GetText()
		if (text) then
			return line, i - 1
		end
	end
end


-- -- if there are blank lines in the middle, move everything up and put them at the end
GameTooltip["ArrangeLines"] = function(self)
	local lines = self:NumLines(true)
	local lastline = ""
	for i = lines, 1, -1 do
		local text = line and line:GetText()
		if (text == "") then
			line:SetText(lastline)
		end
		lastline = text
	end
end

GameTooltip["GetLine"] = function(self, num)
	if type(num) == "table" then
		num = num:GetName():gsub("GameTooltipTextLeft", "")
		num = tonumber(num)
		return num
	else
		return _G["GameTooltipTextLeft" .. num]
	end
end

--Find a line
GameTooltip["FindLine"] = function(self, msg, exact, from)
	if not msg then return end
	local lines = self:NumLines(true)
	for i = from or 1, lines do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line and line:GetText()
		if text and ((exact and text == msg) or (not exact and text:find(msg))) then
			return line, i
		end
	end
end

--Num Lines
local _NumLines = GameTooltip.NumLines
GameTooltip["NumLines"] = function(self, ignoreDeleted)
	if ignoreDeleted then
		local line, realLines, i = true, 0, 0
		while line do
			i = i + 1
			line = _G[self:GetName() .. "TextLeft" .. i]
			local text = line and line:GetText()
			if text and string.len(text) > 0 then
				realLines = realLines + 1
			else
				break
			end
		end
		return realLines
	end
	return _NumLines(self)
end

--Delete Line
GameTooltip["DeleteLine"] = function(self, line, exact)
	local numLines, originalNum, barNum = self:NumLines()
	local line2 = false
	if type(line) == "number" then
		line = _G["GameTooltipTextLeft" .. line]
		line2 = _G["GameTooltipTextRight" .. line]
	elseif type(line) == "string" then
		line = self:FindLine(line, exact)
	end
	if line then
		originalNum = self:GetLine(line)
		line2 = _G["GameTooltipTextRight" .. originalNum]
		-- print(originalNum)
		if line ~= _G["GameTooltipTextLeft" .. numLines] then
			local number = self:GetLine(line)
			local tbl = {}
			for i = number + 1, numLines do
				tbl[i - 1] = _G["GameTooltipTextLeft" .. i]
			end
			for k, v in pairs(tbl) do
				local text = v:GetText()
				local newLine = _G["GameTooltipTextLeft" .. k]
				if v:GetStringHeight() > select(2, v:GetFont()) then
					text = wrapText(text)
				end
				newLine.deleted = v.deleted
				newLine:SetText(text)
				newLine:SetTextColor(v:GetTextColor())
			end
			line = _G["GameTooltipTextLeft" .. numLines]
			if not line then return end
		end
		line.deleted = true
		line:SetText("")
		line:Hide()
		if (line2) then
			line2:SetText("")
			line2:Hide()
		end
		self:Show()
	end
end

GameTooltip["GetLines"] = function(self, num)
	if type(num) == "table" then
		num = num:GetName():gsub("GameTooltipTextLeft", "")
		num = tonumber(num)
		return num
	else
		return _G["GameTooltipTextLeft" .. num]
	end
end
