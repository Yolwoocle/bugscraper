require "scripts.util"
local images = require "data.images"
local Class = require "scripts.meta.class"

local GameUI = Class:inherit()

function GameUI:init(game)
	self.game = game

    self.is_visible = true
end

function GameUI:update(dt)
end

function GameUI:set_visible(bool)
    self.is_visible = bool
end

function GameUI:draw()
	if not self.is_visible then return end
	self:draw_logo()
	self:draw_join_tutorial()
	self:draw_timer()
	self:draw_version()
end

function GameUI:draw_logo()
	for i=1, #LOGO_COLS + 1 do
		local ox, oy = cos(game.logo_a + i*.4)*8, sin(game.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = LOGO_COLS[i]
		local spr = images.logo_shad
		if col == nil then
			col = COL_WHITE
			spr = images.logo_noshad
		end
		gfx.setColor(col)
		gfx.draw(spr, logo_x + ox, game.logo_y + oy)
	end
end

function GameUI:draw_version()
	local text = concat("v", BUGSCRAPER_VERSION)
	local x = math.floor(CANVAS_WIDTH - get_text_width(text) - 2)
	local y = CANVAS_HEIGHT - self.game.logo_y + 16
	print_outline(COL_DARK_GRAY, nil, text, x, y)
end

function GameUI:draw_join_tutorial()
	local def_x = math.floor((game.level.door_ax + game.level.door_bx) / 2)
	local def_y = game.logo_y + 50
	local number_of_keyboard_users = Input:get_number_of_users(INPUT_TYPE_KEYBOARD)

	local icons = {
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("jump", INPUT_TYPE_CONTROLLER), BUTTON_STYLE_XBOX),
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("jump", INPUT_TYPE_CONTROLLER), BUTTON_STYLE_PLAYSTATION5),
		Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("jump", INPUT_TYPE_KEYBOARD)),
	}
	if number_of_keyboard_users >= 1 then
		table.remove(icons)
	end
	
	local x = def_x
	local y = def_y
	print_outline(COL_WHITE, COL_BLACK_BLUE, "JOIN", x, y)
	for i, icon in pairs(icons) do
		x = x - icon:getWidth() - 2
		love.graphics.draw(icon, x, y)
		if i ~= #icons then
			print_outline(COL_WHITE, COL_BLACK_BLUE, "/", x-3, y)
		end
	end
	
	x = def_x
	y = y + 16
	if number_of_keyboard_users >= 1 then
		local icon_split_kb = Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("split_keyboard"))

		print_outline(COL_WHITE, COL_BLACK_BLUE, ternary(number_of_keyboard_users == 1, "SPLIT KEYBOARD", "UNSPLIT KEYBOARD"), x, y)
		x = x - icon_split_kb:getWidth() - 2
		love.graphics.draw(icon_split_kb, x, y)
	end
end

function GameUI:draw_timer()
	if not Options:get("timer_on") then
		return
	end

	rect_color({0,0,0,0.5}, "fill", 0, 10, 50, 12)
	gfx.print(time_to_string(game.time), 8, 8)
end

return GameUI