local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Groups")
local config
local oUF = bdUI.oUF
local initialized = false

-- ======================================================
-- Update the raidframe header with new configuration values
-- ======================================================
local function update_raid_header()
	if (InCombatLockdown()) then
		return
	end

	local header = mod.frameHeader

	mod:resize_container(mod.frameHeader, mod.raid_holder, config.width, config.height)

	local group_by,
		group_sort,
		sort_method,
		yOffset,
		xOffset,
		new_group_anchor,
		new_player_anchor,
		hgrowth,
		vgrowth,
		num_groups = mod:get_attributes()

	-- growth/spacing
	header:SetAttribute("columnAnchorPoint", new_group_anchor)
	header:SetAttribute("point", new_player_anchor)

	if (config.group_growth == "Right") then
		-- header:SetAttribute("columnSpacing", config.group_growth == "Right" and xOffset or -yOffset)
		header:SetAttribute("columnSpacing", xOffset)
	else
		header:SetAttribute("columnSpacing", -yOffset)
	end

	header:SetAttribute("yOffset", yOffset)
	header:SetAttribute("xOffset", xOffset)

	-- what to show
	header:SetAttribute("showpartyleadericon", config.showpartyleadericon)

	-- when to show
	header:SetAttribute("showSolo", config.showsolo)
	header:SetAttribute("maxColumns", num_groups)

	-- width/height
	header:SetAttribute("initial-width", config.width)
	header:SetAttribute("initial-height", config.height)

	-- grouping/sorting
	header:SetAttribute("groupBy", group_by)
	header:SetAttribute("groupingOrder", group_sort)
	header:SetAttribute("sortMethod", sort_method)
end

local function initialize()
	-- raid and party
	local raid_party = CreateFrame("frame", "bdGrid", UIParent)
	raid_party:SetSize(config["width"], config["height"] * 5)
	raid_party:SetPoint("LEFT", UIParent, "LEFT", 10, -90)
	bdMove:set_moveable(raid_party, "Raid Frames")

	-- register events for resizing the box/group size
	raid_party:SetScript(
		"OnEvent",
		function(self, event, arg1)
			if (event == "PLAYER_ENTERING_WORLD") then
				C_Timer.After(
					2,
					function()
						update_raid_header()
					end
				)
			else
				update_raid_header()
			end
		end
	)

	mod.raid_holder = raid_party

	-- send to factory
	-- oUF:Factory(function(self)
	oUF:SetActiveStyle("bdGrid")

	-- Initial header spawning
	local group_by,
		group_sort,
		sort_method,
		yOffset,
		xOffset,
		new_group_anchor,
		new_player_anchor,
		hgrowth,
		vgrowth,
		num_groups = mod:get_attributes()

	local attributes = {}
	attributes.showParty = true
	attributes.showPlayer = true
	attributes.showSolo = config.showSolo
	attributes.showRaid = true
	attributes["initial-scale"] = 1
	attributes.unitsPerColumn = 5
	attributes.columnSpacing = yOffset
	attributes.xOffset = xOffset
	attributes.yOffset = yOffset
	attributes.maxColumns = num_groups
	attributes.groupingOrder = group_sort
	attributes.sortMethod = sort_method
	attributes.columnAnchorPoint = new_group_anchor
	attributes["initial-width"] = config.width
	attributes["initial-height"] = config.height
	attributes.point = new_player_anchor
	attributes.groupBy = group_by
	attributes["oUF-initialConfigFunction"] = format("self:SetWidth(%d); self:SetHeight(%d);", config.width, config.height)

	-- ouf gives us secureheader
	mod.frameHeader = oUF:SpawnHeader("bdUI_raid", nil, "raid,party,solo", attributes)

	update_raid_header()

	-- mod:demo_mode()
	-- end)
end

function mod:demo_mode()
	for _, frame in ipairs(oUF.objects) do
		-- assert(false, frame)
		-- print(frame.unit)
		-- print(frame.layout)
		-- print(frame:GetAttribute('unitsuffix'))
		local type = frame:GetAttribute("oUF-guessUnit")

		if (type == "raid") then
			local playerName = "TestPlayer" .. frame:GetID()
			frame.ShortTest:SetText(playerName)
			frame.ShortTest:Show()
			frame.Short:Hide()
		end
		-- local frame = _G[unit] -- Get the actual frame associated with the unit

		-- -- Check if the frame exists and is visible
		-- if frame and frame:IsVisible() then
		-- 	local playerClass = "PRIEST" -- Choose any class for testing
		-- 	local playerRole = "HEALER" -- Choose any role for testing

		-- 	-- Set unit attributes
		--
		-- 	-- frame.class:SetText(playerClass)
		-- 	-- frame.role:SetText(playerRole)
		-- end
	end
end

local function callback()
	if (not mod.frameHeader) then
		return
	end
	update_raid_header()
end

local function disable(_config)
	if (not mod.frameHeader) then
		return
	end

	config = _config
	mod.raid_holder:UnregisterEvent("PLAYER_REGEN_ENABLED")
	mod.raid_holder:UnregisterEvent("PLAYER_ENTERING_WORLD")
	mod.raid_holder:UnregisterEvent("RAID_ROSTER_UPDATE")
	mod.raid_holder:UnregisterEvent("GROUP_JOINED")
	mod.raid_holder:UnregisterEvent("GROUP_ROSTER_UPDATE")
	mod.raid_holder:UnregisterEvent("ZONE_CHANGED_NEW_AREA")

	mod.raid_holder:Hide()
	mod.frameHeader:SetAttribute("showParty", false)
	mod.frameHeader:SetAttribute("showSolo", false)
	mod.frameHeader:SetAttribute("showRaid", false)

	return false
end

local function enable(_config)
	config = _config

	-- disable it
	if (not config.enabled_raid) then
		return false
	end

	-- run first time
	if (not initialized) then
		initialize()
		initialized = true
	end

	-- show the frame
	mod.raid_holder:Show()
	-- mod.frameHeader:SetAttribute("showParty", true)
	mod.frameHeader:SetAttribute("showSolo", config.showSolo)
	mod.frameHeader:SetAttribute("showRaid", true)

	-- register callbacks
	mod.raid_holder:RegisterEvent("PLAYER_REGEN_ENABLED")
	mod.raid_holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	mod.raid_holder:RegisterEvent("RAID_ROSTER_UPDATE")
	mod.raid_holder:RegisterEvent("GROUP_JOINED")
	mod.raid_holder:RegisterEvent("GROUP_ROSTER_UPDATE")
	mod.raid_holder:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	-- now run config callback on it
	callback()

	-- it's enabled, don't run to disabled function
	return true
end

local function path()
end
mod:add_element("raid_frames", path, enable, disable)
