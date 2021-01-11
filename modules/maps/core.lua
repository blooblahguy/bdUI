local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config



--=============================================
-- Initialize function
--=============================================
function mod:initialize()
	mod.config = mod:get_save()
	
	mod:create_objective_tracker()

	if (not mod.config.enabled) then return end

	mod:create_minimap()
	mod:create_button_frame()
	mod:worldmap_coords()

	mod:config_callback()
end

function mod:config_callback()
	config = mod.config

	-- resize elements
	Minimap:SetScale(config.scale)
	
	local border = bdUI.border --* (1 / config.scale)
	Minimap.background:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = border})
	Minimap.background:SetBackdropColor(0, 0, 0, 0)
	Minimap.background:SetBackdropBorderColor(unpack(bdUI.media.border))
	Minimap:SetSize(config.size, config.size)
	Minimap.qa:SetSize(config.size * config.scale, 50)

	-- Mask the minimap
	if (config.shape == "Rectangle") then
		Minimap:SetMaskTexture("Interface\\Addons\\bdUI\\media\\rectangle.tga")
		Minimap.background:SetScale(1 * (1 / config.scale))
		Minimap.background:SetSize(config.size * config.scale, (config.size * config.scale) *.75)
	else
		Minimap.background:SetScale(1 * (1 / config.scale))
		Minimap.background:SetSize(config.size * config.scale, config.size * config.scale)
		Minimap:SetMaskTexture(bdUI.media.flat)
	end
	
	-- scale elements back down
	TimeManagerClockButton:SetScale(1 / config.scale)
	MiniMapMailIcon:SetScale(1 / config.scale)
	MiniMapMailFrame:SetScale(1 / config.scale)
	Minimap.zone:SetScale(1 / config.scale)
	TicketStatusFrame:SetScale(1 / config.scale)
	Minimap.rd:SetScale(1 / config.scale)
	
	-- Minimap.buttonFrame:SetSize(Minimap:GetWidth() - (bdUI.border * 2), config.buttonsize)

	-- show/hide time
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn('Blizzard_TimeManager')
	end
	if (config.showtime) then
		TimeManagerClockButton:SetAlpha(1)
		TimeManagerClockButton:Show()
	else
		TimeManagerClockButton:SetAlpha(0)
		TimeManagerClockButton:Hide()
	end


	-- reposition button frame
	-- Button Frame positioning
	if (config.buttonpos == "Disable") then
		Minimap.buttonFrame:ClearAllPoints()
		Minimap.buttonFrame:Hide()
	else 
		Minimap.buttonFrame:ClearAllPoints()

		local space = bdUI.border * 2
		local size = config.buttonsize + space

		if (config.buttonpos == "Top") then
			Minimap.buttonFrame:SetPoint("BOTTOMLEFT", Minimap.background, "TOPLEFT", bdUI.border, space)
			-- Minimap.buttonFrame:SetPoint("TOPRIGHT", Minimap.background, "TOPRIGHT", -bdUI.border, size)
		elseif (config.buttonpos == "Right") then
			Minimap.buttonFrame:SetPoint("TOPLEFT", Minimap.background, "TOPRIGHT", space, -bdUI.border)
			-- Minimap.buttonFrame:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", size, bdUI.border)
		elseif (config.buttonpos == "Bottom") then
			Minimap.buttonFrame:SetPoint("TOPLEFT", Minimap.background, "BOTTOMLEFT", bdUI.border, -space)
			-- Minimap.buttonFrame:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", -bdUI.border, -size)
		elseif (config.buttonpos == "Left") then
			Minimap.buttonFrame:SetPoint("TOPRIGHT", Minimap.background, "TOPLEFT", -space, -bdUI.border)
			-- Minimap.buttonFrame:SetPoint("BOTTOMLEFT", Minimap.background, "BOTTOMLEFT", -size, bdUI.border)
		end
	end

	mod:position_button_frame()
end