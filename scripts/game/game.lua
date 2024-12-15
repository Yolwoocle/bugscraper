local TextManager = require "scripts.text"
local backgrounds = require "data.backgrounds"
local LightWorld = require "scripts.graphics.light_world"
Text = TextManager:new()

local Class = require "scripts.meta.class"
local CollisionManager = require "scripts.physics.collision"
local Player = require "scripts.actor.player"
local Enemies = require "data.enemies"
local ParticleSystem = require "scripts.game.particles"
local AudioManager = require "scripts.audio.audio"
local MenuManager = require "scripts.ui.menu.menu_manager"
local InputManager = require "scripts.input.input"
local MusicPlayer = require "scripts.audio.music_player"
local Level = require "scripts.level.level"
local GameUI = require "scripts.ui.game_ui"
local Debug = require "scripts.game.debug"
local Camera = require "scripts.game.camera"
local Layer = require "scripts.graphics.layer"
local LightLayer = require "scripts.graphics.light_layer"
local ScreenshotManager = require "scripts.screenshot"
local QueuedPlayer = require "scripts.game.queued_player"
local GunDisplay = require "scripts.actor.enemies.gun_display"

local DiscordPresence = require "scripts.meta.discord_presence"
local Steamworks = require "scripts.meta.steamworks"

local guns = require "data.guns"
local upgrades = require "data.upgrades"
local shaders = require "data.shaders"
local images = require "data.images"
local skins = require "data.skins"
local sounds = require "data.sounds"
local utf8 = require "utf8"

