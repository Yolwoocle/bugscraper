local Class = require "scripts.meta.class"
local CollisionManager = require "scripts.game.collision"
local Player = require "scripts.actor.player"
local Enemies = require "data.enemies"
local Bullet = require "scripts.actor.bullet"
local WorldGenerator = require "scripts.level.worldgenerator"
local ParticleSystem = require "scripts.game.particles"
local AudioManager = require "scripts.audio.audio"
local MenuManager = require "scripts.ui.menu.menu_manager"
local OptionsManager = require "scripts.game.options"
local InputManager = require "scripts.input.input"
local MusicPlayer = require "scripts.audio.music_player"
local MusicDisk = require "scripts.audio.music_disk"
local Level = require "scripts.game.level"
local InputButton = require "scripts.input.input_button"
local GameUI = require "scripts.ui.game_ui"
local Loot = require "scripts.actor.loot"
local Debug = require "scripts.game.debug"

local skins = require "data.skins"
local shaders  = require "data.shaders"
local sounds = require "data.sounds"
local images = require "data.images"
local guns = require "data.guns"
local utf8 = require "utf8"

require "scripts.util"
require "scripts.meta.constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	Input = InputManager:new(self)
	Options = OptionsManager:new(self)
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()
	Audio = AudioManager:new()

	Input:init_users()

	-- OPERATING_SYSTEM = "Web"
	OPERATING_SYSTEM = love.system.getOS()
	USE_CANVAS_RESIZING = true
	SCREEN_WIDTH, SCREEN_HEIGHT = 0, 0

	if OPERATING_SYSTEM == "Web" then
		USE_CANVAS_RESIZING = false
		CANVAS_SCALE = 2
		-- Init window
		love.window.setMode(CANVAS_WIDTH*CANVAS_SCALE, CANVAS_HEIGHT*CANVAS_SCALE, self:get_window_flags())
	else
		-- Init window
		love.window.setMode(Options:get("windowed_width"), Options:get("windowed_height"), self:get_window_flags())
	end
	
	SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
	love.window.setTitle("Bugscraper")
	love.window.setIcon(love.image.newImageData("icon.png"))
	gfx.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")

	self:update_screen()

	canvas = gfx.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Load fonts
	-- FONT_REGULAR = gfx.newFont("fonts/HopeGold.ttf", 16)
	FONT_REGULAR = gfx.newImageFont("fonts/hope_gold.png", FONT_CHARACTERS)
	FONT_7SEG = gfx.newImageFont("fonts/7seg_font.png", " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	FONT_MINI = gfx.newFont("fonts/Kenney Mini.ttf", 8)
	FONT_PAINT = gfx.newFont("fonts/NicoPaint-Regular.ttf", 16)
	gfx.setFont(FONT_REGULAR)
	
	-- Audio ===> Moved to OptionsManager
	-- self.volume = options:get("volume")
	-- self.sound_on = options:get("sound_on")

	Options:set_volume(Options:get("volume"))
	
	self:new_game()
	
	self.debug = Debug:new(self)
	self.menu_manager = MenuManager:new(self)
	love.mouse.setVisible(Options:get("mouse_visible"))

	self.is_first_time = Options.is_first_time
end

function Game:new_game()
	love.audio.stop()
	
	-- Reset global systems
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()

	-- number_of_players = (number_of_players or self.number_of_players) or 0

	self.t = 0
	self.frame = 0

	-- Players
	self.max_number_of_players = MAX_NUMBER_OF_PLAYERS
	self.number_of_players = 0
	self.waves_until_respawn = {}
	for i = 1, MAX_NUMBER_OF_PLAYERS do 
		self.waves_until_respawn[i] = -1
	end

	self.level = Level:new(self)

	-- Map & world gen
	self.shaft_w, self.shaft_h = 26,14
	self.world_generator = WorldGenerator:new(self.level.map)
	self.world_generator:generate(10203)
	self.world_generator:make_box(self.shaft_w, self.shaft_h)

	-- Level info
	self.floor = 0 --Floor n°

	-- Bounding box
	local map_w = self.level.map.width * BW
	local map_h = self.level.map.height * BW
	local box_ax = self.world_generator.box_ax
	local box_ay = self.world_generator.box_ay
	local box_bx = self.world_generator.box_bx
	local box_by = self.world_generator.box_by
	-- Don't try to understand all you have to know is that it puts collision 
	-- boxes around the elevator shaft
	self.boxes = {
		{name="box_up",     is_solid = false, x = -BW, y = -BW,  w=map_w + 2*BW,     h=BW + box_ay*BW},
		{name="box_down", is_solid = false, x = -BW, y = (box_by+1)*BW,  w=map_w + 2*BW,     h=BW*box_ay},
		{name="box_left", is_solid = false, x = -BW,  y = -BW,   w=BW + box_ax * BW, h=map_h + 2*BW},
		{name="box_right", is_solid = false, x = BW*(box_bx+1), y = -BW, w=BW*box_ax, h=map_h + 2*BW},
	}
	for i,box in pairs(self.boxes) do   Collision:add(box)   end
	
	-- Actors
	self.actor_limit = 100
	self.enemy_count = 0
	self.actors = {}
	self:init_players()

	-- Start button
	local nx = CANVAS_WIDTH * 0.75
	local ny = self.world_generator.box_by * BLOCK_WIDTH
	-- local l = create_actor_centered(Enemies.ButtonGlass, nx, ny)
	local l = create_actor_centered(Enemies.ButtonSmallGlass, floor(nx), floor(ny))
	self:new_actor(l)
	
	-- Exit sign 
	local exit_x = CANVAS_WIDTH * 0.25
	self:new_actor(create_actor_centered(Enemies.ExitSign, floor(exit_x), floor(ny)))

	-- Camera & screenshake
	self.cam_x = 0
	self.cam_y = 0
	self.cam_zoom = 1
	self.cam_realx, self.cam_realy = 0, 0
	self.cam_ox, self.cam_oy = 0, 0
	self.screenshake_q = 0
	self.screenshake_speed = 20

	-- Debugging
	self.debug_mode = true
	self.colview_mode = false
	self.msg_log = {}

	self.test_t = 0

	-- Logo
	self.logo_y = 30
	self.logo_vy = 0
	self.logo_a = 0
	self.move_logo = false
	self.jetpack_tutorial_y = -30
	self.move_jetpack_tutorial = false
	
	if self.menu_manager then
		self.menu_manager:reset()
		self.menu_manager:set_menu()
	end

	self.stats = {
		floor = 0,
		kills = 0,
		time = 0,
		max_combo = 0,
	}
	self.kills = 0
	self.time = 0
	self.max_combo = 0

	-- Cabin stats
	--TODO: fuze it into map or remove map, only have coll boxes & no map
	local bw = BLOCK_WIDTH
	self.cabin_x, self.cabin_y = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_ax, self.cabin_ay = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_bx, self.cabin_by = self.world_generator.box_bx*bw, self.world_generator.box_by*bw
	self.door_ax, self.door_ay = self.cabin_x+154, self.cabin_x+122
	self.door_bx, self.door_by = self.cabin_y+261, self.cabin_y+207

	self.frames_to_skip = 0
	self.slow_mo_rate = 0

	self.draw_shadows = true
	self.shadow_ox = 1
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
	self.sfx_elevator_bg = sounds.elevator_bg.source
	self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	-- self.music_source:setVolume(options:get("music_volume"))
	self.sfx_elevator_bg:setVolume(0)
	self.sfx_elevator_bg:play()
	self.time_before_music = math.huge

	self.game_state = GAME_STATE_WAITING
	self.endless_mode = false
	self.timer_before_game_over = 0
	self.max_timer_before_game_over = 3.3

	-- UI
	self.game_ui = GameUI:new()

	Options:update_sound_on()
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
	end
	self:update_screen()
end

function Game:update_fullscreen(is_fullscreen)
	love.window.setFullscreen(is_fullscreen)

	if not is_fullscreen then
		local window_w = Options:get("windowed_width")
		local window_h = Options:get("windowed_height")
		love.window.setMode(window_w, window_h, self:get_window_flags())
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
	if type(pixel_scale_mode) == "number" then
		scale = math.min(pixel_scale_mode, auto_scale)

	elseif pixel_scale_mode == "auto" then
		scale = auto_scale
		
	elseif pixel_scale_mode == "max whole" then
		scale = math.floor(auto_scale)
	end

	CANVAS_SCALE = scale

	CANVAS_OX = math.floor(max(0, (WINDOW_WIDTH  - CANVAS_WIDTH  * CANVAS_SCALE)/2))
	CANVAS_OY = math.floor(max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * CANVAS_SCALE)/2))
