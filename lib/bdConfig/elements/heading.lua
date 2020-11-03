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
	options.size = options.size or "full"

	local container = lib:create_container(options, parent)
	container:SetHeight(lib.dimensions.header)
	container:SetBackdropColor(.8, .8, .8, 0)

	local heading = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	heading:SetText(string.upper(options.value))
	heading:SetAlpha(lib.media.muted)
	heading:SetJustifyH("LEFT")
	heading:SetJustifyV("MIDDLE")
	heading:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 4, 0)
	heading.border = container:CreateTexture(nil, "OVERLAY")
	heading.border:SetTexture(lib.media.flat)
	heading.border:SetVertexColor(1, 1, 1, 0.2)
	heading.border:SetHeight(lib.border)
	heading.border:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, -10)
	heading.border:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -10)

	container.value = options.value

	return container
end

lib:register_element("heading", create)