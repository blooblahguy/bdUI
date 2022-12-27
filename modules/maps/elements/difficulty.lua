local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")

function mod:minimap_difficulty()
	-- hide blizzard
	if (MiniMapInstanceDifficulty) then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", bdMinimap, "TOPRIGHT", -2, -2)
	end

	-- add ours
	local difftext = {}
	local rd = CreateFrame("Frame", nil, Minimap)
	rd:SetSize(24, 8)
	rd:EnableMouse(false)
	rd:RegisterEvent("PLAYER_ENTERING_WORLD")
	if (bdUI.version >= 50000) then
		rd:RegisterEvent("CHALLENGE_MODE_START")
		rd:RegisterEvent("CHALLENGE_MODE_COMPLETED")
		rd:RegisterEvent("CHALLENGE_MODE_RESET")
		rd:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	end
	rd:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
	rd:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	local rdt = rd:CreateFontString(nil, "OVERLAY")
	rdt:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 6)
	rdt:SetFontObject(bdUI:get_font(13))
	rdt:SetJustifyH("RIGHT")
	rdt:SetTextColor(.7,.7,.7)
	rd:SetScript("OnEvent", function()
		local difficulty = select(3, GetInstanceInfo())
		local numplayers = select(9, GetInstanceInfo())
		local mplusdiff = C_ChallengeMode and select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or "";

		if (difficulty == 1) then
			rdt:SetText("5")
		elseif difficulty == 2 then
			rdt:SetText("5H")
		elseif difficulty == 3 then
			rdt:SetText("10")
		elseif difficulty == 4 then
			rdt:SetText("25")
		elseif difficulty == 5 then
			rdt:SetText("10H")
		elseif difficulty == 6 then
			rdt:SetText("25H")
		elseif difficulty == 7 then
			rdt:SetText("LFR")
		elseif difficulty == 8 then
			rdt:SetText("M+"..mplusdiff)
		elseif difficulty == 9 then
			rdt:SetText("40")
		elseif difficulty == 11 then
			rdt:SetText("HScen")
		elseif difficulty == 12 then
			rdt:SetText("Scen")
		elseif difficulty == 14 then
			rdt:SetText("N:"..numplayers)
		elseif difficulty == 15 then
			rdt:SetText("H:"..numplayers)
		elseif difficulty == 16 then
			rdt:SetText("M")
		elseif difficulty == 17 then
			rdt:SetText("LFR:"..numplayers)
		elseif difficulty == 23 then
			rdt:SetText("M+")
		elseif difficulty == 24 then
			rdt:SetText("TW")
		else
			rdt:SetText("")
		end
	end)

	Minimap.rd = rd
end