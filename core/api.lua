-- local function SetBackdrop(self, attrs)
-- 	Mixin(self, BackdropTemplateMixin)
-- 	self.
-- end

local function AddAPI(object)
	local mt = getmetatable(object).__index

	-- if not object.SetBackdrop then Mixin(object, BackdropTemplateMixin) end
	-- if not object.SetFadeInTemplate then mt.SetFadeInTemplate = SetFadeInTemplate end
	-- if not object.SetFadeOutTemplate then mt.SetFadeOutTemplate = SetFadeOutTemplate end
	-- if not object.SetFontTemplate then mt.SetFontTemplate = SetFontTemplate end
	-- if not object.Size then mt.Size = Size end
	-- if not object.Point then mt.Point = Point end
	-- if not object.SetOutside then mt.SetOutside = SetOutside end
	-- if not object.SetInside then mt.SetInside = SetInside end
	-- if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	-- if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	-- if not object.StripTextures then mt.StripTextures = StripTextures end
	-- if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	-- if not object.Kill then mt.Kill = Kill end
	-- if not object.StyleButton then mt.StyleButton = StyleButton end
	-- if not object.Width then mt.Width = Width end
	-- if not object.Height then mt.Height = Height end
	-- if not object.FontString then mt.FontString = FontString end
	-- if not object.SkinEditBox then mt.SkinEditBox = SkinEditBox end
	-- if not object.SkinButton then mt.SkinButton = SkinButton end
	-- if not object.SkinCloseButton then mt.SkinCloseButton = SkinCloseButton end
	-- if not object.SkinArrowButton then mt.SkinArrowButton = SkinArrowButton end
	-- if not object.SkinDropDown then mt.SkinDropDown = SkinDropDown end
	-- if not object.SkinCheckBox then mt.SkinCheckBox = SkinCheckBox end
	-- if not object.SkinTab then mt.SkinTab = SkinTab end
	-- if not object.SkinScrollBar then mt.SkinScrollBar = SkinScrollBar end
end

-- local Handled = {["Frame"] = true}

-- local Object = CreateFrame("Frame")
-- local Button = CreateFrame("Button")
-- AddAPI(Object)
-- AddAPI(Button)
-- AddAPI(Object:CreateTexture())
-- AddAPI(Object:CreateFontString())

-- Object = EnumerateFrames()

-- while Object do
-- 	if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
-- 		AddAPI(Object)
-- 		Handled[Object:GetObjectType()] = true
-- 	end

-- 	Object = EnumerateFrames(Object)
-- end