require "bugscraper_config"
require "scripts.meta.constants"
require "scripts.util"
require "scripts.meta.post_constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	Input = InputManager:new(self)
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()
	Audio = AudioManager:new()
	Screenshot = ScreenshotManager:new()

	Input:init_users()

	SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
	-- love.window.setTitle("Bugscraper")
	-- love.window.setIcon(love.image.newImageData("icon.png"))
	gfx.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")

	self:update_screen()

	main_canvas = gfx.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Load fonts
	-- FONT_REGULAR = gfx.newFont("fonts/Hardpixel.otf", 20)
	FONT_REGULAR = gfx.newImageFont("fonts/hope_gold.png", FONT_CHARACTERS)
	FONT_7SEG = gfx.newImageFont("fonts/7seg_font.png", " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	FONT_MINI = gfx.newFont("fonts/Kenney Mini.ttf", 8)
	FONT_CHINESE = gfx.newFont("fonts/BoutiqueBitmap9x9_1.9.ttf", 10)
	FONT_PAINT = gfx.newFont("fonts/NicoPaint-Regular.ttf", 16)

	gfx.setFont(FONT_REGULAR)

	-- Audio ===> Moved to OptionsManager
	-- self.volume = options:get("volume")
	-- self.sound_on = options:get("sound_on")

	Options:set("volume", Options:get("volume"))

	self:new_game()

	self.debug = Debug:new(self)
	self.menu_manager = MenuManager:new(self)
	love.mouse.setVisible(Options:get("mouse_visible"))

	self.is_game_ui_visible = true
	self.is_first_time = Options.is_first_time
	self.has_seen_controller_warning = false
	self.ui_visible = true

	self.discord_presence = DiscordPresence
	self.steamworks = Steamworks

	self.debug_mode = DEBUG_MODE

	self.show_splash = true
end

function Game:new_game()
	if OPERATING_SYSTEM ~= "Web" then -- scotch
		love.audio.stop()
	end

	-- Reset global systems
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()
	Input:mark_all_actions_as_handled()

	self.t = 0
	self.frame = 0

	-- Remove old queued players
	self:remove_queued_players()

	-- Players
	self.waves_until_respawn = {}
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		self.waves_until_respawn[i] = {-1, nil}
	end

	-- Camera
	self.camera = Camera:new()
	self.camera:set_position(312 - 16, 48)

	self.level = Level:new(self)

	-- Actors
	self.actor_limit = 100
	self.actors = {}
	self:init_players()

	-- Debugging
	self.colview_mode = false
	self.msg_log = {}

	self.test_t = 0

	-- Logo
	self.logo_y = 0
	self.logo_vy = 0
	self.logo_a = 0
	self.move_logo = false
	self.jetpack_tutorial_y = -30
	self.move_jetpack_tutorial = false

	if self.menu_manager then
		self.menu_manager:reset()
		self.menu_manager:set_menu()
	end

	self.apply_bounds_clamping = true

	self.stats = {
		floor = 0,
		kills = 0,
		time = 0,
		max_combo = 0,
	}
	self.kills = 0
	self.time = 0
	self.max_combo = 0

	self.frames_to_skip = 0
	self.slow_mo_rate = 0

	self.light_world = LightWorld:new()

	self.layers = {}
	self.layers_count = LAYER_COUNT
	self:init_layers()

	self.is_light_on = true
	self.draw_shadows = true
	self.shadow_ox = -1
	self.shadow_oy = 2
	self.object_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.front_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.smoke_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.smoke_buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Music
	if self.music_player then self.music_player:stop() end
	self.music_player = MusicPlayer:new()
	self.music_player:set_disk("intro")
	self.music_player:play()
	self.sfx_elevator_bg            = sounds.elevator_bg.source
	self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	-- self.music_source:setVolume(options:get("music_volume"))
	self.sfx_elevator_bg:setVolume(0)
	self.sfx_elevator_bg:play()

	-- Cutscenes
	self.cutscene = nil

	self.can_start_game = false
	self.game_state = GAME_STATE_WAITING
	self.endless_mode = false
	self.timer_before_game_over = 0
	self.max_timer_before_game_over = 3.3

	-- UI
	self.game_ui = GameUI:new(self, self.is_game_ui_visible)
	self.menu_blur = 1
	self.max_menu_blur = 3

	self.notif = ""
	self.notif_timer = 0.0

	self.upgrades = {}
	self:update_skin_choices()

	Options:update_volume()
end

function Game:init_layers()
	self.layers = {}
	for i = 1, self.layers_count do
		local layer
		if i == LAYER_LIGHT then
			layer = LightLayer:new(CANVAS_WIDTH, CANVAS_HEIGHT, self.light_world)
		else
			layer = Layer:new(CANVAS_WIDTH, CANVAS_HEIGHT)
		end
		table.insert(self.layers, layer)
	end
end

function Game:get_window_flags()
	return {
		fullscreen = ternary(OPERATING_SYSTEM == "Web", false, Options:get("is_fullscreen")),
		resizable = true,
		vsync = Options:get("is_vsync"),
		minwidth = CANVAS_WIDTH,
		minheight = CANVAS_HEIGHT,
	}
end

function Game:on_resize(w, h)
	if not Options:get("is_fullscreen") then
		Options:set("windowed_width", w)
		Options:set("windowed_height", h)
		Options:set("is_window_maximized", love.window.isMaximized())
	end
	self:update_screen()
end

function Game:update_fullscreen(is_fullscreen)
	love.window.setFullscreen(is_fullscreen)

	if not is_fullscreen then
		local window_w = Options:get("windowed_width")
		local window_h = Options:get("windowed_height")
		local maximized = Options:get("is_window_maximized")

		love.window.setMode(window_w, window_h, self:get_window_flags())
		if maximized then
			love.window.maximize()
		end
	end

	self:update_screen()
end

function Game:update_screen()
	WINDOW_WIDTH, WINDOW_HEIGHT = gfx.getDimensions()

	local pixel_scale_mode = Options:get("pixel_scale")

	local screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	local screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	local auto_scale = math.min(screen_sx, screen_sy)

	local scale = auto_scale

	if pixel_scale_mode == "auto" then
		scale = auto_scale
	elseif pixel_scale_mode == "max_whole" then
		scale = math.floor(auto_scale)
	elseif type(tonumber(pixel_scale_mode)) == "number" then
		scale = math.min(tonumber(pixel_scale_mode), auto_scale)
	else
		print("Game.update_screen: WARNING: pixel scale mode has invalid value: '" .. tostring(pixel_scale_mode) .. "'")
	end

	CANVAS_SCALE = scale

	CANVAS_OX = math.floor(max(0, (WINDOW_WIDTH - CANVAS_WIDTH * CANVAS_SCALE) / 2))
	CANVAS_OY = math.floor(max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * CANVAS_SCALE) / 2))
