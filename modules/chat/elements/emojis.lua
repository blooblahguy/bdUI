--============================================
-- CHAT EMOJIS BUBBLES
-- Bubble skinning for outside of raids/bg
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

-- Thanks to ElvUI for providing great textures
local p = "Interface\\Addons\\bdUI\\core\\media\\emojis\\"
local emoji_textures = {
	Angry = p.."Angry.tga",
	Blush = p.."Blush.tga",
	BrokenHeart = p.."BrokenHeart.tga",
	CallMe = p.."CallMe.tga",
	Cry = p.."Cry.tga",
	Facepalm = p.."Facepalm.tga",
	Grin = p.."Grin.tga",
	Heart = p.."Heart.tga",
	HeartEyes = p.."HeartEyes.tga",
	Joy = p.."Joy.tga",
	Kappa = p.."Kappa.tga",
	Meaw = p.."Meaw.tga",
	MiddleFinger = p.."MiddleFinger.tga",
	Murloc = p.."Murloc.tga",
	OkHand = p.."OkHand.tga",
	OpenMouth = p.."OpenMouth.tga",
	Poop = p.."Poop.tga",
	qqMonk = p.."qqMonk.tga",
	Rage = p.."Rage.tga",
	SadKitty = p.."SadKitty.tga",
	Scream = p.."Scream.tga",
	ScreamCat = p.."ScreamCat.tga",
	SemiColon = p.."SemiColon.tga",
	SlightFrown = p.."SlightFrown.tga",
	Smile = p.."Smile.tga",
	Smirk = p.."Smirk.tga",
	Sob = p.."Sob.tga",
	StuckOutTongue = p.."StuckOutTongue.tga",
	StuckOutTongueClosedEyes = p.."StuckOutTongueClosedEyes.tga",
	Sunglasses = p.."Sunglasses.tga",
	Thinking = p.."Thinking.tga",
	ThumbsUp = p.."ThumbsUp.tga",
	Wink = p.."Wink.tga",
	ZZZ = p.."ZZZ.tga"
}

