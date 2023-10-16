local _, ns = ...
local oUF = ns.oUF

local ttscan = CreateFrame('GameTooltip', 'oUFQuestProgress', nil, 'GameTooltipTemplate')
ttscan:SetOwner(WorldFrame, 'ANCHOR_NONE')

local activeQuests = {}
local activeWorldQuests = {}

if not GetQuestObjectiveInfo then return end

local colors = {
	['world'] = {},
	['quest'] = {},
}

local textures = {
	['loot'] = {
		"Banker",
		{.07, .93, .07, .93},
		0,
		"atlas"
	},
	['kill'] = {
		"Interface/CURSOR/Attack.PNG",
		-- "Interface/CharacterFrame/UI-StateIcon",
		-- {.5, 1, 0, .49},
		{.07, .93, .07, .93},
		0,
		"texture",
		-- 30
	},
	-- ['kill'] = {
	-- 	1375574,
	-- 	{.1, .9, .1, .9},
	-- 	0.785398,
	-- 	"texture"
	-- },
	['quest'] = {
		"Interface/QuestFrame/AutoQuest-Parts",
		{0.30273438, 0.41992188, 0.015625, 0.953125},
		0,
		"texture"
	},
	['item'] = {
		"",
		{.07, .93, .07, .93},
		0,
		"texture"
	}
}

--==============================================
-- Parse out a quest for progression information
--==============================================
local function QuestProgressByUnit(unit)	
	ttscan:SetUnit(unit)
	
	local progressGlob -- concatenated glob of quest text
	local questType -- 1 for player, 2 for group
	local objectiveCount = 0
	local questTexture -- if usable item
	local questLogIndex -- should generally be set, index usable with questlog functions
	local questID
	for i = 3, ttscan:NumLines() do
		local str = _G['oUFQuestProgressTextLeft' .. i]
		local text = str and str:GetText()
		if not text then return end

		questID = questID or activeWorldQuests[ text ]
		local playerName = ""
		local progressText = text
		local textOffset = select(4, str:GetPoint(2)) or 0
		local isQuestText = textOffset > 27 and textOffset < 29 -- Threat text is 30, Quest text is 28?
		
		-- todo: if multiple entries are present, ONLY read the quest objectives for the player
		-- if a name is listed in the pattern then we must be in a group
		if playerName and playerName ~= '' and playerName ~= UnitName("player") then -- quest is for another group member
			if not questType then
				questType = 2
			end
		else
			if isQuestText then
				local done, total = strmatch(progressText, '(%d+)/(%d+)')
				if done and total then
					local numLeft = total - done
					if numLeft > objectiveCount then -- track highest number of objectives
						objectiveCount = numLeft
					end
				else
					local progress = tonumber(strmatch(progressText, '([%d%.]+)%%')) -- tooltip actually contains progress %
					if progress and progress <= 100 then
						local questID = activeWorldQuests[ text ] -- not a guarantee
						local questType = 3
						return text, questType, ceil(100 - progress), questID
					end
				end

				-- 
				if not done or (done and total and done ~= total) then
					progressGlob = progressGlob and progressGlob .. '\n' .. progressText or progressText
				end
			elseif activeWorldQuests[text] then
				local questID = activeWorldQuests[ text ]
				local progress = C_TaskQuest.GetQuestProgressBarInfo(questID) -- or GetQuestProgressBarPercent(questID) -- not sure what the difference is between these functions
				if progress then
					local questType = 3 -- progress bar
					return text, questType, ceil(100 - progress), questID
				end
			elseif activeQuests[text] then
				questLogIndex = activeQuests[text]
			end
		end
	end
	
	return progressGlob, progressGlob and 1 or questType, objectiveCount, questLogIndex, questID
end