end

local n = 0
function Game:update(dt)
	self.frame = self.frame + 1

	self.frames_to_skip = max(0, self.frames_to_skip - 1)
	local do_frameskip = self.slow_mo_rate ~= 0 and self.frame%self.slow_mo_rate ~= 0
	if self.frames_to_skip > 0 or do_frameskip then
		self:apply_screenshake(dt)
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

	-- THIS SHOULD BE LAST
	Input:update_last_input_state(dt)
end

function Game:update_main_game(dt)
	if self.game_state == GAME_STATE_PLAYING then
		self.time = self.time + dt
	end
	self.t = self.t + dt

	self:listen_for_player_join(dt)
	
	self.level:update(dt)
	
	-- Elevator swing 
	-- self.elev_x = cos(self.t) * 4
	-- self.elev_y = 4 + sin(self.t) * 4

	self:update_timer_before_game_over(dt)
	self:apply_screenshake(dt)
	
	if not Options:get("screenshake_on") then self.cam_ox, self.cam_oy = 0,0 end
	self.cam_realx, self.cam_realy = self.cam_x + self.cam_ox, self.cam_y + self.cam_oy

	-- Particles
	Particles:update(dt)

	-- Update actors
	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]

		actor:update(dt)
	
		if actor.is_removed then
			actor:final_remove()
			table.remove(self.actors, i)
		end
	end
	
	-- Logo
	self.logo_a = self.logo_a + dt*3
	if self.move_logo then
		self.logo_vy = self.logo_vy - dt
		self.logo_y = self.logo_y + self.logo_vy
	end
	if self.move_jetpack_tutorial then
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, 70, 0.1)
	else
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, -30, 0.1)
	end

	self:update_debug(dt)
	-- local q = 4
	-- if love.keyboard.isScancodeDown("a") then self.cam_x = self.cam_x - q end
	-- if love.keyboard.isScancodeDown("d") then self.cam_x = self.cam_x + q end
	-- if love.keyboard.isScancodeDown("w") then self.cam_y = self.cam_y - q end
	-- if love.keyboard.isScancodeDown("s") then self.cam_y = self.cam_y + q end
