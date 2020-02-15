
--============================================
-- COMMUNITY
-- Hides guild / community chat by default for streamers
-- Credit to Nnogga
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

function mod:create_community()
	local config = mod.config
	local commOpen = CreateFrame("frame", nil, UIParent)
	commOpen:RegisterEvent("ADDON_LOADED")
	commOpen:RegisterEvent("CHANNEL_UI_UPDATE")
	commOpen:SetScript("OnEvent", function(self, event, addonName)    
		if event == "ADDON_LOADED" and addonName == "Blizzard_Communities" then
			--create overlay
			local f = CreateFrame("Button",nil,UIParent)
			f:SetFrameStrata("HIGH")
			f.tex = f:CreateTexture(nil, "BACKGROUND")
			f.tex:SetAllPoints()
			f.tex:SetColorTexture(0.1,0.1,0.1,1)
			f.text = f:CreateFontString()
			f.text:SetFontObject("GameFontNormalMed3")
			f.text:SetText("Chat Hidden. Click to show")
			f.text:SetTextColor(1, 1, 1, 1)
			f.text:SetJustifyH("CENTER")
			f.text:SetJustifyV("CENTER")
			f.text:SetHeight(20)
			f.text:SetPoint("CENTER",f,"CENTER",0,0)
			f:EnableMouse(true)
			f:RegisterForClicks("AnyUp")
			f:SetScript("OnClick",function(...)
				f:Hide()
			end)
			--toggle
			local function toggleOverlay()       
				if CommunitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT and config.chatHide then
					f:SetAllPoints(CommunitiesFrame.Chat.InsetFrame)
					f:Show()
				else
					f:Hide()
				end
			end
			local function hideOverlay()
				f:Hide()  
			end        
			toggleOverlay() --run once
			
			--hook        
			hooksecurefunc(CommunitiesFrame,"SetDisplayMode", toggleOverlay)
			hooksecurefunc(CommunitiesFrame,"Show",toggleOverlay)
			hooksecurefunc(CommunitiesFrame,"Hide",hideOverlay)
			hooksecurefunc(CommunitiesFrame,"OnClubSelected", toggleOverlay)        
		end
	end)
end

--=============================================
-- TELL TARGET
-- thanks phanx for simple script
--=============================================
function mod:telltarget()
	SLASH_TELLTARGET1 = "/tt"
	SLASH_TELLTARGET2 = "/wt"
	SlashCmdList.TELLTARGET = function(message)
		if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
			SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
		end
	end
end