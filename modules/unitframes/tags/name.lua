local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

mod.tags.name = function(self, unit)
	if (self.Name) then return end

	self.Name = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Name:SetFontObject(bdUI:get_font(13, "THINOUTLINE"))
	oUF.Tags.Events["bdUI:name"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE PLAYER_TARGET_CHANGED"
	oUF.Tags.Methods["bdUI:name"] = function(unit, r)
		local name = UnitName(r or unit)
		local c = UnitClassification(r or unit)
		
		if(c == 'rare') then
			c = 'R'
		elseif(c == 'rareelite') then
			c = 'R+'
		elseif(c == 'elite') then
			c = '+'
		elseif(c == 'worldboss') then
			c = 'B'
		elseif(c == 'minus') then
			c = '-'
		else
			c = false
		end

		if (c) then
			return name.." |cffbbbbbb"..c.."|r" 
		else
			return name 
		end
	end	
	
	self:Tag(self.Name, '[bdUI:name]')
end