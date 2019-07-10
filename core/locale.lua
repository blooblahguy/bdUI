local bdUI, c, l = unpack(select(2, ...))

--============================================
-- enUS
--============================================
local L = LibStub("AceLocale-3.0"):NewLocale("bdUI", "enUS", true)
L["LOAD_MSG"] = "bdUI Loaded. Enjoy."

--============================================
-- deDE
--============================================
local L = LibStub("AceLocale-3.0"):NewLocale("bdUI", "deDE")
if (L) then

end



--===========================================
-- Commit to variable
--===========================================
local engine = select(2, ...)
engine[3] = LibStub("AceLocale-3.0"):GetLocale("bdUI")