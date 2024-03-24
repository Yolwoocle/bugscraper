local Class = require "scripts.meta.class"
local CollisionManager = require "scripts.game.collision"
local Player = require "scripts.actor.player"
local Enemies = require "data.enemies"
local Bullet = require "scripts.actor.bullet"
local TileMap = require "scripts.level.tilemap"
local WorldGenerator = require "scripts.level.worldgenerator"
local ParticleSystem = require "scripts.game.particles"
local AudioManager = require "scripts.audio.audio"
local MenuManager = require "scripts.ui.menu.menu_manager"
local OptionsManager = require "scripts.game.options"
local InputManager = require "scripts.input.input"
local MusicPlayer = require "scripts.audio.music_player"
local MusicDisk = require "scripts.audio.music_disk"
local Elevator = require "scripts.game.elevator"
local InputButton = require "scripts.input.input_button"

local shaders  = require "scripts.graphics.shaders"
local sounds = require "data.sounds"
local images = require "data.images"
local guns = require "data.guns"

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

	CANVAS_WIDTH = 480
	CANVAS_HEIGHT = 270

	-- OPERATING_SYSTEM = "Web"
	OPERATING_SYSTEM = love.system.getOS()
	USE_CANVAS_RESIZING = true
	SCREEN_WIDTH, SCREEN_HEIGHT = 0, 0

	if OPERATING_SYSTEM == "Web" then
		USE_CANVAS_RESIZING = false
		CANVAS_SCALE = 2
		-- Init window
		love.window.setMode(CANVAS_WIDTH*CANVAS_SCALE, CANVAS_HEIGHT*CANVAS_SCALE, {
			fullscreen = false,
			resizable = true,
			vsync = Options:get"is_vsync",
			minwidth = CANVAS_WIDTH,
			minheight = CANVAS_HEIGHT,
		})
		SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
		love.window.setTitle("Bugscraper")
		love.window.setIcon(love.image.newImageData("icon.png"))
	else
		-- Init window
		love.window.setMode(0, 0, {
			fullscreen = Options:get("is_fullscreen"),
			resizable = true,
			vsync = Options:get("is_vsync"),
			minwidth = CANVAS_WIDTH,
			minheight = CANVAS_HEIGHT,
		})
		SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
		love.window.setTitle("Bugscraper")
		love.window.setIcon(love.image.newImageData("icon.png"))
	end
	gfx.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")

	self:update_screen()

	canvas = gfx.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Load fonts
	FONT_REGULAR = gfx.newFont("fonts/HopeGold.ttf", 16)
	FONT_7SEG = gfx.newImageFont("fonts/7seg_font.png", " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	FONT_MINI = gfx.newFont("fonts/Kenney Mini.ttf", 8)
	FONT_PAINT = gfx.newFont("fonts/NicoPaint-Regular.ttf", 16)
	gfx.setFont(FONT_REGULAR)
	
	-- Audio ===> Moved to OptionsManager
	-- self.volume = options:get("volume")
	-- self.sound_on = options:get("sound_on")

	Options:set_volume(Options:get("volume"))
	
	self:new_game()
	
	-- Menu Manager
	self.menu_manager = MenuManager:new(self)

	love.mouse.setVisible(Options:get("mouse_visible"))

	self.is_first_time = Options.is_first_time
end


function Game:update_screen(scale)
	-- When scale is (-1), it will find the maximum whole number
	if scale == "auto" then   scale = nil    end
	if scale == "max whole" then   scale = -1    end
	if type(scale) ~= "number" then    scale = nil    end
 
	CANVAS_WIDTH = 480
	CANVAS_HEIGHT = 270

	WINDOW_WIDTH, WINDOW_HEIGHT = gfx.getDimensions()

	screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	CANVAS_SCALE = min(screen_sx, screen_sy)

	if scale then
		if scale == -1 then
			CANVAS_SCALE = floor(CANVAS_SCALE)
		else
			CANVAS_SCALE = scale
		end
	end

	CANVAS_OX = max(0, (WINDOW_WIDTH  - CANVAS_WIDTH  * CANVAS_SCALE)/2)
	CANVAS_OY = max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * CANVAS_SCALE)/2)
end

