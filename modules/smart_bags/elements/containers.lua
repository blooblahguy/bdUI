local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

function mod:create_container(name)
	local frame = CreateFrame("frame", "bdBags_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	bdUI:set_backdrop(frame)

	frame:SetSize(500, 400)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetFrameStrata("HIGH")
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	if (name == "Bags") then
		frame:SetPoint("BOTTOMRIGHT", -20, 20)
	else
		frame:SetPoint("TOPLEFT", 20, -20)
	end
	frame:Hide()

	-- header
	local header = CreateFrame("frame", nil, frame)
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -mod.spacing / 2, -mod.spacing * 1.75)
	frame.header = header

	-- footer
	local footer = CreateFrame("frame", nil, frame)
	footer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
	footer:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	frame.footer = footer

	-- close
	local close_button = mod:create_button(header)
	close_button.text:SetText("X")
	close_button:SetPoint("RIGHT", header, "RIGHT", -4, 0)
	close_button.callback = function(self)
		frame:Hide()
	end

	-- sort
	local sort_bags = mod:create_button(header)
	sort_bags.text:SetText("S")
	sort_bags:SetPoint("RIGHT", close_button, "LEFT", -4, 0)
	if(name == "Bags") then
		sort_bags.callback = function() if (SortBags) then SortBags() else noop() end end
	elseif (name == "Bank") then
		sort_bags.callback = function() if (SortBankBags) then SortBankBags() else noop() end end
	end
	frame.sorter = sort_bags

	-- bags
	local bags_button = mod:create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags, "LEFT", -4, 0)
	bags_button.callback = function()
		self.bag_slots:SetShown(not self.bag_slots:IsShown())
	end

	-- money
	local money = mod:create_money(name, frame)
	money:SetPoint("LEFT", header, "LEFT", mod.spacing, -1)

	-- search
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", frame, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("LEFT", money, "RIGHT", 4, 1)
	searchBox:SetWidth(250)
	searchBox:SetFrameLevel(27)
	searchBox.Left:Hide()
	searchBox.Right:Hide()
	searchBox.Middle:Hide()
	local icon = _G[searchBox:GetName().."SearchIcon"]
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", searchBox,"LEFT", 4, -1)
	bdUI:set_backdrop(searchBox)
	searchBox._background:SetVertexColor(.06, .07, .09, 1)
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	-- function frame:update_size(width, height)
	-- 	if (frame.currencies) then
	-- 		frame:SetSize(width, height + header:GetHeight() + footer:GetHeight())
	-- 	else
	-- 		frame:SetSize(width, height + header:GetHeight() + 10)
	-- 	end
	-- end

	return frame
end