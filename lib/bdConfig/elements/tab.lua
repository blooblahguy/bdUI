local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["add"] = function(self, frame)
		table.insert(self.children, frame)
		return frame
	end,
	["update"] = function(self, options, save)
		if (not self.active) then return 0 end

		local height = self:calculate_height() or 0
		self:SetHeight(height)

		return height
	end,
	["calculate_height"] = function(self)
		local height = lib.dimensions.padding

		if (not self.children) then return end -- not a layout child
		local children = self.children

		for row, element in pairs(children) do
			if (element._isrow) then
				height = height + element:GetHeight() + lib.dimensions.padding
			end
			if (element._type == "group") then
				height = height + element:calculate_height() + lib.dimensions.padding
			end
		end

		return height
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	local padding = lib.dimensions.padding
	local yspace = padding

	-- tab container (if needed)
	if (not parent.tabContainer) then
		local tabContainer = lib:create_container(options, parent)
		table.insert(parent.children, tabContainer)
		tabContainer:SetHeight(lib.dimensions.header + 8)
		tabContainer:SetBackdrop({bgFile = lib.media.flat})
		tabContainer:SetBackdropColor(0.06, 0.07, 0.09)

		parent.tabContainer = tabContainer
		parent.tabs = {}
		-- tabContainer.border = tabContainer:CreateTexture(nil, "OVERLAY")
		-- tabContainer.border:SetTexture(lib.media.flat)
		-- tabContainer.border:SetVertexColor(1, 1, 1, 0.2)
		-- tabContainer.border:SetHeight(lib.border)
		-- tabContainer.border:SetPoint("BOTTOMLEFT", tabContainer, "BOTTOMLEFT", 0, 0)
		-- tabContainer.border:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", 0, 0)
	end

	-- create tab page
	local page = lib:create_container(options, parent)
	-- local border = lib:get_border(page)
	page:SetSize(parent.tabContainer:GetWidth(), 30)
	page:SetPoint("TOPLEFT", parent.tabContainer, "BOTTOMLEFT", 0, -lib.media.padding)
	page.children = {}
	-- -- page:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = border})
	-- -- page:SetBackdropColor(0, 0, 0, 0.08)
	-- -- page:SetBackdropBorderColor(0, 0, 0, 0.15)
	Mixin(page, methods)

	-- -- create tab to link to this page
	local index = #parent.tabs + 1
	local tab = lib.elements['button']({solo = true}, parent.tabContainer)
	local text = ((options.value or options.label):gsub("^%l", string.upper))

	tab.inactiveColor = {1, 1, 1, 0}
	tab.hoverColor = {1, 1, 1, 0}
	tab.activeColor = {1, 1, 1, 0}
	tab:OnLeave()
	tab:SetText(text)
	tab:SetHeight(parent.tabContainer:GetHeight() - 3)
	tab.page = page
	tab.page:Hide()
	tab.border = tab:CreateTexture(nil, "OVERLAY")
	tab.border:SetTexture(lib.media.flat)
	tab.border:SetVertexColor(unpack(lib.media.blue))
	tab.border:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT")
	tab.border:SetPoint("TOPRIGHT", tab, "BOTTOMRIGHT", 0, 3)
	tab.border:Hide()
	parent.tabs[index] = tab
	tab.text:SetFontObject("bdConfig_font")

	-- show page on select
	function tab:select()
		tab.page:Show()
		tab.border:Show()
		tab.text:SetFontObject("bdConfig_font_bold")
		tab.active = true
		tab.page.active = true

		tab.page:update()
		options.module:update_scroll()

		tab:OnLeave()
		parent.activePage = page
	end

	-- hide page on tab unselect
	function tab:unselect()
		tab.text:SetFontObject("bdConfig_font")
		tab.page:Hide()
		tab.border:Hide()
		tab.active = false
		tab.page.active = false
		tab:OnLeave()

		parent.activePage = false
	end

	-- unselect / hide other tabs
	tab:SetScript("OnClick", function()
		if (tab.active) then return end
		for i, t in pairs(parent.tabs) do
			t:unselect()
		end
		tab:select()
	end)

	-- position
	if (index == 1) then
		tab:SetPoint("LEFT", parent.tabContainer, "LEFT", 2, 0)
		tab:select()
	else
		tab:SetPoint("LEFT", parent.tabs[index - 1], "RIGHT", 1, 0)
	end
	
	return page
end

lib:register_container("tab", create)