local bdUI, c, l = unpack(select(2, ...))

local noop = function() return end
local noob = CreateFrame("frame", nil, UIParent)

--====================================================
-- VANILLA
--====================================================
bdUI.mobhealth = LibStub("LibClassicMobHealth-1.0")
-- mod health

-- classic spell durations
local UnitAura = _G.UnitAura
bdUI.spell_durations = LibStub("LibClassicDurations")
bdUI.spell_durations:Register("bdUI")
UnitAura = bdUI.spell_durations

-- globals
ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME or 0.4
