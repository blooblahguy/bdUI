local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_qol()
	local config = mod.config
	-- increase equipment sets per player
	setglobal("MAX_EQUIPMENT_SETS_PER_PLAYER", 100)


	if (config.autodismount) then

		local eFrame = CreateFrame("FRAME")
		eFrame:RegisterEvent("UI_ERROR_MESSAGE")
		eFrame:SetScript("OnEvent", function(self, event, messageType, msg)
			-- Auto stand
			if msg == SPELL_FAILED_NOT_STANDING
			or msg == ERR_CANTATTACK_NOTSTANDING
			or msg == ERR_LOOT_NOTSTANDING
			or msg == ERR_TAXINOTSTANDING
			then
				DoEmote("stand")
				UIErrorsFrame:Clear()
			-- Auto dismount
			elseif msg == ERR_ATTACK_MOUNTED
			or msg == ERR_MOUNT_ALREADYMOUNTED
			or msg == ERR_NOT_WHILE_MOUNTED
			or msg == ERR_TAXIPLAYERALREADYMOUNTED
			or msg == SPELL_FAILED_NOT_MOUNTED
			then
				if IsMounted() then
					Dismount()
					UIErrorsFrame:Clear()
				end
			end
		end)
	end

	local total = 0
	local fps_location = CreateFrame("frame", "FPS/MS", WorldFrame)
	fps_location:SetPoint("TOPLEFT", WorldFrame, "TOPLEFT", 20, -20)
	fps_location:SetSize(100, 40)
	fps_location:Hide()
	fps_location:SetMovable(true)
	fps_location:EnableMouse(true)
	fps_location:SetUserPlaced(true)
	fps_location:RegisterForDrag("LeftButton")
	fps_location:SetScript("OnDragStart", fps_location.StartMoving)
	fps_location:SetScript("OnDragStop", fps_location.StopMovingOrSizing)
	fps_location:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total > 0.05) then
			total = 0

			-- fps info and color
			local fps = math.floor(GetFramerate()+0.5)
			local target_fps = GetCVar("targetfps")
			local fps_quality = (fps - 15) / (target_fps - 15)
			local fr, fg, fb = bdUI:ColorGradient(fps_quality, 1,0,0, 1,1,0, 0,1,0)
			local fps_color = RGBPercToHex(fr, fg, fb)

			-- latency info and color
			local down, up, lagHome, lagWorld = GetNetStats()
			local local_quality = math.floor((lagHome / 200) - .15)
			local lr, lg, lb = bdUI:ColorGradient(local_quality, 0,1,0, 1,1,0, 1,0,0)
			local local_color = RGBPercToHex(lr, lg, lb)

			local world_quality = math.floor((lagWorld / 200) - .15)
			local wr, wg, wb = bdUI:ColorGradient(world_quality, 0,1,0, 1,1,0, 1,0,0)
			local world_color = RGBPercToHex(wr, wg, wb)

			self.fps.text:SetFormattedText("fps: |cff%s%s", fps_color, fps)
			self.ms.text:SetFormattedText("ms: |cff%s%s / |cff%s%s", local_color, lagHome, world_color, lagWorld)

			self:SetWidth(math.max(self.fps.text:GetWidth(), self.ms.text:GetWidth()))
			self:SetHeight(self.fps.text:GetHeight() + self.ms.text:GetHeight() + 4)
		end
	end)
	-- bdMove:set_moveable(fps_location)

	local fps = CreateFrame("Frame", nil, fps_location)
	fps.text = fps:CreateFontString(nil, "OVERLAY")
	fps.text:SetFontObject("BDUI_SMALL")
	fps.text:SetPoint("TOPLEFT", fps_location, "TOPLEFT", 0 -2)
	fps.text:SetJustifyH("LEFT")
	fps_location.fps = fps

	local ms = CreateFrame("Frame", nil, fps_location)
	ms.text = ms:CreateFontString(nil, "OVERLAY")
	ms.text:SetFontObject("BDUI_SMALL")
	ms.text:SetPoint("TOPLEFT", fps.text, "BOTTOMLEFT", 0 -2)
	ms.text:SetJustifyH("LEFT")
	fps_location.ms = ms

	hooksecurefunc("ToggleFramerate", function()
		fps_location:SetShown(not fps_location:IsShown())
		FramerateLabel:Hide()
		FramerateText:Hide()
	end)


end


local autorelease = CreateFrame("frame", nil, UIParent)
autorelease:RegisterEvent("PLAYER_DEAD")
autorelease:RegisterEvent("PLAYER_ENTERING_WORLD")
autorelease:SetScript("OnEvent", function()
	local config = mod.config
	if (config.autorelease) then
		for i = 1, 5 do
			local status = GetBattlefieldStatus(i)
			if status == "active" then
				RepopMe()
				break
			end
		end
	end
end)