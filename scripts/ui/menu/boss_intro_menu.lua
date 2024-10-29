require "scripts.util"
local Menu = require "scripts.ui.menu.menu"
local TextMenuItem = require "scripts.ui.menu.text_menu_item"
local images       = require "data.images"

local BossIntroMenu = Menu:inherit()

function BossIntroMenu:init(game, bg_color, title, layers)
	BossIntroMenu.super.init(self, game, {{""}}, bg_color, nil, nil)

	self.title = title
	self.layers = layers

	self:init_boss_intro()
end

function BossIntroMenu:on_set()
	self:init_boss_intro()
end

function BossIntroMenu:init_boss_intro()
	self.bg_color[4] = 0.0
	self.bg_alpha_target = 0.8
	self.blur_enabled = false

	self.border_scroll = 0
	self.border_scroll_speed = -14
	self.border_loop_threshold = 14
	self.border_width_target = 48
	self.title_border_add = 32
	self.border_width = -self.title_border_add

	self.title_padding = 16
	
	self.layers_scroll = CANVAS_WIDTH
	self.layers_scroll_enter_speed = 1500
	self.layers_scroll_linger_speed = 32
	self.layers_scroll_exit_speed = 2500
	self.layers_scroll_speed = self.layers_scroll_enter_speed
	self.layers_linger_zone = 32
end

function BossIntroMenu:update(dt)
	BossIntroMenu.super.update(self, dt)

	self.border_width = lerp(self.border_width, self.border_width_target, 0.08)
	self.bg_color[4] = lerp(self.bg_color[4], self.bg_alpha_target, 0.08)

	if self.layers_scroll <= -self.layers_linger_zone then
		self.border_width_target = -self.title_border_add
		self.bg_alpha_target = 0.0
	end
	
	if self.layers_scroll > self.layers_linger_zone then
		self.layers_scroll_speed = self.layers_scroll_enter_speed

	elseif self.layers_scroll > -self.layers_linger_zone then
		self.layers_scroll_speed = self.layers_scroll_linger_speed

	elseif self.layers_scroll <= -self.layers_linger_zone then
		self.layers_scroll_speed = self.layers_scroll_exit_speed

	end
	-- layers_scroll_exit_speed
	
	self.layers_scroll = self.layers_scroll - dt * self.layers_scroll_speed
	self.border_scroll = (self.border_scroll + self.border_scroll_speed * dt) % self.border_loop_threshold

	if self.layers_scroll < -CANVAS_WIDTH * 1.5 then
		game.menu_manager:set_menu()

	end
end

function BossIntroMenu:draw()
	BossIntroMenu.super.draw(self)

	self:draw_borders()
	self:draw_layers()

	local h = get_text_height(self.title) * 3
	print_outline(COL_WHITE, COL_BLACK_BLUE, self.title, self.title_padding, CANVAS_HEIGHT - self.border_width - h + 32, 3, 0, 3)
end

function BossIntroMenu:draw_borders()
	local x = round(-self.border_loop_threshold + self.border_scroll)
	love.graphics.draw(images.sawtooth_separator, x, round(self.border_width), 0, 1, -1)
	rect_color(COL_BLACK_BLUE, "fill", 0, 0, CANVAS_WIDTH, round(self.border_width) - 8)
	
	local bot_y = CANVAS_HEIGHT - self.border_width - self.title_border_add
	love.graphics.draw(images.sawtooth_separator, x, bot_y)
	rect_color(COL_BLACK_BLUE, "fill", 0, bot_y + 8, CANVAS_WIDTH, CANVAS_HEIGHT - bot_y)	
end

function BossIntroMenu:draw_layers()
	for _, layer in pairs(self.layers) do
		love.graphics.draw(layer.image, self.layers_scroll * layer.z_mult, 0)
	end
end

return BossIntroMenu