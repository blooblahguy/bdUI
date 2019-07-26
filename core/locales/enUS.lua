local bdUI, c, l = unpack(select(2, ...))

--============================================
-- enUS
--============================================
local L = LibStub("AceLocale-3.0"):NewLocale("bdUI", "enUS", true)
L["LOAD_MSG"] = "bdUI Loaded. Enjoy."


--===========================================
-- Commit to variable
--===========================================
local engine = select(2, ...)
engine[3] = LibStub("AceLocale-3.0"):GetLocale("bdUI")