end

function Game:update(dt)
	self.frame = self.frame + 1

	self.camera:update_screenshake(dt)

	self.frames_to_skip = max(0, self.frames_to_skip - 1)
	local do_frameskip = self.slow_mo_rate ~= 0 and self.frame % self.slow_mo_rate ~= 0
	if self.frames_to_skip > 0 or do_frameskip then
		return
	end

	Input:update(dt)
	self.music_player:update(dt)

	-- Menus
	self.menu_manager:update(dt)
	if self.debug_mode then
		self.debug:update(dt)
	end

	if not self.menu_manager.cur_menu then
		self:update_main_game(dt)
	end

	for i = 1, #self.layers - 1 do
		self.layers[i].blur = Options:get("menu_blur") and (self.menu_manager.cur_menu ~= nil) and
		(self.menu_manager.cur_menu.blur_enabled)
	end

	self.discord_presence:update(dt)
	self.steamworks:update(dt)

	-- THIS SHOULD BE LAST
	Input:update_last_input_state(dt)
end

function Game:update_main_game(dt)
	self.camera:update(dt)

	if self.game_state == GAME_STATE_PLAYING then
		self.time = self.time + dt
	end
	self.t = self.t + dt

	self:listen_for_player_join(dt)

	self.level:update(dt)

	self:update_timer_before_game_over(dt)

	self.game_ui:update(dt)
	self:update_skin_choices()
	self:update_queued_players(dt)
	Particles:update(dt)
	self:update_actors(dt)
	self:update_logo(dt)
	self:update_camera_offset(dt)
	self:update_debug(dt)
	if self.cutscene then
		self.cutscene:update(dt)
		if not self.cutscene.is_playing then
			self.cutscene = nil
		end
	end
	self.light_world:update(dt)

	self.notif_timer = math.max(self.notif_timer - dt, 0)
end

function Game:quit()
	self.discord_presence:quit()
	self.steamworks:quit()
end

function Game:get_enemy_count()
	local enemy_count = 0
	for _, actor in pairs(self.actors) do
		if actor.is_active and actor.counts_as_enemy then
			enemy_count = enemy_count + 1
		end
	end
	return enemy_count
end

function Game:update_actors(dt)
	if self.sort_actors_flag then
		table.sort(self.actors, function(a, b)
			if a.z == b.z then
				return a.creation_index > b.creation_index
			end
			return a.z > b.z
		end)
		self.sort_actors_flag = false
	end

	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]

		if not actor.is_removed and actor.is_active then
			actor:update(dt)
			if actor.is_affected_by_bounds and self.apply_bounds_clamping then
				actor:clamp_to_bounds(self.level.cabin_inner_rect)
			end

			if not self.level.kill_zone:is_point_in_inclusive(actor.mid_x, actor.mid_y) then
				actor:kill()
			end
		end

		if actor.is_removed then
			actor:final_remove()
			table.remove(self.actors, i)
		end
	end
end

function Game:update_logo(dt)
	self.logo_a = self.logo_a + dt * 12
	if self.move_logo then
		self.logo_vy = self.logo_vy - dt
		self.logo_y = self.logo_y + self.logo_vy
	end
	if self.move_jetpack_tutorial then
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, 70, 0.1)
	else
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, -30, 0.1)
	end
end

