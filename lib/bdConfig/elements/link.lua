local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, options, save)

	end,
	["get"] = function(self, options, save)

	end,
	["onchange"] = function(self, options, save)

	end,
	["onclick"] = function(self, options, save)
		
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local media = lib.media
	local border = media.border_size
	local link
	local container

	if (options.solo) then
		link = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	else
		container = lib:create_container(options, parent, 28)
		link = CreateFrame("button", nil, container, BackdropTemplateMixin and "BackdropTemplate")
		link:SetPoint("LEFT", container, "LEFT")
	end


	local color = options.color or media.blue
	local br, bg, bb, ba = unpack(color)

	link.activeColor = color
	link.inactiveColor = {br, bg, bb, .1}
	link.callback = options.callback or lib.noop
	link.save = options.save
	link.key = options.key
	-- link.activeAlpha = 1
	-- link.hoverAlpha = 0.8
	-- link.inactiveAlpha = 0.5
	link:SetBackdrop({bgFile = media.flat, edgeFile = media.flat, edgeSize = lib.border})

	-- shadow
	lib:create_shadow(link, 10)
	link._shadow:SetColor(1, 1, 1, .1)

	-- text
	link.text = link:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	link.text:SetPoint("CENTER")
	link.text:SetJustifyH("CENTER")
	link.text:SetJustifyV("MIDDLE")
	function link:GetText()
		return link.text:GetText()
	end
	function link:SetText(text)
		link.text:SetText(text)
		link:SetWidth(link.text:GetStringWidth() + 30)
	end
	
	-- color
	link:SetBackdropColor(unpack(link.inactiveColor))
	link:SetBackdropBorderColor(unpack(color))
	link:SetHeight(30)
	link:EnableMouse(true)

	function link:OnEnter()
		link:SetBackdropColor(unpack(link.activeColor))
	end

	function link:OnLeave()
		link:SetBackdropColor(unpack(link.inactiveColor))
	end

	function link:OnClickDefault()
		if (link.OnClick) then link.OnClick(link) end
		if (link.autoToggle) then
			if (link.active) then
				link.active = false
			else
				link.active = true
			end
		end

		link:OnLeave()

		link:callback(link, options)
	end
	
	link:SetScript("OnEnter", link.OnEnter)
	link:SetScript("OnLeave", link.OnLeave)
	link:SetScript("OnClick", link.OnClickDefault)

	link:OnLeave()
	link:SetText(options.value or options.label)

	if (options.solo) then
		return link
	else
		container.link = link
		return container
	end
end

lib:register_element("link", create)