local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")
local config

function mod:create_loot()
	config = mod:get_save()

	mod:skin_loot()
	mod:create_qol()

	-- Extend the size of the loot frame to show all items
	local p, r, x, y = "TOP", "BOTTOM", 0, -4
	local buttonHeight = LootButton1:GetHeight() + abs(y)
	local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)
	local old_LootFrame_Show = LootFrame_Show
	local shared = LootFrame:CreateTexture(nil, "OVERLAY")
	local sharedf = LootFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	function LootFrame_Show(self, ...)
		LootFrameInset:Hide()
		local maxButtons = floor(UIParent:GetHeight() / LootButton1:GetHeight() * 0.7)
		
		local num = GetNumLootItems()
		
		num = min(num, maxButtons)

		LootFrame:SetHeight(baseHeight + (num * buttonHeight))
		for i = 1, num do
			local button = _G["LootButton"..i]
			if (not button) then
				button = CreateFrame("Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
				button.IconBorder = shared
				button.IconOverlay = shared
				_G[button:GetName().."NormalTexture"] = shared
				_G[button:GetName().."IconTexture"] = shared
				_G[button:GetName().."Count"] = sharedf
			end
			if i > LOOTFRAME_NUMBUTTONS then
				LOOTFRAME_NUMBUTTONS = i
			end

			if i > 1 then
				button = _G["LootButton"..i]
				button:ClearAllPoints()
				button:SetPoint(p, "LootButton"..(i-1), r, x, y)
			end
		end
		
		mod:skin_loot()

		return old_LootFrame_Show(self, ...)
	end

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		if (bdUI:get_game_version() == "vanilla") then return end
		local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(index)
		local frame = _G["LootButton"..index]
		if (config.skinloot) then
			_G["LootButton"..index.."IconQuestTexture"]:SetAlpha(0) -- hide quest item texture
			_G["LootButton"..index.."NameFrame"]:SetAlpha(0) -- hide sucky drops :D
		end
		if isQuestItem then
			frame._border:SetVertexColor(1.0, 0.82, 0)
		else
			frame._border:SetVertexColor(unpack(bdUI.media.backdrop))
		end	
	end)

	local LootTargetPortrait = CreateFrame("PlayerModel", nil, LootFrame)
	LootTargetPortrait:SetPoint("BOTTOMLEFT", LootFrame, "TOPLEFT", 9, -66)
	LootTargetPortrait:SetSize(187, 34)
	bdUI:set_backdrop(LootTargetPortrait)

	LootPortraitFrame = CreateFrame("Frame")
	LootPortraitFrame:RegisterEvent("LOOT_OPENED")
	LootPortraitFrame:SetScript("OnEvent", function(self, event, id)
		if event == "LOOT_OPENED" then
			if UnitExists("target") then
				LootTargetPortrait:SetUnit("target")
				LootTargetPortrait:SetCamera(0)
			else
				LootTargetPortrait:ClearModel()
				LootTargetPortrait:SetModel("PARTICLES\\Lootfx.m2")
			end
		end
	end)
end

function mod:skin_loot()
	if (not config.skinloot) then return end
	
	_G["LootFrameCloseButton"]:Hide()
	_G["LootFramePortraitOverlay"]:SetAlpha(0)

	for i = 1, 50 do
		local frame = _G['LootButton'..i]
		if (not frame) then break end

		if (i ~= 1) then
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT",_G['LootButton'..i-1],"BOTTOMLEFT",0,-2)
		end
		if (not frame.skinned) then
			local font = _G['LootButton'..i..'Text']
			local count = _G['LootButton'..i..'Count']
			local icon =  frame.icon
			local nf = _G['LootButton'..i..'NameFrame']
			local quality = frame.IconBorder
			if (quality) then
				quality:SetTexture("")
				quality:Hide()
				quality:SetAlpha(0)
			end
			
			font:SetFontObject(bdUI:get_font(14))

			if (count) then
				count:SetFontObject(bdUI:get_font(14))
			end
			
			frame:SetNormalTexture("")
			frame:SetPushedTexture("")
			local hover = frame:CreateTexture()
			hover:SetTexture(bdUI.media.flat)
			hover:SetVertexColor(1, 1, 1, 0.1)
			hover:SetAllPoints(frame)
			frame.hover = hover
			frame:SetHighlightTexture(hover)
			if (icon) then
				icon:SetTexCoord(.1, .9, .1, .9)
			end

			bdUI:set_backdrop(frame)
			nf:SetAlpha(0)
			
			frame.skinned = true
		end
	end

	local regions = {LootFrame:GetRegions()}
	local child = select(1, LootFrame:GetChildren())
	local more_regions = {child:GetRegions()}
	for k, v in pairs(more_regions) do table.insert(regions, v) end

	for k, r in pairs(regions) do
		if r then
			if r.GetText and r:GetText() == ITEMS then
				r:ClearAllPoints()
				r:SetPoint("TOP", -12, -19.5)
			elseif (r.GetTexture) then
				r:Hide()
			end
		end
	end

end

function mod:create_qol()

end