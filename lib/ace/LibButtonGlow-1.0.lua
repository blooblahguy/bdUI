--[[
	Big Dumb Modified version of the following lib:

Copyright (c) 2015-2017, Hendrik "nevcairiel" Leppkes <h.leppkes@gmail.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
      this list of conditions and the following disclaimer in the documentation 
      and/or other materials provided with the distribution.
    * Neither the name of the developer nor the names of its contributors 
      may be used to endorse or promote products derived from this software without 
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--local MAJOR_VERSION = "LibButtonGlow-1.0"
--local MINOR_VERSION = 6

--if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
--local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
--if not lib then return end

local Masque = LibStub("Masque", true)
bdButtonGlow = {}
local lib = bdButtonGlow
lib.unusedOverlays = lib.unusedOverlays or {}
lib.numOverlays = lib.numOverlays or 0

local tinsert, tremove, tostring = table.insert, table.remove, tostring

local function OverlayGlowAnimOutFinished(animGroup)
	local overlay = animGroup:GetParent()
	local frame = overlay:GetParent()
	overlay:Hide()
	tinsert(lib.unusedOverlays, overlay)
	frame.__LBGoverlay = nil
end

local function OverlayGlow_OnHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		OverlayGlowAnimOutFinished(self.animOut)
	end
end

local function CreateScaleAnim(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation("Scale")
	scale:SetTarget(target:GetName())
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay)
	local alpha = group:CreateAnimation("Alpha")
	alpha:SetTarget(target:GetName())
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromAlpha)
	alpha:SetToAlpha(toAlpha)

	if delay then
		alpha:SetStartDelay(delay)
	end
end

local function AnimIn_OnPlay(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetSize(frameWidth, frameHeight)
	frame.spark:SetAlpha(0.3)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.ants:SetAlpha(1.0)
end

local function CreateOverlayGlow()
	lib.numOverlays = lib.numOverlays + 1

	-- create frame and textures
	local name = "bdGlow" .. tostring(lib.numOverlays)
	local overlay = CreateFrame("Frame", name, UIParent)

	-- spark
	overlay.spark = overlay:CreateTexture(name .. "Spark", "BACKGROUND")
	overlay.spark:SetPoint("CENTER")
	overlay.spark:SetAlpha(0)
	overlay.spark:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	overlay.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

	-- ants
	overlay.ants = overlay:CreateTexture(name .. "Ants", "OVERLAY")
	overlay.ants:SetPoint("TOPLEFT", overlay, "TOPLEFT", -8, 6)
	overlay.ants:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 6, -6)
	overlay.ants:SetAlpha(0)
	overlay.ants:SetTexture("Interface\\SpellActivationOverlay\\IconAlertAnts")

	-- setup antimations
	overlay.animIn = overlay:CreateAnimationGroup()
	CreateScaleAnim(overlay.animIn, overlay.spark,          1, 0.2, 1.5, 1.5)
	CreateAlphaAnim(overlay.animIn, overlay.spark,          1, 0.2, 0, 1)
	CreateScaleAnim(overlay.animIn, overlay.spark,          1, 0.2, 2/3, 2/3, 0.2)
	CreateAlphaAnim(overlay.animIn, overlay.spark,          1, 0.2, 1, 0, 0.2)
	CreateAlphaAnim(overlay.animIn, overlay.ants,           1, 0.2, 0, 1, 0.3)
	overlay.animIn:SetScript("OnPlay", AnimIn_OnPlay)
	overlay.animIn:SetScript("OnFinished", AnimIn_OnFinished)

	overlay.animOut = overlay:CreateAnimationGroup()
	CreateAlphaAnim(overlay.animOut, overlay.ants,          1, 0.2, 1, 0)
	overlay.animOut:SetScript("OnFinished", OverlayGlowAnimOutFinished)

	-- scripts
	overlay:SetScript("OnUpdate", ActionButton_OverlayGlowOnUpdate)
	overlay:SetScript("OnHide", OverlayGlow_OnHide)

	return overlay
end

local function GetOverlayGlow()
	local overlay = tremove(lib.unusedOverlays)
	if not overlay then
		overlay = CreateOverlayGlow()
	end
	return overlay
end

function lib.ShowOverlayGlow(frame)
	if frame.__LBGoverlay then
		if frame.__LBGoverlay.animOut:IsPlaying() then
			frame.__LBGoverlay.animOut:Stop()
			frame.__LBGoverlay.animIn:Play()
		end
	else
		local overlay = GetOverlayGlow()
		local frameWidth, frameHeight = frame:GetSize()
		overlay:SetParent(frame)
		overlay:SetFrameLevel(frame:GetFrameLevel() + 5)
		overlay:ClearAllPoints()
		--Make the height/width available before the next frame:
		overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4)
		overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
		overlay.animIn:Play()
		frame.__LBGoverlay = overlay

		if Masque and Masque.UpdateSpellAlert and (not frame.overlay or not issecurevariable(frame, "overlay")) then
			local old_overlay = frame.overlay
			frame.overlay = overlay
			Masque:UpdateSpellAlert(frame)

			frame.overlay = old_overlay
		end
	end
end

function lib.HideOverlayGlow(frame)
	if frame.__LBGoverlay then
		if frame.__LBGoverlay.animIn:IsPlaying() then
			frame.__LBGoverlay.animIn:Stop()
		end
		if frame:IsVisible() then
			frame.__LBGoverlay.animOut:Play()
		else
			OverlayGlowAnimOutFinished(frame.__LBGoverlay.animOut)
		end
	end
end
