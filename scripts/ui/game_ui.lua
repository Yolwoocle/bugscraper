require "scripts.util"
local images = require "data.images"
local Class = require "scripts.meta.class"
local PlayerPreview = require "scripts.ui.player_preview"
local shaders = require "data.shaders"
local Ui = require "scripts.ui.ui"
local Timer = require "scripts.timer"

local GameUI = Class:inherit()

function GameUI:init(game, is_visible)
	self.game = game

    self.is_visible = param(is_visible, true)

	self.floating_text = ""
	self.floating_text_y = -50
	self.floating_text_target_y = -100

	self.player_previews = {}
	local w = 108
	local spacing = 10
	local x = CANVAS_WIDTH/2 - ((w + spacing) * (MAX_NUMBER_OF_PLAYERS-1) + w)/2
	local y = 200
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		table.insert(self.player_previews, PlayerPreview:new(i, x, y, w, 64))
		x = x + w + spacing	
	end

	self.splash_x = 0
	self.splash_vx = 0
	self.show_splash = true

	self.cinematic_bar_loop_threshold = 14
	self.cinematic_bar_scroll = 0
	self.cinematic_bar_scroll_speed = -14
	self.cinematic_bar_current_height = 0
	self.cinematic_bar_height = 24

	self.fury_previous_value = 0
	self.fury_visual_width = 0
	self.fury_flash_timer = 0
	self.fury_flash_max_timer = 0.2
	self.fury_is_flashing = false

	self.offscreen_indicators_enabled = true
	
	self.title_buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.title = "Léo Bernard"
	self.subtitle = "Yolwoocle"
	self.overtitle = "A game by"
	self.title_alpha = 0.0
	self.title_alpha_target = 1.0

	self.title_intro_duration = 0.5
	self.title_stay_duration = 1.0
	self.title_outro_duration = 0.5

	self.title_state = "intro"
	self.title_state_timer = Timer:new(0.0)
	self.current_title_state_duration = "intro"

	self.dark_overlay_alpha = 0.0
	self.dark_overlay_alpha_target = 0.0

	self.t = 0
end

function GameUI:update(dt)
	self:update_floating_text(dt)
	for i, preview in pairs(self.player_previews) do
		preview:update(dt)
		preview.y = preview.base_y - self.game.logo_y
	end

	self:update_cinematic_bars(dt)
	self:update_splash(dt)
	self:update_fury(dt)
	self:update_convention_video(dt)
	self:update_title(dt)
	self.dark_overlay_alpha = move_toward(self.dark_overlay_alpha, self.dark_overlay_alpha_target, dt)

	self.t = self.t + dt
end

function GameUI:start_title(title, subtitle, overtitle, intro_dur, stay_dur, outro_dur)
	self.title = Text:parse(title)
	self.subtitle = Text:parse(subtitle)
	self.overtitle = Text:parse(overtitle)

	self.title_intro_duration = intro_dur
	self.title_stay_duration = stay_dur
	self.title_outro_duration = outro_dur

	self.title_state = "intro"

	self.title_state_timer:start(self.title_intro_duration)
end

function GameUI:update_title(dt)
	if self.title_state_timer:update(dt) then
		if self.title_state == "intro" then
			self.title_state = "stay"
			self.title_state_timer:start(self.title_stay_duration)
			
		elseif self.title_state == "stay" then
			self.title_state = "outro"
			self.title_state_timer:start(self.title_outro_duration)

		elseif self.title_state == "outro" then
			self.title_state = "off"
			self.title = nil
			self.subtitle = nil
			self.overtitle = nil
		end
	end

	if self.title_state == "off" then
		self.title_alpha = 0
	end 
	if self.title_state == "stay" then
		self.title_alpha = 1
	end 
	if self.title_state == "intro" or self.title_state == "outro" then
		local a, b = 0, 1
		if self.title_state == "outro" then
			a, b = 1, 0
		end
		self.title_alpha = lerp(a, b, self.title_state_timer:get_ratio())
	end
end

function GameUI:update_floating_text(dt)
	self.floating_text_y = lerp(self.floating_text_y, self.floating_text_target_y, 0.05)
end

function GameUI:enable_floating_text(text)
	self.floating_text = text
	self.floating_text_target_y = 80
end

function GameUI:disable_floating_text()
	self.floating_text_target_y = -50
end

function GameUI:set_visible(bool)
    self.is_visible = bool
end

