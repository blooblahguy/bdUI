local bdUI, c, l = unpack(select(2, ...))

--============================================
-- deDE
--============================================
local L = LibStub("AceLocale-3.0"):NewLocale("bdUI", "deDE")
if not (L) then return end

--===========================================
-- Commit to variable
--===========================================
local engine = select(2, ...)
engine[3] = LibStub("AceLocale-3.0"):GetLocale("bdUI")