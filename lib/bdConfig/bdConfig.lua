--[[












]]

local addonName, ns = ...
local mod = ns.bdConfig

--=================================================================
-- REGISTER ADDON
--=================================================================
function mod:register(name, saved_variables_string, lock_toggle)
	local instance = {}

	instance._ns = name
	instance._modules = {}
	instance._window = mod:create_windows(name, lock_toggle)
	instance.save = mod:initialize_saved_variables(saved_variables_string)



	-- show config window toggle
	function instance:toggle()
		if (self._window:IsShown()) then
			self._window:Hide()
		else
			self._window:Show()
			self._default:select()
		end
	end

	--========================================
	-- Called by individual modules/addons
	--========================================
	function instance:register_module(name, config, callback)
		local module = mod:create_module(instance, name)
		module._config = config
		module._containers = {}

		--========================================
		-- Recursively build config
		--========================================
		function module:build(config, name, parent)
			instance.save[name] = instance.save[name] or {}
			local sv = instance.save[name]

			-- loop through options
			for option, info in pairs(config) do
				mod:ensure_value(sv, info.key, info.value) -- initiate sv default
				local group = parent

				-- frame build here
				info.save = sv
				info.module = name
				info.callback = callback or noop
				local group = parent

				-- container group
				if (mod.containers[info.type]) then
					group = group:add(mod.containers[info.type](info, group))
				elseif (mod.elements[info.type]) then
					group:add(mod.elements[info.type](info, group))
				else
					mod:debug("No module found for", info.type, "for", info.key)
				end

				-- recursive call
				if (info.args) then
					module:build(info.args, name, group)
				end

				parent.last_frame = group
			end
		end

		-- call recursive build function
		local group = mod.containers["group"]({}, module, true)
		-- group:SetBackdrop({bgFile = mod.media.flat})
		-- group:SetBackdropColor(0, 1, 0, 0.08)
		group.scroller = module
		module:build(config, name, group)
		group:update()

		-- return configuration reference
		return instance.save[name]
	end

	-- debug - show configuration window
	bdUI:add_action("post_loaded", function()
		instance:toggle()
	end)

	-- returns instance to be called
	return instance
end

--=================================================================
-- ELEMENTS & CONTAINERS
--=================================================================
mod.containers = {}
function mod:register_container(name, create)
	if (mod.containers[name]) then return end
	mod.containers[name] = function(config, parent, ...)
		local frame = create(config, parent, ...)
		frame._type = name
		frame._layout = "group"
		parent.last_frame = frame
		return frame
	end
end

mod.elements = {}
function mod:register_element(name, create)
	if (mod.elements[name]) then return end
	mod.elements[name] = function(config, parent, ...)
		local frame = create(config, parent, ...)
		frame._type = name
		frame._layout = "element"
		parent.last_frame = frame
		return frame
	end
end

--=================================================================
-- LAYOUT FRAMES
--=================================================================

function mod:create_container(options, parent, height)
	local padding = mod.dimensions.padding
	height = height or 30
	local sizes = {
		half = 0.5,
		third = 0.33,
		twothird = 0.66,
		full = 1
	}

	-- track row width
	size = sizes[options.size or "full"]
	parent._row = parent._row or 0
	parent._row = parent._row + size

	local container = CreateFrame("frame", nil, parent)
	container:SetSize((parent:GetWidth() * size) - (padding * 1.5), height)
	-- TESTING : shows a background around each container for debugging
	-- container:SetBackdrop({bgFile = mod.media.flat})
	-- container:SetBackdropColor(.1, .8, .2, 0.1)

	if (parent._row > 1 or not parent._lastel) then
		-- new or first row
		parent._row = size
		container._isrow = true

		if (not parent._rowel and parent.last_frame) then
			-- first, but next to group or element
			container:SetPoint("TOPLEFT", parent.last_frame, "BOTTOMLEFT", 0, -padding)
			parent._rowel = container
		elseif (not parent._rowel) then
			-- first element
			container:SetPoint("TOPLEFT", parent, "TOPLEFT", padding, -padding)
			parent._rowel = container
		else
			-- new row
			container:SetPoint("TOPLEFT", parent._rowel, "BOTTOMLEFT", 0, -padding)
			parent._rowel = container
		end
	else
		-- same row
		local height = container:GetHeight()
		local lastheight = parent._lastel:GetHeight()
		local idealheight = math.max(height, lastheight)
		container:SetHeight(idealheight)
		parent._lastel:SetHeight(idealheight)
		-- print(height, lastheight)
		-- if (height < lastheight) then
		-- end
		container:SetPoint("LEFT", parent._lastel, "RIGHT", padding, 0)
	end

	parent._lastel = container

	return container
end