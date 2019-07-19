local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {

}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	local padding = mod.dimensions.padding
	local width = parent:GetWidth()
	local height = parent:GetHeight()

	-- scrollframe
	local scrollParent = CreateFrame("ScrollFrame", nil, parent) 
	scrollParent:SetPoint("TOPLEFT", parent) 
	scrollParent:SetSize(width - padding, height)

	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollParent, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -18) 
	scrollbar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -18, 18) 
	scrollbar:SetMinMaxValues(1, 600)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)

	--content frame 
	local content = CreateFrame("Frame", nil, scrollParent) 
	content:SetPoint("TOPLEFT", parent, "TOPLEFT") 
	content:SetSize(scrollParent:GetWidth() - (padding * 2), scrollParent:GetHeight())
	scrollParent.content = content
	scrollParent:SetScrollChild(content)

	-- scripts
	scrollbar:SetScript("OnValueChanged", function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end)

	-- scroller
	local function scroll(self, delta)
		scrollbar:SetValue(scrollbar:GetValue() - (delta*30))
	end
	scrollbar:SetScript("OnMouseWheel", scroll)
	content:SetScript("OnMouseWheel", scroll)

	content.scrollParent = scrollParent
	content.scrollbar = scrollbar
	content.parent = parent

	return content
end

mod:register_element("scrollframe", create)