--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Minimap")


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================

-- helps force mailupdate
local mailupdate = CreateFrame("frame")
mailupdate:RegisterEvent("MAIL_CLOSED")
mailupdate:RegisterEvent("MAIL_INBOX_UPDATE")
mailupdate:SetScript("OnEvent",function(self, event)
	if (event == "MAIL_CLOSED") then
		CheckInbox();
	else
		InboxFrame_Update()
		OpenMail_Update()
	end
end)