end

function Game:get_camera()
	return self.cam_x, self.cam_y
end

function Game:set_camera(x, y)
	self.cam_x = x
	self.cam_y = y
end

function Game:get_zoom()
	return self.cam_zoom
end
function Game:set_zoom(zoom)
	self.cam_zoom = zoom
end

function Game:update_debug(dt)
	
end

function Game:draw()
	if OPERATING_SYSTEM == "Web" then
		gfx.scale(CANVAS_SCALE, CANVAS_SCALE)
		gfx.translate(0, 0)
		gfx.clear(0,0,0)
		
		game:draw_game()
	else
		-- Using a canvas for that sweet, resizable pixel art
		gfx.setCanvas(canvas)
		gfx.clear(0,0,0)
		gfx.translate(0, 0)
		
		game:draw_game()
		
		gfx.setCanvas()
		gfx.origin()
		gfx.scale(1, 1)
		gfx.draw(canvas, CANVAS_OX, CANVAS_OY, 0, CANVAS_SCALE, CANVAS_SCALE)
	end
end

function Game:draw_game()
	local real_camx, real_camy = (self.cam_x + self.cam_ox), (self.cam_y + self.cam_oy)
	-- local real_camx, real_camy = math.cos(self.t) * 10, math.sin(self.t) * 10;
	local function reset_transform()
		love.graphics.origin()
		love.graphics.scale(self.cam_zoom)
	end
	
	-- Sky
	gfx.clear(self.level.bg_col)
	
	local old_canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.object_canvas)
	love.graphics.clear()
	love.graphics.translate(-real_camx, -real_camy)

	-- Draw actors
	for _,actor in pairs(self.actors) do
		if not actor.is_player then
			actor:draw()
		end
	end
	for _,p in pairs(self.players) do
		p:draw()
	end

	Particles:draw()
	
	---------------------------------------------

	-- Buffering these so that we can draw their shadows but still draw then in front of everything
	local draw_front_objects = function()
		-- Draw actors UI
		Particles:draw_front()
		-- Draw actors
		reset_transform()		
		for k,actor in pairs(self.actors) do
			if actor.draw_hud and self.game_ui.is_visible then     actor:draw_hud()    end
		end
		love.graphics.translate(-real_camx, -real_camy)
	end

	love.graphics.setCanvas(self.front_canvas)
	love.graphics.clear()
	draw_front_objects()
	love.graphics.setCanvas(self.object_canvas)
	love.graphics.setCanvas(old_canvas)
	
	---------------------------------------------

	self.level:draw()
	
	reset_transform()
	love.graphics.setColor(0,0,0, 0.5)
	love.graphics.draw(self.object_canvas, self.shadow_ox, self.shadow_oy)
	love.graphics.draw(self.front_canvas,  self.shadow_ox, self.shadow_oy)
	love.graphics.setColor(1,1,1, 1)
	love.graphics.draw(self.object_canvas, 0, 0)
	
	self:draw_smoke_canvas()
	
	love.graphics.setColor(1,1,1, 1)
	love.graphics.translate(-real_camx, -real_camy)
	
	-- Walls
	if self.level.show_cabin then
		gfx.draw(images.cabin_walls, self.cabin_x, self.cabin_y)
	end

	reset_transform()
	love.graphics.draw(self.front_canvas, 0, 0)
	-- love.graphics.translate(-real_camx, -real_camy)
	reset_transform()

	-- Logo
	self.game_ui:draw()
	self.level:draw_front()

	-- Debug
	if self.debug.colview_mode then
		self.debug:draw_colview()
	end

	-- Menus
	if self.menu_manager.cur_menu then
		self.menu_manager:draw()
	end

	
	if self.debug_mode then
		self.debug:draw()
	end

	-----------------------------------------------------

	--'Memory used (in kB): ' .. collectgarbage('count')
	
	-- local t = "EARLY VERSION - NOT FINAL!"
	-- gfx.print(t, CANVAS_WIDTH-get_text_width(t), 0)
	-- local t = os.date('%a %d/%b/%Y')
	-- print_color({.7,.7,.7}, t, CANVAS_WIDTH-get_text_width(t), 12)	