function Game:update_camera_offset(dt)
	-- Cafeteria camera pan on the right edge
	-- local all_players_on_the_right = ternary(#self.players == 0, false, true)
	-- for _, player in pairs(self.players) do
	-- 	if player.mid_x < (76 * 16) then
	-- 		all_players_on_the_right = false
	-- 		break
	-- 	end
	-- end

	-- if all_players_on_the_right and self.level:is_on_cafeteria() then
	-- 	self.camera:set_target_offset(1000, 0)
	-- else
	-- 	self.camera:set_target_offset(0, 0)
	-- end
end

function Game:get_camera_position()
	return self.camera:get_position()
end

function Game:set_camera_position(x, y)
	self.camera:set_position(x, y)
end

function Game:get_zoom()
	return self.camera:get_zoom()
end

function Game:set_zoom(zoom)
	self.camera:set_zoom(zoom)
end

function Game:update_debug(dt)

end

function Game:get_layer(layer_id)
	return self.layers[layer_id]
end

function Game:draw_on_layer(layer_id, paint_function, params)
	local layer = self.layers[layer_id]
	if layer == nil then return end

	params = param(params, {})
	local apply_camera = param(params.apply_camera, true)

	layer:paint(paint_function, {
		apply_camera = apply_camera,
		camera = ternary(apply_camera, self.camera, nil),
	})
end

function Game:draw()
	-- Using a canvas for that sweet, resizable pixel art
	gfx.setCanvas(main_canvas)
	gfx.clear(0, 0, 0)
	gfx.translate(0, 0)

	self:draw_game()

	gfx.setCanvas()
	gfx.origin()
	gfx.scale(1, 1)

	gfx.draw(main_canvas, CANVAS_OX, CANVAS_OY, 0, CANVAS_SCALE, CANVAS_SCALE)

	if self.debug.layer_view then
		self.debug:draw_layers()
	end
	if self.notif_timer > 0 then
		love.graphics.print(self.notif, 0, 0, 0, 3, 3)
	end
end

function Game:draw_game()
	-- local real_camx, real_camy = math.cos(self.t) * 10, math.sin(self.t) * 10;
	exec_on_canvas(self.smoke_canvas, love.graphics.clear)

	---------------------------------------------

	self:draw_on_layer(LAYER_BACKGROUND, function()
		love.graphics.clear()
		self.level:draw()
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_OBJECTS, function()
		love.graphics.clear()

		Particles:draw_layer(PARTICLE_LAYER_BACK)

		-- Draw actors
		for _, actor in pairs(self.actors) do
			if not actor.is_player and actor.is_active then
				actor:draw()
			end
		end
		for _, p in pairs(self.players) do
			if p.is_active then
				p:draw()
			end
		end

		Particles:draw_layer(PARTICLE_LAYER_NORMAL)
	end)

	self:draw_on_layer(LAYER_OBJECT_SHADOWLESS, function()
		love.graphics.clear()
		Particles:draw_layer(PARTICLE_LAYER_SHADOWLESS)
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_HUD, function()
		love.graphics.clear()
		for k, actor in pairs(self.actors) do
			if actor.is_active and actor.draw_hud and self.game_ui.is_visible then
				actor:draw_hud()
			end
		end
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_SHADOW, function()
		love.graphics.clear()

		exec_color({ 0, 0, 0, 0.5 }, function()
			love.graphics.draw(self:get_layer(LAYER_OBJECTS).canvas, self.shadow_ox, self.shadow_oy)
			love.graphics.draw(self:get_layer(LAYER_HUD).canvas, self.shadow_ox, self.shadow_oy)
		end)
	end, { apply_camera = false })

	-----------------------------------------------------

	self:draw_on_layer(LAYER_FRONT, function()
		love.graphics.clear()

		self:draw_smoke_canvas()
		self.level:draw_front()

		for _, actor in pairs(self.actors) do
			if actor.is_active and actor.is_front then
				actor:draw()
			end
		end

		Particles:draw_layer(PARTICLE_LAYER_FRONT)
	end)

	-----------------------------------------------------

	self:draw_on_layer(LAYER_LIGHT, function()
		-- love.graphics.clear({0, 0, 0, 0.85})
		local c = copy_table(COL_BLACK_BLUE)
		c[4] = self.light_world.darkness_intensity
		rect_color(c, "fill", -CANVAS_WIDTH, -CANVAS_HEIGHT, CANVAS_WIDTH * 3, CANVAS_HEIGHT * 3)
	end)

	-----------------------------------------------------

	-- UI
	self:draw_on_layer(LAYER_UI, function()
		love.graphics.clear()

		love.graphics.draw(self.front_canvas, 0, 0)
		self.game_ui:draw()
		self.level:draw_ui()
		if self.debug.colview_mode then
			self.debug:draw_colview()
		end
	end, { apply_camera = false })

	-----------------------------------------------------

	-- Menus
	self:draw_on_layer(LAYER_MENUS, function()
		love.graphics.clear()

		-- Menus
		if self.menu_manager.cur_menu then
			self.menu_manager:draw()
		end
		self.game_ui:draw_front()

		if self.debug_mode then
			self.debug:draw()
		end
	end, { apply_camera = false })

	-----------------------------------------------------

	love.graphics.origin()
	love.graphics.scale(1)
	for i = 1, #self.layers do
		local layer = self.layers[i]
		if (not layer.is_light_layer) or (layer.is_light_layer and not self.is_light_on) then
			self.layers[i]:draw(0, 0)
		end
	end

	--'Memory used (in kB): ' .. collectgarbage('count')

	-- local t = "EARLY VERSION - NOT FINAL!"
	-- gfx.print(t, CANVAS_WIDTH-get_text_width(t), 0)
	-- local t = os.date('%a %d/%b/%Y')
	-- print_color({.7,.7,.7}, t, CANVAS_WIDTH-get_text_width(t), 12)	
end

function Game:draw_smoke_canvas()
	self.camera:reset_transform()

	-- Used for effects for the stink bugs
	exec_on_canvas(self.smoke_buffer_canvas, function()
		love.graphics.clear()

		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.draw(self.smoke_canvas, 0, 4)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.smoke_canvas, 0, 0)
	end)
	exec_on_canvas(self.smoke_canvas, function()
		love.graphics.clear()

		love.graphics.setColor(0, 0, 0.1)
		-- Outline
		love.graphics.draw(self.smoke_buffer_canvas, -1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 0, -1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 0)
	end)

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.draw(self.smoke_canvas, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)

	self.camera:apply_transform()
