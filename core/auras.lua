local bdUI, c, l = unpack(select(2, ...))
-- aura functions will move here


-- for classic cooldown spirals
function bdUI:update_duration(cd_frame, unit, spellID, caster, name, duration, expiration)
	if (not bdUI.spell_durations or duration ~= 0 or expiration ~= 0) then
		return duration, expiration
	end

	local durationNew, expirationTimeNew = bdUI.spell_durations:GetAuraDurationByUnit(unit, spellID, caster, name)
	if duration == 0 and durationNew then
		duration = durationNew
		expirationTime = expirationTimeNew
	end

	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		cd_frame:SetCooldown(expirationTime - duration, duration)
		cd_frame:Show()
	else
		cd_frame:Hide()
	end

	return duration, expiration
end
