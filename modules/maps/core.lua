local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

--=============================================
-- Initialize function
--=============================================
function mod:initialize()
	mod.config = mod:get_save()

	if (not mod.config.enabled) then return end

	mod:create_objective_tracker()

	mod:create_minimap()

	if (mod.create_button_frame) then
		mod:create_button_frame()
	end

	mod:worldmap_coords()

	mod:config_callback()
end

function mod:config_callback()
	config = mod.config
	if (not mod.config.enabled) then return end

	-- mm callback
	Minimap:SetScale(config.scale)
	Minimap:SetSize(config.size, config.size)
	mod.bdMinimap:SetSize(config.size * config.scale, config.size * config.scale)

	-- Mask the minimap
	if (config.shape == "Rectangle") then
		Minimap:SetMaskTexture("Interface\\Addons\\bdUI\\core\\media\\rectangle.tga")
	else
		Minimap:SetMaskTexture(bdUI.media.flat)
	end

	-- -- scale elements back down
	-- TimeManagerClockButton:SetScale(1 / config.scale)
	-- MiniMapMailIcon:SetScale(1 / config.scale)
	-- local MiniMapMailFrame = MiniMapMailFrame or MailFrame
	-- MiniMapMailFrame:SetScale(1 / config.scale)
	-- Minimap.zone:SetScale(1 / config.scale)
	-- TicketStatusFrame:SetScale(1 / config.scale)
	-- Minimap.rd:SetScale(1 / config.scale)


	-- -- show/hide time
	-- if not IsAddOnLoaded("Blizzard_TimeManager") then
	-- 	LoadAddOn('Blizzard_TimeManager')
	-- end
	-- if (config.showtime) then
	-- 	TimeManagerClockButton:SetAlpha(1)
	-- 	TimeManagerClockButton:Show()
	-- else
	-- 	TimeManagerClockButton:SetAlpha(0)
	-- 	TimeManagerClockButton:Hide()
	-- end

	if (mod.create_button_frame) then
		mod:position_button_frame()
	end
end