end

function Game:set_ui_visible(bool)
	self.game_ui:set_visible(bool)
end

function Game:listen_for_player_join(dt)
	if self.game_state ~= GAME_STATE_WAITING then return end

	if Input:action_pressed_global("join_game") then
		local global_user = Input:get_global_user()
		local last_button = global_user.last_pressed_button
		local input_profile_id = ""
		local joystick = nil

		local can_add_keyboard_user = ternary(
			last_button and last_button.type == INPUT_TYPE_KEYBOARD,
			(Input:get_number_of_users(INPUT_TYPE_KEYBOARD) <= 0),
			true
		)
		if last_button and Input:can_add_user() and can_add_keyboard_user then
			if last_button.type == INPUT_TYPE_KEYBOARD then
				input_profile_id = "keyboard_solo"
			elseif last_button.type == INPUT_TYPE_CONTROLLER then
				input_profile_id = "controller"
				joystick = Input:get_global_user().last_active_joystick
			end
			self:queue_join_game(input_profile_id, joystick)
		end
	end

	if Input:action_pressed_global("split_keyboard") then
		if Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 1 then
			self:queue_join_game("keyboard_solo")
			Input:split_keyboard()

			-- elseif Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 2 then
			-- 	self:unsplit_keyboard_and_kick_second_player()
		end
	end
end

function Game:remove_queued_player(player_n)
    local queued_player = self.queued_players[player_n]
	if not queued_player then
		return
	end

	Input:remove_user(player_n)
	self.queued_players[player_n]:remove()
	self.queued_players[player_n] = nil
end

function Game:remove_queued_players()
	if self.queued_players then
		for _, queued_player in pairs(self.queued_players) do
			Input:remove_user(queued_player.player_n)
		end
	end
	self.queued_players = {}
end

