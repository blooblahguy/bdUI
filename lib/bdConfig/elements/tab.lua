local addonName, ns = ...
local mod = ns.bdConfig

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
		local height = mod.dimensions.padding

		if (not self.children) then return end -- not a layout child
		local children = self.children

		for row, element in pairs(children) do
			if (element._isrow) then
				-- print(element._type, element:GetHeight())
				height = height + element:GetHeight() + mod.dimensions.padding
			end
			if (element._type == "group") then
				height = height + element:calculate_height() + mod.dimensions.padding
			end
		end

		return height
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	local padding = mod.dimensions.padding
	local yspace = padding

	-- tab container (if needed)
	if (not parent.tabContainer) then
		local tabContainer = mod:create_container(options, parent)
		table.insert(parent.children, tabContainer)
		tabContainer:SetHeight(mod.dimensions.header)
		parent.tabContainer = tabContainer
		parent.tabs = {}

		options._module.tab_containers = options._module.tab_containers or 1
		options._module.tab_containers = options._module.tab_containers + 1
	end

	-- create tab page
	local page = mod:create_container(options, parent)
	local border = mod:get_border(page)
	page:SetSize(parent.tabContainer:GetWidth(), 30)
	page:SetPoint("TOPLEFT", parent.tabContainer, "BOTTOMLEFT", 0, 0)
	page.children = {}
	page:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = border})
	page:SetBackdropColor(0, 0, 0, 0.08)
	page:SetBackdropBorderColor(0, 0, 0, 0.15)
	Mixin(page, methods)

	-- create tab to link to this page
	local index = #parent.tabs + 1
	local tab = mod.elements['button']({}, parent.tabContainer)

	tab.inactiveColor = {1,1,1,0.05}
	tab.hoverColor = {1,1,1,0.1}
	tab:OnLeave()
	tab:SetText(options.value or options.label)
	tab.page = page
	tab.page:Hide()
	parent.tabs[index] = tab

	-- show page on select
	function tab:select()
		tab.page:Show()
		tab.active = true
		tab.page.active = true

		tab.page:update()
		options._module:update_scroll()

		tab:OnLeave()
		parent.activePage = page
	end

	-- hide page on tab unselect
	function tab:unselect()
		tab.page:Hide()
		tab.active = false
		tab.page.active = false
		tab:OnLeave()

		parent.activePage = false
	end

	-- unselect / hide other tabs
	tab.OnClick = function()
		for i, t in pairs(parent.tabs) do
			t:unselect()
		end
		tab:select()
	end

	-- position
	if (index == 1) then
		tab:SetPoint("LEFT", parent.tabContainer, "LEFT", 2, 0)
		tab:select()
	else
		tab:SetPoint("LEFT", parent.tabs[index - 1], "RIGHT", 1, 0)
	end
	
	return page
end

mod:register_container("tab", create)