function Game:new_game()
	-- Reset global systems
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()

	-- number_of_players = (number_of_players or self.number_of_players) or 0

	self.t = 0
	self.frame = 0

	-- Players
	self.max_number_of_players = MAX_NUMBER_OF_PLAYERS
	self.number_of_players = 0
	self.number_of_alive_players = 0

	self.elevator = Elevator:new(self)

	-- Map & world gen
	self.shaft_w, self.shaft_h = 26,14
	self.map = TileMap:new(30, 17)
	self.world_generator = WorldGenerator:new(self.map)
	self.world_generator:generate(10203)
	self.world_generator:make_box(self.shaft_w, self.shaft_h)

	-- Level info
	self.floor = 0 --Floor n°
	-- self.max_elev_speed = 1/2
	self.cur_wave_max_enemy = 1

	-- Bounding box
	local map_w = self.map.width * BW
	local map_h = self.map.height * BW
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

	-- Start lever
	local nx = CANVAS_WIDTH * 0.75
	local ny = self.world_generator.box_by * BLOCK_WIDTH
	-- local l = create_actor_centered(Enemies.ButtonGlass, nx, ny)
	local l = create_actor_centered(Enemies.ButtonSmallGlass, floor(nx), floor(ny))
	self:new_actor(l)

	-- Camera & screenshake
	self.cam_x = 0
	self.cam_y = 0
	self.cam_realx, self.cam_realy = 0, 0
	self.cam_ox, self.cam_oy = 0, 0
	self.screenshake_q = 0
	self.screenshake_speed = 20

	-- Debugging
	self.debug_mode = false
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

	-- Music
	if self.music_player then self.music_player:stop() end
	self.music_player = MusicPlayer:new()
	self.music_player:set_disk("intro")
	self.music_player:play()
	self.sfx_elevator_bg = sounds.elevator_bg[1]
	self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	-- self.music_source:setVolume(options:get("music_volume"))
	self.sfx_elevator_bg:setVolume(0)
	self.sfx_elevator_bg:play()
	self.time_before_music = math.huge

	self.endless_mode = false
	self.game_started = false
	self.is_game_over = false
	self.timer_before_game_over = 0
	self.max_timer_before_game_over = 3.3

	Options:update_sound_on()
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
	
	if not self.menu_manager.cur_menu then
		self:update_main_game(dt)
	end

	-- THIS SHOULD BE LAST
	Input:update_last_input_state(dt)
end

