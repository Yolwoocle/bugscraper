require "scripts.util"
local images = require "data.images"

return {
	{
		spr_idle = images.ant1,
		spr_jump = images.ant2,
		spr_wall_slide = images.ant_wall_slide,
		spr_dead = images.ant_dead,
		spr_head = images.ant_head,
		color_palette = {color(0xf6757a), color(0xb55088), color(0xe43b44), color(0x9e2835), color(0x3a4466), color(0x262b44)},
		menu_color = color(0xf6757a),
		icon = "🐜",
	},
	{
		spr_idle = images.caterpillar_1,
		spr_jump = images.caterpillar_2,
		spr_wall_slide = images.caterpillar_2,
		spr_dead = images.caterpillar_dead,
		spr_head = images.caterpillar_head,
		color_palette = {color(0x63c74d), color(0x3e8948), color(0x265c42), color(0x193c3e), color(0x5a6988), color(0x3a4466)},
		menu_color = color(0x3e8948),
		icon = "🐛",
	},
	{
		spr_idle = images.bee_1,
		spr_jump = images.bee_2,
		spr_wall_slide = images.bee_2,
		spr_dead = images.bee_dead,
		spr_head = images.caterpillar_head,
		color_palette = {color(0xfee761), color(0xfeae34), color(0x743f39), color(0x3f2832), color(0xc0cbdc), color(0x9e2835)},
		-- menu_color = color(0xfee761),
		-- menu_color = color(0xfeae34),
		menu_color = color(0x743f39),
		-- menu_color = color(0x3f2832),
		-- menu_color = color(0xc0cbdc),
		-- menu_color = color(0x9e2835),
		icon = "🐝",
	},
	
	{
		spr_idle = images.beetle_1,
		spr_jump = images.beetle_2,
		spr_wall_slide = images.beetle_2,
		spr_dead = images.beetle_dead,
		spr_head = images.caterpillar_head,
		color_palette = {color(0x2ce8f5), color(0x0195e9), color(0x9e2835), color(0x3a4466), color(0x262b44)},
		menu_color = color(0x0195e9), 
		icon = "🪲",
	},
}