function GameUI:draw()
	if not self.is_visible then return end
	if game.debug and game.debug.title_junk then
		self:draw_timer()
		self:draw_version()
	end 
	self:draw_offscreen_indicators()
	self:draw_floating_text()
	self:draw_upgrades()

	self:draw_convention_video()
	self:draw_player_previews()
	self:draw_cinematic_bars()
	self:draw_fury()
	
	self:draw_titles()
	if self.dark_overlay_alpha > 0 then
		rect_color(transparent_color(COL_BLACK_BLUE, self.dark_overlay_alpha), "fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	end

	self:draw_splash_animation()
	-- local r
    -- r = game.level.cabin_inner_rect
    -- rect_color(COL_GREEN, "line", r.ax, r.ay, r.w, r.h)
	-- r = game.level.cabin_rect
    -- rect_color(COL_RED, "line", r.ax, r.ay, r.w, r.h)
end

function GameUI:draw_front()
	if not self.is_visible then return end

	self:draw_FPS()
end

function GameUI:draw_titles()
	exec_on_canvas(self.title_buffer_canvas, function()
		love.graphics.clear()

		Text:push_font(FONT_REGULAR)
		if self.title then
			print_centered_outline(nil, nil, self.title, CANVAS_CENTER[1], CANVAS_CENTER[2])
		end
		Text:pop_font()
	
		Text:push_font(FONT_MINI)
		if self.subtitle then
			print_centered_outline(nil, nil, self.subtitle, CANVAS_CENTER[1], CANVAS_CENTER[2] + 12)
		end
		if self.overtitle then
			print_centered_outline(COL_LIGHTEST_GRAY, nil, self.overtitle, CANVAS_CENTER[1], CANVAS_CENTER[2] - 16)
		end
		Text:pop_font()
	end)

	exec_color({1, 1, 1, self.title_alpha}, function()		
		love.graphics.draw(self.title_buffer_canvas, 0, 0)
	end)
end

function GameUI:draw_logo()
	for i=1, #LOGO_COLS + 1 do
		local ox, oy = cos(game.logo_a + i*.4)*8, sin(game.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = LOGO_COLS[i]
		local img = images.logo_shad
		if col == nil then
			col = COL_WHITE
			img = images.logo_noshad
		end
		love.graphics.setColor(col)
		love.graphics.draw(img, math.floor(logo_x + ox), math.floor(game.logo_y + oy))
		if DEMO_BUILD then
			if i == 4 then
				print_outline(COL_WHITE, COL_BLACK_BLUE, Text:text("game.demo"), logo_x + ox + 90, game.logo_y + oy + 19)
			else
				print_outline(col, col, Text:text("game.demo"), logo_x + ox + 90, game.logo_y + oy + 19)
			end
		end
	end
end

function GameUI:draw_version()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(FONT_MINI)

	local text = concat("v", BUGSCRAPER_VERSION)
	if BETA_BUILD then
		text = "Beta build: game might be unstable and change in the future - "..text
	end
	local x = math.floor(CANVAS_WIDTH - get_text_width(text) - 2)
	local y = self.game.logo_y
	print_color(COL_DARK_GRAY, text, x, y)
	love.graphics.setFont(old_font)

	-- if OPERATING_SYSTEM == "Web" and not game.has_seen_controller_warning then
	-- 	print_centered_outline(COL_MID_GRAY, COL_BLACK_BLUE, "⚠️ "..Text:text("game.warning_web_controller"), CANVAS_WIDTH/2, y+6)
	-- end
end

function GameUI:draw_timer()
	if not Options:get("timer_on") then 
		return
	end

	local text = time_to_string(game.time)
	rect_color({0,0,0,0.5}, "fill", 0, 10, get_text_width(text) + 16, 12)
	love.graphics.flrprint(text, 8, 8)
end

function GameUI:draw_FPS()
	if not Options:get("show_fps_warning") then
		return
	end
	
	local t = "⚠ "..Text:text("game.fps", love.timer.getFPS())
	
	if game.t > 2 and love.timer.getFPS() <= 50 then
		print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3)
		-- if game.menu_manager.cur_menu ~= nil then
		-- 	t = "⚠ "..Text:text("game.fps_warning")
		-- 	print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3+get_text_height())
		-- end
	end
end

function GameUI:draw_offscreen_indicators()
	if not self.offscreen_indicators_enabled then
		return
	end
	local cam_x, cam_y = self.game.camera:get_position()
	for i, player in pairs(self.game.all_players) do
		if (player.x + player.w < cam_x) or (cam_x + CANVAS_WIDTH < player.x) 
			or (player.y + player.h < cam_y) or (cam_y + CANVAS_HEIGHT < player.y) then 
			self:draw_offscreen_indicator_for(player)
		end
	end
end

function GameUI:draw_offscreen_indicator_for(player)
	-- local padding = 17
	local padding = 24
	local radius = 10
	
	local cam_x, cam_y = self.game.camera:get_position()
	local x = math.floor(clamp(player.mid_x - cam_x, padding, CANVAS_WIDTH - padding))
	local y = math.floor(clamp(player.mid_y - cam_y, padding, CANVAS_HEIGHT - padding))
	local rot = math.atan2(player.mid_y - (y + cam_y), player.mid_x - (x + cam_x))
	
	local scale = 0.5
	exec_color(player.skin.color_palette[3], function()
		draw_centered(images.offscreen_indicator, x+1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x-1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y+1, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y-1, rot, scale, scale)
	end)
	exec_color(player.skin.color_palette[1], function()
		draw_centered(images.offscreen_indicator, x, y, rot, scale, scale)
	end)
	
	shaders.draw_in_color:sendColor("fillColor", player.skin.color_palette[4])
	exec_color(player.skin.color_palette[4], function()
		print_centered(player.skin.icon, x, y)
	end)
	print_centered_outline(player.skin.color_palette[1], player.skin.color_palette[4], Text:text("player.abbreviation", player.n), x, y - 16)
