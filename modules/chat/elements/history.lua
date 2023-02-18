local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

-- event management
local reloadingUITime = 0
local history = CreateFrame("frame", nil)
history:RegisterEvent("PLAYER_LOGOUT")
history:RegisterEvent("LOADING_SCREEN_ENABLED")

function mod:create_history()
	-- ensure SVs
	BDUI_CHAT_HISTORY = BDUI_CHAT_HISTORY or {}
	BDUI_CHAT_HISTORY.lines = BDUI_CHAT_HISTORY.lines or {}
	BDUI_CHAT_HISTORY.savedChat = BDUI_CHAT_HISTORY.savedChat or {}

	-- if its not set then here are some defaults
	if not BDUI_CHAT_HISTORY.lines then BDUI_CHAT_HISTORY.lines = {["ChatFrame1"] = 1000} end
	for k, v in next, BDUI_CHAT_HISTORY.lines do
		local chatFrame = _G[k]
		chatFrame.historyBuffer.maxElements = v
	end

	-- we've loaded into the game with some saved chat lines
	if BDUI_CHAT_HISTORY.savedChat then
		for k, v in next, BDUI_CHAT_HISTORY.savedChat do
			local chatFrame = _G[k]
			if chatFrame then
				local buffer = chatFrame.historyBuffer
				local num = buffer.headIndex
				local prevElements = buffer.elements
				local curTime = GetTime()
				local restore = {}

				for i = 1, #v do
					local tbl = v[i]
					tbl.timestamp = curTime -- Update timestamp on restored chat. If it's really old, it will show as hidden after the reload.
					restore[#restore+1] = tbl
				end
				
				for i = 1, num do -- Restore any early chat we removed (usually addon prints)
					local element = prevElements[i]
					if element then -- Safety
						element.timestamp = curTime
						restore[#restore+1] = element
					end
				end

				buffer.headIndex = #restore
				for i = 1, #restore do
					prevElements[i] = restore[i]
					restore[i] = nil
				end
			end
		end
	end
	-- we're done, lets clear that saved variable
	BDUI_CHAT_HISTORY.savedChat = nil

	-- events
	history:SetScript("OnEvent", function(event, arg1)
		-- started reloading
		if (event == "LOADING_SCREEN_ENABLED") then
			reloadingUITime = GetTime()
			return
		end

		-- if (GetTime() - reloadingUITime) > 2 then return end

		-- started logging out
		BDUI_CHAT_HISTORY.savedChat = {}
		for index = 1, NUM_CHAT_WINDOWS do
			if index ~= 2 then -- No combat log
				local name = ("ChatFrame%d"):format(index)
				local chatFrame = _G[name]
				if chatFrame then
					local tbl = {1, 2, 3, 4, 5}
					local num = chatFrame.historyBuffer.headIndex
					local tblCount = 5
					for i = num, -10, -1 do
						if i > 0 then
							if type(chatFrame.historyBuffer.elements[i]) == "table" and chatFrame.historyBuffer.elements[i].message then -- Compensate for nil entries
								tbl[tblCount] = chatFrame.historyBuffer.elements[i]
								tblCount = tblCount - 1
								if tblCount == 0 then
									break
								end
							end
						else -- Compensate for less than 5 lines of history
							if tblCount > 0 then
								tremove(tbl, tblCount)
								tblCount = tblCount - 1
							else
								break
							end
						end
					end
					if #tbl > 0 then
						BDUI_CHAT_HISTORY.savedChat[name] = tbl
					end
				end
			end
		end
	end)
end