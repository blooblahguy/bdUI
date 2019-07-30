local MAJOR, MINOR = "lib-1.0", 1
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
noop = function() end

--========================================================
-- Defaults
--========================================================
lib.moveable_frames = {}
lib.save = nil
lib.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	font = "fonts\\ARIALN.ttf",
}

-- set savedvariable
function lib:set_save(sv)
	lib.save = sv
	lib.save.positions = lib.save.positions or {}
end


--========================================================
-- Methods
--========================================================
local methods = {
	['unlock'] = function(self)
		self:SetAlpha(1)
		self.text:Show()
		self:EnableMouse(true)
		self:SetMovable(true)
		self:SetUserPlaced(false)
		self:RegisterForDrag("LeftButton")
		self:SetFrameStrata("TOOLTIP")
		self:SetScript("OnDragStart", function(self) 
			StickyFrames:StartMoving(self, lib.moveable_frames, -bdUI.border, -bdUI.border, -bdUI.border, -bdUI.border)
		end)
		self:SetScript("OnDragStop", function(self) 
			StickyFrames:StopMoving(self)
			StickyFrames:AnchorFrame(self)
		end)
	end,
	['lock'] = function(self)
		self:SetAlpha(0)
		self.text:Hide()
		self:EnableMouse(false)
		self:SetUserPlaced(false)
		self:SetMovable(false)
		self:SetFrameStrata("BACKGROUND")
		self:SetScript("OnDragStart", noop)
		self:SetScript("OnDragStop", noop)

		-- save in saved variables
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		if (not relativeTo) then relativeTo = UIParent end
		relativeTo = relativeTo:GetName()

		lib.save.positions[rename] = {point, relativeTo, relativePoint, xOfs, yOfs}
	end,
	-- position save in saved variables (protects against lost positions during UI errors)
	['position'] = function(self)
		self:ClearAllPoints()
		if (lib.save.positions[rename]) then
			point, relativeTo, relativePoint, xOfs, yOfs = unpack(lib.save.positions[rename])
			relativeTo = _G[relativeTo]

			if (not point or not relativeTo or not relativePoint or not xOfs or not yOfs) then
				lib.save.positions[rename] = nil
				self:position()
			else
				self:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
			end
		else
			self:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
		end
	end
}

--========================================================
-- Mover
--========================================================
function lib:set_moveable(frame, rename, left, top, right, bottom)
	if (not lib.save) then print("lib needs SavedVariable to save positions. Use lib:set_save(sv_string)") return end
	rename = rename or frame:GetName()

	left = left or 2
	top = top or 2
	right = right or left or 2
	bottom = bottom or top or 2

	-- get dimensions
	local height = frame:GetHeight()
	local width = frame:GetWidth()
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	relativeTo = _G[relativeTo] or relativeTo:GetName()

	-- Create Mover Parent
	local mover = CreateFrame("frame", rename, UIParent)
	mover:EnableMouse(false)
	mover:SetSize(width + (right + left), height + (top + bottom))
	mover:SetBackdrop({bgFile = lib.media.flat})
	mover:SetBackdropColor(0,0,0,.6)
	mover:SetFrameStrata("BACKGROUND")
	mover:SetClampedToScreen(true)
	mover:SetAlpha(0)
	
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
		mover:SetSize(width+2+bdUI.border, height+2+bdUI.border)
	end)

	-- Attach the frame to the mover
	frame.mover = mover
	mover.frame = frame
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover, "CENTER", 0, 0)

	-- Transfer Methods to this object
	Mixin(mover, methods)
	mover:position()

	table.insert(lib.moveable_frames, mover)
end

function lib:toggle_lock()
	if (lib.unlocked) then
		-- lock
		lib.unlocked = false
		for k, frame in pairs(lib.moveable_frames) do
			frame:lock()
		end
	else
		-- unlock
		lib.unlocked = true
		for k, frame in pairs(lib.moveable_frames) do
			frame:unlock()
		end
	end
end

function lib:reset_positions()
	lib.save.positions = {}
end

--========================================================
-- Controls
--========================================================
lib.controls = CreateFrame("frame", nil, bdParent)
function lib:create_controls()

end

function lib:attach_controls(frame)

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
SpellFlyout:HookScript("OnShow", SpellFlyoutHook)