function Game:update_main_game(dt)
	if self.game_started then
		self.time = self.time + dt
	end
	self.t = self.t + dt

	self:listen_for_player_join(dt)
	
	-- BG color gradient
	if not self.elevator.is_on_win_screen then
		self.elevator.bg_color_progress = self.elevator.bg_color_progress + dt*0.2
		local i_prev = mod_plus_1(self.elevator.bg_color_index-1, #self.elevator.bg_colors)
		if self.floor <= 1 then
			i_prev = 1
		end

		local i_target = mod_plus_1(self.elevator.bg_color_index, #self.elevator.bg_colors)
		local prog = clamp(self.elevator.bg_color_progress, 0, 1)
		self.elevator.bg_col = lerp_color(self.elevator.bg_colors[i_prev], self.elevator.bg_colors[i_target], prog)
		self.elevator.bg_particle_col = self.elevator.bg_particle_colors[i_target]
	end
	
	-- Elevator swing 
	-- self.elev_x = cos(self.t) * 4
	-- self.elev_y = 4 + sin(self.t) * 4

	self:update_timer_before_game_over(dt)

	self:apply_screenshake(dt)
	
	if not Options:get("screenshake_on") then self.cam_ox, self.cam_oy = 0,0 end
	self.cam_realx, self.cam_realy = self.cam_x + self.cam_ox, self.cam_y + self.cam_oy

	self.map:update(dt)

	-- Particles
	Particles:update(dt)
	self.elevator:update_bg_particles(dt)
	self.elevator:progress_elevator(dt)

	-- Update actors
	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]

		actor:update(dt)
	
		if actor.is_removed then
			table.remove(self.actors, i)
		end
	end

	-- Flash 
	self.elevator.flash_alpha = max(self.elevator.flash_alpha - dt, 0)
	
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

	local q = 4
	-- if love.keyboard.isScancodeDown("a") then self.cam_x = self.cam_x - q end
	-- if love.keyboard.isScancodeDown("d") then self.cam_x = self.cam_x + q end
	-- if love.keyboard.isScancodeDown("w") then self.cam_y = self.cam_y - q end
	-- if love.keyboard.isScancodeDown("s") then self.cam_y = self.cam_y + q end
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

testx = 0
testy = 0
function Game:draw_game()
	-- Sky
	gfx.clear(self.elevator.bg_col)
	local real_camx, real_camy = (self.cam_x + self.cam_ox), (self.cam_y + self.cam_oy)
	love.graphics.translate(-real_camx, -real_camy)

	local old_canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.object_canvas)
	love.graphics.clear()

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
	
	if self.elevator.show_rubble then
		self.elevator:draw_rubble(self.cabin_x, self.cabin_y)
	end

	---------------------------------------------

	-- Buffering these so that we can draw their shadows but still draw then in front of everything
	local draw_front_objects = function()
		-- Draw actors UI
		Particles:draw_front()
		-- Draw actors
		love.graphics.origin()			
		for k,actor in pairs(self.actors) do
			if actor.draw_hud then     actor:draw_hud()    end
		end
		love.graphics.translate(-real_camx, -real_camy)
	end

	love.graphics.setCanvas(self.front_canvas)
	love.graphics.clear()
	draw_front_objects()
	love.graphics.setCanvas(self.object_canvas)
	love.graphics.setCanvas(old_canvas)
	
	---------------------------------------------

	--Draw bg particles
	if self.elevator.show_bg_particles then
		for i,o in pairs(self.elevator.bg_particles) do
			local y = o.y + o.oy
			local mult = 1 - clamp(abs(self.elevator.elevator_speed / 100), 0, 1)
			local sin_oy = mult * sin(self.t + o.rnd_pi) * o.oh * o.h 
			
			rect_color(o.col, "fill", o.x, o.y + o.oy + sin_oy, o.w, o.h * o.oh)
		end
	end

	-- Map
	self.map:draw()
	
	-- Background
	
	-- Door background
	if self.elevator.show_cabin then
		rect_color(self.elevator.bg_col, "fill", self.door_ax, self.door_ay, self.door_bx - self.door_ax+1, self.door_by - self.door_ay+1)
		-- If doing door animation, draw buffered enemies
		if self.elevator.door_animation then
			for i,e in pairs(self.elevator.door_animation_enemy_buffer) do
				e:draw()
			end
		end
		self.elevator:draw_background(self.cabin_x, self.cabin_y)
	end
	
	love.graphics.origin()
	love.graphics.setColor(0,0,0, 0.5)
	love.graphics.draw(self.object_canvas, self.shadow_ox, self.shadow_oy)
	love.graphics.draw(self.front_canvas,  self.shadow_ox, self.shadow_oy)
	love.graphics.setColor(1,1,1, 1)
	love.graphics.draw(self.object_canvas, 0, 0)
	love.graphics.translate(-real_camx, -real_camy)

	-- Walls
	if self.elevator.show_cabin then
		gfx.draw(images.cabin_walls, self.cabin_x, self.cabin_y)
	end

	love.graphics.origin()
	love.graphics.draw(self.front_canvas, 0, 0)
	love.graphics.translate(-real_camx, -real_camy)

	-- UI
	-- print_centered_outline(COL_WHITE, COL_DARK_BLUE, concat("FLOOR ",self.floor), CANVAS_WIDTH/2, 8)
	-- local w = 64
	-- rect_color(COL_DARK_GRAY, "fill", floor((CANVAS_WIDTH-w)/2),    16, w, 8)
	-- rect_color(COL_WHITE,    "fill", floor((CANVAS_WIDTH-w)/2) +1, 17, (w-2)*self.floor_progress, 6)

	gfx.origin()

	-- Logo
	self:draw_logo()

	-- "CONGRATS" at the end
	if self.elevator.is_on_win_screen then
		self.elevator:draw_win_screen()
	end

	-- Flash
	if self.elevator.flash_alpha then
		rect_color({1,1,1,self.elevator.flash_alpha}, "fill", self.cam_realx, self.cam_realy, CANVAS_WIDTH, CANVAS_HEIGHT)
	end

	-- Timer
	if Options:get("timer_on") then
		rect_color({0,0,0,0.5}, "fill", 0, 10, 50, 12)
		gfx.print(time_to_string(self.time), 8, 8)
	end

	-- Debug
	if self.colview_mode then
		self:draw_colview()
	end
	if self.debug_mode then
		self:draw_debug()
	end

	-- Menus
	if self.menu_manager.cur_menu then
		self.menu_manager:draw()
	end

	-- self:removeme_bg_test2()
	--'Memory used (in kB): ' .. collectgarbage('count')

	-- local t = "EARLY VERSION - NOT FINAL!"
	-- gfx.print(t, CANVAS_WIDTH-get_text_width(t), 0)
	-- local t = os.date('%a %d/%b/%Y')
	-- print_color({.7,.7,.7}, t, CANVAS_WIDTH-get_text_width(t), 12)	
