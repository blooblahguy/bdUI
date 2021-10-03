local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

local developer_names = {}
developer_names["Padder"] = true
developer_names["Nodis"] = true
developer_names["Bloo"] = true
developer_names["Redh"] = true
developer_names["Update"] = true
local developer = developer_names[select(1, UnitName("player"))]

local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable Smart Bag Code (in beta)",
		value = false,
	},
	{
		key = "dbgroup",
		type = "group",
		heading = "Bags",
		args = {
			{
				key = "buttonsize",
				type = "range",
				label = "Bag Buttons Size",
				value = 36,
				step = 2,
				min = 20,
				max = 40,
			},
			{
				key = "buttonsperrow",
				type = "range",
				value = 16,
				min = 8,
				max = 30,
				step = 1,
				label = "Bag Buttons Per Row",
			},
		},
	},

	{
		key = "dbgroup",
		type = "group",
		heading = "Bank",
		args = {
			{
				key = "bankbuttonsize",
				type = "range",
				label = "Bank Buttons Size",
				value = 32,
				step = 2,
				min = 20,
				max = 40,
			},
			{
				key = "bankbuttonsperrow",
				type = "range",
				value = 16,
				min = 8,
				max = 30,
				step = 1,
				label = "Bank Buttons Per Row",
			},
		},
	},
}

local hide = true
if (developer) then 
	hide = false
end

local mod = bdUI:register_module("Smart Bags (beta)", config, {
	hide_ui = hide
})

function mod:initialize()
	mod.config = mod:get_save()

	GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
		local _, link = tooltip:GetItem()
		if not link then return end
		
		local itemString = string.match(link, "item[%-?%d:]+")
		local _, itemId = strsplit(":", itemString)

		local name, link, rarity, ilvl, minlevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)

		local lcolor = {0.6, 0.6, 0.6}
		local rcolor = {1, 1, 1}

		-- print(GetItemInfo(link))

		-- local itemType = 
		tooltip:AddDoubleLine("itemId", itemId, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("itemType", itemType, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("itemSubType", itemSubType, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("ilvl", ilvl, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("minlevel", minlevel, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("itemEquipLoc", itemEquipLoc, unpack(lcolor), unpack(rcolor))
		tooltip:AddDoubleLine("itemId", itemId, unpack(lcolor), unpack(rcolor))
	end)
end