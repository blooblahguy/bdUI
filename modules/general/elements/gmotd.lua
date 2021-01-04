local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_gmotd()
	local config = mod.config
	bdUI.persistent.gmotd = bdUI.persistent.gmotd or {}
	
	local gmotd = CreateFrame("frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	gmotd:SetSize(350, 150)
	gmotd:Hide()
	gmotd:SetPoint("TOP", UIParent, "TOP", 0, -140)
	bdUI:set_backdrop(gmotd)
	gmotd.header = gmotd:CreateFontString(nil)
	gmotd.header:SetFontObject(bdUI:get_font(14))
	gmotd.header:SetPoint("BOTTOM", gmotd, "TOP", 0, 4)

	gmotd.text = gmotd:CreateFontString(nil)
	gmotd.text:SetHeight(130)
	gmotd.text:SetPoint("TOPLEFT", gmotd, "TOPLEFT", 10, -10)
	gmotd.text:SetPoint("TOPRIGHT", gmotd, "TOPRIGHT", -10, -10)
	gmotd.text:SetJustifyV("TOP")
	gmotd.text:SetFontObject(bdUI:get_font(13))
	gmotd.text:SetTextColor(0, 1, 0)
	gmotd.text:CanWordWrap(true)
	gmotd.text:SetWordWrap(true)

	gmotd.button = CreateFrame("Button", nil, gmotd, BackdropTemplateMixin and "BackdropTemplate")
	gmotd.button:SetText("Got it");
	gmotd.button:SetPoint("TOP", gmotd, "BOTTOM", 0, -4)
	bdUI:skin_button(gmotd.button, false)
	gmotd.button:SetScript("OnClick",function(self)
		bdUI.persistent.gmotd[gmotd.msg] = true
		gmotd:Hide()
	end)
	
	gmotd:RegisterEvent("GUILD_MOTD")
	gmotd:RegisterEvent("GUILD_ROSTER_UPDATE")
	gmotd:SetScript("OnEvent", function(self, event, message)
		if (not config.skingmotd) then return end

		local guild = false
		local msg = false
		if (event == "GUILD_MOTD") then
			msg = message
			guild = select(1, GetGuildInfo("player"))
		else
			msg = GetGuildRosterMOTD()
			guild = select(1, GetGuildInfo("player"))
		end
		
		if (strlen(msg) > 0 and guild and not bdUI.persistent.gmotd[msg]) then
			gmotd.msg = msg
			gmotd.text:SetText(msg)
			gmotd.header:SetText(guild.." - Message of the Day")
			gmotd:Show()
			local numlines = gmotd.text:GetNumLines()
			gmotd:SetHeight(20+(12.2*numlines))
		end
	end)
end