end

function Game:listen_for_player_join(dt)
	if self.game_started then return end

	if Input:action_pressed_any_player("debug_1") then
		self:leave_game(1)
	end
	if Input:action_pressed_any_player("debug_2") then
		self:leave_game(2)
	end
	if Input:action_pressed_any_player("debug_3") then
		self:leave_game(3)
	end
	if Input:action_pressed_any_player("debug_4") then
		self:leave_game(4)
	end

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
	if Input:action_pressed_global("split_keyboard") and Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 1 then
		self:join_game("keyboard_solo")
		Input:split_keyboard()
	end
end

function Game:removeme_bg_test()
	-- love.graphics.setColor(COL_BLACK_BLUE)
	-- love.graphics.clear()
	love.graphics.setColor(COL_WHITE)
	local ox, oy = CANVAS_WIDTH/2, CANVAS_HEIGHT/2
	local padding = CANVAS_WIDTH/2
	local z = 9
	local fov = 1
	local interval = 42
	for iy = -CANVAS_HEIGHT*5, 5*CANVAS_HEIGHT, interval do
		local y = iy + ((self.t*100) % interval)
		love.graphics.line(math.floor(fov *  padding + ox), math.floor(fov * y + oy), math.floor(fov *  padding/z + ox), math.floor(fov * y/z + oy))
		love.graphics.line(math.floor(fov * -padding + ox), math.floor(fov * y + oy), math.floor(fov * -padding/z + ox), math.floor(fov * y/z + oy))
	end
end

local function new_bg_line()
	return {
		x = random_range(0, 480), 
		y = -80,
		dy = random_range(8, 16),
		h = random_range(30, 60),
	}
end
local removeme_parallax_y = 0
local bglines = {}
for i=1, 30 do 
	table.insert(bglines, new_bg_line())
end
function Game:removeme_bg_test2()
	love.graphics.clear(COL_LIGHT_BLUE)
	love.graphics.setColor(COL_WHITE)

	removeme_parallax_y = self.t * 60
	love.graphics.draw(images._test_layer0, 0, 0)
	love.graphics.draw(images._test_layer1, 0, removeme_parallax_y * 0.01)
	love.graphics.draw(images._test_layer2, 0, removeme_parallax_y * 0.05)
	love.graphics.draw(images._test_layer3, 0, removeme_parallax_y * 0.1)

	love.graphics.draw(images._test_shine, 0, 0)

	exec_using_shader(shaders.lighten, function()
		love.graphics.draw(self.object_canvas, -4, -12)
	end)
	local y0 = (removeme_parallax_y * 5) % (96*2)
	local i_line = 1
	for iy=y0-(96*2), CANVAS_HEIGHT+100, 96 do
		local x0 = ternary(i_line % 2 == 0, -16, -16 - 32)
		for ix=x0, CANVAS_WIDTH, 64 do
			love.graphics.draw(images._test_window, ix, iy)
		end
		i_line = i_line + 1
	end

	for i=1, #bglines do
		bglines[i].y = bglines[i].y + bglines[i].dy
		love.graphics.line(bglines[i].x, bglines[i].y, bglines[i].x, bglines[i].y + bglines[i].h)
		if bglines[i].y > CANVAS_HEIGHT then
			bglines[i] = new_bg_line()
		end
	end
end

