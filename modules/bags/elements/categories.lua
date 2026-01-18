local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")


--===============================================
-- CATEGORY POOL FUNCTIONS
--===============================================
mod.category_pool_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent, BackdropTemplateMixin and "BackdropTemplate")

	-- frame:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.get_border()})
	-- frame:SetBackdropColor(1, 1, 0, 0.4)
	-- frame:SetBackdropBorderColor(0, 0, 0, 0.8)

	-- Mixin(frame, category_methods)

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(bdUI:get_font(13))
	text:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -2, 4)
	text:SetAlpha(0.7)
	frame.text = text

	return frame
end

mod.category_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:Hide()
end
