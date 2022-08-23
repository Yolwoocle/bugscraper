local Class = require "class"
local Collision = require "collision"
local Player = require "player"
local Enemies = require "data.enemies"
local Bullet = require "bullet"
local TileMap = require "tilemap"
local WorldGenerator = require "worldgenerator"
local Inventory = require "inventory"
local ParticleSystem = require "particles"
local AudioManager = require "audio"
local MenuManager = require "menu"
local OptionsManager = require "options"
local utf8 = require "utf8"

local waves = require "data.waves"
local sounds = require "data.sounds"
local images = require "data.images"

require "util"
require "constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	options = OptionsManager:new(self)
	collision = Collision:new()
	particles = ParticleSystem:new()
	audio = AudioManager:new()
	
	-- Global Options ==> Moved to OptionsManager
	-- is_fullscreen = options:get("is_fullscreen")
	-- is_vsync = options:get("is_vsync")
	-- pixel_scale = options:get("pixel_scale")

	CANVAS_WIDTH = 480
	CANVAS_HEIGHT = 270

	-- Init window
	love.window.setMode(0, 0, {
		fullscreen = options:get"is_fullscreen",
		resizable = true,
		vsync = options:get"is_vsync",
		minwidth = CANVAS_WIDTH,
		minheight = CANVAS_HEIGHT,
	})
	SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
	love.window.setTitle("Bugscraper")
	love.window.setIcon(love.image.newImageData("icon.png"))
	gfx.setDefaultFilter("nearest", "nearest")
	
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

	options:set_volume(options:get("volume"))
	
	self:new_game()
	
	-- Menu Manager
	self.menu = MenuManager:new(self)

	love.mouse.setVisible(options:get("mouse_visible"))

	self.music_source = sounds.music1
	self.is_first_time = options.is_first_time
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

function Game:new_game(number_of_players)
	-- Reset global systems
	collision = Collision:new()
	particles = ParticleSystem:new()

	number_of_players = number_of_players or 1

	self.t = 0

	-- Players
	self.max_number_of_players = 4 
	self.number_of_players = number_of_players

	-- Map & world gen
	self.shaft_w, self.shaft_h = 26,14
	self.map = TileMap:new(30, 17)
	self.world_generator = WorldGenerator:new(self.map)
	self.world_generator:generate(10203)
	self.world_generator:make_box(self.shaft_w, self.shaft_h)

	-- Level info
	self.floor = 0 --Floor n°
	self.floor_progress = 3.5 --How far the cabin is to the next floor
	-- self.max_elev_speed = 1/2
	self.cur_wave_max_enemy = 1
	
	-- Background
	self.door_offset = 0
	self.door_animation = false
	
	self.draw_enemies_in_bg = false
	
	self.def_elevator_speed = 400
	self.elevator_speed_cap = -1000
	self.elevator_speed = 0
	self.elevator_speed_overflow = 0
	self.has_switched_to_next_floor = false
	self.is_reversing_elevator = false
	self.is_exploding_elevator = false
	self.downwards_elev_progress = 0
	
	self.bg_color_progress = 0
	self.bg_color_index = 1
	self.bg_colors = {COL_BLACK_BLUE, COL_DARK_GREEN, COL_DARK_RED, COL_LIGHT_BLUE}
	self.bg_col = COL_BLACK_BLUE

	self.game_started = false

	self.show_bg_particles = true
	self.def_bg_col = COL_BLACK_BLUE
	self.bg_col = self.def_bg_col
	self.bg_particles = {}
	for i=1,60 do
		local p = self:new_bg_particle()
		p.x = random_range(0, CANVAS_WIDTH)
		p.y = random_range(0, CANVAS_HEIGHT)
		table.insert(self.bg_particles, p)
	end

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
	for i,box in pairs(self.boxes) do   collision:add(box)   end
	
	-- Actors
	self.actor_limit = 100
	self.enemy_count = 0
	self.actors = {}
	self:init_players()

	-- Start lever
	local nx = CANVAS_WIDTH/2
	local ny = self.world_generator.box_by * BLOCK_WIDTH
	-- local l = create_actor_centered(Enemies.ButtonGlass, nx, ny)
	local l = create_actor_centered(Enemies.DummyTarget, floor(nx), floor(ny))
	self:new_actor(l)

	self.inventory = Inventory:new()

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
	self.logo_y = 15
	self.logo_vy = 0
	self.logo_a = 0
	self.logo_cols = {COL_LIGHT_YELLOW, COL_LIGHT_BLUE, COL_LIGHT_RED}
	self.move_logo = false
	self.jetpack_tutorial_y = -30
	self.move_jetpack_tutorial = false
	
	if self.menu then
		self.menu:set_menu()
	end

	self.stats = {
		floor = 0,
		kills = 0,
		time = 0,
	}
	self.kills = 0
	self.time = 0

	-- Cabin stats
	--TODO: fuze it into map or remove map, only have coll boxes & no map
	local bw = BLOCK_WIDTH
	self.cabin_x, self.cabin_y = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_ax, self.cabin_ay = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_bx, self.cabin_by = self.world_generator.box_bx*bw, self.world_generator.box_by*bw
	self.door_ax, self.door_ay = self.cabin_x+154, self.cabin_x+122
	self.door_bx, self.door_by = self.cabin_y+261, self.cabin_y+207

	self.flash_alpha = 0
	self.show_cabin = true
	self.show_rubble = false

	self.is_on_win_screen = false

	self.frames_to_skip = 0

	self.draw_shadows = false
	
	-- Music
	-- TODO: a "ambient sfx" system
	self.music_source = sounds.music1
	self.sfx_elevator_bg = sounds.elevator_bg
	self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	self.music_source:play()
	self.sfx_elevator_bg:play()
	self:set_music_volume(options:get("music_volume"))

	options:update_sound_on()
