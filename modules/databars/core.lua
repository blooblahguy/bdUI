--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")
local config

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
local honor, rep, xp, altpower, container
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config
	
	-- create the bars
	altpower = mod:create_altpower()

	if (not config.databars) then return end

	-- framestack bars
	container = CreateFrame("frame", "bdDatabars", UIParent)
	xp = mod:create_xp()
	rep = mod:create_reputation()
	honor = mod:create_honor()

	-- put into frame group
	bdUI:frame_group(container, "downwards", honor, rep, xp)
	container:SetPoint("TOP", bdParent, "TOP", 0, -10)
	bdMove:set_moveable(container, "Databars")
end


-- config callback
function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config

	if (not config.databars) then return end

	if (xp) then
		xp:SetSize(config.databars_width, config.databars_height)
		for i = 1, 19 do
			local tex = xp.tex[i]
			local offset = (xp:GetWidth() / 20) * i
			tex:SetPoint("TOP", xp, "TOP")
			tex:SetPoint("BOTTOM", xp, "BOTTOM")
			tex:SetPoint("LEFT", xp, "LEFT", offset, 0)
		end
		xp:callback()
	end
	if (rep) then
		rep:SetSize(config.databars_width, config.databars_height)
		rep:callback()
	end
	if (honor) then
		honor:SetSize(config.databars_width, config.databars_height)
		honor:callback()
	end
	if (altpower) then
		altpower:SetSize(config.alt_width, config.alt_height)
		altpower:callback()
	end

	
	bdUI:frame_group(container, "downwards", honor, rep, xp)
end