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
local function IsMouseOverFrame(self)
	if MouseIsOver(self) then return true end
	if not SpellFlyout or not SpellFlyout:IsShown() then return false end
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

lib.movers = {}
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

	for k, v in pairs(lib.movers) do
		v:position()
	end
end

--========================================================
-- Bumper
--========================================================
local bumper = CreateFrame("frame", "bdMoveBumper", UIParent, BackdropTemplateMixin and "BackdropTemplate")
bumper:SetSize(114, 20)
bumper:SetFrameStrata("TOOLTIP")
bumper:SetFrameLevel(129)
bumper:SetPoint("CENTER", UIParent, "CENTER")
bumper:SetBackdrop({bgFile = lib.media.flat})
bumper:SetBackdropColor(unpack(lib.media.border))
bumper:Hide()
lib.bumper = bumper

local buttons = {"Left", "Right", "Up", "Down", "CenterH", "CenterY"}
for i = 1, #buttons do
	local name = buttons[i]

	local button = CreateFrame("button", nil, bumper, BackdropTemplateMixin and "BackdropTemplate")
	button:SetSize(18, 18)
	button:SetBackdrop({bgFile = lib.media.flat})
	button:SetBackdropColor(0, 0, 0, 1)
	button.bumper = bumper

	-- l, r, t, b
	button.tex = button:CreateTexture(nil, "OVERLAY")
	button.tex:SetTexture(lib.media.arrow)
	button.tex:SetPoint("CENTER")
	button.tex:SetSize(button:GetWidth() * 0.7, button:GetHeight() * 0.7)
	button.tex:SetDesaturated(1)

	-- default callback
	button.callback = function(self)
		local frame = self.bumper.frame

		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		if (IsShiftKeyDown()) and IsControlKeyDown() then
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(self.moveX*20), yOfs+(self.moveY*20))
		elseif (IsShiftKeyDown()) then
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(self.moveX*10), yOfs+(self.moveY*10))
		else
			frame:SetPoint(point, relativeTo, relativePoint, xOfs+(self.moveX*1), yOfs+(self.moveY*1))
		end

		frame:save()
	end

	button:SetScript("OnEnter", function(self)
		self.tex:SetDesaturated(false)
	end)
	button:SetScript("OnLeave", function(self)
		self.tex:SetDesaturated(1)
	end)
	button:SetScript("OnClick", function(self)
		button.callback(self)
	end)

	-- automatically position
	if (bumper.last) then
		button:SetPoint("LEFT", bumper.last, "RIGHT", lib.pixel, 0)
	else
		button:SetPoint("LEFT", bumper, "LEFT", lib.pixel, 0)
	end

	bumper.last = button
	bumper[name] = button
end

-- left
bumper.Left.moveX = -1
bumper.Left.moveY = 0
bumper.Left.tex:SetRotation(3.14159)

-- right
bumper.Right.moveX = 1
bumper.Right.moveY = 0

-- up
bumper.Up.moveX = 0
bumper.Up.moveY = 1
bumper.Up.tex:SetRotation(1.5708)

-- down
bumper.Down.moveX = 0
bumper.Down.moveY = -1
bumper.Down.tex:SetRotation(-1.5708)

-- center horizontal
bumper.CenterH.tex:SetTexture(lib.media.align)
bumper.CenterH.tex:SetRotation(1.5708)
bumper.CenterH.callback = function(self)
	local frame = bumper.frame
	-- print(frame, self, bumper)
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
end

-- center vertically
bumper.CenterY.tex:SetTexture(lib.media.align)
bumper.CenterY = function(self)
	local frame = bumper.frame
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
end


