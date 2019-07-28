local _G = _G
local version = 1

if _G.bdMove and _G.bdMove.version >= version then
	bdMove = _G.bdMove
	return -- a newer or same version has already been created, ignore this file
end

-- Helper functions
noop = function() end

_G.bdMove = {}
local StickyFrames = LibStub("LibSimpleSticky-1.0")
bdMove.moveable_frames = {}
bdMove.save = nil
bdMove.spacing = 2
bdMove.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	arial = "fonts\\ARIALN.ttf",
}

-- set savedvariable
function bdMove:set_save(sv)
	bdMove.save = sv
	bdMove.save.positions = bdMove.save.positions or {}
end

-- main moveable registration
function bdMove:set_moveable(frame, rename, left, top, right, bottom)
	if (not bdMove.save) then print("bdMove needs SavedVariable to save positions") return end
	if rename == nil then rename = frame:GetName() end
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
	mover:SetBackdrop({bgFile = bdMove.media.flat})
	mover:SetBackdropColor(0,0,0,.6)
	mover:SetFrameStrata("BACKGROUND")
	mover:SetClampedToScreen(true)
	mover:SetAlpha(0)
	
	-- Text Label
	mover.text = mover:CreateFontString(mover:GetName().."_Text")
	mover.text:SetFont(bdMove.media.arial, 14, "OUTLINE")
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

	-- Moving functionality
	function mover:unlock()
		mover:SetAlpha(1)
		mover.text:Show()
		mover:EnableMouse(true)
		mover:SetMovable(true)
		mover:SetUserPlaced(false)
		mover:RegisterForDrag("LeftButton")
		mover:SetFrameStrata("TOOLTIP")
		mover:SetScript("OnDragStart", function(self) 
			StickyFrames:StartMoving(self, bdMove.moveable_frames, -bdUI.border, -bdUI.border, -bdUI.border, -bdUI.border)
		end)
		mover:SetScript("OnDragStop", function(self) 
			StickyFrames:StopMoving(self)
			StickyFrames:AnchorFrame(self)
		end)
	end
	function mover:lock()
		mover:SetAlpha(0)
		mover.text:Hide()
		mover:EnableMouse(false)
		mover:SetUserPlaced(false)
		mover:SetMovable(false)
		mover:SetFrameStrata("BACKGROUND")
		mover:SetScript("OnDragStart", noop)
		mover:SetScript("OnDragStop", noop)

		-- save in saved variables
		local point, relativeTo, relativePoint, xOfs, yOfs = mover:GetPoint()
		if (not relativeTo) then relativeTo = UIParent end
		relativeTo = relativeTo:GetName()

		bdMove.save.positions[rename] = {point, relativeTo, relativePoint, xOfs, yOfs}
	end

	-- position save in saved variables
	function mover:position()
		mover:ClearAllPoints()
		if (bdMove.save.positions[rename]) then
			point, relativeTo, relativePoint, xOfs, yOfs = unpack(bdMove.save.positions[rename])
			relativeTo = _G[relativeTo]

			if (not point or not relativeTo or not relativePoint or not xOfs or not yOfs) then
				bdMove.save.positions[rename] = nil
				mover:position()
			else
				mover:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
			end
		else
			mover:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs), math.floor(yOfs))
		end
	end
	mover:position()

	table.insert(bdMove.moveable_frames, mover)
end

function bdMove:toggle_lock()
	if (bdMove.unlocked) then
		-- lock
		bdMove.unlocked = false
		for k, frame in pairs(bdMove.moveable_frames) do
			frame:lock()
		end
	else
		-- unlock
		bdMove.unlocked = true
		for k, frame in pairs(bdMove.moveable_frames) do
			frame:unlock()
		end
	end
end

function bdMove:reset_positions()
	bdMove.save.positions = {}
	ReloadUI()
end

-- controls, build once and move around
bdMove.controls = CreateFrame("frame", nil, bdParent)
function bdMove:attach_controls(frame)

end


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

--========================================================
-- Mover
--========================================================

--========================================================
-- Positioners
--========================================================
function bdMove:CreateFrameGroup(pointa, pointb, spacing)
	
end
--========================================================
-- Frames / Faders
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
function bdMove:CreateFader(frame, children, inAlpha, outAlpha, duration)
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