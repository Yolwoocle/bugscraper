require "scripts.util"
local images = require "data.images"

local skins = {
	{
		anim_idle = {images.mio_idle, 0.2, 4},
		anim_wall_slide = {images.mio_wall_slide},
		img_walk_down = images.mio_walk_down,
		img_airborne = images.mio_airborne,
		spr_dead = images.mio_dead,

		color_palette = {color(0xf6757a), color(0xb55088), color(0xe43b44), color(0x9e2835), color(0x3a4466), color(0x262b44)},
		menu_color = color(0xf6757a),
		icon = "🐜",
		text_key = "mio",
	},
	{
		anim_idle = {images.cap_idle, 0.2, 4},
		anim_wall_slide = {images.cap_wall_slide},
		img_walk_down = images.cap_walk_down,
		img_airborne = images.cap_airborne,
		spr_dead = images.cap_dead,
		
		color_palette = {color(0x63c74d), color(0x3e8948), color(0x265c42), color(0x193c3e), color(0x5a6988), color(0x3a4466)},
		menu_color = color(0x3e8948),
		icon = "🐛",
		text_key = "cap",
	},
	{
		anim_idle = {images.zia_idle, 0.2, 4},
		anim_wall_slide = {images.zia_wall_slide},
		img_walk_down = images.zia_walk_down,
		img_airborne = images.zia_airborne,
		spr_dead = images.zia_dead,
		
		color_palette = {color(0xfee761), color(0xfeae34), color(0x743f39), color(0x3f2832), color(0xc0cbdc), color(0x9e2835)},
		menu_color = color(0x743f39),
		icon = "🐝",
		text_key = "zia",
	},
	{
		anim_idle = {images.tok_idle, 0.18, 4},
		anim_wall_slide = {images.tok_wall_slide},
		img_walk_down = images.tok_walk_down,
		img_airborne = images.tok_airborne,
		spr_dead = images.tok_dead,

		color_palette = {COL_LIGHT_BLUE, COL_MID_BLUE, color(0x9e2835), color(0x3a4466), color(0x262b44)},
		menu_color = color(0x0195e9), 
		icon = "🪲",
		text_key = "tok",
	},
	{
		anim_idle = {images.nel_idle, 0.18, 4},
		anim_wall_slide = {images.nel_wall_slide},
		img_walk_down = images.nel_walk_down,
		img_airborne = images.nel_airborne,
		spr_dead = images.nel_dead,

		color_palette = {COL_LIGHT_RED, COL_DARK_RED, COL_DARK_BROWN, color(0x3a4466), color(0x262b44)},
		menu_color = COL_LIGHT_RED, 
		icon = "🐞",
		text_key = "nel",
	},
	{
		anim_idle = {images.rabbit_1, 0.2, 1},
		anim_wall_slide = {images.rabbit_2},
		img_walk_down = images.rabbit_1,
		img_airborne = images.rabbit_2,
		spr_dead = images.rabbit_dead,

		color_palette = {COL_WHITE, COL_LIGHTEST_GRAY, COL_MID_GRAY, COL_DARK_GRAY, COL_BLACK_BLUE},
		menu_color = COL_MID_GRAY, 
		icon = "🐰",
		text_key = "rico",
	},
	{
		anim_idle = {images.leo, 0.2, 1},
		anim_wall_slide = {images.leo},
		img_walk_down = images.leo,
		img_airborne = images.leo,
		spr_dead = images.leo,
		color_palette = {color(0x63c74d), color(0x3e8948), color(0x265c42), color(0x193c3e), color(0x5a6988), color(0x3a4466)},
		menu_color = color(0x3e8948), 
		icon = "🥦",
		text_key = "leo",
	},
	{
		anim_idle = {images.dodu_idle, 0.18, 1},
		anim_wall_slide = {images.dodu_wall_slide},
		img_walk_down = images.dodu_walk_down,
		img_airborne = images.dodu_airborne,
		spr_dead = images.dodu_dead,

		color_palette = {COL_MID_GRAY, COL_LIGHT_GRAY, COL_LIGHTEST_GRAY, COL_WHITE, COL_WHITE},
		menu_color = COL_MID_GRAY, 
		icon = "🐧",
		text_key = "dodu",
	},
}

for key, skin in pairs(skins) do
	skins[key].id = key
end

return skins