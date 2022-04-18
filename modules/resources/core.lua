local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Resources & Power")
local config

-- Primary Display
function mod:create_primary()
	local primary = CreateFrame("frame", "bdPrimaryResource", mod.Resources)
	primary:SetSize(config.resources_width, config.resources_primary_height)
	primary:EnableMouse(false)
	primary:Hide()
	bdUI:set_backdrop(primary)

	return primary
end

-- Secondary Display
function mod:create_primary()
	local secondary = CreateFrame("frame", "bdPrimaryResource", mod.Resources)
	secondary:SetSize(config.resources_width, config.resources_secondary_height)
	secondary:EnableMouse(false)
	secondary:Hide()
	bdUI:set_backdrop(secondary)

	return secondary
end

function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	mod.Resources = CreateFrame("frame", "bdResources", UIParent)
	mod.Resources:SetPoint("CENTER", bdParent, "CENTER", 0, -180)
	mod.Resources:EnableMouse(false)
	bdMove:set_moveable(mod.Resources, "Player Resources")

	-- mana/rage/energy
	mod.Resources.power = mod:create_power()

	-- combo points, holy power
	-- mod.Resources.primary = mod:create_power()

	-- 
	-- mod.Resources.secondary = mod:create_power()
	mod:config_callback()
end

function mod:config_callback()
	config = mod.config
	if (config.resources_enable) then
		mod.Resources:Show()
	else
		mod.Resources:Hide()
		return
	end
	bdUI:frame_group(mod.Resources, "downwards", self.Resources.power)--, mod.Resources.swing, mod.Resources.primary, mod.Resources.secondary)
end