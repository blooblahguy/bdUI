local addonName, ns = ...
local mod = ns.bdConfig

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
	options.size = options.size or "full"

	local container = mod:create_container(options, parent)
	container:SetHeight(20)
	container:SetBackdropColor(.8, .8, .8, 0)

	local heading = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	heading:SetText(options.value)
	heading:SetAlpha(1)
	heading:SetScale(1.1)
	heading:SetTextColor(unpack(mod.media.primary))
	heading:SetAlpha(0.8)
	heading:SetJustifyH("LEFT")
	heading:SetJustifyV("MIDDLE")
	heading:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 4, 0)

	container.value = options.value

	return container
end

mod:register_element("heading", create)