function Game:unsplit_keyboard_and_kick_second_player()
	local second_user = Input:get_users(INPUT_TYPE_KEYBOARD)[2]
	if second_user == nil then return end

	self:leave_game(second_user.n)
	Input:unsplit_keyboard()
end

function Game:on_menu()
	self.music_player:on_menu()
	self:pause_repeating_sounds()
end

function Game:on_pause()
	Audio:play("menu_pause")
end

function Game:on_unpause()
	Audio:play("menu_unpause")
end

function Game:pause_repeating_sounds()
	self.sfx_elevator_bg:pause()
	for k, a in pairs(self.actors) do
		a:pause_constant_sounds()
	end
end

function Game:on_button_glass_spawn(button)
	self.music_player:stop()
end

function Game:on_unmenu()
	self.music_player:on_unmenu()
	self.sfx_elevator_bg:play()

	for k, a in pairs(self.actors) do
		a:resume_constant_sounds()
	end
end

function Game:set_music_volume(vol)
	self.music_player:set_volume(vol)
end

function Game:new_actor(actor, buffer_enemy)
	if #self.actors >= self.actor_limit then
		actor:remove()
		actor:final_remove()
		return
	end

	self.sort_actors_flag = true
	table.insert(self.actors, actor)
end

function Game:on_kill(actor)
	if actor.counts_as_enemy then
		self.kills = self.kills + 1
	end

	if actor.is_player then
		self:on_player_death(actor)
	end
end

function Game:on_player_death(player)
	self.players[player.n] = nil
	self.waves_until_respawn[player.n] = {1, player}

	if self:get_number_of_alive_players() <= 0 then
		self:on_last_player_death(player)
	end
end

function Game:on_last_player_death(player)
	self.menu_manager:set_can_pause(false)
	self.music_player:set_disk("game_over")
	self.music_player:pause()
	self:pause_repeating_sounds()
	self.game_state = GAME_STATE_DYING
	self.timer_before_game_over = self.max_timer_before_game_over

	self:save_stats()
end

function Game:update_timer_before_game_over(dt)
	if self.game_state ~= GAME_STATE_DYING then
		return
	end
	self.timer_before_game_over = self.timer_before_game_over - dt

	if self.timer_before_game_over <= 0 then
		self:game_over()
	end
end

function Game:kill_all_active_enemies()
	for _, actor in pairs(self.actors) do
		if actor.is_active and actor.counts_as_enemy then
			actor:kill()
		end
	end
end

function Game:kill_all_enemies()
	for _, actor in pairs(self.actors) do
		if actor.counts_as_enemy then
			actor:kill()
		end
	end
end

function Game:save_stats()
	self.stats.time = self.time
	self.stats.floor = self.level.floor
	self.stats.kills = self.kills
	self.stats.max_combo = self.max_combo
end

function Game:game_over()
	self.menu_manager:set_menu("game_over")
	-- for _, a in pairs(self.actors) do
	-- 	a:remove()
	-- 	a:final_remove()
	-- end
end

function Game:do_win()

end

function Game:get_floor()
	return self.level:get_floor()
end

function Game:set_floor(val)
	self.level:set_floor(val)
end

