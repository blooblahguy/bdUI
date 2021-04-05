local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

GameTooltip["GetLines"] = function(self, num)
	if type(num) == "table" then
		num = num:GetName():gsub("GameTooltipTextLeft", "")
		num = tonumber(num)
		return num
	else
		return _G["GameTooltipTextLeft"..num]
	end
end

GameTooltip["GetLine"] = function(self, num)
	if type(num) == "table" then
		num = num:GetName():gsub("GameTooltipTextLeft", "")
		num = tonumber(num)
		return num
	else
		return _G["GameTooltipTextLeft"..num]
	end
end