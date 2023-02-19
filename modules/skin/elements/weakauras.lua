local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")

local function skin_wa_frame(frame)
	if frame.icon then
		frame.icon:SetTexCoord(.07, .93, .07, .93)
		frame.icon.SetTexCoord = noop
		if frame.border and not frame.bar then
			frame.border:Hide()
		end
	end

	bdUI:set_backdrop(frame)

	if frame.stacks then
		local font, fontHeight, outline = frame.stacks:GetFont()
		fontHeight = fontHeight > 0 and fontHeight or 14;
		-- print("stacks", fontHeight)
		frame.stacks:SetFontObject(bdUI:get_font(fontHeight))
	end
	
	if frame.timer then
		local font, fontHeight, outline = frame.timer:GetFont()
		fontHeight = fontHeight > 0 and fontHeight or 14;
		-- print("timer", fontHeight)
		frame.timer:SetFontObject(bdUI:get_font(fontHeight))
	end
	
	if frame.text then
		local font, fontHeight, outline = frame.text:GetFont()
		fontHeight = fontHeight > 0 and fontHeight or 18;
		-- print("text", fontHeight)
		frame.text:SetFontObject(bdUI:get_font(fontHeight))
	end
	if frame.cooldown then
		local font, fontHeight, outline = frame.cooldown:GetRegions():GetFont()
		fontHeight = fontHeight > 0 and fontHeight or 14;
		-- print("cooldown", fontHeight)
		frame.cooldown:GetRegions():SetFontObject(bdUI:get_font(fontHeight))
	end
end

-- run on wa events
local wa_skin = CreateFrame("Frame")
wa_skin:RegisterEvent("ADDON_LOADED")
wa_skin:SetScript("OnEvent", function(self, event,addon)
	if (event == "ADDON_LOADED" and not addon == "WeakAuras") then return end

	C_Timer.After(1, function()
		mod:skin_weak_auras()
	end)
end)

function mod:skin_weak_auras()
	if (not WeakAurasFrame) then return end

	local config = bdUI:get_module("General"):get_save()
	if (not config.skin_was) then return end

	for k, wa in pairs({WeakAurasFrame:GetChildren()}) do
		if (wa.icon) then
			-- skin_wa_frame(wa)
		end
	end
end