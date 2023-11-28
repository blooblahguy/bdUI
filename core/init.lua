local addonName, ns = ...

local engine = ns
engine[1] = CreateFrame("Frame", nil, UIParent) -- core ui
engine[2] = {}                                  -- config
engine[3] = {}                                  -- locale
bdUI = engine[1]
bdUI.caches = {}
bdUI.name = addonName
bdUI.class = select(2, UnitClass("player"))
bdUI.classColor = RAID_CLASS_COLORS[bdUI.class]
bdUI.colorString = '|cffA02C2Fbd|r'
-- auras
bdUI.aura_lists = {}
bdUI.aura_lists.raid = {}
bdUI.aura_lists.class = {}
bdUI.aura_lists.mine = {}
bdUI.aura_lists.blacklist = {}
bdUI.aura_lists.whitelist = {}
bdUI.aura_lists.special = {}

--===================================================================
-- Basic Config
--===================================================================
bdUI.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	arial = "fonts\\ARIALN.ttf",
	smooth = "Interface\\Addons\\" .. addonName .. "\\core\\media\\smooth.tga",
	font = "Interface\\Addons\\" .. addonName .. "\\core\\media\\PTSansNarrow.ttf",
	myriad = "Interface\\Addons\\" .. addonName .. "\\core\\media\\Myriad.ttf",
	arrow = "Interface\\Addons\\" .. addonName .. "\\core\\media\\arrow.tga",
	align = "Interface\\Addons\\" .. addonName .. "\\core\\media\\align.tga",
	shadow = "Interface\\Addons\\" .. addonName .. "\\mcore\\media\\shadow.blp",
	highlight = "Interface\\Addons\\" .. addonName .. "\\core\\media\\highlight.blp",
	fonts = {},
	backgrounds = {},
	border = { .03, .04, .05, .8 },
	backdrop = { .08, .09, .11, 0.9 },
	red = { .62, .17, .18, 1 },
	blue = { .2, .4, 0.8, 1 },
	green = { .1, .7, 0.3, 1 },
}

-- bdUI.media.font = bdUI.media.other_font

--===================================================================
-- Scale & Alt-UIParent
--===================================================================
bdParent = CreateFrame("frame", "bdUIParent", UIParent)
bdParent:SetPoint("TOPLEFT", UIParent)
bdParent:SetPoint("BOTTOMRIGHT", UIParent)

function bdUI:calculate_scale()
	bdUI.scale = 768 / select(2, GetPhysicalScreenSize())
	bdUI.ui_scale = GetCVar("useUiScale") and GetCVar("uiScale") or 1
	bdUI.pixel = bdUI.scale / bdUI.ui_scale

	bdUI.border = bdUI.pixel * 2
	bdParent:SetScale(bdUI.pixel)
end

bdUI:calculate_scale()

bdUI.hidden = CreateFrame("frame", nil, nil)
bdUI.hidden:Hide()
bdUI.hidden:SetAlpha(0)
bdUI.hidden:SetScale(0.001)
bdUI.hidden.Show = function() return end

-- developer stuff
local developer_names = {}
developer_names["Padder"] = true
developer_names["Nodis"] = true
developer_names["Bloo"] = true
developer_names["Redh"] = true
developer_names["Update"] = true
bdUI.developer = developer_names[select(1, UnitName("player"))]

--===================================================================
--Return game version, so that we can have cross version compatibility when possible
--===================================================================
bdUI.level_cap = GetMaxPlayerLevel() --MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

local versions = {}
versions[109999] = "dragonflight"
versions[99999] = "shadowlands"
versions[89999] = "bfa"
versions[79999] = "legion"
versions[69999] = "wod"
versions[59999] = "mop"
versions[49999] = "cataclysm"
versions[39999] = "wrath"
versions[29999] = "tbc"
versions[19999] = "vanilla"
function bdUI:get_game_version()
	local version, build, date, tocversion = GetBuildInfo()

	local game = 0
	local version = 1000000

	for k_id, v_name in pairs(versions) do
		if (tocversion < k_id and k_id < version) then
			version = k_id
			game = v_name
		end
	end

	bdUI.version = version
	bdUI.expansion = game

	return game, tocversion
end

bdUI:get_game_version()
