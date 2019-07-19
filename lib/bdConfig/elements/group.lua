local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["add"] = function(self, frame)
		table.insert(self.children, frame)
		return frame
	end,
	["update"] = function(self, options, save)
		local height = self:calculate_height()
		self:SetHeight(height)
		return height
	end,
	["calculate_height"] = function(self)
		local height = mod.dimensions.padding

		for row, element in pairs(self.children) do
			if (element.children) then
				height = height + element:update() + mod.dimensions.padding
			elseif (element._isrow) then
				height = height + element:GetHeight() + mod.dimensions.padding
			end			
		end

		return height
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent, nobg)
	local padding = mod.dimensions.padding
	local yspace = padding

	-- Create Group Heading if it exists
	if (options.heading) then
		table.insert(parent.children, mod.elements['heading']({value = options.heading}, parent))
	end

	local group = mod:create_container(options, parent)
	group:SetSize(parent:GetWidth() - (padding * 2), 30)
	group.children = {}
	Mixin(group, methods)

	if (not nobg) then
		local border = mod:get_border(group)
		group:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = border})
		group:SetBackdropColor(0, 0, 0, 0.08)
		group:SetBackdropBorderColor(0, 0, 0, 0.15)
	end

	if (parent.last_frame) then
		group:SetPoint("TOPLEFT", parent.last_frame, "BOTTOMLEFT", 0, -yspace)
	else
		group:SetPoint("TOPLEFT", parent, "TOPLEFT", padding, -yspace)
	end

	return group
end

mod:register_container("group", create)