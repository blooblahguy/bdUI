local bdUI, c, l = unpack(select(2, ...))

--============================================
-- enUS
--============================================
local L = LibStub("AceLocale-3.0"):NewLocale("bdUI", "enUS", true)
L["loaded"] = "Loaded Enjoy! /bdui for options"
L["reload ui"] = "Reload UI"
L["lock"] = "Lock"
L["unlock"] = "Unlock"

--===========================================
-- Commit to variable
--===========================================
local engine = select(2, ...)
engine[3] = LibStub("AceLocale-3.0"):GetLocale("bdUI")