end

function Game:draw_smoke_canvas()
	exec_on_canvas(self.smoke_canvas, love.graphics.clear)

	-- Used for effects for the stink bugs
	exec_on_canvas(self.smoke_buffer_canvas, function()
		love.graphics.clear()

		love.graphics.setColor(0.2,0.2,0.2)
		love.graphics.draw(self.smoke_canvas, 0, 4)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.smoke_canvas, 0, 0)
	end)
	exec_on_canvas(self.smoke_canvas, function()
		love.graphics.clear()
		
		love.graphics.setColor(0,0,0.1)
		love.graphics.draw(self.smoke_buffer_canvas, -1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 0, -1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 1)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 0)
	end)
	
	love.graphics.setColor(1,1,1,0.5)
	love.graphics.draw(self.smoke_canvas, 0, 0)
	love.graphics.setColor(1,1,1,1)
end

function Game:set_ui_visible(bool)
	self.game_ui:set_visible(bool)
end

function Game:listen_for_player_join(dt)
	if self.game_state ~= GAME_STATE_WAITING then return end

	if Input:action_pressed_global("jump") then 
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
			self:join_game(input_profile_id, joystick)
		end
	end

	if Input:action_pressed_global("split_keyboard") then
		if Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 1 then
			self:join_game("keyboard_solo")
			Input:split_keyboard()

		elseif Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 2 then
			self:unsplit_keyboard_and_kick_second_player()
		end
	end
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
	-- THIS is SO stupid. We should have a system that stores all sounds instead
	-- of doing this manually.

	self.sfx_elevator_bg:pause()
	for k,p in pairs(self.players) do
		p.sfx_wall_slide:setVolume(0)
	end
	for k,a in pairs(self.actors) do
		if a.pause_repeating_sounds then
			a:pause_repeating_sounds()
		end
	end
