local addonName, ns = ...
ns.bdConfig = {}
local mod = ns.bdConfig
mod.callback = LibStub("CallbackHandler-1.0"):New(mod, "Register", "Unregister", "UnregisterAll")

-- Developer functions
function mod:noop() return end
function mod:debug(...) print("|cffA02C2FbdConfig|r:", ...) end
function mod:round(num, idp) local mult = 10^(idp or 0) return floor(num * mult + 0.5) / mult end