local addonName, addon = ...
local MAJOR, MINOR = "bdMove-1.0", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed

-- Load library support
local StickyFrames = LibStub("LibSimpleSticky-1.0")

LibStub("bdCallbacks-1.0"):New(lib)

--========================================================
-- Helpers
--========================================================
function IsMouseOverFrame(self)
	if MouseIsOver(self) then return true end
	if not SpellFlyout:IsShown() then return false end
	if not SpellFlyout.__faderParent then return false end
	if SpellFlyout.__faderParent == self and MouseIsOver(SpellFlyout) then return true end

	return false
end
local function GetQuadrant(frame)
	local x,y = frame:GetCenter()
	local hhalf = (x > UIParent:GetWidth()/2) and "RIGHT" or "LEFT"
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, vhalf, hhalf
end
noop = function() end

--========================================================
-- Defaults
--========================================================
lib.screenheight = select(2, GetPhysicalScreenSize())
lib.scale = 768 / lib.screenheight
lib.ui_scale = GetCVar("uiScale") or 1
lib.pixel = lib.scale / lib.ui_scale
lib.border = lib.pixel * 2

StickyFrames.rangeX = lib.border * 3
StickyFrames.rangeY = lib.border * 3

lib.moveable_frames = {}
lib.save = nil
lib.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	font = "fonts\\ARIALN.ttf",
	border = {.62, .17, .18, 0.6},
	backdrop = {.1, .1, .1, 0.6},
	arrow = "Interface\\Addons\\"..addonName.."\\media\\arrow.blp",
	align = "Interface\\Addons\\"..addonName.."\\media\\align.blp",
}

-- set savedvariable
function lib:set_save(sv)
	-- migrate over positions from last config
	if (lib.save and lib.save.positions and not sv.positions) then
		local last = lib.save.positions
		lib.save = sv
		lib.save.positions = lib.save.positions or {}
		Mixin(lib.save.positions, last)
	else
		lib.save = sv
		lib.save.positions = lib.save.positions or {}
	end

	for k, v in pairs(lib.moveable_frames) do
		v:position()
	end
end

--========================================================
-- Methods
--========================================================
local methods = {
	['unlock'] = function(self)
		self:SetAlpha(1)
		self.text:Show()
		self.locked = false
		self:EnableMouse(true)
		self:SetMovable(true)
		self:SetUserPlaced(false)
		self:RegisterForDrag("LeftButton")
		self:SetFrameStrata("TOOLTIP")
		self:SetScript("OnDragStart", function(self)
			StickyFrames:StartMoving(self, lib.moveable_frames, -lib.border, -lib.border, -lib.border, -lib.border)
		end)
		self:SetScript("OnDragStop", function(self)
			StickyFrames:StopMoving(self)
			StickyFrames:AnchorFrame(self)
		end)
	end,
	['save'] = function(self)
		-- save in saved variables
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		if (not relativeTo) then relativeTo = UIParent end
		relativeTo = relativeTo:GetName()

		lib.save.positions[self.rename] = {point, relativeTo, relativePoint, xOfs, yOfs}
	end,
	['lock'] = function(self)
		self:SetAlpha(0)
		self.text:Hide()
		self.locked = true
		self:EnableMouse(false)
		self:SetUserPlaced(false)
		self:SetMovable(false)
		self:SetFrameStrata("BACKGROUND")
		self:SetScript("OnDragStart", noop)
		self:SetScript("OnDragStop", noop)

		self:save()
	end,
	-- position save in saved variables (protects against lost positions during UI errors)
	['position'] = function(self)
		self:ClearAllPoints()
		local point, relativeTo, relativePoint, xOfs, yOfs = self.frame:GetPoint()
		relativeTo = _G[relativeTo] or relativeTo:GetName()
		
		-- set posiition from save
		if (lib.save.positions[self.rename]) then
			point, relativeTo, relativePoint, xOfs, yOfs = unpack(lib.save.positions[self.rename])
			relativeTo = _G[relativeTo]

			if (not point or not relativeTo or not relativePoint or not xOfs or not yOfs) then
				lib.save.positions[self.rename] = nil
				self:position()
			else
				self:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
			end
		else -- set position from initial frame position
			self:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
			lib.save.positions[self.rename] = {point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs)}
		end

		self.frame:ClearAllPoints()
		self.frame:SetPoint("CENTER", self, "CENTER", 0, 0)
	end
}

