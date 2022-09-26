local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

-- local quest_xp = CreateFrame("frame", nil, UIParent)
-- quest_xp:RegisterEvent("QUEST_DETAIL")
-- quest_xp:RegisterEvent("QUEST_ACCEPTED")
-- quest_xp:RegisterEvent("QUEST_REMOVED")

-- local QuestXP

-- local function show_xp(xp)
-- 	local xpshow = QuestInfoRewardsFrame.xp_text
-- 	if (not xpshow) then
-- 		QuestInfoRewardsFrame.xp_text = QuestInfoRewardsFrame:CreateFontString(nil, "OVERLAY")
-- 		xpshow = QuestInfoRewardsFrame.xp_text
-- 		xpshow:SetFontObject(QuestInfoRewardsFrame.ItemReceiveText:GetFontObject())
-- 		xpshow:SetPoint("TOPRIGHT", QuestDetailsScrollChildFrame, -10, -10)
-- 	end

-- 	xpshow:SetText(xp)
-- end

local cache_name = {}
local cache_id = {}

function bdUI:print_quest_xp()
	local numEntries, numQuests = GetNumQuestLogEntries()

	if (not QuestXP) then
		QuestXP = QuestieLoader:ImportModule("QuestXP")
	end

	local total = 0
	local entries = 0

	-- update xp numbers and save them
	for index = 1, numEntries do
		local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(index);

		if (not isHeader) then
			local xp = QuestXP:GetQuestLogRewardXP(questID, true)
			total = total + xp
			entries = entries + 1

			print(questLogTitleText, xp)

			if (not cache_id[questID]) then
				cache_name[questLogTitleText] = xp
				cache_id[questID] = xp
			end
		end
	end
	print("Total XP: ", total, "From", entries, "Quests")
end

-- quest_xp:SetScript("OnEvent", function(self, event, ...)
-- 	print(self, event)
-- 	self[event](...)
-- end)

-- hooksecurefunc("QuestLog_Update", function()
-- 	quest_xp:QuestLog_Update("QuestLog")
-- end)

-- hooksecurefunc("QuestLogFrame", "OnShow", function()

-- end)

-- local function show_xp_per()
-- 	local frame = CreateFrame("frame", nil, UIParent)
-- 	frame:SetSize(100, 300)
-- 	frame:SetPoint("TOPLEFT", UIParent, 10, -200)
-- 	frame:SetUserPlaced(true)
-- 	frame:EnableMouse(true)
-- 	frame:RegisterForDrag("LeftButton")
-- 	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
-- 	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
-- 	frame:RegisterEvent("PLAYER_XP_UPDATE")
-- 	bdUI:set_backdrop(frame)

-- 	local total_xp_earned = 0
-- 	local xp_started_hour = UnitXP("player")
-- 	local xp_started_minute = UnitXP("player")
-- 	local hour_window = GetTime()
-- 	local minute_window = GetTime()
-- 	frame:SetScript("OnEvent", function()
-- 		total_xp_earned = UnitXP("player")
-- 	end)

-- 	local t1 = frame:CreateFontString()
-- 	t1:SetFontObject(bdUI:get_font(12))
-- 	local t2 = frame:CreateFontString()
-- 	t1:SetFontObject(bdUI:get_font(12))
-- 	local t3 = frame:CreateFontString()
-- 	t1:SetFontObject(bdUI:get_font(12))
-- 	local t4 = frame:CreateFontString()
-- 	t1:SetFontObject(bdUI:get_font(12))

-- 	-- per hour
-- 	-- per 10 minutes

-- 	t1:SetPoint("TOPLEFT", frame, 4, 4)
-- end