function draw_log()
	-- log
	local x2 = floor(CANVAS_WIDTH / 2)
	local h = gfx.getFont():getHeight()
	print_label("--- LOG ---", x2, 0)
	for i = 1, min(#msg_log, max_msg_log) do
		print_label(msg_log[i], x2, i * h)
	end
end

function Game:init_players()
	self.players = {}

	for i = 1, MAX_NUMBER_OF_PLAYERS do
		if Input:get_user(i) ~= nil then
			self:new_player(i)
		end
	end
end


function Game:queue_join_game(input_profile_id, joystick)
	-- FIXME ça marche pas quand tu join avec manette puis que tu join sur clavier
	local player_n = Input:find_free_user_number()
	if player_n == nil then
		return
	end
	-- Is joystick already taken?
	if joystick ~= nil and Input:get_joystick_user(joystick) ~= nil then
		return
	end

	Input:new_user(player_n)
	Input:set_last_ui_user_n(player_n)
	if joystick ~= nil then
		Input:assign_joystick(player_n, joystick)
	end
	Input:assign_input_profile(player_n, input_profile_id)

	self.queued_players[player_n] = QueuedPlayer:new(player_n, input_profile_id, joystick)

	return player_n
end

function Game:join_game(player_n)
	local player = self:new_player(player_n, nil, nil, true)

	if player then
		self.skin_choices[player.skin.id] = false
	end

	self.game_ui:on_player_joined(player)
end

function Game:new_player(player_n, x, y, put_in_buffer)
	player_n = player_n or self:find_free_player_number()
	if player_n == nil then
		return
	end
	local mx = math.floor(self.level.door_rect.ax)
	-- x = param(x, mx + ((player_n-1) / (MAX_NUMBER_OF_PLAYERS-1)) * (self.level.door_rect.bx - self.level.door_rect.ax))
	-- x = param(x, mx + math.floor((self.level.door_rect.bx - self.level.door_rect.ax)/2))
	x = param(x, 26 * 16 + 16 * 5 * (player_n - 1))
	y = param(y, CANVAS_HEIGHT - 3 * 16 + 4)

	local player = Player:new(player_n, x, y, Input:get_user(player_n):get_skin() or skins[1])
	self.players[player_n] = player
	self.waves_until_respawn[player_n] = {-1, nil}
	if put_in_buffer then
		player:set_active(false)
		self.level:buffer_actor(player)
		self.level.elevator:open_door(1.0)
	end

	self:new_actor(player)

	return player
end

function Game:leave_game(player_n)
	if self.players[player_n] == nil then
		return
	end

	local player = self.players[player_n]
	local profile_id = Input:get_input_profile_from_player_n(player.n):get_profile_id()

	Particles:smoke(player.mid_x, player.mid_y, 10)
	self.players[player_n]:remove()
	self.players[player_n] = nil
	Input:remove_user(player_n)
	if profile_id == "keyboard_split_p1" or profile_id == "keyboard_split_p2" then
		Input:unsplit_keyboard()
	end
end

function Game:update_queued_players(dt)
	for _, queued_player in pairs(self.queued_players) do
		queued_player:update(dt, self.queued_players)
	end

	for key, queued_player in pairs(self.queued_players) do
		if queued_player.is_removed then
			self.queued_players[key] = nil
		end
	end
end

function Game:get_number_of_alive_players()
	local count = 0
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		if self.players[i] ~= nil then
			count = count + 1
		end
	end
	return count
end

function Game:enable_endless_mode()
	self.endless_mode = true
	self.music_player:play()
end

function Game:start_game()
	self.move_logo = true
	self.game_state = GAME_STATE_PLAYING
	self.music_player:set_disk("w1")
	self.level:activate_enemy_buffer()
	self.level:begin_next_wave_animation()
	self:remove_queued_players()

	self.menu_manager:set_can_pause(true)
	self:set_zoom(1)
	local x, y = self.camera:get_position()
	game.camera:set_target_position(0, 0)
	game.camera:reset()
	self:set_camera_position(x, y)
	game.camera:set_x_locked(true)
	game.camera:set_y_locked(true)
end

function Game:on_red_button_pressed()
	self:save_stats()
	self.game_state = GAME_STATE_ELEVATOR_BURNING
	self.menu_manager:set_can_pause(false)
	self.level:on_red_button_pressed()
end

function Game:on_elevator_crashed()
	self.game_state = GAME_STATE_WIN
	self.menu_manager:set_can_pause(true)
	self.level:on_elevator_crashed()
end

function Game:apply_upgrade(upgrade)
	table.insert(self.upgrades, upgrade)
	for i, player in pairs(self.players) do
		player:apply_upgrade(upgrade)
	end
end

function Game:revoke_upgrade(upgrade_index)
	assert(self.upgrades[upgrade_index] ~= nil)

	table.remove(self.upgrades, upgrade_index)
	for i, player in pairs(self.players) do
		player:revoke_upgrade(upgrade_index)
	end
end

function Game:screenshot()
	local filename, filepath, imgdata, imgpng = Screenshot:screenshot()
	self.notif = "screenshot " .. filename
	self.notif_timer = 3.0
	-- Particles:word(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
end

-- SCOTCH!!!
function Game:new_gun_display(x, y)
	local gun = guns:get_random_gun()
	return GunDisplay:new(x, y, gun)
end

function Game:play_cutscene(cutscene)
	self.cutscene = cutscene
	self.cutscene:play()
end

function Game:kill_actors_with_name(name)
	for _, actor in pairs(game.actors) do
		if actor.name == name then
			actor:kill()
		end
	end
end

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

function Game:keypressed(key, scancode, isrepeat)
	if scancode == "f12" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rshift")) then
		self.debug_mode = true
		self.debug.notif = "debug mode enabled"
		self.debug.notif_timer = 3.0

		-- self.debug
	end

	if self.menu_manager then
		self.menu_manager:keypressed(key, scancode, isrepeat)
	end
	if self.debug then
		self.debug:keypressed(key, scancode, isrepeat)
	end
end

function Game:keyreleased(key, scancode)
	if self.debug then
		self.debug:keyreleased(key, scancode)
	end
end

function Game:joystickadded(joystick)
	Input:joystickadded(joystick)
end

function Game:joystickremoved(joystick)
	Input:joystickremoved(joystick)

	local player_n = Input:get_joystick_user_n(joystick)
	if player_n ~= -1 then
		if self.game_state == GAME_STATE_WAITING then
			self:leave_game(player_n)
			self.menu_manager:unpause()
		else
			self.menu_manager:enable_joystick_wait_mode(joystick)
		end
	end
end

function Game:gamepadpressed(joystick, buttoncode)
	Input:gamepadpressed(joystick, buttoncode)
	if self.menu_manager then self.menu_manager:gamepadpressed(joystick, buttoncode) end
	if self.debug then self.debug:gamepadpressed(joystick, buttoncode) end
end

function Game:gamepadreleased(joystick, buttoncode)
	Input:gamepadreleased(joystick, buttoncode)
	if self.menu_manager then self.menu_manager:gamepadreleased(joystick, buttoncode) end
	if self.debug then self.debug:gamepadreleased(joystick, buttoncode) end
end

function Game:gamepadaxis(joystick, axis, value)
	Input:gamepadaxis(joystick, axis, value)
	if self.menu_manager then self.menu_manager:gamepadaxis(joystick, axis, value) end
	if self.debug then self.debug:gamepadaxis(joystick, axis, value) end
end

function Game:mousepressed(x, y, button, istouch, presses)
	-- Input:mousepressed(joystick, axis, value)
	if self.menu_manager then self.menu_manager:mousepressed(x, y, button, istouch, presses) end
end

function Game:mousereleased(x, y, button, istouch, presses)
	-- Input:mousereleased(joystick, axis, value)
	if self.menu_manager then self.menu_manager:mousereleased(x, y, button, istouch, presses) end
end

function Game:textinput( text )
	if self.menu_manager then self.menu_manager:textinput(text) end
end

function Game:focus(f)
	if f then
	else
		if Options:get("pause_on_unfocus") and self.menu_manager and Input:get_number_of_users() >= 1 then
			self.menu_manager:pause()
		end
	end
end

function Game:screenshake(q)
	self.camera:screenshake(q)
end

function Game:frameskip(q)
	self.frames_to_skip = math.max(self.frames_to_skip, q)
	self.frames_to_skip = math.min(60, self.frames_to_skip)
end

function Game:slow_mo(q)
	self.slow_mo_rate = q
end

function Game:reset_slow_mo(q)
	self.slow_mo_rate = 0
end

function Game:update_skin_choices()
	self.skin_choices = {}
	for i = 1, #skins do
		self.skin_choices[i] = true
	end
	for i, player in pairs(self.players) do
		self.skin_choices[player.skin.id] = false
	end
end

return Game
