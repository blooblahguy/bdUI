local parent, ns = ...
local lib = ns.bdConfig

--=================================================================
-- REGISTER ELEMENTS & CONTAINERS
--=================================================================
lib.containers = {}
function lib:register_container(name, create)
	if (lib.containers[name]) then return end
	lib.containers[name] = function(options, parent, ...)
		local frame = create(options, parent, ...)
		frame._type = name
		frame._layout = "group"
		parent.last_frame = frame
		return frame
	end
end

lib.active_elements = {}
lib.elements = {}
function lib:register_element(name, create)
	if (lib.elements[name]) then return end

	lib.elements[name] = function(options, parent, ...)
		local frame = create(options, parent, ...)
		frame._type = name
		frame._layout = "element"
		parent.last_frame = frame

		-- print(name, options.key)

		lib.active_elements[options.key or name] = frame

		return frame
	end
end

--=================================================================
-- LAYOUT CONTAINERS
--=================================================================
function lib:create_container(options, parent, height)
	local padding = lib.dimensions.padding
	height = height or 30
	local sizes = {
		half = 0.5,
		third = 0.33,
		twothird = 0.66,
		full = 1
	}

	-- track row width
	local size = sizes[options.size or "full"]
	parent._row = parent._row or 0
	parent._row = parent._row + size

	local container = CreateFrame("frame", nil, parent)
	container:SetSize((parent:GetWidth() * size) - (padding * 2), height)
	-- TESTING : shows a background around each container for debugging
	-- container:SetBackdrop({bgFile = lib.media.flat})
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
		container:SetPoint("LEFT", parent._lastel, "RIGHT", padding, 0)
	end

	parent._lastel = container

	return container
end