function Game:draw_logo()
	for i=1, #LOGO_COLS + 1 do
		local ox, oy = cos(self.logo_a + i*.4)*8, sin(self.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = LOGO_COLS[i]
		local spr = images.logo_shad
		if col == nil then
			col = COL_WHITE
			spr = images.logo_noshad
		end
		gfx.setColor(col)
		gfx.draw(spr, logo_x + ox, self.logo_y + oy)
	end
	self:draw_join_tutorial()
end

function Game:draw_join_tutorial()
	local def_x = math.floor((self.door_ax + self.door_bx) / 2)
	local def_y = 80

	local icons = {
		Input:get_button_icon(1, Input:get_input_profile("keyboard_solo"):get_primary_button("jump")),
		Input:get_button_icon(1, Input:get_input_profile("controller"):get_primary_button("jump"), BUTTON_STYLE_XBOX),
		Input:get_button_icon(1, Input:get_input_profile("controller"):get_primary_button("jump"), BUTTON_STYLE_PLAYSTATION5),
	}
	
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
	if Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 1 then
		local icon_split_kb = Input:get_button_icon(1, Input:get_input_profile("global"):get_primary_button("split_keyboard"))
		print_outline(COL_WHITE, COL_BLACK_BLUE, "SPLIT KEYBOARD", x, y)
		x = x - icon_split_kb:getWidth() - 2
		love.graphics.draw(icon_split_kb, x, y)
	end
end

function Game:draw_colview()
	local items, len = Collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = Collision.world:getRect(it)
		rect_color({0,1,0,.2},"fill", x, y, w, h)
		rect_color({0,1,0,.5},"line", x, y, w, h)
	end
end

function Game:draw_debug()
	gfx.print(concat("FPS: ",love.timer.getFPS(), " / frmRpeat: ",self.frame_repeat, " / frame: ",frame), 0, 0)
	
	local players_str = "players: "
	for k, player in pairs(self.players) do
		players_str = concat(players_str, "{", k, ":", player.n, "}, ")
	end

	local users_str = "users: "	
	for k, player in pairs(Input.users) do
		users_str = concat(users_str, "{", k, ":", player.n, "}, ")
	end
	
	local joystick_user_str = "joysticks_to_users: "	
	for joy, user in pairs(Input.joystick_to_user_map) do
		joystick_user_str = concat(joystick_user_str, "{", string.sub(joy:getName(),1,4), "... ", ":", user.n, "}, ")
	end
	
	local joystick_str = "joysticks: "	
	for _, joy in pairs(love.joystick.getJoysticks()) do
		joystick_str = concat(joystick_str, "{", string.sub(joy:getName(),1,4), "...}, ")
	end

	
	-- Print debug info
	local txt_h = get_text_height(" ")
	local txts = {
		concat("FPS: ",love.timer.getFPS()),
		concat("n° of actors: ", #self.actors, " / ", self.actor_limit),
		concat("n° of enemies: ", self.enemy_count),
		concat("n° collision items: ", Collision.world:countItems()),
		concat("frames_to_skip: ", self.frames_to_skip),
		concat("debug1 ", self.debug1),
		concat("real_wave_n ", self.debug2),
		concat("bg_color_index ", self.debug3),
		concat("number_of_alive_players ", self.number_of_alive_players),
		concat("number_of_users(*) ", Input:get_number_of_users()),
		concat("number_of_users(KEYBOARD) ", Input:get_number_of_users(INPUT_TYPE_KEYBOARD)),
		concat("number_of_users(CONTROLLER) ", Input:get_number_of_users(INPUT_TYPE_CONTROLLER)),
		players_str,
		users_str,
		joystick_user_str,
		joystick_str,
		"",
	}

	for i=1, #txts do  print_label(txts[i], self.cam_x, self.cam_y+txt_h*i) end

	for _, e in pairs(self.actors) do
		love.graphics.circle("fill", e.x, e.y, 3)
	end

	self.world_generator:draw()
	draw_log()
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
	self.number_of_alive_players = self.number_of_alive_players - 1
	self.players[player.n] = nil

	if self.number_of_alive_players <= 0 then
		-- Save stats
		self.music_player:pause()
		self:pause_repeating_sounds()
		self.game_started = false
		self.is_game_over = true
		self.timer_before_game_over = self.max_timer_before_game_over
		self:save_stats()
	end
end

function Game:update_timer_before_game_over(dt)
	if not self.is_game_over then
		return 
	end
	self.timer_before_game_over = self.timer_before_game_over - dt
	
	if self.timer_before_game_over <= 0 then
		self:on_game_over()
		Audio:play("game_over_2")
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
	self:new_player(player_n)
	if joystick ~= nil then
		Input:assign_joystick(player_n, joystick)
	end
	Input:assign_input_profile(player_n, input_profile_id)

	return player_n
end

function Game:new_player(player_n)
	player_n = player_n or self:find_free_player_number()
	if player_n == nil then
		return
	end

	self.number_of_alive_players = self.number_of_alive_players + 1

	local skins = {
		{
			spr_idle = images.ant1,
			spr_jump = images.ant2,
			spr_dead = images.ant_dead,
			color_palette = {color(0xf6757a), color(0xb55088), color(0xe43b44), color(0x9e2835), color(0x3a4466), color(0x262b44)},
		},
		{
			spr_idle = images.caterpillar_1,
			spr_jump = images.caterpillar_2,
			spr_dead = images.caterpillar_dead,
			color_palette = {color(0x63c74d), color(0x3e8948), color(0x265c42), color(0x193c3e), color(0x5a6988), color(0x3a4466)},
		},
		{
			spr_idle = images.bee_1,
			spr_jump = images.bee_2,
			spr_dead = images.bee_dead,
			color_palette = {color(0xfee761), color(0xfeae34), color(0x743f39), color(0x3f2832), color(0xc0cbdc), color(0x9e2835)},
		},
		{
			spr_idle = images.ant2_1,
			spr_jump = images.ant2_2,
			spr_dead = images.ant2_dead,
			color_palette = {color(0x2ce8f5), color(0x2ce8f5), color(0x0195e9), color(0x9e2835), color(0x3a4466), color(0x262b44)},
		},
	}

	local mx = floor((self.map.width / self.max_number_of_players))
	local my = floor(self.map.height - 3)

	local player = Player:new(player_n, mx*16 + player_n*16, my*16, skins[player_n])
	self.players[player_n] = player
	self:new_actor(player)
end

function Game:leave_game(player_n)
	if self.players[player_n] == nil then
		return
	end

	self.players[player_n]:remove()
	self.players[player_n] = nil
	Input:remove_user(player_n)
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
	self.game_started = true
	self.music_player:set_disk("w1")
end

function Game:on_red_button_pressed()
	self.elevator:on_red_button_pressed()
end

function Game:apply_upgrade(upgrade) 
	for i, player in pairs(self.players) do
		player:apply_upgrade(upgrade)
	end
end

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

local igun = 1
function Game:keypressed(key, scancode, isrepeat)
	if key == "f3" then
		self.debug_mode = not self.debug_mode
	elseif key == "f2" then
		self.colview_mode = not self.colview_mode
	elseif key == "f1" then
		local all_guns = {
			guns.Machinegun,
			guns.Triple,
			guns.Burst,
			guns.Shotgun,
			guns.Minigun,
			guns.Ring,
			guns.MushroomCannon,
			guns.unlootable.DebugGun,
		}
		
		igun = mod_plus_1(igun + 1, #all_guns)
		self.players[1]:equip_gun(all_guns[igun]:new())
	end

	if self.menu_manager then
		self.menu_manager:keypressed(key, scancode, isrepeat)
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
end

function Game:gamepadreleased(joystick, buttoncode)
	Input:gamepadreleased(joystick, buttoncode)
	if self.menu_manager then   self.menu_manager:gamepadreleased(joystick, buttoncode)   end
end

function Game:gamepadaxis(joystick, axis, value)
	Input:gamepadaxis(joystick, axis, value)
	if self.menu_manager then   self.menu_manager:gamepadaxis(joystick, axis, value)   end
end

function Game:focus(f)
	if f then
	else
		if Options:get("pause_on_unfocus") and self.menu_manager and Input:get_number_of_users() >= 1 then
			self.menu_manager:pause()
		end
	end
end

-- function Game:keyreleased(key, scancode)
-- 	for i, ply in pairs(self.players) do
-- 		--ply:keyreleased(key, scancode)
-- 	end
-- end

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