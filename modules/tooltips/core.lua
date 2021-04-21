local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local function kill_texture(tex)
	if (not tex) then return end
	-- tex:Hide()
	-- tex = nil
	tex:SetTexture(nil)
	tex:Hide()
	tex:SetAlpha(0)
	tex.Show = noop
end

-- hook functions and skin
local function hook_and_skin(self)
	-- if (self._skinned) then return end
	-- print()

	bdUI:set_backdrop(self)

	kill_texture(self.Center)
	kill_texture(self.TopEdge)
	kill_texture(self.LeftEdge)
	kill_texture(self.RightEdge)
	kill_texture(self.BottomEdge)
	kill_texture(self.TopLeftCorner)
	kill_texture(self.TopRightCorner)
	kill_texture(self.BottomLeftCorner)
	kill_texture(self.BottomRightCorner)

	local ignore = {}
	ignore[self._background] = true
	ignore[self._border] = true
	ignore[self.l] = true
	ignore[self.r] = true
	ignore[self.t] = true
	ignore[self.b] = true

	for k, v in pairs({self:GetRegions()}) do
		if v:GetObjectType() == "Texture" then
			-- print(v)
			if (not ignore[v]) then
				kill_texture(v)
			end
		end
	end

	for i = 1, 10 do
		_G['GameTooltipTexture'..i]:Hide()
	end

	-- self._skinned = true
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
	mod.tooltipanchor:SetPoint("LEFT", bdParent, "CENTER", 474, -116)
	bdMove:set_moveable(mod.tooltipanchor, "Tooltips")

	--============================
	-- anchor the tooltip
	--============================
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		local config = mod.config
	
		if (config.anchor == "Frame") then
			self:SetOwner(parent, "ANCHOR_NONE")
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", mod.tooltipanchor, "TOPLEFT", -34, 16)
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
	GameTooltip:HookScript('OnTooltipSetUnit', update_unit_tooltip)
	-- mod:RegisterEvent("PLAYER_LOGIN")
	-- mod:SetScript("OnEvent", function()
	-- 	if (LibDBIconTooltip) then
	-- 		LibDBIconTooltip:SetScript('OnShow', hook_and_skin)
	-- 	end
	-- end)

end


