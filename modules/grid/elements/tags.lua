local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Grid")
local oUF = bdUI.oUF

mod.add_tags = function(self, unit)
	local config = mod:get_save()

	-- STATUS
	oUF.Tags.Events["bdGrid.status"] = "UNIT_HEALTH UNIT_CONNECTION"
	oUF.Tags.Methods["bdGrid.status"] = function(unit)
		if not UnitIsConnected(unit) then
			return "offline"		
		elseif UnitIsDead(unit) then
			return "dead"		
		elseif UnitIsGhost(unit) then
			return "ghost"
		end
	end
	

	-- NAME
	oUF.Tags.Events["bdGrid.short"] = "UNIT_NAME_UPDATE"
	oUF.Tags.Methods["bdGrid.short"] = function(unit)
		local name = UnitName(unit)
		if (not name) then return end
		-- if (bdUI.persistent.GridAliases[name]) then
		-- 	name = bdUI.persistent.GridAliases[name];
		-- end
		return string.utf8sub(name, 1, config.namewidth)
	end
	

	-- GROUP
	oUF.Tags.Events["bdGrid.group"] = "UNIT_NAME_UPDATE"
	oUF.Tags.Methods["bdGrid.group"] = function(unit)
		local name, server = UnitName(unit)
		if(server and server ~= '') then
			name = string.format('%s-%s', name, server)
		end
		
		for i = 1, GetNumGroupMembers() do
			local raidName, _, group = GetRaidRosterInfo(i)
			if( raidName == name ) then
				return "[" .. group .. "]"
			end
		end
	end

	-- Status (offline/dead)
	self.Status = self.name_holder:CreateFontString(nil)
	self.Status:SetFontObject(bdUI:get_font(12))
	self.Status:SetPoint('BOTTOMLEFT', self, "BOTTOMLEFT", 0, 0)
	
	-- shortname
	self.Short = self.name_holder:CreateFontString(nil, "OVERLAY")
	self.Short:SetFontObject(bdUI:get_font(12))
	self.Short:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0,0)
	self.Short:SetJustifyH("RIGHT")

	-- group number
	self.Group = self.name_holder:CreateFontString(nil)
	self.Group:SetFontObject(bdUI:get_font(12))
	self.Group:SetPoint('TOPRIGHT', self, "TOPRIGHT", -2, -2)
	self.Group:Hide()
	
	-- register tags
	self:Tag(self.Short, '[bdGrid.short]')
	self:Tag(self.Status, '[bdGrid.status]')
	self:Tag(self.Group, '[bdGrid.group]')
end