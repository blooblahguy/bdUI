local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables
local gcd = 1.5
local colors = {
	["normal"] = {1, 1, 1},
	["red"] = {0.8, 0.1, 0.1},
	["yellow"] = {0.9, 0.9, 0.1},
	["blue"] = {0.1, 0.1, 0.9},
}

local function style_cooldown(self, button, start, duration)
	local progress = start + duration - GetTime()
	local icon = _G[button:GetName().."Icon"]

	-- print("cooldown style", button:GetName(), self.duration, progress, gcd)

	-- figure out text color
	local color = colors["normal"]
	if (progress >= 5) then
		color = colors['yellow']
	-- elseif (progress >= gcd) then
	else
		color = colors['red']
	end
	self:GetRegions():SetTextColor(unpack(color))

	-- grey out the icon if needed
	if (progress <= gcd) then
		icon:SetDesaturated(false)
	else
		icon:SetDesaturated(true)
	end
end

function mod:cooldown_on_update(self, elapsed)
	if (self.duration <= gcd) then return end
	self.total = self.total + elapsed
	if (self.total > 0.1) then
		self.total = 0
		style_cooldown(self, self:GetParent(), self.start, self.duration)
	end
end

-- each cooldown button calls this when their cooldown is set
function mod:hook_cooldown(start, duration)
	-- store this info for the on_update
	self.total = 0
	self.start = start
	self.duration = duration

	-- store the GCD
	if (duration <= 1.5) then
		gcd = duration
	end

	style_cooldown(self, self:GetParent(), start, duration)
end