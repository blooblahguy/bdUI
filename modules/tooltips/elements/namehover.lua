local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")
local config = {}

function mod:create_mouseover_tooltips()
	config = mod.config
	if (not config.enablemott) then return end

	local motooltip = CreateFrame('frame',nil)
	motooltip:SetFrameStrata("TOOLTIP")
	motooltip.text = motooltip:CreateFontString(nil, "OVERLAY")
	motooltip.text:SetFont(bdUI.media.font, 11, "THINOUTLINE")

	-- Show unit name at mouse
	motooltip:SetScript("OnUpdate", function(self)
		if (not config.enablemott) then motooltip:Hide() return end

		if GetMouseFocus() and GetMouseFocus():IsForbidden() then self:Hide() return end
		if GetMouseFocus() and GetMouseFocus():GetName()~="WorldFrame" then self:Hide() return end
		if not UnitExists("mouseover") then self:Hide() return end
		local x, y = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		self.text:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y+15)
	end)
	motooltip:SetScript("OnEvent", function(self)
		if GetMouseFocus():GetName()~="WorldFrame" then return end
		local name = UnitName("mouseover")
		if not name then return end
		
		local AFK = UnitIsAFK("mouseover")
		local DND = UnitIsDND("mouseover")
		local prefix = ""
		
		if AFK then prefix = "<AFK> " end
		if DND then prefix = "<DND> " end
		
		self.text:SetTextColor(mod:getcolor())
		self.text:SetText(prefix..name)

		self:Show()
	end)
	motooltip:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

end