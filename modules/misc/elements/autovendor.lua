local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Misc")

local delete_panel = StaticPopupDialogs["DELETE_GOOD_ITEM"]

local function prefill_text(box)
	box.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end

hooksecurefunc(delete_panel, "OnShow", prefill_text)