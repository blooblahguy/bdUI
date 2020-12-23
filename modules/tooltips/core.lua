local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

-- add dynamic tooltip information
local function dynamic_tooltip_information(self, unit)
	-- who's targeting whom?
	if (unit and UnitExists(unit..'target')) then
		local r, g, b = mod:getReactionColor(unit..'target')
		GameTooltip:AddDoubleLine("Target", UnitName(unit..'target'), .7, .7, .7, r, g, b)
	end


end

-- Update healthbars
local function update_healthbars(self, unit)
	if (self._healthbars) then return end

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, bdUI.border)
	GameTooltipStatusBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 6)
	GameTooltipStatusBar:SetStatusBarTexture(bdUI.media.smooth)
	GameTooltipStatusBar:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	GameTooltipStatusBar:RegisterEvent("UNIT_HEALTH")
	GameTooltipStatusBar:SetScript("OnEvent", function(self)
		if (not UnitExists("mouseover")) then return end
		
		local hp, hpmax = UnitHealth("mouseover"), UnitHealthMax("mouseover")
		self:SetMinMaxValues(0, hpmax)
		self:SetValue(hp)
		if (UnitIsPlayer("mouseover")) then
			self:SetStatusBarColor( mod:getUnitColor() )
		else
			self:SetStatusBarColor( GameTooltipTextLeft1:GetTextColor() )
		end

		local perc = 0
		if (hp > 0 and hpmax > 0) then
			perc = math.floor((hp / hpmax) * 100)
		end
		if (not hpmax) then
			perc = ''
		end
		self.text:SetText(perc)
	end)

	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil)
	GameTooltipStatusBar.text:SetFont(bdUI.media.font, 11, "THINOUTLINE")
	GameTooltipStatusBar.text:SetAllPoints()
	GameTooltipStatusBar.text:SetJustifyH("CENTER")
	GameTooltipStatusBar.text:SetJustifyV("MIDDLE")
	bdUI:set_backdrop(GameTooltipStatusBar)

	self._healthbars = true
end

-- extra information, like being targeted or holding shift to see spec info
local function extra_tooltip_info(self, unit)
	if (IsShiftKeyDown()) then
		mod:getAverageItemLevel(self, self.unit)
	end
	if (self._extra) then return end

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:HookScript("OnEvent", function(self, event, arg1, arg2)
		if (not UnitIsPlayer("mouseover")) then return end

		if (IsShiftKeyDown()) then
			mod:getAverageItemLevel(self, "mouseover")
		else
			if (self.ilvl) then
				_G["GameTooltipTextLeft"..self.ilvl]:SetText("")
				_G["GameTooltipTextLeft"..self.ilvl]:Hide()
				_G["GameTooltipTextRight"..self.ilvl]:SetText("")
				_G["GameTooltipTextRight"..self.ilvl]:Hide()

				_G["GameTooltipTextLeft"..self.spec]:SetText("")
				_G["GameTooltipTextLeft"..self.spec]:Hide()
				_G["GameTooltipTextRight"..self.spec]:SetText("")
				_G["GameTooltipTextRight"..self.spec]:Hide()

				self:Show()
			end
		end
	end)

	self._extra = true
end

