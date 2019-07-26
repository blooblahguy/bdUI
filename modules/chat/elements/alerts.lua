-- Alert Frame
bdChat.alert = CreateFrame("Frame");
bdChat.alert:ClearAllPoints();
bdChat.alert:SetHeight(300);
bdChat.alert:SetWidth(300);
bdChat.alert:Hide();
bdChat.alert.text = bdChat.alert:CreateFontString(nil, "BACKGROUND");
bdChat.alert.text:SetFont(bdUI.media.font, 16, "OUTLINE");
bdChat.alert.text:SetAllPoints();
bdChat.alert:SetPoint("CENTER", 0, 200);
bdChat.alert.time = 0;
bdChat.alert:SetScript("OnUpdate", function(self)
	if (bdChat.alert.time < GetTime() - 3) then
		local alpha = bdChat.alert:GetAlpha();
		if (alpha ~= 0) then bdChat.alert:SetAlpha(alpha - .05); end
		if (alpha == 0) then bdChat.alert:Hide(); end
	end
end);
 
local function alertMessage(message)
	bdChat.alert.text:SetText(message);
	bdChat.alert:SetAlpha(1);
	bdChat.alert:Show();
	bdChat.alert.time = GetTime();
	PlaySound(3081,"master")
end