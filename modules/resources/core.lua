local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Resources & Power")
local config
local oUF = bdUI.oUF

-- Primary Display
local function create_primary(self, unit)
	self:SetParent(mod.Resources)
	self:SetSize(config.resources_width, config.resources_primary_height)
	self:EnableMouse(false)
	self:Hide()
	bdUI:set_backdrop(self)

	if (class == "SHAMAN") then

	elseif (class == "DEATHKNIGHT") then

	elseif (class == "MONK") then

	else

	end
end

-- Secondary Display
local function create_secondary(self, unit)
	self:SetParent(mod.Resources)
	self:SetSize(config.resources_width, config.resources_secondary_height)
	self:EnableMouse(false)
	self:Hide()
	bdUI:set_backdrop(self)

	if (class == "DEATHKNIGHT") then

	elseif (class == "MONK") then
	
	end
end

-- Start the addon
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	-- main holder frame
	mod.Resources = CreateFrame("frame", "bdResources", UIParent)
	mod.Resources:SetPoint("CENTER", bdParent, "CENTER", 0, -180)
	mod.Resources:EnableMouse(false)
	bdMove:set_moveable(mod.Resources, "Player Resources")

	-- create some of these bars as oUF players
	oUF:RegisterStyle("bdPrimaryResource", create_primary)
	oUF:RegisterStyle("bdSecondaryResource", create_secondary)

	-- mana/rage/energy
	mod.Resources.power = mod:create_power()

	-- combo points, holy power
	oUF:SetActiveStyle("bdPrimaryResource")
	mod.Resources.primary = oUF:Spawn("player", "bdPrimaryResource")

	-- extra stuff like stagger / necro bar
	oUF:SetActiveStyle("bdSecondaryResource")
	mod.Resources.secondary = oUF:Spawn("player", "bdSecondaryResource")

	-- position / size
	mod:config_callback()
end

-- on load AND on change
function mod:config_callback()
	config = mod.config

	if (config.resources_enable) then
		mod.Resources:Show()
	else
		mod.Resources:Hide()
		return
	end

	-- position them in a stack
	bdUI:frame_group(mod.Resources, "downwards", self.Resources.power)--, mod.Resources.swing, mod.Resources.primary, mod.Resources.secondary)
end