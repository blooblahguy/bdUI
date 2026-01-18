local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Groups")
local config
local oUF = bdUI.oUF
local initialized = false

-- ======================================================
-- Update the party frame header with new configuration values
-- ======================================================
local function update_party_header()
	if (InCombatLockdown()) then
		return
	end

	local header = mod.partyHeader

	mod:resize_container(mod.partyHeader, mod.party_holder, config.party_width, config.party_height)

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
	header:SetAttribute("initial-width", config.party_width)
	header:SetAttribute("initial-height", config.party_height)

	-- grouping/sorting
	header:SetAttribute("groupBy", group_by)
	header:SetAttribute("groupingOrder", group_sort)
	header:SetAttribute("sortMethod", sort_method)
end

local function initialize()
	-- party frames
	local party_frame = CreateFrame("frame", "bdParty", UIParent)
	party_frame:SetSize(config["width"], config["height"] * 5)
	party_frame:SetPoint("LEFT", UIParent, "LEFT", 10, -200)
	bdMove:set_moveable(party_frame, "Party Frames")

	-- register events for resizing the box/group size
	local pause_update = false
	party_frame:SetScript(
		"OnEvent",
		function(self, event, arg1)
			if (event == "PLAYER_ENTERING_WORLD") then
				pause_update = true
				C_Timer.After(2, function()
					pause_update = false
					update_party_header()
				end
				)
			elseif (pause_update == false) then
				update_party_header()
			end
		end
	)

	mod.party_holder = party_frame

	-- send to factory
	oUF:SetActiveStyle("bdParty")

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
	attributes.showRaid = false
	attributes["initial-scale"] = 1
	attributes.unitsPerColumn = 5
	attributes.columnSpacing = yOffset
	attributes.xOffset = xOffset
	attributes.yOffset = yOffset
	attributes.maxColumns = num_groups
	attributes.groupingOrder = group_sort
	attributes.sortMethod = sort_method
	attributes.columnAnchorPoint = new_group_anchor
	attributes["initial-width"] = config.party_width
	attributes["initial-height"] = config.party_height
	attributes.point = new_player_anchor
	attributes.groupBy = group_by
	attributes["oUF-initialConfigFunction"] = format("self:SetWidth(%d); self:SetHeight(%d);", config.party_width, config.party_height)

	-- ouf gives us secureheader
	mod.partyHeader = oUF:SpawnHeader("bdUI_party", nil, "party", attributes)

	update_party_header()
end

local function callback()
	if (not mod.partyHeader) then
		return
	end
	update_party_header()
end

local function disable(_config)
	if (not mod.partyHeader) then
		return
	end

	config = _config
	mod.party_holder:UnregisterEvent("PLAYER_REGEN_ENABLED")
	mod.party_holder:UnregisterEvent("PLAYER_ENTERING_WORLD")
	mod.party_holder:UnregisterEvent("RAID_ROSTER_UPDATE")
	mod.party_holder:UnregisterEvent("GROUP_JOINED")
	mod.party_holder:UnregisterEvent("GROUP_ROSTER_UPDATE")
	mod.party_holder:UnregisterEvent("ZONE_CHANGED_NEW_AREA")

	mod.party_holder:Hide()
	mod.partyHeader:SetAttribute("showParty", false)
	mod.partyHeader:SetAttribute("showSolo", false)

	return false
end

local function enable(_config)
	config = _config

	-- disable it
	if (not config.enabled_party) then
		return false
	end

	-- run first time
	if (not initialized) then
		initialize()
		initialized = true
	end

	-- show the frame
	mod.party_holder:Show()
	mod.partyHeader:SetAttribute("showSolo", config.showSolo)
	mod.partyHeader:SetAttribute("showParty", true)

	-- register callbacks
	mod.party_holder:RegisterEvent("PLAYER_REGEN_ENABLED")
	mod.party_holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	mod.party_holder:RegisterEvent("RAID_ROSTER_UPDATE")
	mod.party_holder:RegisterEvent("GROUP_JOINED")
	mod.party_holder:RegisterEvent("GROUP_ROSTER_UPDATE")
	mod.party_holder:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	-- now run config callback on it
	callback()

	-- it's enabled, don't run to disabled function
	return true
end

local function path()
end
mod:add_element("party_frames", path, enable, disable)
