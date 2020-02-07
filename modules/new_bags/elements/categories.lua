local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

local dragger_methods = {
	['click'] = function(self, ...)
		print("clicked", ...)
	end,
	['receive_item'] = function(self, ...)
		print("received", ...)
	end
}

local category_methods = {
	['create_dragger'] = function(self)
		local dragger = CreateFrame("ItemButton", nil, self, "ContainerFrameItemButtonTemplate")
		dragger:ClearAllPoints()
		dragger:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -6)
		dragger:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -26)
		dragger:SetScript('OnReceiveDrag', function(self) self:click() end)
		dragger:SetScript('OnClick', function(self) self:click() end)
		dragger:RegisterEvent("ITEM_LOCK_CHANGED")
		dragger:SetScript("OnEvent", function(...)
			local type, id, info = GetCursorInfo()
			if (type == "item") then
				dragger:RegisterEvent("CURSOR_UPDATE")
				dragger:UnregisterEvent("ITEM_LOCK_CHANGED")
				dragger:Show()
			else
				dragger:UnregisterEvent("CURSOR_UPDATE")
				dragger:RegisterEvent("ITEM_LOCK_CHANGED")
				dragger:Hide()
			end
		end)

		bdUI:set_backdrop(dragger)
		Mixin(dragger, dragger_methods)

		self.dragger = dragger
	end,
	['create_text'] = function(self)
		local text = self:CreateFontString(nil, "OVERLAY")
		text:SetFont(bdUI.media.font, 13, "OUTLINE")
		text:SetPoint("LEFT", self.dragger, "LEFT", 8, -1)
		text:SetAlpha(0.7)

		self.text = text
	end,
	['create_container'] = function(self)
		local container = CreateFrame("frame", nil, self)
		container:SetPoint("TOPLEFT", self.dragger, "BOTTOMLEFT", 10, -8)
		container:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
		bdUI:set_backdrop(container)

		self.container = container
	end,
	['update_size'] = function(self, width, height)
		print(self.text:GetText(), width, height)
		self.container:SetSize(width, height)
		self:SetSize(width, height)
	end
}

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
mod.category_pool_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent)
	Mixin(frame, category_methods)

	frame:create_dragger()
	frame:create_container()
	frame:create_text()

	return frame
end
mod.category_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame.text:SetText("")
	frame:Hide()
end

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
function mod:delete_category(name)

end
function mod:create_category(name, custom_conditions, order)
	-- if (mod.categories[name]) then return end
	order = order or #mod.categories + 1
	mod.categories[name] = mod.categories[name] or {}
	local category = mod.categories[name]

	-- default condition fillers
	local conditions = {}
	conditions['type'] = {}
	conditions['subtype'] = {}
	conditions['ilvl'] = 0
	conditions['expacID'] = 0
	conditions['rarity'] = 0
	conditions['minlevel'] = 0
	conditions['itemids'] = {}
	for k, v in pairs(custom_conditions) do conditions[k] = v end

	category.conditions = conditions
	category.name = name
	category.order = order
end

function mod:category_add_filter()

end