local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

local ftimer = CreateFrame("frame", "Fight Timer", UIParent)
ftimer:SetSize(250, 30)

ftimer.text = ftimer:CreateFontString(nil, "OVERLAY")
ftimer.text:SetFontObject(bdUI:get_font(11))
ftimer.text:SetPoint("LEFT")

function mod:create_fighttimer()
	local config = mod:get_save()

	if (config.enable_ft) then

	else

	end
end