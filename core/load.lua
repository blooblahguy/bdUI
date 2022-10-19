local bdUI, c, l = unpack(select(2, ...))

-- measure addon load times
-- local enabled_addons = {}
-- for i = 1, 60 do
-- 	local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
-- 	if (not name) then break end
-- 	if (enabled) then
-- 		-- print(name)
-- 		enabled_addons[name] = GetTime()
-- 	end
-- end

local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	-- print(addon, "loaded in", GetTime() - enabled_addons[addon])

	if (addon == bdUI.name) then
		-- loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("pre_loaded")

		-- overwrite some ouf colors
		bdUI.oUF.colors.power[0] = {46/255, 130/255, 215/255}
		bdUI.oUF.colors.power["MANA"] = {46/255, 130/255, 215/255}
		bdUI.oUF.colors.power["RAGE"] = {220/255, 30/255, 30/255}
		bdUI.oUF.colors.power.ARCANE_CHARGES = {55/255, 139/255, 224/255}

		-- Load bdConfig now that we have saved variables
		bdUI.config_instance = bdUI.bdConfig:load()
		bdUI.persistent = BDUI_SAVE.persistent

		-- migrating bdGrid profile over to groups
		if (BDUI_SAVE and BDUI_SAVE.profiles and BDUI_SAVE.profiles.default and BDUI_SAVE.profiles.default.Grid) then
			BDUI_SAVE.profiles.default.Groups = BDUI_SAVE.profiles.default.Grid
			BDUI_SAVE.profiles.default.Grid = nil
		end

		-- set save for bdMove, so that we're not vulnerable to UI errors resetting positioning
		local profile = bdUI.bdConfig:get_save("BDUI_SAVE")
		bdMove:set_save(bdUI.bdConfig:get_save("BDUI_SAVE"))

		-- pass new profile to bdMove when profile changes
		bdUI:add_action("profile_change", function()
			local sv = bdUI.bdConfig:get_save("BDUI_SAVE")
			bdMove:set_save(sv)
		end, 5)
		bdMove.spacing = bdUI.border

		bdUI:debug(l['loaded'])
		-- bdUI:debug(l['for options'])
		bdUI:do_action("loaded")
		bdUI:do_action("post_loaded")

		-- if (not BDUI_SAVE.first_run) then
		-- 	BDUI_SAVE.first_run = true
		-- 	bdUI:do_action("setup")
		-- end

		--=====================================
		-- Add minimap icon
		--=====================================
		-- icon
		local LDB = LibStub("LibDataBroker-1.1", true)
		local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
		bdUI_configButton = LDB and LibStub("LibDBIcon-1.0", true)
		if LDB then
			local minimapIcon = LDB:NewDataObject("bdUI", {
				type = "launcher",
				icon = "Interface\\AddOns\\bdUI\\media\\minimapicon.blp",
				OnClick = function(clickedframe, button)
					if (button == "LeftButton") then
						if (IsControlKeyDown()) then
							ReloadUI()
						else
							bdUI.bdConfig:toggle()
						end
					elseif (button == "RightButton") then
						if (IsControlKeyDown()) then
							bdUI_configButton:Hide("bdUI")
							BDUI_SAVE.MinimapIcon.hide = true --for non bdUI minimaps
							bdUI:get_module("Maps").config.showconfig = false
						else
							bdUI.bdConfig.header.lock:Click()
						end
					end	
				end,
				OnTooltipShow = function(tt)
					tt:AddLine(bdUI.colorString.."Config")
					tt:AddLine("|cffFFAA33Left Click:|r |cff00FF00Open bdUI Config|r")
					tt:AddLine("|cffFFAA33Right Click:|r |cff00FF00Toggle lock/unlock|r")
					tt:AddLine("|cffFFAA33Ctrl+Left Click:|r |cff00FF00Reload UI|r")
					tt:AddLine("|cffFFAA33Ctrl+Right Click:|r |cff00FF00Hide Button|r")
				end,
			})

			if bdUI_configButton then
				-- init value
				if (BDUI_SAVE.MinimapIcon == nil) then
					BDUI_SAVE.MinimapIcon = { minimapPos = 225, hide = false }
				end
				bdUI_configButton:Register("bdUI", minimapIcon, BDUI_SAVE.MinimapIcon)
			end
		end

	end
end)

if (IsAddOnLoaded("bdCore")) then
	DisableAddOn("bdCore")
	DisableAddOn("bdChat")
	DisableAddOn("bdNameplates")
	DisableAddOn("bdMinimap")
	DisableAddOn("bdBuffs")
	DisableAddOn("bdGrid")
	DisableAddOn("bdBags")
	DisableAddOn("bdTooltips")
	DisableAddOn("bdUnitframes")
end