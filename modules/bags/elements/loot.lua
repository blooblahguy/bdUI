local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

-- @TODO Group Loot Frame

function mod:auto_greed_loot()
	local eh = CreateFrame("frame")
	eh:RegisterEvent("START_LOOT_ROLL")
	eh:SetScript("OnEvent", function(self, rollID, rollTime, lootHandle)
	
	end)
end

function mod:skin_loot()
	if (not mod.config.skinloot) then return end
	local p, r, spacing_x, spacing_y = "TOP", "BOTTOM", 0, -4

	LootFrame:SetMovable(true)
	LootFrame:EnableMouse(true)
	LootFrame:RegisterForDrag("LeftButton")
	LootFrame:SetScript("OnDragStart", function() LootFrame:StartMoving() end)
	LootFrame:SetScript("OnDragStop", function() LootFrame:StopMovingOrSizing() end)
	bdUI:set_backdrop(LootFrame)

	LootFrameCloseButton:SetFrameLevel(10)

	local model = CreateFrame("PlayerModel", nil, LootFrame)
	model:SetPoint("TOPLEFT", LootFrame, 8, -8)
	model:SetPoint("TOPRIGHT", LootFrame, -8, -8)
	model:SetHeight(50)
	model:EnableMouse(true)
	model:RegisterForDrag("LeftButton")
	model:SetScript("OnDragStart", function() LootFrame:StartMoving() end)
	model:SetScript("OnDragStop", function() LootFrame:StopMovingOrSizing() end)
	bdUI:set_backdrop(model)


	local function skin_loot(self)
		local num = GetNumLootItems()

		local buttonHeight = LootButton1:GetHeight() + abs(spacing_y)
		LootFrame:SetHeight(24 + model:GetHeight() + (num * buttonHeight))
		LootFrame:SetWidth(250)

		for i = 1, num do
			local button = _G["LootButton"..i]
			
			if i > LOOTFRAME_NUMBUTTONS then
				if not button then
					button = CreateFrame(ItemButtonMixin and "ItemButton" or "Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
				end
				LOOTFRAME_NUMBUTTONS = i
			end
			if i > 1 then
				button:ClearAllPoints()
				button:SetPoint(p, "LootButton"..(i-1), r, spacing_x, spacing_y)
			end

			local lootIcon, lootName, lootQuantity, _, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local text = _G[button:GetName().."Text"]

			if (not button.quality_border) then
				bdUI:strip_textures(button, false)
				bdUI:strip_textures(LootFrame, true)
				bdUI:strip_textures(LootFrameInset, true)
				bdUI:strip_textures(LootFrameInset.NineSlice, true)
				bdUI:strip_textures(LootFrame.NineSlice, true)

				button.icon = button:CreateTexture(nil, "OVERLAY")
				button.icon:SetPoint("TOPLEFT", button)
				button.icon:SetSize(buttonHeight - 4, buttonHeight - 4)
				button.icon:SetTexCoord(.1, .9, .1, .9)

				text:ClearAllPoints()
				text:SetPoint("LEFT", button.icon, "RIGHT", 10, 0)

				button.qty = button:CreateFontString(nil, "OVERLAY")
				button.qty:SetPoint("BOTTOMRIGHT", button.icon, -2, 2)
				button.qty:SetFontObject(bdUI:get_font(13))

				button.border = button:CreateTexture(nil, "BACKGROUND")
				button.border:SetTexture(bdUI.media.flat)
				button.border:SetVertexColor(bdUI.media.border)
				button.border:SetPoint("TOPLEFT", button.icon, -bdUI.border, bdUI.border)
				button.border:SetPoint("BOTTOMRIGHT", button.icon, bdUI.border, -bdUI.border)

				button.hover = button:CreateTexture(nil, "BACKGROUND")
				button.hover:SetTexture(bdUI.media.flat)
				button.hover:SetVertexColor(1, 1, 1, .03)
				button.hover:SetPoint("TOPLEFT", button)
				button.hover:SetPoint("BOTTOMRIGHT", text)
				button:HookScript("OnEnter", function(self) self.hover:Show() end)
				button:HookScript("OnLeave", function(self) self.hover:Hide() end)

				button.quality_border = CreateFrame("frame", button:GetName().."QualityBorder", button)
				button.quality_border:SetPoint("TOPLEFT", button.icon, "TOPLEFT", bdUI.border, -bdUI.border)
				button.quality_border:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", -bdUI.border, bdUI.border)
				bdUI:set_backdrop(button.quality_border)
				button.quality_border:set_border_color(1, 0, 0, 1)
				button.quality_border._background:Hide()
			end

			-- this makes no sense, but it works for hover
			button:SetWidth(LootFrame:GetWidth() - 84 - buttonHeight)
			button.hover:Hide()

			-- text
			text:SetWidth(LootFrame:GetWidth() - 24 - buttonHeight)
			text:SetText(lootName)

			-- icon
			button.icon:SetTexture(lootIcon)

			-- quantitiy
			_G[button:GetName().."Count"]:Hide()
			_G[button:GetName().."Count"].Show = noop
			if (lootQuantity and lootQuantity >= 2) then
				button.qty:Show()
				button.qty:SetText(lootQuantity)
			else
				button.qty:Hide()
			end

			-- item quality
			if (rarity and rarity > 1) then
				local r, g, b, hex = GetItemQualityColor(rarity)
				button.quality_border:set_border_color(r, g, b, 1)
				button.quality_border:Show()
				text:SetTextColor(r, g, b, 1)
			else
				button.quality_border:Hide()
			end		

			-- frame model
			if (UnitExists("target")) then
				model:SetUnit("target")
				model:SetCamera(0)
				model:FreezeAnimation(0, 0)
			else
				model:ClearModel()
				model:SetModel("PARTICLES\\Lootfx_green.m2")
			end
		end

		-- default position
		if ( GetCVar("lootUnderMouse") ~= "1" ) then
			LootFrame:ClearAllPoints()
			LootFrame:SetPoint("LEFT", UIParent, 150, 0)
		end
		
		LootFrame_Update()
	end

	-- mod:SecureHook(LootFrame, "OnShow", skin_loot)
	mod:SecureHook("LootFrame_Show", skin_loot)
end