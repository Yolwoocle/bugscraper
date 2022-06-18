local Class = require "class"
local Collision = require "collision"
local Player = require "player"
local Enemies = require "enemies"
local Bullet = require "bullet"
local TileMap = require "tilemap"
local WorldGenerator = require "worldgenerator"
local Inventory = require "inventory"
local ParticleSystem = require "particles"

local images = require "images"
require "util"
require "constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	collision = Collision:new()
	particles = ParticleSystem:new()

	-- Players
	self.number_of_player = 2

	-- Map & world gen
	self.shaft_w, self.shaft_h = 26,14
	self.map = TileMap:new(30, 17)
	self.world_generator = WorldGenerator:new(self.map)
	self.world_generator:generate(10203)
	self.world_generator:make_box(self.shaft_w, self.shaft_h)

	-- Level info
	self.floor = 0 --Floor n°
	self.floor_progress = 0 --How far the cabin is to the next floor, 0-1
	self.elevator_speed = 1/10

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
	self.actor_limit = 30
	self.actors = {}
	self:init_players()
	self:new_actor(Enemies.Bug:new(64,64))

	self.inventory = Inventory:new()

	-- Debugging
	self.debug_mode = false
	self.msg_log = {}

	self.test_t = 0

	self.test_bgstuff = {}
	for i=1,20 do
		local o = {}
		o.x = love.math.random(0, CANVAS_WIDTH)
		o.w = love.math.random(2, 12)
		o.h = love.math.random(8, 64)
		o.y = -o.h - love.math.random(0, CANVAS_HEIGHT)
		table.insert(self.test_bgstuff, o)
	end
end

function Game:update(dt)
	for i,o in pairs(self.test_bgstuff) do
		o.y = o.y + dt*400
		if o.y > CANVAS_HEIGHT then
			o.x = love.math.random(0, CANVAS_WIDTH)
			o.w = love.math.random(2, 12)
			o.h = love.math.random(8, 64)
			o.y = -o.h- love.math.random(0, CANVAS_HEIGHT)
		end
	end

	self.map:update(dt)
	particles:update(dt)

	self:progress_elevator(dt)

	for k,actor in pairs(self.actors) do
		actor.debug_timer = 0
	end

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

	--- azdazedad teststet test SPAWN ACT5OR
	self.test_t = self.test_t-dt
	if self.test_t < 0 then

	end

	if love.keyboard.isDown("r") then   
		self.world_generator.seed = self.world_generator.seed - 0.05
		self.world_generator:generate(self.map)
	end
	if love.keyboard.isDown("t") then   
		self.world_generator.seed = self.world_generator.seed + 0.05
		self.world_generator:generate(self.map)
	end
end

function Game:draw()
	-- Sky
	gfx.clear(COL_DARK_BLUE)
	particles:draw()

	for i,o in pairs(self.test_bgstuff) do
		rect_color(COL_DARK_GRAY, "fill", o.x, o.y, o.w, o.h)
	end

	-- Map & Actor
	self.map:draw()
	--TODO: fuze it into map or remove map, only have coll boxes & no map
	local bw = BLOCK_WIDTH
	gfx.draw(images.cabin_bg, self.world_generator.box_ax*bw, self.world_generator.box_ay*bw)
	for k,actor in pairs(self.actors) do
		actor:draw()
	end

	-- UI
	print_centered_outline(COL_WHITE, COL_DARK_BLUE, concat("FLOOR ",self.floor), CANVAS_WIDTH/2, 8)
	local w = 64
	rect_color(COL_MID_GRAY, "fill", floor((CANVAS_WIDTH-w)/2),    16, w, 8)
	rect_color(COL_WHITE,    "fill", floor((CANVAS_WIDTH-w)/2) +1, 17, (w-2)*self.floor_progress, 6)

	-- Debug
	if self.debug_mode then
		self:draw_debug()
	end

	gfx.print(concat("FPS: ",love.timer.getFPS()), 0, 0)
end

function Game:new_actor(actor)
	if #self.actors >= self.actor_limit then   
		actor:remove()
		return
	end
	table.insert(self.actors, actor)
end

function Game:draw_debug()
	local items, len = collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		rect_color({0,1,0},"line", x, y, w, h)
	end
	
	local ii = 1
	for i, it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		if it.is_actor then
			ii = ii + 1
			print_color(COL_WHITE, ii, x, y)
		end
	end
	
	-- Print FPS
	local txts = {
		love.timer.getFPS(),
		concat("n° of actors: ", #self.actors, " / ", self.actor_limit),
		concat("n° collision items: ", --[[collision.world:countItems()]]0)
	}
	for i=1, #txts do  print_label(txts[i], 0, 16*i) end 
	
	self.world_generator:draw()
	draw_log()
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
			left = {"a"},
			right = {"d"},
			up = {"w"},
			down = {"s"},
			jump = {"c"},
			fire = {"v"},
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

function Game:progress_elevator(dt)
	self.floor_progress = self.floor_progress + self.elevator_speed * dt
	if self.floor_progress > 1 then
		self.floor = self.floor + 1
		self.floor_progress = self.floor_progress - 1
		self:new_wave()
	end
end

function Game:new_wave()
	-- Spawn a bunch of enemies
	local bw = BLOCK_WIDTH
	local wg = self.world_generator
	local n = 10 + self.floor
	for i=1, n do
		local x,y = love.math.random(wg.box_ax*bw, wg.box_bx*bw), love.math.random(wg.box_ay*bw, wg.box_by*bw)
		local enem = random_sample{Enemies.Bee, Enemies.Larva}
		self:new_actor(enem:new(x,y))
	end
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