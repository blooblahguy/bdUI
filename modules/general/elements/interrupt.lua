local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_interrupt()
	local interrupt = CreateFrame('frame')
	interrupt:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	local function OnEvent(self, event)
		if (not mod.config.interrupt ) then return end

		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, school, resisted, blocked, absorbed, critial, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()

		if (subevent ~= 'SPELL_INTERRUPT') then return end

		-- local inInstance, instanceType = IsInInstance()

		if (UnitExists(sourceName) and UnitIsUnit(sourceName, 'player') and inInstance and (instanceType == "party" or instanceType == "raid")) then
		-- if (UnitExists(sourceName) and UnitIsUnit(sourceName, 'player')) then
			local str = UnitName("player")..' interrupted ' .. (GetSpellLink(extraSpellID) or spellName)
			SendChatMessage(str, "SAY")
		end
	end

	interrupt:SetScript('OnEvent', OnEvent)
end
