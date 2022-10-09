local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")
local config

mod.enemy_style = function(self, event, unit)
	config = mod.config

	-- names
	self.Name:Show()
	if (config.hideEnemyNames == "Always Hide") then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Only Target" and not self.isTarget) then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Hide in Arena") then
		local inInstance, instanceType = IsInInstance();
		if (inInstance and instanceType == "arena") then
			self.Name:Hide()
		end
	end
	self.Name:SetTextColor(1,1,1)
	self.Name:ClearAllPoints()
	if (config.name_position == "Inside" and self.currentStyle == "enemy") then
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	else
		self.Name:SetPoint("BOTTOM", self, "TOP", 0, config.name_offset)
	end
	
	if (self.currentStyle and self.currentStyle == "enemy") then return end
	self.currentStyle = "enemy"

	-- elements
	self:EnableElement("Buffs")
	self:EnableElement("Debuffs")
	self:EnableElement("Castbar")
	if (config.enablequests) then
		self:EnableElement("QuestProgress")
	else
		self:DisableElement("QuestProgress")
		self.Name:SetTextColor(1, 1, 1)
	end
	self:EnableElement("FixateAlert")

	

	-- castbars
	self.Castbar:ClearAllPoints()
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI:get_border(self.Castbar))
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()

	if (config.fixatealert == "None") then
		self:DisableElement("FixateAlert")
	else
		self:EnableElement("FixateAlert")
	end

	-- on target callback
	self.OnTarget = function(self, event, unit)
		if (config.showenergy) then
			self.Curpower:Show()
		else
			self.Curpower:Hide()
		end

		if (config.showhptexttargetonly and not self.isTarget) then
			self.Curpower:Hide()
			self.Curhp:Hide()
			return
		end
		if (config.hptext == "None") then
			self.Curhp:Hide()
			return
		end

		self.Curhp:Show()
	end
end