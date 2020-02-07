local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")

local function skin_wa_frame(frame)
	if frame.icon then
		frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.icon.SetTexCoord = function() return end
		if frame.border and not frame.bar then
			frame.border:Hide()
		end
		
	end

	bdUI:set_backdrop(frame)

	if frame.stacks then
		local fontHeight = select(3, frame.stacks:GetFont())
		if (not tonumber(fontHeight) or not fontHeight >0) then fontHeight = 14 end
		frame.stacks:SetFont(bdUI.media.font, fontHeight, "OUTLINE")
	end

	if frame.timer then
		local fontHeight = select(3, frame.timer:GetFont())
		if (not tonumber(fontHeight) or not fontHeight >0) then fontHeight = 14 end
		frame.timer:SetFont(bdUI.media.font, fontHeight, "OUTLINE")
	end

	if frame.text then
		local fontHeight = select(3, frame.text:GetFont())
		if (not tonumber(fontHeight) or not fontHeight >0) then fontHeight = 18 end
		frame.text:SetFont(bdUI.media.font, fontHeight, "OUTLINE")
	end
	if frame.cooldown then
		local fontHeight = select(3, frame.cooldown:GetRegions():GetFont())
		if (not tonumber(fontHeight) or not fontHeight >0) then fontHeight = 14 end
		frame.cooldown:GetRegions():SetFont(bdUI.media.font, fontHeight, "OUTLINE")
	end
end

-- run on wa events
local wa_skin = CreateFrame("Frame")
wa_skin:RegisterEvent("ADDON_LOADED")
wa_skin:SetScript("OnEvent", function(self, event,addon)
	if (event == "ADDON_LOADED" and not addon == "WeakAuras") then return end

	mod:skin_weak_auras()
end)

function mod:skin_weak_auras()
	local config = bdUI:get_module("General"):get_save()

	if (WeakAurasFrame) then
		if (not config.skin_was) then return end
		for weakAura, v in pairs(WeakAuras.regions) do
			if (WeakAuras.regions[weakAura].regionType == "icon" or WeakAuras.regions[weakAura].regionType == "aurabar") then
				skin_wa_frame(WeakAuras.regions[weakAura].region)
			end
		end
	end
end