end
function Game:on_button_glass_spawn(button)
	self.music_player:stop()
end

function Game:on_unmenu()
	self.music_player:on_unmenu()
	self.sfx_elevator_bg:play()
	
	for k,a in pairs(self.actors) do
		if a.play_repeating_sounds then
			a:play_repeating_sounds()
		end
	end
end

function Game:set_music_volume(vol)
	self.music_player:set_volume(vol)
end

function Game:new_actor(actor)
	if #self.actors >= self.actor_limit then
		actor:remove()
		return
	end
	if actor.counts_as_enemy then
		self.enemy_count = self.enemy_count + 1
	end
	table.insert(self.actors, actor)
end

function Game:on_kill(actor)
	if actor.counts_as_enemy then
		self.enemy_count = self.enemy_count - 1
		self.kills = self.kills + 1
	end

	if actor.is_player then
		self:on_player_death(actor)
	end
end

function Game:on_player_death(player)
	self.players[player.n] = nil
	self.waves_until_respawn[player.n] = Input:get_number_of_users()

	if self:get_number_of_alive_players() <= 0 then
		-- Save stats
		self.menu_manager:set_can_pause(false)

		self.music_player:set_disk("game_over")
		self.music_player:pause()
		self:pause_repeating_sounds()
		self.game_state = GAME_STATE_DYING
		self.timer_before_game_over = self.max_timer_before_game_over
		self:save_stats()
	end
end

function Game:update_timer_before_game_over(dt)
	if self.game_state ~= GAME_STATE_DYING then
		return 
	end
	self.timer_before_game_over = self.timer_before_game_over - dt
	
	if self.timer_before_game_over <= 0 then
		self:on_game_over()
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
	self.stats.floor = self.floor
	self.stats.kills = self.kills
	self.stats.max_combo = self.max_combo
end

function Game:on_game_over()
	self.menu_manager:set_menu("game_over")
end

function Game:do_win()

end

