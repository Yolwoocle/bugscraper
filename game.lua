local Class = require "class"
local Collision = require "collision"
local Player = require "player"
local Enemies = require "stats.enemies"
local Bullet = require "bullet"
local TileMap = require "tilemap"
local WorldGenerator = require "worldgenerator"
local Inventory = require "inventory"
local ParticleSystem = require "particles"
local AudioManager = require "audio"
local waves = require "stats.waves"

local images = require "images"
require "util"
require "constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	collision = Collision:new()
	particles = ParticleSystem:new()
	audio = AudioManager:new()

	-- Audio
	self.sound_on = false

	-- Players
	self.number_of_player = 1

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
	self.draw_enemies_in_bg = false
	self.door_animation = false
	self.def_elevator_speed = 400
	self.elevator_speed = self.def_elevator_speed
	self.has_switched_to_next_floor = false

	-- Bounding box
	local map_w = self.map.width * BW
	local map_h = self.map.height * BW
	self.boxes = {
		{name="box_up",     is_solid = true, x = -BW, y = -BW,      w=map_w + 2*BW, h=BW},
		{name="box_down", is_solid = true, x = -BW, y = map_h, w=map_w + 2*BW, h=BW},
		{name="box_left", is_solid = true, x = -BW,  y = -BW, w=BW, h=map_h + 2*BW},
		{name="box_right", is_solid = true, x = map_w, y = -BW, w=BW, h=map_h + 2*BW},
	}
	for i,box in pairs(self.boxes) do   collision:add(box)   end
	
	-- Actors
	self.actor_limit = 100
	self.enemy_count = 0
	self.actors = {}
	self:init_players()
	self:new_actor(Enemies.Bug:new(64,64))

	self.inventory = Inventory:new()

	-- Debugging
	self.debug_mode = false
	self.msg_log = {}

	self.test_t = 0

	self.bg_particles = {}
	for i=1,60 do
		table.insert(self.bg_particles, self:new_bg_particle())
	end

	-- Logo
	self.logo_y = 15
	self.logo_vy = 0
	self.move_logo = false
end

function Game:update(dt)
	self.map:update(dt)
	
	-- Particles
	particles:update(dt)
		-- Background lines
	for i,o in pairs(self.bg_particles) do
		o.y = o.y + dt*self.elevator_speed*o.spd
		if o.y > CANVAS_HEIGHT then
			o.x = love.math.random(0, CANVAS_WIDTH)
			o.w = love.math.random(2, 12)
			o.h = love.math.random(8, 64)
			o.y = -o.h- love.math.random(0, CANVAS_HEIGHT)
			o.col = random_sample{COL_DARK_GRAY, COL_MID_GRAY, --[[COL_DARK_RED, COL_MID_DARK_GREEN, COL_DARK_BLUE, COL_DARK_PURPLE]]}
		end

		-- Size corresponds to elevator speed
		o.oh = max(o.w/o.h, self.elevator_speed / self.def_elevator_speed)
		o.oy = .5 * o.h * o.oh
	end

	self:progress_elevator(dt)

	-- Update actors
	for k,actor in pairs(self.actors) do
		if not actor.debug_timer then    actor.debug_timer = 0    end
		actor.debug_timer = actor.debug_timer + 1
		actor:update(dt)
	end

	-- Delete actors
	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]
		if actor.is_removed then
			table.remove(self.actors, i)
		end
	end

	-- Logo
	if self.move_logo then
		self.logo_vy = self.logo_vy - dt
		self.logo_y = self.logo_y + self.logo_vy
	end
end

function Game:draw()
	-- Sky
	gfx.clear(COL_BLACK_BLUE)

	for i,o in pairs(self.bg_particles) do
		rect_color(o.col, "fill", o.x, o.y + o.oy, o.w, o.h * o.oh)
	end

	-- Map
	self.map:draw()
	
	-- Background
	--TODO: fuze it into map or remove map, only have coll boxes & no map
	local bw = BLOCK_WIDTH
	self.cabin_x, self.cabin_y = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.door_ax, self.door_ay = self.cabin_x+154, self.cabin_x+122
	self.door_bx, self.door_by = self.cabin_y+261, self.cabin_y+207

	-- If doing door animation, draw buffered enemies
	if self.door_animation then
		for i,e in pairs(self.door_animation_enemy_buffer) do 
			e:draw()
		end
	end
	self:draw_background(self.cabin_x, self.cabin_y)
	
	-- Draw actors
	for k,actor in pairs(self.actors) do
		actor:draw()
	end
	particles:draw()

	-- Walls
	gfx.draw(images.cabin_walls, self.cabin_x, self.cabin_y)
	
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

	love.graphics.draw(images.logo, (CANVAS_WIDTH - images.logo:getWidth())/2, self.logo_y)

	-- Debug
	if self.debug_mode then
		self:draw_debug()
	end

	gfx.print(concat("FPS: ",love.timer.getFPS(), " / frmRpeat: ",self.frame_repeat, " / frame: ",frame), 0, 0)
