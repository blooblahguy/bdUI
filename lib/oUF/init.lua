local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

local _, _, _, toc = GetBuildInfo()

ns.oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
ns.oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.oUF.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
ns.oUF.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
