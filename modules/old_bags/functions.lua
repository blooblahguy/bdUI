--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:comma_value(amount)
	local formatted = amount
	while true do  
		formatted, k = gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function mod:killShowable(frame)
	if (not frame or not frame.Hide) then return end
	frame:Hide()
	frame.Show = function() return end
	frame.Hide = function() return end
	frame.SetAlpha = function() return end
	frame.SetTextColor = function() return end
	frame.SetVertexColor = function() return end
end