-- EMOJI EXPRESSION MAPS
mod.emojis = {}
mod.emojis[':angry:'] = emoji_textures.Angry
mod.emojis[':blush:'] = emoji_textures.Blush
mod.emojis[':broken_heart:'] = emoji_textures.BrokenHeart
mod.emojis[':call_me:'] = emoji_textures.CallMe
mod.emojis[':cry:'] = emoji_textures.Cry
mod.emojis[':facepalm:'] = emoji_textures.Facepalm
mod.emojis[':grin:'] = emoji_textures.Grin
mod.emojis[':heart:'] = emoji_textures.Heart
mod.emojis[':heart_eyes:'] = emoji_textures.HeartEyes
mod.emojis[':joy:'] = emoji_textures.Joy
mod.emojis[':kappa:'] = emoji_textures.Kappa
mod.emojis[':middle_finger:'] = emoji_textures.MiddleFinger
mod.emojis[':murloc:'] = emoji_textures.Murloc
mod.emojis[':ok_hand:'] = emoji_textures.OkHand
mod.emojis[':open_mouth:'] = emoji_textures.OpenMouth
mod.emojis[':poop:'] = emoji_textures.Poop
mod.emojis['qqmonk'] = emoji_textures.qqMonk
mod.emojis['qqMonk'] = emoji_textures.qqMonk
mod.emojis[':rage:'] = emoji_textures.Rage
mod.emojis[':sadkitty:'] = emoji_textures.SadKitty
mod.emojis[':scream:'] = emoji_textures.Scream
mod.emojis[':scream_cat:'] = emoji_textures.ScreamCat
mod.emojis[':slight_frown:'] = emoji_textures.SlightFrown
mod.emojis[':smile:'] = emoji_textures.Smile
mod.emojis[':smirk:'] = emoji_textures.Smirk
mod.emojis[':sob:'] = emoji_textures.Sob
mod.emojis[':sunglasses:'] = emoji_textures.Sunglasses
mod.emojis[':thinking:'] = emoji_textures.Thinking
mod.emojis[':thumbs_up:'] = emoji_textures.ThumbsUp
mod.emojis[':thumbsup:'] = emoji_textures.ThumbsUp
mod.emojis[':semi_colon:'] = emoji_textures.SemiColon
mod.emojis[':wink:'] = emoji_textures.Wink
mod.emojis[':zzz:'] = emoji_textures.ZZZ
mod.emojis[':stuck_out_tongue:'] = emoji_textures.StuckOutTongue
mod.emojis[':stuck_out_tongue_closed_eyes:'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis[':meaw:'] = emoji_textures.Meaw
mod.emojis['>:%('] = emoji_textures.Rage
mod.emojis[':%$'] = emoji_textures.Blush
mod.emojis['<\\3'] = emoji_textures.BrokenHeart
mod.emojis[':\'%)'] = emoji_textures.Joy
mod.emojis[';\'%)'] = emoji_textures.Joy
mod.emojis[',,!,,'] = emoji_textures.MiddleFinger
mod.emojis['D:<'] = emoji_textures.Rage
mod.emojis[':o3'] = emoji_textures.ScreamCat
-- mod.emojis['XP'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis['8%-%)'] = emoji_textures.Sunglasses
mod.emojis['8%)'] = emoji_textures.Sunglasses
mod.emojis[':%+1:'] = emoji_textures.ThumbsUp
mod.emojis[':;:'] = emoji_textures.SemiColon
mod.emojis[';o;'] = emoji_textures.Sob
mod.emojis[':%-@'] = emoji_textures.Angry
mod.emojis[':@'] = emoji_textures.Angry
mod.emojis[':%-%)'] = emoji_textures.Smile
mod.emojis[':%)'] = emoji_textures.Smile
mod.emojis[':D'] = emoji_textures.Smile
mod.emojis[':%-D'] = emoji_textures.Grin
mod.emojis[';%-D'] = emoji_textures.Grin
mod.emojis[';D'] = emoji_textures.Grin
mod.emojis['=D'] = emoji_textures.Smile
mod.emojis['xD'] = emoji_textures.Grin
mod.emojis['XD'] = emoji_textures.Grin
mod.emojis[':%-%('] = emoji_textures.SlightFrown
mod.emojis[':%('] = emoji_textures.SlightFrown
mod.emojis[':o'] = emoji_textures.OpenMouth
mod.emojis[':%-o'] = emoji_textures.OpenMouth
mod.emojis[':%-O'] = emoji_textures.OpenMouth
mod.emojis[':O'] = emoji_textures.OpenMouth
mod.emojis[':%-0'] = emoji_textures.OpenMouth
mod.emojis[':P'] = emoji_textures.StuckOutTongue
mod.emojis[':%-P'] = emoji_textures.StuckOutTongue
mod.emojis[':p'] = emoji_textures.StuckOutTongue
mod.emojis[':%-p'] = emoji_textures.StuckOutTongue
mod.emojis['=P'] = emoji_textures.StuckOutTongue
mod.emojis['=p'] = emoji_textures.StuckOutTongue
mod.emojis[';%-p'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis[';p'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis[';P'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis[';%-P'] = emoji_textures.StuckOutTongueClosedEyes
mod.emojis[';%-%)'] = emoji_textures.Wink
mod.emojis[';%)'] = emoji_textures.Wink
mod.emojis[':S'] = emoji_textures.Smirk
mod.emojis[':%-S'] = emoji_textures.Smirk
mod.emojis[':,%('] = emoji_textures.Cry
mod.emojis[':,%-%('] = emoji_textures.Cry
mod.emojis[':\'%('] = emoji_textures.Cry
mod.emojis[':\'%-%('] = emoji_textures.Cry
mod.emojis[':F'] = emoji_textures.MiddleFinger
mod.emojis['<3'] = emoji_textures.Heart
mod.emojis['</3'] = emoji_textures.BrokenHeart

-- replace emojis
function mod:create_emojis()


	local function filter(chatFrame, event, msg, ...)
		if (not mod.config.enableemojis) then return end

		local newMsg = msg

		for word in gmatch(newMsg, "%s-%S+%s*") do
			word = strtrim(word)
			local pattern = gsub(word, '([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
			local emoji = mod.emojis[pattern]
			-- mod:alert_message(mod:rawText(pattern))
			if emoji and strmatch(newMsg, '[%s%p]-'..pattern..'[%s%p]*') then
				emoji = "|T"..emoji..":12|t"
				local base64 = bdUI.base64:Encode(word)
				newMsg = gsub(newMsg, '([%s%p]-)'..pattern..'([%s%p]*)', (base64 and ('%1|Hbduimoji:%%'..base64..'|h|cFFffffff|r|h') or '%1')..emoji..'%2');
			end
		end

		return false, newMsg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
end