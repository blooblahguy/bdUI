local addonName, ns = ...
local bdUI, c, l = unpack(select(2, ...))

-- ouf
bdUI.oUF = ns.oUF

-- base libraries
bdUI.base64 = LibStub("LibBase64-1.0")
bdUI.shared = LibStub("LibSharedMedia-3.0")
LibStub("bdCallbacks-1.0"):New(bdUI)
LibStub("CallbackHandler-1.0"):New(bdUI)
bdMove = LibStub("bdMove-1.0")

LibStub("AceHook-3.0"):Embed(bdUI)

-- library initialization
if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
	bdUI.mobhealth = LibStub("LibClassicMobHealth-1.0")
end

-- Load bdConfig
ns.bdConfig.media.font = "Interface\\Addons\\"..addonName.."\\media\\PTSansNarrow.ttf"
ns.bdConfig.media.font_bold = "Interface\\Addons\\"..addonName.."\\media\\PTSansNarrow.ttf"
bdUI.bdConfig = ns.bdConfig:new("bdUI", "BDUI_SAVE", bdMove.toggle_lock)

-- set better fonts for libraries
bdMove.media.font = bdUI.media.font
bdUI.shared:Register("font", "PTSansNarrow (bdUI)", bdUI.media.font)