function draw_log()
	-- log
	local x2 = floor(CANVAS_WIDTH/2)
	local h = gfx.getFont():getHeight()
	print_label("--- LOG ---", x2, 0)
	for i=1, min(#msg_log, max_msg_log) do
		print_label(msg_log[i], x2, i*h)
	end
end

function Game:init_players()
	self.players = {}

	for i = 1, self.max_number_of_players do
		if Input:get_user(i) ~= nil then
			self:new_player(i)
		end
	end
end

function Game:find_free_player_number()
	for i = 1, self.max_number_of_players do
		if self.players[i] == nil then
			return i
		end
	end
	return nil
end

function Game:join_game(input_profile_id, joystick)
	-- FIXME ça marche pas quand tu join avec manette puis que tu join sur clavier
	local player_n = self:find_free_player_number()
	if player_n == nil then
		return
	end
	-- Is joystick already taken?
	if joystick ~= nil and Input:get_joystick_user(joystick) ~= nil then
		return
	end

	Input:new_user(player_n)
	Input:set_last_ui_user_n(player_n)
	self:new_player(player_n)
	if joystick ~= nil then
		Input:assign_joystick(player_n, joystick)
	end
	Input:assign_input_profile(player_n, input_profile_id)

	return player_n
end

function Game:new_player(player_n, x, y)
	player_n = player_n or self:find_free_player_number()
	if player_n == nil then
		return
	end
	local mx = floor(self.door_ax)
	x = param(x, mx + ((player_n-1) / (MAX_NUMBER_OF_PLAYERS-1)) * (self.door_bx - self.door_ax))
	y = param(y, CANVAS_HEIGHT - 3*16)

	local player = Player:new(player_n, x, y, skins[player_n])
	self.players[player_n] = player
	self.waves_until_respawn[player_n] = -1
	self:new_actor(player)

	return player
end

function Game:leave_game(player_n)
	if self.players[player_n] == nil then
		return
	end

	local player = self.players[player_n]
	local profile_id = Input:get_input_profile_from_player_n(player.n):get_profile_id()
	
	self.players[player_n]:remove()
	self.players[player_n] = nil
	Input:remove_user(player_n)
	if profile_id == "keyboard_split_p1" or profile_id == "keyboard_split_p2" then
		Input:unsplit_keyboard()
	end
end

function Game:get_number_of_alive_players()
	local count = 0
	for i = 1, self.max_number_of_players do
		if self.players[i] ~= nil then
			count = count + 1
		end
	end
	return count
end

function Game:apply_screenshake(dt)
	-- Screenshake
	self.screenshake_q = max(0, self.screenshake_q - self.screenshake_speed * dt)
	-- self.screenshake_q = lerp(self.screenshake_q, 0, 0.2)

	local multiplier = Options:get("screenshake")
	local q = self.screenshake_q * multiplier
	local ox, oy = random_neighbor(q), random_neighbor(q)
	if abs(ox) >= 0.2 then   ox = sign(ox) * max(abs(ox), 1)   end -- Using an epsilon of 0.2 to avoid
	if abs(oy) >= 0.2 then   oy = sign(oy) * max(abs(oy), 1)   end -- jittery effects on UI elmts
	self.cam_ox = ox
	self.cam_oy = oy
end

function Game:enable_endless_mode()
	self.endless_mode = true
	self.music_player:play()
end

function Game:start_game()
	self.move_logo = true
	self.game_state = GAME_STATE_PLAYING
	self.music_player:set_disk("w1")

	self.menu_manager:set_can_pause(true)
	self:set_zoom(1)
	self:set_camera(0, 0)
end

function Game:on_red_button_pressed()
	self:save_stats()
	self.menu_manager:set_can_pause(false)
	self.game_state = GAME_STATE_ELEVATOR_BURNING
	self.level:on_red_button_pressed()
end

function Game:on_exploding_elevator()
	self.game_state = GAME_STATE_WIN
	self.menu_manager:set_can_pause(true)
end

function Game:apply_upgrade(upgrade) 
	for i, player in pairs(self.players) do
		player:apply_upgrade(upgrade)
	end
end

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

function Game:keypressed(key, scancode, isrepeat)
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
end

function Game:gamepadpressed(joystick, buttoncode)
	Input:gamepadpressed(joystick, buttoncode)
	if self.menu_manager then   self.menu_manager:gamepadpressed(joystick, buttoncode)   end
	if self.debug then          self.debug:gamepadpressed(joystick, buttoncode)    end
end

function Game:gamepadreleased(joystick, buttoncode)
	Input:gamepadreleased(joystick, buttoncode)
	if self.menu_manager then   self.menu_manager:gamepadreleased(joystick, buttoncode)   end
	if self.debug then          self.debug:gamepadreleased(joystick, buttoncode)    end
end

function Game:gamepadaxis(joystick, axis, value)
	Input:gamepadaxis(joystick, axis, value)
	if self.menu_manager then   self.menu_manager:gamepadaxis(joystick, axis, value)   end
	if self.debug then          self.debug:gamepadaxis(joystick, axis, value)    end
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
	if not Options:get('screenshake_on') then  return   end
	-- self.screenshake_q = self.screenshake_q + q
	self.screenshake_q = math.max(self.screenshake_q, q)
end

function Game:frameskip(q)
	self.frames_to_skip = min(60, self.frames_to_skip + q + 1)
end

function Game:slow_mo(q)
	self.slow_mo_rate = q
end

function Game:reset_slow_mo(q)
	self.slow_mo_rate = 0
end

return Game