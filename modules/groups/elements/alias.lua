local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Groups")

-- player alias functionality
local function aliasPrompt(playerName)
	StaticPopupDialogs["BDGRID_ALIAS"] = {
		text = "Set alias for "..playerName,
		button1 = "Accept",
		button2 = "Cancel",
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		OnCancel = function (self, data)
			self:Hide()
		end,
		OnShow = function (self, data)
			local parent = self
			if (bdUI.persistent.GridAliases[playerName]) then
				self.editBox:SetText(bdUI.persistent.GridAliases[playerName])
			else
				self.editBox:SetText("")
			end
			self.editBox:SetScript("OnEscapePressed", function(self) parent:Hide() end)
			self.editBox:SetScript("OnEnterPressed", function(self) parent.button1:Click() end)
		end,
		OnAccept = function (self, data, data2)
			local text = self.editBox:GetText()
			if (text == "") then
				bdUI.persistent.GridAliases[playerName] = nil
			else
				bdUI.persistent.GridAliases[playerName] = text
			end
			self:Hide()
		end,
		OnHide = function (self) 
			self.data = nil; 
			self:Hide() 
		end,
		hasEditBox = true,
		enterClicksFirstButton = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show("BDGRID_ALIAS")
end

--=======================================================
-- Alias Dropdown Select
--=======================================================
function mod:create_alias()
	-- turns out its not at all simple to add a button where you want in an already-existing dropdown. that or i'm dumb
	hooksecurefunc("ToggleDropDownMenu", function(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay) 
		if (level == 1 and not button) then
			local name = _G['DropDownList1Button1NormalText']
			local focus = _G['DropDownList1Button3NormalText']

			-- only add a button if this is a unitmenu
			if (focus and focus:GetText() == "Set Focus") then
				name = name:GetText()
				if (name and (UnitInRaid(name) or UnitInParty(name) or UnitIsUnit(name, "player"))) then
					-- add our button
					local info = UIDropDownMenu_CreateInfo()
					info.text = "Add player alias"
					info.notCheckable = true;
					info.func = function()
						aliasPrompt(name)
					end
					UIDropDownMenu_AddButton(info)

					-- loop through all, reposition
					local gap = nil
					local lasty = nil
					local idealy = nil
					for i = 1, 30 do
						local item = _G['DropDownList1Button'..i]
						if (not item) then return end
						local point, anchor, anchorpoint, x, y = item:GetPoint()
						-- calculate how large the menu is
						if (not gap) then
							if (not lasty) then
								lasty = y
							else
								gap = y - lasty
							end
						else
							local text = _G['DropDownList1Button'..i.."NormalText"]:GetText()
							if (i >= 5) then
								-- find out what y axis the new button is taking over
								if (i == 5) then
									idealy = y
								end
								
								-- send everyting down by gap
								item:SetPoint(point, anchor, anchorpoint, x, y+gap)

								if (text == "Add player alias") then
									item:SetPoint(point, anchor, anchorpoint, x, idealy)
								end
							end
						end
					end
				end
			end
		end
	end)
end