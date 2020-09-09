local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")

-- pretty much all credit here to the fine folks at tuk/elv

-- GLOBALS: CHAT_FONT_HEIGHTS, UNIT_NAME_FONT, DAMAGE_TEXT_FONT, STANDARD_TEXT_FONT, NORMALOFFSET, BIGOFFSET, SHADOWCOLOR
local function SetFont(self, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	self:SetFont(font, size, style)
	
	if sr and sg and sb then
		self:SetShadowColor(sr, sg, sb)
	end
	
	if sox and soy then
		self:SetShadowOffset(sox, soy)
	end
	
	if r and g and b then
		self:SetTextColor(r, g, b)
	elseif r then
		self:SetAlpha(r)
	end
end

UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

local function changeFonts()
	local config = bdUI:get_module("General"):get_save()
	if (not config.change_fonts) then return end
	-- if (not c.persistent.bdAddons.changefonts) then return end

	local font = bdUI.media.font--bdUI:getMedia("font", c.persistent.bdAddons.font )

	local NORMAL = font
	local COMBAT = font
	local NUMBER = font
	local MONOCHROME = "THIN"

	local fontScale = 1--c.persistent.bdAddons.fontScale;
	
	UNIT_NAME_FONT = NORMAL
	DAMAGE_TEXT_FONT = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	---
	SetFont(ChatBubbleFont,						NORMAL, 15 * fontScale, "OUTLINE")
	SetFont(SystemFont_Shadow_Large_Outline,	NUMBER, 20 * fontScale, "OUTLINE")
	SetFont(GameTooltipHeader, 					NORMAL, 14 * fontScale)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 14 * fontScale, "OUTLINE");
	SetFont(NumberFont_Outline_Huge, 			NUMBER, 28 * fontScale, "THICKOUTLINE", 28);
	SetFont(NumberFont_Outline_Large, 			NUMBER, 17 * fontScale, "OUTLINE");
	SetFont(NumberFont_Outline_Med, 			NUMBER, 15 * fontScale, "OUTLINE");
	SetFont(NumberFont_Shadow_Med, 				NORMAL, 14 * fontScale);
	SetFont(NumberFont_Shadow_Small, 			NORMAL, 14 * fontScale);
	SetFont(QuestFont, 							NORMAL, 14 * fontScale);
	SetFont(QuestFont_Large, 					NORMAL, 14 * fontScale);
	SetFont(SystemFont_Large, 					NORMAL, 17 * fontScale);
	SetFont(SystemFont_Med1, 					NORMAL, 14 * fontScale);
	SetFont(SystemFont_Med3, 					NORMAL, 10 * fontScale);
	SetFont(SystemFont_OutlineThick_Huge2, 		NORMAL, 22 * fontScale, "THICKOUTLINE");
	SetFont(SystemFont_Outline_Small, 			NUMBER, 14 * fontScale, "OUTLINE");
	SetFont(SystemFont_Shadow_Large, 			NORMAL, 17 * fontScale);
	SetFont(SystemFont_Shadow_Med1, 			NORMAL, 14 * fontScale);
	SetFont(SystemFont_Shadow_Med3, 			NORMAL, 15 * fontScale);
	-- SetFont(SystemFont_Shadow_Outline_Huge2,	NORMAL, 22 * fontScale, "OUTLINE");
	SetFont(SystemFont_Shadow_Small, 			NORMAL, 13 * fontScale);
	SetFont(SystemFont_Small, 					NORMAL, 14 * fontScale);
	SetFont(SystemFont_Tiny, 					NORMAL, 14 * fontScale);
	SetFont(Tooltip_Med, 						NORMAL, 14 * fontScale);
	SetFont(Tooltip_Small, 						NORMAL, 14 * fontScale);
	SetFont(CombatTextFont, 					NORMAL, 200 * fontScale, "OUTLINE");
	SetFont(SystemFont_Shadow_Huge1, 			NORMAL, 22 * fontScale, "THINOUTLINE");
	SetFont(ZoneTextString, 					NORMAL, 32 * fontScale, "OUTLINE");
	SetFont(SubZoneTextString, 					NORMAL, 27 * fontScale, "OUTLINE");
	SetFont(PVPInfoTextString, 					NORMAL, 24 * fontScale, "THINOUTLINE");
	SetFont(PVPArenaTextString, 				NORMAL, 24 * fontScale, "THINOUTLINE");
	SetFont(FriendsFont_Normal, 				NORMAL, 14 * fontScale);
	SetFont(FriendsFont_Small, 					NORMAL, 13 * fontScale);
	SetFont(FriendsFont_Large, 					NORMAL, 14 * fontScale);
	SetFont(FriendsFont_UserText, 				NORMAL, 13 * fontScale);
	SetFont(SystemFont_Shadow_Huge3,            NORMAL, 22 * fontScale, nil, SHADOWCOLOR, BIGOFFSET)
	SetFont(GameFontNormalMed3,					NORMAL, 15 * fontScale)

	SetFont(QuestFont_Shadow_Huge, 				NORMAL, 15 * fontScale, nil, SHADOWCOLOR, NORMALOFFSET)
	SetFont(QuestFont_Shadow_Small, 			NORMAL, 14 * fontScale, nil, SHADOWCOLOR, NORMALOFFSET);
	SetFont(SystemFont_Outline, 				NORMAL, 13 * fontScale, MONOCHROME.."OUTLINE");
	SetFont(SystemFont_OutlineThick_WTF,		NORMAL, 32 * fontScale, MONOCHROME.."OUTLINE");
	SetFont(SubZoneTextFont,					NORMAL, 24 * fontScale, MONOCHROME.."OUTLINE");
	SetFont(QuestFont_Super_Huge,				NORMAL, 22 * fontScale, nil, SHADOWCOLOR, BIGOFFSET);
	SetFont(QuestFont_Huge,						NORMAL, 15 * fontScale, nil, SHADOWCOLOR, BIGOFFSET);
	SetFont(CoreAbilityFont,					NORMAL, 26 * fontScale);
	SetFont(MailFont_Large,						NORMAL, 14 * fontScale);
	SetFont(InvoiceFont_Med,					NORMAL, 12 * fontScale);
	SetFont(InvoiceFont_Small,					NORMAL, 14 * fontScale);
	SetFont(AchievementFont_Small,				NORMAL, 14 * fontScale);
	SetFont(ReputationDetailFont,				NORMAL, 14 * fontScale);
	SetFont(GameFontNormalMed2,					NORMAL, 15 * fontScale);
	SetFont(BossEmoteNormalHuge,				NORMAL, 24 * fontScale);
	SetFont(GameFontHighlightMedium,			NORMAL, 15 * fontScale);
	SetFont(GameFontNormalLarge2,				NORMAL, 15 * fontScale);
	SetFont(QuestFont_Enormous, 				NORMAL, 24 * fontScale, nil, SHADOWCOLOR, NORMALOFFSET); 
	SetFont(DestinyFontHuge,					NORMAL, 20 * fontScale, nil, SHADOWCOLOR, BIGOFFSET);
	SetFont(Game24Font, 						NORMAL, 24 * fontScale);								
	SetFont(SystemFont_Huge1, 					NORMAL, 20 * fontScale);
	SetFont(SystemFont_Huge1_Outline, 			NORMAL, 18 * fontScale, MONOCHROME.."OUTLINE");
	SetFont(Fancy22Font,						NORMAL, 20 * fontScale);
	SetFont(Fancy24Font,						NORMAL, 20 * fontScale);
	SetFont(Game30Font,							NORMAL, 28 * fontScale);
	SetFont(SystemFont_Shadow_Med2,				NORMAL, 14 * fontScale)

	SetFont(Game16Font,							NORMAL, 16 * fontScale);
	SetFont(Game46Font,							NORMAL, 46 * fontScale);
	SetFont(DestinyFontMed,						NORMAL, 14 * fontScale);
	SetFont(Fancy12Font,						NORMAL, 12 * fontScale);
	SetFont(Fancy14Font,						NORMAL, 14 * fontScale);

	SetFont(GameFontHighlightSmall2,			NORMAL, 14 * fontScale);
	SetFont(Game18Font,							NORMAL, 18 * fontScale);
	SetFont(GameFontNormalSmall2,				NORMAL, 12 * fontScale);
	SetFont(GameFontNormalHuge2,				NORMAL, 24 * fontScale);
	SetFont(Game15Font_o1,						NORMAL, 15 * fontScale);
	SetFont(Game13FontShadow,					NORMAL, 14 * fontScale);
	SetFont(NumberFontNormalSmall,				NORMAL, 11 * fontScale, "OUTLINE");
	SetFont(GameFont_Gigantic,					NORMAL, 32 * fontScale, nil, SHADOWCOLOR, BIGOFFSET);
end

-- Base fonts
bdUI:add_action("loaded", changeFonts)