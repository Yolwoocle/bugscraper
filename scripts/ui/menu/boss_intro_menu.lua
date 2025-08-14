require "scripts.util"
local Menu = require "scripts.ui.menu.menu"
local TextMenuItem = require "scripts.ui.menu.items.text_menu_item"
local images       = require "data.images"
local ui = require "scripts.ui.ui"

local BossIntroMenu = Menu:inherit()

function BossIntroMenu:init(game, bg_color, title, sound, layers)
	BossIntroMenu.super.init(self, game, "", {{""}}, bg_color, nil, nil)

	self.sound = sound
	self.boss_title = title
	self.layers = layers
	self.draw_sawtooth_border = false

	self.is_backable = false
	self.do_pause_music_mode = false

	self:init_boss_intro()
end

function BossIntroMenu:on_set()
	BossIntroMenu.super.on_set(self)
	Audio:play(self.sound)
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
	
	self.layers_scroll = CANVAS_WIDTH * 3.5
	self.layers_scroll_enter_speed = 2500
	self.layers_scroll_linger_speed = 20
	self.layers_linger_zone = 38
	self.layers_scroll_exit_speed = 3000
	self.layers_scroll_speed = self.layers_scroll_enter_speed
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

	if self.layers_scroll < -CANVAS_WIDTH * 2.5 then
		game.menu_manager:set_menu()

	end
end

function BossIntroMenu:draw()
	BossIntroMenu.super.draw(self)

	self:draw_borders()
	self:draw_layers()

	local h = get_text_height(self.boss_title) * 3
	print_outline(COL_WHITE, COL_BLACK_BLUE, self.boss_title, self.title_padding, CANVAS_HEIGHT - self.border_width - h + 32, 3, 0, 3)
end

function BossIntroMenu:draw_borders()
	ui:draw_sawtooth_border(self.border_width, self.border_width + self.title_border_add, self.border_scroll)
end

function BossIntroMenu:draw_layers()
	for _, layer in pairs(self.layers) do
		love.graphics.draw(layer.image, self.layers_scroll * layer.z_mult, 0)
	end
end

return BossIntroMenu