--========================================================
-- Mover
--========================================================
function lib:set_moveable(frame, rename, left, top, right, bottom)
	if (not lib.save) then print("lib needs SavedVariable to save positions. Use lib:set_save(sv_string)") return end
	rename = rename or frame:GetName()

	left = left or lib.border
	top = top or lib.border
	right = right or left or lib.border
	bottom = bottom or top or lib.border

	-- get dimensions
	local height = frame:GetHeight()
	local width = frame:GetWidth()
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	if (not relativeTo) then return end
	relativeTo = _G[relativeTo] or relativeTo:GetName()

	-- frame:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = lib.pixel})
	-- frame:SetBackdropColor(0,0.2,0,.4)

	-- Create Mover Parent
	local mover = CreateFrame("frame", rename, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	mover:EnableMouse(false)
	mover:SetSize(width + (right + left), height + (top + bottom))
	mover:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = lib.pixel})
	mover:SetBackdropColor(0,0,0,.6)
	mover:SetBackdropBorderColor(unpack(lib.media.border))
	mover:SetFrameStrata("BACKGROUND")
	mover:SetClampedToScreen(true)
	mover:SetAlpha(0)
	mover:EnableMouse(false)
	mover:SetMovable(false)
	mover.locked = true
	
	-- Text Label
	mover.text = mover:CreateFontString(mover:GetName().."_Text")
	mover.text:SetFont(lib.media.font, 14, "OUTLINE")
	mover.text:SetPoint("CENTER", mover, "CENTER", 0, 0)
	mover.text:SetText(rename)
	mover.text:SetJustifyH("CENTER")
	mover.text:SetAlpha(0.8)
	mover.text:Hide()	

	-- Sizing
	hooksecurefunc(frame, "SetSize", function() 
		local height = frame:GetHeight()
		local width = frame:GetWidth()
		mover:SetSize(width+2+lib.border, height+2+lib.border)
	end)

	-- Transfer Methods to this object
	frame.mover = mover
	mover.frame = frame
	mover.rename = rename
	Mixin(mover, methods)

	-- nudge controls
	mover:SetScript("OnEnter", function(self)
		lib:attach_controls(self)
	end)
	mover:SetScript("OnLeave", function(self)
		if (not MouseIsOver(lib.controls)) then
			lib.controls:Hide()
		end
	end)

	mover:RegisterEvent("PLAYER_ENTERING_WORLD")
	mover:SetScript("OnEvent", function()
		mover:EnableMouse(false)
		mover:SetMovable(false)
	end)

	-- position
	mover:position()

	table.insert(lib.moveable_frames, mover)
end

function lib:toggle_lock()
	if (lib.unlocked) then
		-- lock
		lib.unlocked = false
		lib.align:Hide()
		for k, frame in pairs(lib.moveable_frames) do
			frame:lock()
		end
	else
		if (InCombatLockdown()) then
			print("Moving not allowed in combat")
			return
		end
		-- unlock
		lib.unlocked = true
		lib.align:Show()
		for k, frame in pairs(lib.moveable_frames) do
			frame:unlock()
		end
	end
end

function lib:reset_positions()
	lib.save.positions = {}
end

--========================================================
-- Align Grid
--========================================================
lib.align = CreateFrame('Frame', nil, UIParent) 
lib.align:SetAllPoints(UIParent)
lib.align:Hide()
local grid_x = 32
local grid_y = 18
local w = GetScreenWidth() / grid_x
local h = GetScreenHeight() / grid_y
for i = 0, grid_x do
	local t = lib.align:CreateTexture(nil, 'BACKGROUND')
	if i == grid_x / 2 then
		t:SetColorTexture(unpack(lib.media.border))
	else
		t:SetColorTexture(1, 1, 1, 0.1)
	end
	t:SetPoint('TOPLEFT', lib.align, 'TOPLEFT', i * w - 1, 0)
	t:SetPoint('BOTTOMRIGHT', lib.align, 'BOTTOMLEFT', i * w + 1, 0)
end
for i = 0, grid_y do
	local t = lib.align:CreateTexture(nil, 'BACKGROUND')
	if i == grid_y / 2 then
		t:SetColorTexture(unpack(lib.media.border))
	else
		t:SetColorTexture(1, 1, 1, 0.15)
	end
	t:SetPoint('TOPLEFT', lib.align, 'TOPLEFT', 0, -i * h + 1)
	t:SetPoint('BOTTOMRIGHT', lib.align, 'TOPRIGHT', 0, -i * h - 1)
end

