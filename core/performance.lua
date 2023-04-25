local bdUI, c, l = unpack(select(2, ...))
bdUI.profile_data = {}

local developer_names = {}
developer_names["Padder"] = true
developer_names["Nodis"] = true
developer_names["Bloo"] = true
developer_names["Redh"] = true
developer_names["Bloobank"] = true
developer_names["Update"] = true
developer_names["Updk"] = true
developer_names["Ifthen"] = true
local developer = developer_names[UnitName("player")]
local debug_performance = 0
-- 3 = granular level functions
-- 2 = mid level functions
-- 1 = high level functions
-- 0 = disabled
-- if (developer) then
-- 	debug_performance = 1
-- end

function bdUI:profile_start(name, level)
	if (debug_performance == 0) then return end
	debugprofilestart()
	level = level or 1
	bdUI.profile_data = bdUI.profile_data or {}
	bdUI.profile_data[level] = bdUI.profile_data[level] or {}
	bdUI.profile_data[level][name] = 0
end

function bdUI:profile_stop(name, level)
	if (debug_performance == 0) then return end
	level = level or 1
	local complete = debugprofilestop() - bdUI.profile_data[level][name]
	bdUI.profile_data[level][name] = nil
	if (debug_performance >= level or (complete > 10 and developer)) then
		if (complete > 10) then
			print("|cffFF0000WARNING|r", name, "completed in", complete)
		else
			print(name, "completed in", complete)
		end
	end
end