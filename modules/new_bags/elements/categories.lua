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

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
mod.category_pool_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent)

	local dragger = CreateFrame("ItemButton", nil, frame, "ContainerFrameItemButtonTemplate")
	dragger:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -6)
	dragger:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -26)

	bdUI:set_backdrop(dragger)
	Mixin(dragger, dragger_methods)

	-- accept items for filtering
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

	frame.dragger = dragger

	frame.container = CreateFrame("frame", nil, frame)
	frame.container:SetPoint("TOPLEFT", dragger, "BOTTOMLEFT", 10, -8)
	frame.container:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFont(bdUI.media.font, 13, "OUTLINE")
	frame.text:SetPoint("LEFT", dragger, "LEFT", 8, -1)
	frame.text:SetAlpha(0.7)

	function frame.update_size(width, height)
		frame:SetSize(width + 20, height + frame.dragger:GetHeight() + 20)
	end

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