--========================================================
-- Controls
--========================================================
lib.controls = CreateFrame("frame", nil, bdParent)
lib.controls:SetPoint("CENTER", UIParent)
lib.controls:SetSize(110, 22)
lib.controls:SetFrameStrata("TOOLTIP")
lib.controls:SetFrameLevel(129)
lib.controls:Hide()
lib.controls:SetScript("OnLeave", function(self)
	if (MouseIsOver(self)) then return end
	if (not self._frame) then
		self:Hide()
	elseif (not MouseIsOver(self._frame)) then
		self:Hide()
	end
end)

local function create_nudge_button(moveX, moveY, callback)
	local controls = lib.controls
	moveX = moveX or 0
	moveY = moveY or 0

	local button = CreateFrame("button", nil, controls, BackdropTemplateMixin and "BackdropTemplate")
	button:SetSize(36, 36)
	button:SetBackdrop({bgFile = lib.media.flat})
	button:SetBackdropColor(0,0,0,1)
	button.controls = controls

	-- l, r, t, b
	button.tex = button:CreateTexture(nil, "OVERLAY")
	button.tex:SetTexture(lib.media.arrow)
	button.tex:SetPoint("CENTER")
	button.tex:SetSize(15, 15)
	button.tex:SetDesaturated(1)


	button:SetScript("OnEnter", function(self)
		self.tex:SetDesaturated(false)
	end)
	button:SetScript("OnLeave", function(self)
		self.tex:SetDesaturated(1)
	end)

	-- default callback
	callback = callback or function(self)
		local frame = self.controls._frame
		if (not frame) then print("no frame") return end
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		if (IsShiftKeyDown()) and IsControlKeyDown() then
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(moveX*20), yOfs+(moveY*20))
		elseif (IsShiftKeyDown()) then
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(moveX*5), yOfs+(moveY*5))
		else
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(moveX*1), yOfs+(moveY*1))
		end
		frame:save()
	end

	button:SetScript("OnClick", callback)

	-- automatically position
	if (controls.last) then
		button:SetPoint("LEFT", controls.last, "RIGHT", 2, 0)
	else
		button:SetPoint("LEFT", controls, "LEFT", 2, 0)
	end

	controls.last = button

	return button
end

-- left
lib.controls.left = create_nudge_button(-1, 0)
lib.controls.left.tex:SetRotation(3.14159)

-- up
lib.controls.up = create_nudge_button(0, 1)
lib.controls.up.tex:SetRotation(1.5708)

-- down
lib.controls.down = create_nudge_button(0, -1)
lib.controls.down.tex:SetRotation(-1.5708)

-- right
lib.controls.right = create_nudge_button(1, 0)
lib.controls.right.tex:SetRotation(0)

-- center horizontal
lib.controls.center_h = create_nudge_button(nil, nil, function(self)
	local frame = self.controls._frame
	if (not frame) then return end
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	local width, height = frame:GetSize()
	local s_width, s_height = GetScreenWidth(), GetScreenHeight()

	frame:ClearAllPoints()
	if (point == "LEFT" or point == "TOPLEFT" or point == "BOTTOMLEFT") then
		frame:SetPoint(point, UIParent, point, ((s_width / 2) - (width / 2)), yOfs)
	elseif (point == "CENTER" or point == "TOP" or point == "BOTTOM") then
		frame:SetPoint(point, UIParent, point, 0, yOfs)
	elseif (point == "RIGHT" or point == "TOPRIGHT" or point == "BOTTOMRIGHT") then
		frame:SetPoint(point, UIParent, point, -((s_width / 2) - (width / 2)), yOfs)
	end

	frame:save()
end)

lib.controls.center_h.tex:SetTexture(lib.media.align)
lib.controls.center_h.tex:SetRotation(1.5708)
lib.controls.center_h.tex:SetSize(18, 18)

-- center vertically
lib.controls.center_v = create_nudge_button(nil, nil, function(self)
	local frame = self.controls._frame
	if (not frame) then return end
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	local width, height = frame:GetSize()
	local s_width, s_height = GetScreenWidth(), GetScreenHeight()

	yOfs = ((s_height / 2) - (height / 2))

	frame:ClearAllPoints()
	if (point == "TOPLEFT" or point == "TOP" or point == "TOPRIGHT") then
		frame:SetPoint(point, UIParent, point, xOfs, -yOfs)
	elseif (point == "LEFT" or point == "CENTER" or point == "RIGHT") then
		frame:SetPoint(point, UIParent, point, xOfs, 0)
	elseif (point == "BOTTOMLEFT" or point == "BOTTOM" or point == "BOTTOMRIGHT") then
		frame:SetPoint(point, UIParent, point, xOfs, yOfs)
	end
	
	frame:save()
end)

lib.controls.center_v.tex:SetTexture(lib.media.align)
lib.controls.center_v.tex:SetSize(18, 18)

