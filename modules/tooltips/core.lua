local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")
local config

local function kill_texture(tex)
	if (not tex) then return end
	-- tex:Hide()
	-- tex = nil
	tex:SetTexture(nil)
	tex:Hide()
	tex:SetAlpha(0)
	tex.Show = noop
end

 local function texture_strip(frame)
 	local ignore = {}
	if (frame._background) then
		ignore[frame._background] = true
		ignore[frame._border] = true
		ignore[frame.l] = true
		ignore[frame.r] = true
		ignore[frame.t] = true
		ignore[frame.b] = true
		ignore[frame.b] = true
	end

 	-- ignore[GameTooltipStatusBar] = true
 	for k, v in pairs({frame:GetRegions()}) do
 		if v:GetObjectType() == "Texture" then
 			if (not ignore[v]) then
 				kill_texture(v)
 			end
 		end
 	end
end

-- hook functions and skin
local function hook_and_skin(self)
	-- if (self._skinned) then return end
	-- print()

	bdUI:set_backdrop(self)

	texture_strip(self)
	if (self.NineSlice) then
		texture_strip(self.NineSlice)
	end

	-- self._skinned = true
end

-- add equippables ilvl
local function add_ilvl(tooltip)
	if (not mod.config.show_ilvls or not mod.config.enablett) then return end
	if (not tooltip.GetItem) then return end -- dragonflight
	local item = tooltip:GetItem()
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(item)
	if (not itemLevel or itemEquipLoc == "") then return end
	tooltip:AddDoubleLine("Item Level", itemLevel, nil, nil, nil, 1, 1, 1)
	-- tooltip:AddLine("Item Level: "..itemLevel)
end

--=========================================
-- Main tooltip hook
--=========================================
local function update_unit_tooltip(self)
	if (self:IsForbidden() or self:IsProtected()) then return end -- don't mess with forbidden frames, which sometimes randomly happens

	local name, unit = self:GetUnit()
	unit = not unit and GetMouseFocus() and GetMouseFocus():GetAttribute("unit") or unit

	self.unit = unit
	self.ilvl = nil
	self.spec = nil

	if (not unit) then return end

	-- remove useless info
	local hide = {
		"Horde",
		"Alliance",
		"PvE",
		"PvP",
	}
	for k, v in pairs(hide) do
		GameTooltip:DeleteLine(v, true)
	end

	-- type specific tooltips
	if UnitIsPlayer(unit) then
		mod:player_tooltip(self, unit)
	else
		mod:npc_tooltip(self, unit)
	end

	-- update width
	-- get in here to update level and creature 
	local minwidth = 0
	for i = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft'..i]
		local text = line and line:GetText();
		if (not text) then break end

		minwidth = math.max(minwidth, strlen(text) * 6.65)
	end
	self:SetMinimumWidth(math.min(minwidth, 110))
end

function mod:create_tooltips()
	--============================
	--	Modify default position
	--============================
	mod.tooltipanchor = CreateFrame("frame", "bdTooltip", bdParent)
	mod.tooltipanchor:SetSize(150, 100)
	mod.tooltipanchor:SetPoint("RIGHT", bdParent, "RIGHT", 20, -116)
	bdMove:set_moveable(mod.tooltipanchor, "Tooltips")

	--============================
	-- anchor the tooltip
	--============================
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		local config = mod.config
	
		if (config.anchor == "Frame") then
			local position, vpos, hpos = bdUI:GetQuadrant(mod.tooltipanchor)

			local vspace = 8
			local hspace = -13
			-- local vspace = -17
			-- local hspace = 34
			if (vpos == "BOTTOM") then
				vspace = -vspace
			end
			if (hpos == "RIGHT") then
				hspace = -hspace
			end

			self:SetOwner(parent, "ANCHOR_NONE")
			self:ClearAllPoints()
			self:SetPoint(position, mod.tooltipanchor, position, hspace, vspace)
		else
			self:ClearAllPoints()
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	end)

	--============================
	-- for skinning all the tooltips in the UI
	--============================
	-- GameTooltip:HookScript('OnShow', hook_and_skin)
	local tooltips = {
		'GameTooltip',
		'ItemRefTooltip',
		'ItemRefShoppingTooltip1',
		'ItemRefShoppingTooltip2',
		'ShoppingTooltip1',
		'ShoppingTooltip2',
		'DropDownList1MenuBackdrop',
		'DropDownList2MenuBackdrop',
	}

	for i = 1, #tooltips do
		local frame = _G[tooltips[i]]
		-- frame:HookScript('OnShow', hook_and_skin)
		hook_and_skin(frame)
	end
	-- hooksecurefunc("GameTooltip_OnUpdate", hook_and_skin)

	--============================
	-- hook main styling functions
	--============================
	if (TooltipDataProcessor) then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, update_unit_tooltip);
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, add_ilvl);
	else
		GameTooltip:HookScript('OnTooltipSetUnit', update_unit_tooltip)
		GameTooltip:HookScript("OnTooltipSetItem", add_ilvl)
	end
	
	-- mod:RegisterEvent("PLAYER_LOGIN")
	-- mod:SetScript("OnEvent", function()
	-- 	if (LibDBIconTooltip) then
	-- 		LibDBIconTooltip:SetScript('OnShow', hook_and_skin)
	-- 	end
	-- end)

end




