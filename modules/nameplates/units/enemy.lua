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
	
	if (self.currentStyle and self.currentStyle == "enemy") then return end
	self.currentStyle = "enemy"

	-- elements
	self:EnableElement("Auras")
	self:EnableElement("Castbar")
	self:EnableElement("FixateAlert")

	-- auras
	self.Name:SetTextColor(1,1,1)

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