end

function Game:draw_debug()
	local items, len = collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		rect_color({0,1,0,.7},"line", x, y, w, h)
	end
	
	local ii = 1
	for i, it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		if it.is_actor then
			ii = ii + 1
			print_color(COL_WHITE, ii, x, y)
		end
	end
	
	-- Print debug info
	local txt_h = get_text_height(" ")
	local txts = {
		concat("FPS: ",love.timer.getFPS()),
		concat("n° of actors: ", #self.actors, " / ", self.actor_limit),
		concat("n° collision items: ", collision.world:countItems()),
	}
	for i=1, #txts do  print_label(txts[i], 0, txt_h*i) end 
	
	self.world_generator:draw()
	draw_log()
end

function Game:new_actor(actor)
	if #self.actors >= self.actor_limit then   
		actor:remove()
		return
	end
	if actor.is_enemy then 
		self.enemy_count = self.enemy_count + 1
	end
	table.insert(self.actors, actor)
end

function Game:on_kill(actor)
	if actor.is_enemy then
		self.enemy_count = self.enemy_count - 1
	end
end

function draw_log()
	-- log
	local x2 = floor(CANVAS_WIDTH/2)
	local h = gfx.getFont():getHeight()
	print_label("--- LOG ---", x2, 0)
	for i=1, min(#msg_log, 10) do
		print_label(msg_log[i], x2, i*h)
	end
end

function Game:init_players()
	local control_schemes = {
		[1] = {
			type = "keyboard",
			left = {"a", "left"},
			right = {"d", "right"},
			up = {"w", "up"},
			down = {"s", "down"},
			jump = {"z", "c", "b"},
			fire = {"x", "v", "n"},
			switchgun = {"s"}, --test
		},
		[2] = {
			type = "keyboard",
			left = {"left"},
			right = {"right"},
			up = {"up"},
			down = {"down"},
			jump = {"."},
			fire = {","},
		}
	}

	local sprs = {
		images.ant,
		images.caterpillar
	}

	self.players = {}

	-- Spawn at middle
	local mx = floor((self.map.width - self.number_of_player) / 2)
	local my = floor(self.map.height / 2)

	for i=1, self.number_of_player do
		local player = Player:new(i, mx*16 + i*16, my*16, sprs[i], control_schemes[i])
		self.players[i] = player
		self:new_actor(player)
	end
end


-----------------------------------------------------
--- [[[[[[[[ BACKGROUND & LEVEL PROGRESS ]]]]]]]] ---
-----------------------------------------------------

-- TODO: Should we move this to a separate class?

function Game:new_bg_particle()
	local o = {}
	o.x = love.math.random(0, CANVAS_WIDTH)
	o.w = love.math.random(2, 12)
	o.h = love.math.random(8, 64)
	o.y = -o.h - love.math.random(0, CANVAS_HEIGHT)
	o.col = random_sample{COL_DARK_GRAY, COL_MID_GRAY}
	o.spd = random_range(0.5, 1.5)

	o.oy = 0
	o.oh = 1
	return o
end

function Game:progress_elevator(dt)
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
	elseif self.floor_progress > 2 then
		-- ...Keep door open...
		self.door_offset = 54
	elseif self.floor_progress > 1 then
		-- ...Close doors
		self.door_offset = lerp(self.door_offset, 0, 0.1)
		self:activate_enemy_buffer(dt)
	end

	-- Elevator speed
	if 5 > self.floor_progress and self.floor_progress > 3 then
		self.elevator_speed = max(0, self.elevator_speed - 18)
	elseif self.floor_progress < 1 then
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

	local wave = waves[clamp(self.floor, 1, #waves)]
	local n = love.math.random(wave.min, wave.max)
	for i=1, n do
		-- local x = love.math.random((wg.box_ax+1)*bw, (wg.box_bx-1)*bw)
		-- local y = love.math.random((wg.box_ay+1)*bw, (wg.box_by-1)*bw)
		local x = love.math.random(self.door_ax, self.door_bx)
		local y = love.math.random(self.door_ay, self.door_by)
		
		local enem = random_weighted(wave.enemies)
		local e = enem:new(x,y)
		
		-- Center enemy
		e.x = floor(e.x - e.w/2)
		e.y = floor(e.y - e.h/2)
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

function Game:keypressed(key, scancode, isrepeat)
	if key == "f3" then
		self.debug_mode = not self.debug_mode
	end

	for i, ply in pairs(self.players) do
		--ply:keypressed(key, scancode, isrepeat)
	end
end

function Game:keyreleased(key, scancode)
	for i, ply in pairs(self.players) do
		--ply:keyreleased(key, scancode)
	end
end

return Game