--================================================
-- Event handler for finding world quests
--================================================
local function CreateElement(self, event, nameplate, ...)
	self:UnregisterEvent('NAME_PLATE_CREATED', CreateElement, true)
	local element = self.QuestProgress

	-- if (not element.icon) then
		local icon = element:CreateTexture(nil, "OVERLAY")
		icon:SetPoint("CENTER")
		icon:SetSize(element:GetHeight(), element:GetHeight())
		element.icon = icon
	-- end

	-- if (not element.text) then
		local text = element:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
		text:SetPoint('CENTER', icon, 0, 0)
		text:SetShadowOffset(1, -1)
		-- text:SetAlpha(0)
		-- text:SetText(math.random(20))
		element.text = text
	-- end

	element:Show()

	-- local cooldown = CreateFrame("Cooldown", nil, element, "CooldownFrameTemplate")
	-- cooldown:SetAllPoints()
	-- cooldown:Show()
	-- cooldown:SetReverse(true)
	-- -- cooldown:SetCountdownFont(nil)
	-- -- cooldown:SetDisplayAsPercentage(4)
	-- local seconds = 100;	-- any number, really
	-- cooldown:Pause();
	-- cooldown:SetCooldown(GetTime() - seconds * 0.4, seconds);
	-- local text = cooldown:GetRegions()
	-- text:Hide()
	-- text.Show = text.Hide
	-- dump(cooldown)
end

-- return an plain text version of this type of quest
local function GetQuestType(questID, index, bool)
	local text, objectiveType, finished = GetQuestObjectiveInfo(questID, index, false)

	if (not text) then return false end

	if (not finished) then
		if (objectiveType == "item" or objectiveType == "object") then
			return "item"
		else
			return objectiveType
		end
	end
end

local function UpdateIcon(self, texture, key)
	local element = self.QuestProgress

	element.icon:SetTexCoord(unpack(texture[2]))
	if (texture[4] == "atlas") then
		element.icon:SetAtlas(texture[1])
	else
		element.icon:SetTexture(texture[1])	
	end
	element.icon:SetRotation(texture[3])
	if (texture[5]) then
		element.icon:SetSize(texture[5], texture[5])
	else
		element.icon:SetSize(element:GetHeight(), element:GetHeight())
	end

	if (element.PostUpdateButton) then
		element.PostUpdateButton(self, texture, key)
	end
end

local function Update(self, event, unit)
	unit = unit or self.unit
	if (unit ~= self.unit) then return end

	local element = self.QuestProgress

	-- sometimes some get missed
	if (not element.icon) then
		CreateElement(self)
	end

	-- don't show in raid, pvp, scenario
	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType ~= "none" and instanceType ~= "party")) then
		element:Hide()

		return
	end

	if (element.PreUpdate) then
		element:PreUpdate(unit)
	end

	-- unit quest information
	local progressGlob, questType, objectiveCount, questLogIndex, questID = QuestProgressByUnit(unit)

	-- don't show where there isn't a quest, or its a group member quest
	if not progressGlob or questType == 2 then
		element:Hide()
		if (element.PostHide) then
			element:PostHide(unit)
		end

		return
	end

	-- set basic text about the quest
	element:Show()
	element.text:SetText(progressGlob or '')
	
	if questType == 3 then -- progress type quest
		element.text:SetText(objectiveCount > 0 and objectiveCount or '?')
	else -- normal count type quest
		element.text:SetText(objectiveCount > 0 and objectiveCount or '?')
		if objectiveCount == 1 then
			element.text:SetText("")
		end
	end

	-- by default, let's say we kill everything
	local texture = textures["kill"]

	-- there is a usable item as part of this quest
	if questLogIndex then
		local link, itemTexture, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
		if link and itemTexture then
			texture = textures["item"]
			texture[1] = itemTexture

			UpdateIcon(self, texture, "item")
			return
		end
	end

	-- loop through quests
	if (questID) then
		for i = 1, 10 do
			local questType = GetQuestType(questID, i, false)
			if (questType == false) then break end

			if (questType == "item") then
				texture = textures["loot"]

				UpdateIcon(self, texture, "loot")
				return
			end
		end
	end
	if (questLogIndex) then
		local info = C_QuestLog.GetInfo(questLogIndex)
		for i = 1, GetNumQuestLeaderBoards(questLogIndex) or 0 do
			local questType = GetQuestType(info.questID, i, false)
			if (questType == "item") then
				texture = textures["loot"]

				UpdateIcon(self, texture, "loot")
				return
			end
		end
	end

	-- if we made it here, that means we kill this enemy
	UpdateIcon(self, texture, "kill")

	if (element.PostUpdate) then
		element:PostUpdate(unit, progressGlob, questType, objectiveCount, questLogIndex, questID)
	end