--========================================================
-- Mover
--========================================================
function lib:set_moveable(frame, rename, left, top, right, bottom)
	if (not lib.save) then print("lib needs SavedVariable to save positions. Use lib:set_save(sv_string)") return end
	-- has it been positioned?
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	if (not relativeTo) then return end

	-- get variables
	local height = frame:GetHeight()
	local width = frame:GetWidth()
	rename = rename or frame:GetName()
	left = left or lib.border
	top = top or lib.border
	right = right or left or lib.border
	bottom = bottom or top or lib.border
	relativeTo = _G[relativeTo] or relativeTo:GetName()

	-- Create Mover Parent
	local mover = CreateFrame("Button", rename, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	mover:SetSize(width + (right + left), height + (top + bottom))
	mover:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = lib.pixel})
	mover:SetBackdropColor(0, 0, 0, .3)
	mover:SetBackdropBorderColor(0, 0, 0, 0)
	mover:SetFrameStrata("BACKGROUND")
	mover:SetClampedToScreen(true)
	mover:SetAlpha(0)
	mover:EnableMouse(false)
	mover:SetMovable(false)
	mover.locked = true
	mover.selected = false
	
	-- Text Label
	mover.text = mover:CreateFontString(mover:GetName().."_Text")
	mover.text:SetFont(lib.media.font, 14, "OUTLINE")
	mover.text:SetPoint("CENTER", mover, "CENTER", 0, 0)
	mover.text:SetText(rename)
	mover.text:SetJustifyH("CENTER")
	mover.text:SetAlpha(0.8)
	mover.text:Hide()

	-- Transfer Methods to this object
	frame.mover = mover
	mover.frame = frame
	mover.rename = rename
	
	-- Sizing
	local function resize(self)
		local height = self:GetHeight()
		local width = self:GetWidth()

		self.mover:SetSize(width + 2 + lib.border, height + 2 + lib.border)
	end
	hooksecurefunc(frame, "SetSize", resize)
	hooksecurefunc(frame, "SetScale", resize)

	-- select this element for moving
	function mover:select()
		-- deselect everything else
		for k, frame in pairs(lib.movers) do
			frame:deselect()
		end

		self.selected = true
		self:SetMovable(true)
		self:RegisterForDrag("LeftButton")
		self:SetBackdropColor(0, 0, 0, .8)
		self:SetBackdropBorderColor(unpack(lib.media.border))

		self:SetScript("OnDragStart", function(self)
			StickyFrames:StartMoving(self, lib.movers, -lib.border, -lib.border, -lib.border, -lib.border)
		end)
		self:SetScript("OnDragStop", function(self)
			StickyFrames:StopMoving(self)
			StickyFrames:AnchorFrame(self)

			local quad, y, h = GetQuadrant(self)
			lib.bumper:ClearAllPoints()
			if (y == "TOP") then
				lib.bumper:SetPoint("TOP", self, "BOTTOM", 0, lib.pixel)
			else
				lib.bumper:SetPoint("BOTTOM", self, "TOP", 0, -lib.pixel)
			end
		end)

		-- place the bumper here
		local quad, y, h = GetQuadrant(self)
		lib.bumper.frame = self
		lib.bumper:Show()
		lib.bumper:ClearAllPoints()
		if (y == "TOP") then
			lib.bumper:SetPoint("TOP", self, "BOTTOM", 0, lib.pixel)
		else
			lib.bumper:SetPoint("BOTTOM", self, "TOP", 0, -lib.pixel)
		end
	end

	-- deselect this for movement
	function mover:deselect()
		self.selected = false
		self:SetMovable(false)
		self:SetBackdropColor(0,0,0,.3)
		self:SetBackdropBorderColor(0, 0, 0, 0)

		self:SetScript("OnDragStart", noop)
		self:SetScript("OnDragStop", noop)

		self:SetScript("OnEnter", noop)
		self:SetScript("OnLeave", noop)
	end

	-- unlock ui for movement
	function mover:unlock()
		self:SetAlpha(1)
		self.text:Show()
		self.locked = false
		self.selected = false
		self:EnableMouse(true)
		self:SetFrameStrata("TOOLTIP")
		
		mover:SetScript("OnClick", mover.select)

		self:SetScript("OnEnter", function() 
			if (self.frame:GetScript("OnEnter")) then
				self.frame:GetScript("OnEnter")(self.frame)
			end
		end)
		self:SetScript("OnLeave", function() 
			if (self.frame:GetScript("OnLeave")) then
				self.frame:GetScript("OnLeave")(self.frame)
			end
		end)
	end

	-- lock ui movement again
	function mover:lock()
		self:SetAlpha(0)
		self.text:Hide()
		self.locked = true
		self.selected = false

		self:SetScript("OnEnter", noop)
		self:SetScript("OnLeave", noop)
		self:SetScript("OnDragStart", noop)
		self:SetScript("OnDragStop", noop)
		self:SetScript("OnClick", noop)

		self:SetMouseMotionEnabled(false)
		self:SetMouseClickEnabled(false)
		self:SetFrameStrata("BACKGROUND")
		self:SetMovable(false)
		self:EnableMouse(false)
		
		self:save()
	end

	function mover:save()
		-- save in saved variables
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		if (not relativeTo) then relativeTo = UIParent end
		relativeTo = relativeTo:GetName()

		lib.save.positions[self.rename] = {point, relativeTo, relativePoint, xOfs, yOfs}
	end

	
	-- position save in saved variables (protects against lost positions during UI errors)
	function mover:position()
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

	-- position
	mover:position()

	table.insert(lib.movers, mover)
end

function lib:toggle_lock()
	if (lib.unlocked) then
		-- lock
		lib.bumper:Hide()
		lib.unlocked = false
		lib.align:Hide()
		for k, frame in pairs(lib.movers) do
			frame:deselect()
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
		for k, frame in pairs(lib.movers) do
			frame:deselect()
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
lib.align:SetAlpha(0.5)
local grid_x = 32
local grid_y = 18
local w = GetScreenWidth() / grid_x
local h = GetScreenHeight() / grid_y
for i = 0, grid_x do
	local t = lib.align:CreateTexture(nil, 'BACKGROUND')
	if i == grid_x / 2 then
		t:SetColorTexture(unpack(lib.media.border))
	else
		t:SetColorTexture(1, 1, 1, 0.2)
	end
	t:SetPoint('TOPLEFT', lib.align, 'TOPLEFT', i * w - 1, 0)
	t:SetPoint('BOTTOMRIGHT', lib.align, 'BOTTOMLEFT', i * w + 1, 0)
end
for i = 0, grid_y do
	local t = lib.align:CreateTexture(nil, 'BACKGROUND')
	if i == grid_y / 2 then
		t:SetColorTexture(unpack(lib.media.border))
	else
		t:SetColorTexture(1, 1, 1, .2)
	end
	t:SetPoint('TOPLEFT', lib.align, 'TOPLEFT', 0, -i * h + 1)
	t:SetPoint('BOTTOMRIGHT', lib.align, 'TOPRIGHT', 0, -i * h - 1)
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