end

function GameUI:draw_floating_text()
	if #self.floating_text > 0 then
		print_centered_outline(nil, nil, self.floating_text, CANVAS_WIDTH/2, self.floating_text_y)
	end
end

function GameUI:get_upgrade_preview_position(i)
	local padding = 4
	local item_size = 20
	return CANVAS_WIDTH - padding - item_size/2 - item_size * (i-1)
end

function GameUI:draw_upgrades()
	local item_size = 20
	local i = 1
	local y = 4 + item_size/2
	for _, upgrade in pairs(game.upgrades) do
		local x = self:get_upgrade_preview_position(i)
		draw_centered(upgrade.sprite, x, y)
		i = i + 1
	end
end

function GameUI:update_convention_video(dt)
	-- Exit if not in convention_mode
	if not Options:get("convention_mode") then
		if self.convention_video and self.convention_video:isPlaying() then
			self.convention_video:pause()
		end
		return
	end

	-- Load convention video if needed
	if not self.convention_video then
		-- Uncomment when videos are ready
		-- self.convention_video = love.graphics.newVideo("videos/testvideo.ogv")
		-- self.convention_video:play()
	end
		
	-- Rewind video if reached end
	if self.convention_video and not self.convention_video:isPlaying() then
		self.convention_video:rewind()
	end
end

function GameUI:draw_convention_video()
	if Options:get("convention_mode") and self.convention_video then
		love.graphics.draw(self.convention_video, 0, 0)
	end
end

function GameUI:draw_player_previews()
	for i, preview in pairs(self.player_previews) do
		preview:draw()
	end
end

function GameUI:on_player_joined(player)
	for i, preview in pairs(self.player_previews) do
		preview:on_player_joined(player)
	end
end

-- CINEMATIC BARS

function GameUI:update_cinematic_bars(dt)
	local target_height = 0
	if self.cinematic_bars_enabled then
		target_height = self.cinematic_bar_height
	end
	self.cinematic_bar_current_height = lerp(self.cinematic_bar_current_height, target_height, 0.08)

	self.cinematic_bar_scroll = (self.cinematic_bar_scroll + self.cinematic_bar_scroll_speed * dt) % self.cinematic_bar_loop_threshold
end


function GameUI:draw_cinematic_bars()
	Ui:draw_sawtooth_border(
		self.cinematic_bar_current_height, 
		self.cinematic_bar_current_height, 
		self.cinematic_bar_scroll, 
		{
			color = COL_BLACK_BLUE, 
			image_top = images.sawtooth_separator_small, 
			image_bottom = images.sawtooth_separator_small
		}
	)	
end

--- SPLASH

function GameUI:update_splash(dt)
	if self.splash_x < -CANVAS_WIDTH*2 then
		game.show_splash = false
	end
	self.splash_vx = self.splash_vx - dt*500 
	self.splash_x = self.splash_x + self.splash_vx * dt
end

function GameUI:draw_splash_animation()
	if not game.show_splash then 
		return
	end
	love.graphics.draw(images.splash, self.splash_x, 0)
end

--- FURY

function GameUI:update_fury(dt)
	local target = math.max((game.level.fury_bar - game.level.fury_threshold) * 32, 0)
	self.fury_visual_width = lerp(self.fury_visual_width, target, 0.3)
	if math.abs(self.fury_visual_width) <= 1 then
		self.fury_visual_width = 0
	end

	self.fury_flash_timer = self.fury_flash_timer - dt
	if self.fury_flash_timer < 0.0 then
		self.fury_flash_timer = self.fury_flash_timer + self.fury_flash_max_timer 
	end
	self.fury_is_flashing = (self.fury_flash_timer < self.fury_flash_max_timer/2)
end


function GameUI:draw_fury()
	-- print_centered_outline(nil, nil, concat(round(game.level.fury_bar, 1), " / ", game.level.fury_max, " (", game.level.fury_threshold, ")"), CANVAS_WIDTH/2, 24)
	if self.fury_visual_width <= 0 then
		return
	end	

	-- local y = 12
	local y = CANVAS_HEIGHT - 12
	local w = math.min(self.fury_visual_width, math.huge)
	local h = 8
	-- local col = ternary(self.fury_is_flashing, COL_YELLOW_ORANGE, COL_ORANGE)

	local col, text_col = COL_YELLOW_ORANGE, COL_LIGHT_YELLOW
	if game.level.has_energy_drink then
		col, text_col = COL_MID_BLUE, COL_LIGHT_BLUE
	end

	rect_color(col, "fill", CANVAS_WIDTH/2 - w, y-h/2, w*2, h)
	print_wavy_centered_outline_text(
		text_col, nil, 
		Text:text("game.combo", game.level.fury_combo), 
		-- concat(game.level.fury_combo), 
		CANVAS_WIDTH/2, y-h/2, nil, self.t, 2, 9, 0.8
	)

end

return GameUI