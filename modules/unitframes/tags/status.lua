local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

mod.tags.status = function(self, unit)
	if (self.Status) then return end

	self.Status = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Status:SetFontObject(bdUI:get_font(10))
	self.Status:SetAlpha(0.7)
	self.Status:SetPoint("CENTER", self.TextHolder)
	oUF.Tags.Events["bdUI:status"] = "PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_UPDATE_RESTING UNIT_HEALTH UNIT_CONNECTION"
	oUF.Tags.Methods["bdUI:status"] = function(unit)
		local config = mod:get_save()
		local size = math.restrict(config.playertargetheight * 0.75, 8, config.playertargetheight)

		if(UnitIsDead(unit)) then
			return 'Dead'
		elseif(UnitIsGhost(unit)) then
			return 'Ghost'
		elseif(not UnitIsConnected(unit)) then
			return 'Offline'
		elseif (unit == "player" and UnitAffectingCombat(unit)) then
			size = math.restrict(config.playertargetheight * 0.85, 8, config.playertargetheight)

			local fileWidth = 100
			local fileHeight = 100
			local width = size
			local height = size
			local left = 0.5
			local right = 1
			local top = 0
			local bottom = 0.49
			local xoffset = 0
			local yoffset = 0

			local texture = CreateTextureMarkup("Interface\\CharacterFrame\\UI-StateIcon", fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)

			return texture
			-- return "z"
		elseif (unit == "player" and IsResting()) then
			local fileWidth = 100
			local fileHeight = 100
			local width = size
			local height = size
			local left = 0
			local right = 0.5
			local top = 0
			local bottom = 0.421875
			local xoffset = 0
			local yoffset = 0

			local texture = CreateTextureMarkup("Interface\\CharacterFrame\\UI-StateIcon", fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)

			return texture
		end

		return ""
	end
	self:Tag(self.Status, '[bdUI:status]')
end