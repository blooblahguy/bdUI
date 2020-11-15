local bdUI, c, l = unpack(select(2, ...))

local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if (addon == bdUI.name) then
		loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("pre_loaded")

		-- Load bdConfig now that we have saved variables
		bdUI.config_instance = bdUI.bdConfig:load()
		bdUI.persistent = BDUI_SAVE.persistent

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
		bdUI:debug(l['for options'])
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
		if LDB then
			local minimapIcon = LDB:NewDataObject("bdUI", {
				type = "launcher",
				icon = "Interface\\AddOns\\bdUI\\media\\minimapicon.blp",
				OnClick = function(clickedframe, button)
					if (IsControlKeyDown()) then
						ReloadUI()
					end
					
					if (button == "LeftButton") then
						bdUI.bdConfig:toggle()
					elseif (button == "RightButton") then
						bdUI.bdConfig.header.lock:Click()
					end	
				end,
				OnTooltipShow = function(tt)
					tt:AddLine(bdUI.colorString.."Config")
					tt:AddLine("|cffFFAA33Left Click:|r |cff00FF00Open bdUI Config|r")
					tt:AddLine("|cffFFAA33Right Click:|r |cff00FF00Toggle lock/unlock|r")
					tt:AddLine("|cffFFAA33Ctrl+Click:|r |cff00FF00Reload UI|r")
				end,
			})

			if LDBIcon then
				LDBIcon:Register("bdUI", minimapIcon, BDUI_SAVE.MinimapIcon)
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

local sharedmedia = CreateFrame("frame", nil, bdParent)
sharedmedia:RegisterEvent("LOADING_SCREEN_DISABLED")
sharedmedia:SetScript("OnEvent", function()
	bdUI:do_action("bdUI/fonts")
	-- print("fonts")
	-- local fonts = bdUI.shared:List("font")
	-- for k, v in pairs(fonts) do
	-- 	print(k, v)
	-- 	local font = bdUI.shared:Fetch("font", v)
	-- 	print(font)
	-- end
	-- print(fonts)
end)