end

local n = 0
function Game:update(dt)
	self.frames_to_skip = max(0, self.frames_to_skip - 1)
	if self.frames_to_skip > 0 then
		return
	end

	-- Menus
	self.menu:update(dt)

	if not self.menu.cur_menu then
		self:update_main_game(dt)
	end

	-- Update button states
	for _, player in pairs(self.players) do
		player:update_button_state()
	end
end

function Game:update_main_game(dt)
	if self.game_started then
		self.time = self.time + dt
	end
	self.t = self.t + dt

	-- bg  pinnn
	self.bg_color_progress = self.bg_color_progress + dt
	local i_prev = clamp(self.bg_color_index-1, 1, #self.bg_colors)
	local i_target = clamp(self.bg_color_index, 1, #self.bg_colors)
	local prog = clamp(self.bg_color_progress, 0, 1)
	self.bg_col = lerp_color(self.bg_colors[i_prev], self.bg_colors[i_target], prog)

	-- Screenshake
	self.screenshake_q = max(0, self.screenshake_q - self.screenshake_speed * dt)
	-- self.screenshake_q = lerp(self.screenshake_q, 0, 0.2)

	-- if self.screenshake_q < 1 then    q = 0    end
	local q = self.screenshake_q
	local ox, oy = random_neighbor(q), random_neighbor(q)
	if abs(ox) >= 0.2 then   ox = sign(ox) * max(abs(ox), 1)   end
	if abs(oy) >= 0.2 then   oy = sign(oy) * max(abs(oy), 1)   end
	self.cam_ox = ox
	self.cam_oy = oy
	
	if not options:get("screenshake_on") then self.cam_ox, self.cam_oy = 0,0 end
	self.cam_realx, self.cam_realy = self.cam_x + self.cam_ox, self.cam_y + self.cam_oy

	self.map:update(dt)

	-- Particles
	particles:update(dt)
	self:update_bg_particles(dt)

	self:progress_elevator(dt)

	-- Update actors
	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]

		actor:update(dt)
	
		if actor.is_removed then
			table.remove(self.actors, i)
		end
	end

	-- Flash 
	self.flash_alpha = max(self.flash_alpha - dt, 0)
	
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
	-- Sky
	gfx.clear(self.bg_col)
	gfx.translate(-(self.cam_x + self.cam_ox), -(self.cam_y + self.cam_oy))

	-- Draw bg particles
	if self.show_bg_particles then
		for i,o in pairs(self.bg_particles) do
			local y = o.y + o.oy
			local mult = 1 - clamp(abs(self.elevator_speed / 100), 0, 1)
			local sin_oy = mult * sin(self.t + o.rnd_pi) * o.oh * o.h 
			
			rect_color(o.col, "fill", o.x, o.y + o.oy + sin_oy, o.w, o.h * o.oh)
		end
	end

	-- Map
	self.map:draw()
	
	-- Background
	
	-- Door background
	if self.show_cabin then
		rect_color(COL_BLACK_BLUE, "fill", self.door_ax, self.door_ay, self.door_bx - self.door_ax, self.door_by - self.door_ay)
		-- If doing door animation, draw buffered enemies
		if self.door_animation then
			for i,e in pairs(self.door_animation_enemy_buffer) do
				e:draw()
			end
		end
		self:draw_background(self.cabin_x, self.cabin_y)
	end

	local old_canvas
	local objs_canvas
	if self.draw_shadows then
		old_canvas = love.graphics.getCanvas()
		objs_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
		love.graphics.setCanvas(objs_canvas)
	end

	-- Draw actors
	for _,actor in pairs(self.actors) do
		if not actor.is_player then
			actor:draw()
		end
	end
	for _,p in pairs(self.players) do
		p:draw()
	end

	particles:draw()
	
	if self.show_rubble then
		self:draw_rubble(self.cabin_x, self.cabin_y)
	end
	
	if self.draw_shadows then
		love.graphics.setCanvas(old_canvas)
		
		love.graphics.setColor(0,0,0, 0.5)
		love.graphics.draw(objs_canvas, 0, 3)
		love.graphics.setColor(1,1,1, 1)
		love.graphics.draw(objs_canvas, 0, 0)
	end

	-- Walls
	if self.show_cabin then
		gfx.draw(images.cabin_walls, self.cabin_x, self.cabin_y)
	end

	-- Draw actors UI
	-- Draw actors
	for k,actor in pairs(self.actors) do
		if actor.draw_hud then     actor:draw_hud()    end
	end

	-- UI
	-- print_centered_outline(COL_WHITE, COL_DARK_BLUE, concat("FLOOR ",self.floor), CANVAS_WIDTH/2, 8)
	-- local w = 64
	-- rect_color(COL_MID_GRAY, "fill", floor((CANVAS_WIDTH-w)/2),    16, w, 8)
	-- rect_color(COL_WHITE,    "fill", floor((CANVAS_WIDTH-w)/2) +1, 17, (w-2)*self.floor_progress, 6)

	-- Logo
	for i=1, #self.logo_cols + 1 do
		local ox, oy = cos(self.logo_a + i*.4)*8, sin(self.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = self.logo_cols[i]
		local spr = images.logo_shad
		if col == nil then
			col = COL_WHITE
			spr = images.logo_noshad
		end
		gfx.setColor(col)
		gfx.draw(spr, logo_x + ox, self.logo_y + oy)
	end
	gfx.draw(images.controls, floor((CANVAS_WIDTH - images.controls:getWidth())/2), floor(self.logo_y) + images.logo:getHeight()+6)
	gfx.draw(images.controls_jetpack, floor((CANVAS_WIDTH - images.controls_jetpack:getWidth())/2), floor(self.jetpack_tutorial_y))

	-- "CONGRATS" at the end
	-- PINNNNNN
	if self.is_on_win_screen then
		local old_font = gfx.getFont()
		gfx.setFont(FONT_PAINT)

		local text = "CONGRATULATIONS! "
		local w = get_text_width(text, FONT_PAINT)
		local text_x1 = floor((CANVAS_WIDTH - w)/2)

		for i=1, #self.logo_cols + 1 do
			local text_x = text_x1
			for i_chr=1, #text do
				local chr = utf8.sub(text, i_chr, i_chr)
				local t = self.t + i_chr*0.04
				local ox, oy = cos(t*4 + i*.2)*8, sin(t*4 + i*.2)*8
				
				local col = self.logo_cols[i]
				if col == nil then
					col = COL_WHITE
				end
				gfx.setColor(col)
				gfx.print(chr, text_x + ox, 40 + oy)

				text_x = text_x + get_text_width(chr) + 1
			end
		end

		gfx.setFont(old_font)
		
		-- Win stats
		local iy = 0
		local ta = {}
		for k,v in pairs(self.stats) do
			local val = v
			if k == "time" then val = time_to_string(v) end
			table.insert(ta, concat(k,": ",val))
		end
		table.insert(ta, "PRESS [ESCAPE]")

		for k,v in pairs(ta) do
			local t = self.t + iy*0.2
			local ox, oy = cos(t*4)*5, sin(t*4)*5
			local mx = CANVAS_WIDTH / 2

			print_centered_outline(COL_WHITE, COL_BLACK_BLUE, v, mx+ox, 80+iy*14 +oy)
			iy = iy + 1
		end
	end

	-- Flash
	if self.flash_alpha then
		rect_color({1,1,1,self.flash_alpha}, "fill", self.cam_realx, self.cam_realy, CANVAS_WIDTH, CANVAS_HEIGHT)
	end

	-- Timer
	if options:get("timer_on") then
		gfx.print(time_to_string(self.time), 2, 2)
	end

	-- Debug
	if self.colview_mode then
		self:draw_colview()
	end
	if self.debug_mode then
		self:draw_debug()
	end
	if self.inputview_mode then
		local txts = {}
		local p = self.players[1]
		for k,v in pairs(p.controls) do
			if type(v) == "table" then
				table.insert(txts, concat(k, "/ down:[", p:button_down(k), "] prsd:[", p:button_pressed(k),"] old:[", p.last_input_state[k], "]"))
			end
		end
		for i=1, #txts do  print_label(txts[i], self.cam_x, 80+self.cam_y+get_text_height("")*i) end
	
		local txts = {}
		local p = self.players[1]
		for k,v in pairs(p.last_input_state) do
			table.insert(txts, concat(k," ",v))
		end
		for i=1, #txts do  print_label(txts[i], self.cam_x+CANVAS_WIDTH/2+30, self.cam_y+get_text_height("")*i) end
	end

	-- Menus
	if self.menu.cur_menu then
		self.menu:draw()
	end

	--'Memory used (in kB): ' .. collectgarbage('count')

	-- local t = "EARLY VERSION - NOT FINAL!"
	-- gfx.print(t, CANVAS_WIDTH-get_text_width(t), 0)
	-- local t = os.date('%a %d/%b/%Y')
	-- print_color({.7,.7,.7}, t, CANVAS_WIDTH-get_text_width(t), 12)

end

function Game:draw_colview()
	local items, len = collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		rect_color({0,1,0,.2},"fill", x, y, w, h)
		rect_color({0,1,0,.5},"line", x, y, w, h)
	end
end

function Game:draw_debug()
	gfx.print(concat("FPS: ",love.timer.getFPS(), " / frmRpeat: ",self.frame_repeat, " / frame: ",frame), 0, 0)
	
	-- Print debug info
	local txt_h = get_text_height(" ")
	local txts = {
		concat("FPS: ",love.timer.getFPS()),
		concat("n° of actors: ", #self.actors, " / ", self.actor_limit),
		concat("n° of enemies: ", self.enemy_count),
		concat("n° collision items: ", collision.world:countItems()),
		concat("elevator speed: ", self.elevator_speed),
		concat("frames_to_skip: ", self.frames_to_skip),
		concat("self.sfx_elevator_bg_volume", self.sfx_elevator_bg_volume),
		concat("debug1", self.debug1),
		"",
	}

	for i=1, #txts do  print_label(txts[i], self.cam_x, self.cam_y+txt_h*i) end
	
	self.world_generator:draw()
	draw_log()
end

function Game:on_menu()
	self.music_source:pause()
	self.sfx_elevator_bg:pause()
	for k,p in pairs(self.players) do
		p.sfx_wall_slide:setVolume(0)
	end
end
function Game:on_unmenu()
	self.music_source:play()
	self.sfx_elevator_bg:play()
end
function Game:set_music_volume(vol)
	self.music_source:setVolume(vol)
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

		if actor.name == "dummy_target" then
			self.game_started = true
		end
	end

	if actor.is_player then
		-- Save stats
		self:save_stats()
	end
end

function Game:save_stats()
	self.stats.time = self.time
	self.stats.floor = self.floor
	self.stats.kills = self.kills
end

function Game:on_game_over()
	self.menu:set_menu("game_over")
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
	-- TODO: move this to a general function (?)
	local sprs = {
		images.ant,
		images.caterpillar
	}

	self.players = {}

	-- Spawn at middle
	local mx = floor((self.map.width / self.max_number_of_players))
	local my = floor(self.map.height / 2)

	for i=1, self.number_of_players do
		local player = Player:new(i, mx*16 + i*16, my*16, sprs[i], options:get_controls(i))
		self.players[i] = player
		self:new_actor(player)
	end
end

-----------------------------------------------------
--- [[[[[[[[ BACKGROUND & LEVEL PROGRESS ]]]]]]]] ---
-----------------------------------------------------

-- TODO: Should we move this to a separate 'Elevator'/'Level' class?
---> Yes, but that would require effort

function Game:new_bg_particle()
	local o = {}
	o.x = love.math.random(0, CANVAS_WIDTH)
	o.w = love.math.random(2, 12)
	o.h = love.math.random(8, 64)
	
	if self.elevator_speed >= 0 then
		o.y = -o.h - love.math.random(0, CANVAS_HEIGHT)
	else
		o.y = CANVAS_HEIGHT + o.h + love.math.random(0, CANVAS_HEIGHT)
	end

	o.col = random_sample{COL_DARK_GRAY, COL_MID_GRAY}
	if self.bg_particle_col then
		o.col = random_sample(self.bg_particle_col)
	end
	o.spd = random_range(0.5, 1.5)

	o.oy = 0
	o.oh = 1

	o.t = 0
	o.rnd_pi = random_neighbor(math.pi)
	return o
end

function Game:update_bg_particles(dt)
	-- Background lines
	for i,o in pairs(self.bg_particles) do
		o.y = o.y + dt*self.elevator_speed*o.spd
		
		local del_cond = (self.elevator_speed>=0 and o.y > CANVAS_HEIGHT) or (self.elevator_speed<0 and o.y < -CANVAS_HEIGHT) 
		if del_cond then
			-- print("y at: CANVAS_HEIGHT * ", (o.y)/CANVAS_HEIGHT)
			local p = self:new_bg_particle()
			-- o = p
			-- ^^^^^ WHY DOES THIS NOT. WORK. I'm going crazy
			o.x = p.x
			o.y = p.y
			o.w = p.w
			o.h = p.h
			o.col = p.col
			o.spd = p.spd
			o.oy = p.oy
			o.oh = p.oh
			o.rnd_pi = p.rnd_pi
		end

		-- Size corresponds to elevator speed
		o.oh = max(o.w/o.h, abs(self.elevator_speed) / self.def_elevator_speed)
		o.oy = .5 * o.h * o.oh
	end
end	

function Game:progress_elevator(dt)
	-- Set bg elevator noise and this should be its own function or some lame dumb shit
	-- There are 2 types of devs: those who make a ElevatorBGNoise class and those who
	-- ship games 
	local r = abs(self.elevator_speed/self.elevator_speed_cap)
	self.sfx_elevator_bg_volume = lerp(self.sfx_elevator_bg_volume,
		clamp(r, 0, self.sfx_elevator_bg_def_volume), 0.1)
	self.sfx_elevator_bg:setVolume(self.sfx_elevator_bg_volume)
	if options:get("disable_background_noise") then
		self.sfx_elevator_bg:setVolume(0)
	end

	-- this is stupid, should've used game.state or smthg
	if self.is_exploding_elevator then
		self:do_exploding_elevator(dt)
		return
	end
	if self.is_reversing_elevator then
		self:do_reverse_elevator(dt)
		return
	end

	-- Only switch to next floor until all enemies killed
	if not self.door_animation and self.enemy_count == 0 then
		self.door_animation = true
		self.has_switched_to_next_floor = false
		self:new_wave_buffer_enemies(dt)
	end

	-- Do the door opening animation
	if self.door_animation then
		self.floor_progress = self.floor_progress - dt
		self:update_door_anim(dt)
	end
	
	-- Go to next floor once animation is finished
	if self.floor_progress <= 0 then
		self.floor_progress = 5.5
		
		self.door_animation = false
		self.draw_enemies_in_bg = false
		self.door_offset = 0
	end
end

function Game:update_door_anim(dt)
	-- 4-3: open doors / 3-2: idle / 2-1: close doors
	if self.floor_progress > 4 then
		-- Door is closed at first...
		self.door_offset = 0
	elseif self.floor_progress > 3 then
		-- ...Open door...
		self.door_offset = lerp(self.door_offset, 54, 0.1)
		sounds.elev_door_open:play()
	elseif self.floor_progress > 2 then
		-- ...Keep door open...
		self.door_offset = 54
	elseif self.floor_progress > 1 then
		-- ...Close doors
		self.door_offset = lerp(self.door_offset, 0, 0.1)
		sounds.elev_door_close:play()
		self:activate_enemy_buffer(dt)
	end

	-- Elevator speed
	if 5 > self.floor_progress and self.floor_progress > 3 then
		-- Slow down
		self.elevator_speed = max(0, self.elevator_speed - 18)
	
	elseif self.floor_progress < 1 then
		-- Speed up	
		self.elevator_speed = min(self.elevator_speed + 10, self.def_elevator_speed)
	end

	-- Switch to next floor if just opened doors
	if self.floor_progress < 4.2 and not self.has_switched_to_next_floor then
		self.floor = self.floor + 1
		self.has_switched_to_next_floor = true
		self:next_floor(dt)
	end
end

function Game:next_floor(dt)
	self.move_logo = true
end

function Game:new_wave_buffer_enemies()
	-- Spawn a bunch of enemies
	local bw = BLOCK_WIDTH
	local wg = self.world_generator
	
	self.cur_wave_max_enemy = n
	self.door_animation_enemy_buffer = {}

	-- print(self.floor, clamp(self.floor, 1, #waves))
	local wave_n = clamp(self.floor+1, 1, #waves) -- floor+1 because the floor indicator changes before enemies are spawned
	local wave = waves[wave_n]
	local n = love.math.random(wave.min, wave.max)

	-- BG color changes
	if wave_n == floor((self.bg_color_index) * (#waves / #self.bg_colors)) then
		self.bg_color_index = self.bg_color_index + 1
		self.bg_color_progress = 0
	end

	-- On wave 5, summon jetpack tutorial
	-- self.move_jetpack_tutorial = (self.is_first_time and wave_n == 5)
	self.move_jetpack_tutorial = (wave_n == 5)
	for i=1, n do
		-- local x = love.math.random((wg.box_ax+1)*bw, (wg.box_bx-1)*bw)
		-- local y = love.math.random((wg.box_ay+1)*bw, (wg.box_by-1)*bw)
		local x = love.math.random(self.door_ax + 16, self.door_bx - 16)
		local y = love.math.random(self.door_ay + 16, self.door_by - 16)

		local enem = random_weighted(wave.enemies)
		local e = enem:new(x,y)

		-- Center enemy
		if enem ~= Enemies.ButtonGlass then
			e.x = floor(e.x - e.w/2)
			e.y = floor(e.y - e.h/2)
		end
		
		-- Prevent collisions with floor
		if e.y+e.h > self.door_by then   e.y = self.door_by - e.h    end
		collision:remove(e)
		table.insert(self.door_animation_enemy_buffer, e)
	end
end

function Game:activate_enemy_buffer()
	for k, e in pairs(self.door_animation_enemy_buffer) do
		e:add_collision()
		self:new_actor(e)
	end
	self.door_animation_enemy_buffer = {}
end

function Game:draw_background(cabin_x, cabin_y)
	local bw = BLOCK_WIDTH

	-- Doors
	gfx.draw(images.cabin_door_left,  cabin_x + 154 - self.door_offset, cabin_y + 122)
	gfx.draw(images.cabin_door_right, cabin_x + 208 + self.door_offset, cabin_y + 122)

	-- Cabin background
	gfx.draw(images.cabin_bg, cabin_x, cabin_y)
	gfx.draw(images.cabin_bg_amboccl, cabin_x, cabin_y)
	
	-- Level counter
	gfx.setFont(FONT_7SEG)
	print_color(COL_WHITE, string.sub("00000"..tostring(self.floor),-3,-1), 198+16*2, 97+16*2)
	gfx.setFont(FONT_REGULAR)
end

function Game:draw_rubble(x,y)
	gfx.draw(images.cabin_rubble, x, (16-5)*BW)
end

function Game:on_red_button_pressed()
	self.is_reversing_elevator = true
end

function Game:do_reverse_elevator(dt)
	self.elevator_speed_cap = -1000
	local speed_cap = self.elevator_speed_cap

	self.elevator_speed = max(self.elevator_speed - dt*100, speed_cap)
	if self.elevator_speed == speed_cap then
		self.elevator_speed_overflow = self.elevator_speed_overflow + dt
	end

	-- exploding bits
	if self.elevator_speed_overflow > 2 then
		self.is_reversing_elevator = false
		self.is_exploding_elevator = true -- I SHOULDVE MADE A STATE SYSTEM BUT FUCK LOGIC
		self:on_exploding_elevator(dt)
		sounds.elev_burning:stop()
		return
	end

	sounds.elev_burning:play()
	sounds.elev_burning:setVolume(abs(self.elevator_speed/speed_cap))

	-- Screenshake
	local spdratio = self.elevator_speed / self.def_elevator_speed
	game.screenshake_q = 2 * abs(spdratio)

	self.downwards_elev_progress = self.downwards_elev_progress - self.elevator_speed
	if self.downwards_elev_progress > 100 then
		self.downwards_elev_progress = self.downwards_elev_progress - 100
		self.floor = self.floor - 1
		if self.floor <= 0 then
			self.do_random_elevator_digits = true
		end

		if self.do_random_elevator_digits then
			self.floor = random_range(0,999)
		end
	end

	-- Downwards elevator
	if self.elevator_speed < 0 then
		for _,p in pairs(self.actors) do
			p.friction_y = p.friction_x
			if p.is_player then  p.is_flying = true end

			p.gravity_mult = max(0, 1 - abs(self.elevator_speed / speed_cap))
			p.vy = p.vy - 4
		end

		-- fire particles
		local q = max(0, (abs(self.elevator_speed) - 200)*0.04)
		for i=1, q do
			local x,y = random_range(self.cabin_ax, self.cabin_bx),random_range(self.cabin_ay, self.cabin_by)
			local size = max(4, abs(self.elevator_speed)*0.01)
			local velvar = max(5, abs(self.elevator_speed))
			particles:fire(x,y,size, nil, velvar)
		end

		-- bg color shift to red
		local p = self.elevator_speed / speed_cap
		local r = lerp(self.def_bg_col[1], 0xf7/255, p)
		local g = lerp(self.def_bg_col[2], 0x76/255, p)
		local b = lerp(self.def_bg_col[3], 0x22/255, p)
		self.bg_col = {r,g,b,1}
		self.bg_particle_col = { {r+0.1, g+0.1, b+0.1, 1},{r+0.2, g+0.2, b+0.2, 1} }
	end
end

function Game:on_exploding_elevator(dt)
	self.elevator_speed = 0
	self.bg_col = COL_BLACK_BLUE
	self.bg_particle_col = nil--{ {r+0.1, g+0.1, b+0.1, 1},{r+0.2, g+0.2, b+0.2, 1} }
	self.flash_alpha = 2
	self:screenshake(40)
	self.show_rubble = true
	self.show_cabin = false
	for _,p in pairs(self.bg_particles) do
		p.col = random_sample{COL_DARK_GRAY, COL_MID_GRAY}
	end
	
	-- Crash sfx
	audio:play(sounds.elev_crash)

	-- YOU WIN
	self.is_on_win_screen = true

	-- init map coll
	local map = self.map
	map:reset()
	local lens = {
		0,29,
		5,26,
		7,23,
		10,22,
		16,17
	}
	--bounds
	for ix=0,map.width do
		map:set_tile(ix,0, 2)
	end
	for iy=0,map.height do
		map:set_tile(0,iy, 2)
		map:set_tile(map.width-1,iy, 2)
	end
	-- map collision
	local mx = map.width/2
	local i=1
	for iy=map.height-1, map.height-1-#lens, -1 do
		local x1, x2 = lens[i], lens[i+1]
		if x1~= nil and x2~= nil then
			local til = 2
			if i==1 then til=1 end

			for ix=x1,x2 do
				map:set_tile(ix, iy, til)
			end
		end
		i=i+2
	end

	----smoke
	for i=1, 200 do
		local x,y = random_range(self.cabin_ax, self.cabin_bx),random_range(self.cabin_ay, self.cabin_by)
		particles:splash(x,y, 5, nil, nil, 10, 4)
	end

	--reset player gravity
	for _,p in pairs(self.actors) do
		p.friction_y = 1
		if p.is_player then  p.is_flying = false end

		p.gravity_mult = 1--max(0, 1 - abs(self.elevator_speed / speed_cap))
		if p.name == "button_pressed" then
			p:kill()
		end
	end
end

function Game:do_exploding_elevator(dt)
	local x,y = random_range(self.cabin_ax, self.cabin_bx), 16*BW
	local mw = CANVAS_WIDTH/2
	y = 16*BW-8 - max(0, lerp(BW*4-8, -16, abs(mw-x)/mw))
	local size = random_range(4, 8)
	particles:fire(x,y,size, nil, 80, -5)
end

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

function Game:keypressed(key, scancode, isrepeat)
	if key == "f3" then
		self.debug_mode = not self.debug_mode
	elseif key == "f2" then
		self.colview_mode = not self.colview_mode
	elseif key == "f1" then
		self.inputview_mode = not self.inputview_mode
	end

	if self.menu then
		self.menu:keypressed(key, scancode, isrepeat)
	end

	for i, ply in pairs(self.players) do
		--ply:keypressed(key, scancode, isrepeat)
	end
end

-- function Game:keyreleased(key, scancode)
-- 	for i, ply in pairs(self.players) do
-- 		--ply:keyreleased(key, scancode)
-- 	end
-- end

function Game:screenshake(q)
	if not options:get('screenshake_on') then  return   end  
	self.screenshake_q = self.screenshake_q + q
end

function Game:frameskip(q)
	self.frames_to_skip = min(60, self.frames_to_skip + q + 1)
end

function Game:button_down(btn)
	--[[
		Returns if ANY player is holding `btn`
	]]
	for _, player in pairs(self.players) do
		if player:button_down(btn) then
			return true, player
		end
	end
	return false
end

function Game:button_pressed(btn)
	--[[
		Returns if ANY player is pressing `btn`
	]]
	for _, player in pairs(self.players) do
		if player:button_pressed(btn) then
			return true, player
		end
	end
	return false
end

-- Moved to OptionsManager
-- function Game:toggle_sound()
-- 	-- TODO: move from bool to a number (0-1), customisable in settings
-- 	self.sound_on = not self.sound_on
-- 	if options then    options:update_options_file()    end
-- end

-- function Game:set_volume(n)
-- 	self.volume = n
-- 	love.audio.setVolume( self.volume )
-- 	if options then    options:update_options_file()    end
-- end

return Game