end

--================================================
-- Event handler for finding quests and storing them
--================================================
local function UpdateQuests(self, event, ...)
	wipe(activeQuests)

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do	
		local info = C_QuestLog.GetInfo(i)
		if (not info.isHeader) then
			activeQuests[info.title] = i
		end
	end
	
	-- Update(self)
end

local function UpdateWorldQuests(self, event, arg1, arg2)

	-- get all world quests
	if (event == "PLAYER_LOGIN" or event == "QUEST_WATCH_LIST_CHANGED") then
		local uiMapID = C_Map.GetBestMapForUnit('player')
		if not uiMapID then return end

		for k, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
			if task.inProgress then
				local questID = task.questId
				local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
				if questName then
					activeWorldQuests[ questName ] = questID
				end
			end
		end

	end


	if (event == "QUEST_ACCEPTED" or event == "QUEST_WATCH_LIST_CHANGED") then
		local questID = event == "QUEST_ACCEPTED" and arg2 or arg1

		-- update and add to world quests
		if questID and C_QuestLog.IsQuestTask(questID) then
			local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
			if questName then
				activeWorldQuests[ questName ] = questID
			end
		end
		Update(self)

		return
	end

	if (event == "QUEST_REMOVED") then
		local questID = arg1

		-- keep world quest list trim when things are removed
		local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
		if questName and activeWorldQuests[ questName ] then
			activeWorldQuests[ questName ] = nil
		end
		Update(self)

		return
	end

end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestProgress

	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_LOGIN', UpdateWorldQuests, true)
		self:RegisterEvent('QUEST_REMOVED', UpdateWorldQuests, true)
		self:RegisterEvent('QUEST_ACCEPTED', UpdateWorldQuests, true)
		self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', UpdateWorldQuests, true)
		
		self:RegisterEvent('PLAYER_ENTERING_WORLD', UpdateQuests)
		self:RegisterEvent('QUEST_LOG_UPDATE', UpdateQuests, true)
		
		-- self:RegisterEvent('NAME_PLATE_CREATED', CreateElement, true)

		self:RegisterEvent('QUEST_LOG_UPDATE', Update, true)
		self:RegisterEvent('NAME_PLATE_UNIT_ADDED', Update, true)
		
		element:Hide()

		return true
	end
end

local function Disable(self)
	local element = self.QuestProgress

	if(element) then
		self:UnregisterEvent('PLAYER_LOGIN', UpdateWorldQuests, true)
		self:UnregisterEvent('QUEST_REMOVED', UpdateWorldQuests, true)
		self:UnregisterEvent('QUEST_ACCEPTED', UpdateWorldQuests, true)
		self:UnregisterEvent('QUEST_WATCH_LIST_CHANGED', UpdateWorldQuests, true)
		
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', UpdateQuests)
		self:UnregisterEvent('QUEST_LOG_UPDATE', UpdateQuests, true)
		
		-- self:UnregisterEvent('NAME_PLATE_CREATED', CreateElement, true)

		self:UnregisterEvent('QUEST_LOG_UPDATE', Update, true)
		self:UnregisterEvent('NAME_PLATE_UNIT_ADDED', Update, true)
		
		element:Hide()
	end
end

oUF:AddElement('QuestProgress', Update, Enable, Disable)