function lib:attach_controls(frame)
	if (frame.locked) then 
		lib.controls:Hide()
		return
	end

	local quad, y, h = GetQuadrant(frame)
	lib.controls._frame = frame
	lib.controls:Show()
	lib.controls:ClearAllPoints()
	if (y == "TOP") then
		lib.controls:SetPoint("TOP", frame, "BOTTOM", 0, 0)
	else
		lib.controls:SetPoint("BOTTOM", frame, "TOP", 0, 0)
	end
end


--========================================================
-- Frames / Faders
-- lib:CreateFader(frame, children, inAlpha, outAlpha, duration)
--========================================================
-- fade out animation, basically mirrors itself onto the given frame
local function CreateFaderAnimation(frame)
	local animFrame = CreateFrame("Frame", nil, frame)
	frame.fader = animFrame:CreateAnimationGroup()
	frame.fader.__owner = frame
	frame.fader.__animFrame = animFrame
	frame.fader.anim = frame.fader:CreateAnimation("Alpha")
	frame.fader:HookScript("OnFinished", function(self)
		self.__owner:SetAlpha(self.finAlpha)
	end)
	frame.fader:HookScript("OnUpdate", function(self)
		self.__owner:SetAlpha(self.__animFrame:GetAlpha())
	end)
end

-- fade in animation
local function StartFadeIn(frame)
	if (not IsMouseOverFrame(frame)) then return end
	if (not frame.enableFader) then return end
	if (frame.fader.direction == "in") then return end
	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.outAlpha)
	frame.fader.anim:SetToAlpha(frame.inAlpha)
	frame.fader.anim:SetDuration(frame.duration)
	frame.fader.anim:SetSmoothing("OUT")
	frame.fader.anim:SetStartDelay(0)
	frame.fader.finAlpha = frame.inAlpha
	frame.fader.direction = "in"
	frame.fader:Play()
end

-- fade out animation
local function StartFadeOut(frame)
	if (not frame.enableFader) then return end
	if (frame.fader.direction == "out") then return end
	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.inAlpha)
	frame.fader.anim:SetToAlpha(frame.outAlpha)
	frame.fader.anim:SetDuration(frame.duration)
	frame.fader.anim:SetSmoothing("OUT")
	frame.fader.anim:SetStartDelay(0)
	frame.fader.finAlpha = frame.outAlpha
	frame.fader.direction = "out"
	frame.fader:Play()
end

local function EnterLeaveHandle(self)
	if (self.__faderParent) then
		self = self.__faderParent
	end

	if IsMouseOverFrame(self) then
		StartFadeIn(self)
	else
		StartFadeOut(self)
	end
end

-- Allows us to mouseover show a frame, with animation
function lib:CreateFader(frame, children, inAlpha, outAlpha, duration)
	if (frame.fader) then return end

	-- set variables
	frame.inAlpha = inAlpha or 1
	frame.outAlpha = outAlpha or 0
	frame.duration = duration or 0.2
	frame.enableFader = true
	frame:SetAlpha(frame.outAlpha)

	-- Create Animation Frame
	CreateFaderAnimation(frame)

	-- Hook Events / Listeners
	frame:EnableMouse(true)
	frame:HookScript("OnEnter", EnterLeaveHandle)
    frame:HookScript("OnLeave", EnterLeaveHandle)

	-- Hook all animation into these events
	frame:HookScript("OnShow", StartFadeIn)
	frame:HookScript("OnHide", StartFadeOut)

	-- Hook Children
	for i, button in next, children do
		if not button.__faderParent then
			button.__faderParent = frame
			button:HookScript("OnEnter", EnterLeaveHandle)
			button:HookScript("OnLeave", EnterLeaveHandle)
		end
  	end
end

-- Allows us to track is mouse is over SpellFlyout child
local function SpellFlyoutHook(self)
	local topParent = self:GetParent():GetParent():GetParent()
	if (not topParent.__fader) then return end

	-- toplevel
	if (not self.__faderParent) then
		self.__faderParent = topParent
		self:HookScript("OnEnter", EnterLeaveHandle)
    	self:HookScript("OnLeave", EnterLeaveHandle)
	end

	-- children
	for i=1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["SpellFlyoutButton"..i]
		if not button then break end

		if not button.__faderParent then
			button.__faderParent = topParent
			button:HookScript("OnEnter", EnterLeaveHandle)
			button:HookScript("OnLeave", EnterLeaveHandle)
		end
	end
end
-- classic doesn't have SpellFlyout?
if (SpellFlyout) then
	SpellFlyout:HookScript("OnShow", SpellFlyoutHook)
end