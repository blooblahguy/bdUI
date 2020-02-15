local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_interrupt()
	local interrupt = CreateFrame('frame')
	interrupt:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	local function OnEvent(self, event)
		if (not mod.config.interrupt ) then return end

		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, school, resisted, blocked, absorbed, critial, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()

		if (subevent ~= 'SPELL_INTERRUPT') then return end

		if (UnitExists(sourceName) and UnitIsUnit(sourceName, 'player')) then
			SendChatMessage(UnitName("player")..' interrupted ' .. GetSpellLink(extraSpellID), channel)
		end
	end

	interrupt:SetScript('OnEvent', OnEvent)
end