-- replace tooltip lines with cleaned up information
local function replace_tooltip_lines(self, unit)
	if (not unit) then return end
	
	-- name info
	local _, realm = UnitName(unit)
	local name = ""
	if (mod.config.enabletitlesintt) then
		name = UnitPVPName(unit) or UnitName(unit)
	else
		name = UnitName(unit)
	end
	local dnd = UnitIsAFK(unit) and " |cffAAAAAA<AFK>|r " or UnitIsDND(unit) and " |cffAAAAAA<DND>|r " or ""
	self.namecolor = {mod:getUnitColor(unit)}
	self.namehex = RGBPercToHex(unpack(self.namecolor))
	name = mod.config.showrealm and realm and "|CFF"..self.namehex..name.."-"..realm.."|r" or "|CFF"..self.namehex..name.."|r"

	-- unit info
	local guild, rank = GetGuildInfo(unit)
	local race = UnitRace(unit) or ""
	local creatureType = UnitCreatureType(unit)
	local factionGroup = select(1, UnitFactionGroup(unit))
	local replacedClass = false

	-- Color level by difficulty
	local level = UnitLevel(unit)
	self.levelColor = GetQuestDifficultyColor(level)
	if level == -1 then
		level = '??'
		self.levelColor = {r = 1, g = 0, b = 0}
	end

	-- Friend / Enemy coloring
	local isFriend = UnitIsFriend("player", unit)
	local friendColor = (factionGroup == "Horde" or not isFriend) and {r = 1, g = 0.15, b = 0} or {r = 0, g = 0.55, b = 1}

	-- delete lines in the "hide" table
	local hide = {}
	hide["Horde"] = true
	hide["Alliance"] = true
	hide["PvE"] = true
	hide["PvP"] = true
	for k, v in pairs(hide) do
		GameTooltip:DeleteLine(k, true)
	end

	-- Set Name

	if UnitIsPlayer(unit) then
		GameTooltipTextLeft1:SetFormattedText('%s%s', name, dnd)
		if (IsShiftKeyDown()) then
			mod:getAverageItemLevel(self, self.unit)
		end
		-- update guild and level
		if (guild) then
			GameTooltipTextLeft2:SetFormattedText('%s <%s>', rank, guild)
			GameTooltipTextLeft3:SetFormattedText('|cff%s%s|r |cff%s%s|r', RGBPercToHex(self.levelColor), level, RGBPercToHex(friendColor), race)
		else
			GameTooltipTextLeft2:SetFormattedText('|cff%s%s|r |cff%s%s|r', RGBPercToHex(self.levelColor), level, RGBPercToHex(friendColor), race)
		end
	else
		-- get in here to update level and creature 
		local minwidth = 0
		for i = 2, self:NumLines() do
			local line = _G['GameTooltipTextLeft'..i]
			local text = line:GetText();
			if (not line or not line:GetText()) then break end
			minwidth = math.max(minwidth, strlen(text) * 6.7)

			if (not replacedClass and (level and line:GetText():find('Level '..level) or (creatureType and line:GetText():find('^'..creatureType)))) then
				replacedClass = true
				line:SetFormattedText('|cff%s%s|r |cff%s%s|r', RGBPercToHex(self.levelColor), level, RGBPercToHex(friendColor), creatureType or 'Unknown')
			end
		end

		minwidth = math.min(minwidth, 200)

		self:SetMinimumWidth(minwidth)
	end
end

local function kill_texture(tex)
	if (not tex) then return end
	tex:Hide()
	tex = nil
end

-- hook functions and skin
local function hook_and_skin(self)
	if (self._skinned) then return end

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

	self._skinned = true
end

--=========================================
-- Main tooltip hook
--=========================================
local function update_tootlip(self)
	if (self:IsForbidden()) then return end -- don't mess with forbidden frames, which sometimes randomly happens
	local name, unit = self:GetUnit()
	unit = not unit and GetMouseFocus() and GetMouseFocus():GetAttribute("unit") or unit

	self.unit = unit
	self.ilvl = nil
	self.spec = nil

	-- skin healthbars
	update_healthbars(self, unit)

	-- extra tooltip information
	extra_tooltip_info(self, unit)

	-- replace tooltip information
	replace_tooltip_lines(self, unit)

	-- dynamic tooltip functions
	dynamic_tooltip_information(self, unit)
end

local function tooltip_anchor(self, parent)
	local config = mod.config

	if (config.anchor == "Frame") then
		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", mod.tooltipanchor, "TOPLEFT", -34, 16)
	else
		self:ClearAllPoints()
		self:SetOwner(parent, "ANCHOR_CURSOR")
	end
end

function mod:create_tooltips()
	---------------------------------------------
	--	Modify default position
	---------------------------------------------
	mod.tooltipanchor = CreateFrame("frame", "bdTooltip", bdParent)
	mod.tooltipanchor:SetSize(150, 100)
	mod.tooltipanchor:SetPoint("LEFT", bdParent, "CENTER", 474, -116)
	bdMove:set_moveable(mod.tooltipanchor, "Tooltips")

	hooksecurefunc("GameTooltip_SetDefaultAnchor", tooltip_anchor)
	-- hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	-- 	self:SetOwner(parent, "ANCHOR_NONE")
	-- 	self:ClearAllPoints()
	-- 	self:SetPoint("TOPLEFT", tooltipanchor, "TOPLEFT", -34, 16)
	-- end)

	-- for skinning all the tooltips in the UI
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
		hook_and_skin(frame)
	end

	---------------------------------------------------------------------
	-- hook main styling functions
	---------------------------------------------------------------------
	GameTooltip:HookScript('OnTooltipSetUnit', update_tootlip)
	mod:RegisterEvent("PLAYER_LOGIN")
	mod:SetScript("OnEvent", function()
		if (LibDBIconTooltip) then
			LibDBIconTooltip:SetScript('OnShow', hook_and_skin)
		end
	end)
end


