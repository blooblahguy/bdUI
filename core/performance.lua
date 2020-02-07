local bdUI, c, l = unpack(select(2, ...))
bdUI.profile_data = {}

local developer_names = {}
developer_names["Padder"] = true
developer_names["Nodis"] = true
developer_names["Bloo"] = true
developer_names["Redh"] = true
local developer = developer_names[UnitName("player")]
local debug_performance = 0
-- 3 = granular level functions
-- 2 = mid level functions
-- 1 = high level functions
-- 0 = disabled

function bdUI:profile_start(category, name, level)
	bdUI.profile_data[category] = bdUI.profile_data[category] or {}
	bdUI.profile_data[category][level] = bdUI.profile_data[category][level] or {}
	bdUI.profile_data[category][level][name] = debugprofilestop()
end

function bdUI:profile_stop(category, name, level)
	local complete = debugprofilestop() - bdUI.profile_data[category][level][name]
	bdUI.profile_data[category][level][name] = nil
	if (debug_performance >= level or complete > 5) then
		if (complete > 5 and developer) then
			print("WARNING", category, name, "completed in", complete)
		else
			print(category, name, "completed in", complete)
		end
	end
end