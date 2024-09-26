-- This file is for functions, classes that are unused but I figure
-- I might have an use for later on. 

--
------------------------------------
-- Old demo waves

local demo_waves = {	
	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},
		},
		music = "w1",

		title = get_world_name("1"),
		title_color = COL_MID_BLUE,
	}),

	
	new_wave({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enable_stomp_arrow_tutorial = true,
		enemies = {
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 3},
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 2},
			{E.Slug, 2},
		},
	}),
	
	new_wave({
		-- Spider intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Spider, 4},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 5},
			{E.Slug, 2},
			{E.Spider, 3},
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		-- Mosquito intro
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 4},
		},
	}),

	new_wave({ 
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 2},
			{E.Slug, 5},
			{E.Fly, 2},
			{E.Mosquito, 2},
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{E.SnailShelled, 3},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			-- 
			{E.Mosquito, 3},
			{E.Fly, 4},
			{E.Larva, 4},
			{E.SnailShelled, 3},
			{E.Spider, 3},
		},
	}),

	new_wave({ 
		-- Spiked Fly intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 1},
			{E.Fly, 2},
			{E.Mosquito, 2},
			{E.SpikedFly, 4},
		},
	}),

	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	}),

	new_cafeteria(),

	new_wave({ 
		-- Grasshopper intro
		min = 4,
		max = 4,
		enemies = {
			{E.Grasshopper, 8},
		},
		music = "w1",
	}),

	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.Grasshopper, 8},
			{E.Woodlouse, 2},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	}),

	new_wave({ 
		-- Mushroom Ant intro
		min = 5,
		max = 6,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 3},
			{E.MushroomAnt, 3},
		},
	}),


	new_wave({ 
		min = 8,
		max = 10,
		enemies = {
			{E.MushroomAnt, 3},
			{E.Woodlouse, 2},
			{E.Fly, 1},
			{E.SpikedFly, 1},
			{E.Spider, 2},
		},
	}),

	new_wave({ 
		-- Honeypot ant intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 3},
			{E.HoneypotAnt, 6},
			{E.MushroomAnt, 3},
			{E.SpikedFly, 3},
		},
	}),

	new_wave({ -- 12
		-- ALL
		min = 12,
		max = 12,
		enemies = {
			{E.Larva, 4},
			{E.Fly, 3},
			{E.SnailShelled, 3},
			{E.Mosquito, 3},
			{E.Slug, 2},
			{E.HoneypotAnt, 2},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.MushroomAnt, 1},
			{E.Spider, 1},
		},
	}),

	new_wave({
		min = 14,
		max = 16,
		enemies = {
			{E.Fly, 3},
			{E.HoneypotAnt, 2},
			{E.SnailShelled, 3},
			{E.Woodlouse, 1},
			{E.Slug, 2},
			{E.Mosquito, 3},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.MushroomAnt, 1},
			{E.Spider, 1},
		},
	}),

	new_wave({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enemies = {	
			{E.Dung, 1, position = {240, 200}},			
		},
		music = "miniboss",
	}),
	
	-- Last wave
	new_wave({ 
		min = 1,
		max = 1,
		enemies = {
			{E.ButtonBigGlass, 1, position = {211, 194}}
		},
		music = "off",
	})
}



------------------------------------
--- Old love.update function
--- 

function love.update(dt)
	_G_t = _G_t + dt
	local cap = 1 --If there's lag spike, repeat up to how many frames?
	local i = 0
	local update_fixed_dt = fixed_dt
	-- local update_fixed_dt = 1/30
	while (not _G_do_fixed_framerate or _G_t > update_fixed_dt) and cap > 0 do
		_G_t = _G_t - update_fixed_dt
		fixed_update()
		cap = cap - 1
		i=i+1
	end

	if game then   game.frame_repeat = i end
	_G_frame = _G_frame + 1
end

------------------------------------


-- Sprite

local r = self.standby_timer.time / self.standby_timer.duration
if r > 0.5 then
	self.spr:set_visible(false)
	self.spike_sprite:set_visible(false)
	return
else
	self.spr:set_visible(true)
	self.spike_sprite:set_visible(true)
end

local s = clamp(1 - (r*2), 0, 1)
if self.orientation == 0 or self.orientation == 2 then
	self.spr:set_scale(1, s)
	self.spike_sprite:set_scale(1, s)
else
	self.spr:set_scale(1, s)
	self.spike_sprite:set_scale(1, s)
end

---------------------------------
-- Twitter video explosins


["kp1"] = {"intro", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "How I made this explosion effect", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 3

	local arc = enemies.Explosion:new(x, y, 32)
	game:new_actor(arc)
end},

["kp2"] = {"dust", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "First, some shrinking circles", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 4
	
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local gradient = {
		type = "gradient",
		COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
	}
	Particles:smoke_big(x, y, gradient, 0, 1, {
		vx = 0, 
		vx_variation = 20, 
		vy = -50, 
		vy_variation = 10,
		-- min_spawn_delay = min_spawn_delay or 0,
		-- max_spawn_delay = max_spawn_delay or 0.2,
	})
end},

["kp3"] = {"smoke", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "Offset them in space and time", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 3

  
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local gradient = {
		type = "gradient",
		COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
	}
	Particles:smoke_big(x, y, gradient, 32+16, 200, {
		vx = 0, 
		vx_variation = 20, 
		vy = -50, 
		vy_variation = 10,
		min_spawn_delay = 0,
		max_spawn_delay = 0.2,
	})
end},

["kp4"] = {"back smoke", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "Add some black smoke afterwards", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 3
	

	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local radius = 32+16
	local function explosion_layer(col, rad, quantity, min_spawn_delay, max_spawn_delay)
		Particles:smoke_big(x, y, col, rad, quantity, {
			vx = 0, 
			vx_variation = 20, 
			vy = -50, 
			vy_variation = 10,
			min_spawn_delay = min_spawn_delay or 0,
			max_spawn_delay = max_spawn_delay or 0.2,
		})
	end

	local gradient = {
		type = "gradient",
		COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
	}
	explosion_layer({type = "gradient", COL_DARK_GRAY},  radius, 100, 0.2, 0.4)
	explosion_layer({type = "gradient", COL_BLACK_BLUE}, radius, 100, 0.2, 0.4)

	explosion_layer(gradient, radius,     200)
	-- explosion_layer(gradient, radius,     80)
	-- explosion_layer(gradient, radius*0.9, 60)
	-- explosion_layer(gradient, radius*0.8, 30)
	-- explosion_layer(gradient, radius*0.7, 20)
	-- explosion_layer(gradient, radius*0.6, 15)
end},

["kp5"] = {"debris", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "Add some flying debris", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 3
	
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local radius = 32+16
	local function explosion_layer(col, rad, quantity, min_spawn_delay, max_spawn_delay)
		Particles:smoke_big(x, y, col, rad, quantity, {
			vx = 0, 
			vx_variation = 20, 
			vy = -50, 
			vy_variation = 10,
			min_spawn_delay = min_spawn_delay or 0,
			max_spawn_delay = max_spawn_delay or 0.2,
		})
	end

	local gradient = {
		type = "gradient",
		COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
	}
	explosion_layer({type = "gradient", COL_DARK_GRAY},  radius, 100, 0.2, 0.4)
	explosion_layer({type = "gradient", COL_BLACK_BLUE}, radius, 100, 0.2, 0.4)

	explosion_layer(gradient, radius,     200)
	-- explosion_layer(gradient, radius,     80)
	-- explosion_layer(gradient, radius*0.9, 60)
	-- explosion_layer(gradient, radius*0.8, 30)
	-- explosion_layer(gradient, radius*0.7, 20)
	-- explosion_layer(gradient, radius*0.6, 15)

	Particles:image(x, y, 5, images.bullet_casing, 4, nil, nil, nil, {
		vx1 = -150,
		vx2 = 150,

		vy1 = 80,
		vy2 = -200,
	})

	Particles:image(x , y, 5, images.white_dust, 4, nil, nil, nil, {
		vx1 = -150,
		vx2 = 150,

		vy1 = 80,
		vy2 = -200,
	})
end},

["kp6"] = {"flash", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "Add a white flash", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 4
	
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	Particles:static_image(images.explosion_flash, x, y)
end},

["kp7"] = {"screenshake", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	if self.removeme_i == 0 then
		self.removeme_i = 1
		Particles:text(x, y-42, "Add some screenshake", nil, 2, nil, nil, 0.01)
		return
	end
	self.removeme_i = (self.removeme_i + 1) % 2
	
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local arc = enemies.Explosion:new(x, y, 32)
	game:new_actor(arc)
end},

["kp8"] = {"done text", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	self.removeme_i = 1
	Particles:text(x, y-42, "Done!", nil, 2, nil, nil, 0.01)
end},

["kp9"] = {"boom", function()
	local x, y = CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5
	local arc = enemies.Explosion:new(x, y, 32)
	game:new_actor(arc)
end},
}


------------------------------------
-- Old combos

-- (in update_combo)
	-- Stop combo if landed for more than a few frames
	if self.frames_since_land > 3 then
		if self.combo > self.max_combo then
			self:new_best_combo()
		end
		
		if self.combo >= 4 then
			-- Particles:word(self.mid_x, self.mid_y, Text:text("game.combo", self.combo), COL_LIGHT_BLUE)
		end
		self.combo = 0
	end

------------------------------------
-- old timer class
require "scripts.util"
local Class = require "scripts.meta.class"

local Timer = Class:inherit()

function Timer:init(duration, on_timeout)
    self.duration = duration
    self.time = duration
    self.on_timeout = on_timeout

    self.is_marked_for_deletion = false
end

function Timer:update(dt)
    if self.is_marked_for_deletion then
        return
    end

    self.time = self.time - dt
    if self.time <= 0 then
        self.on_timeout()
        self.is_marked_for_deletion = true
    end
end

return Timer

------------------------------------

-- View layers
	local x = 0
	local y = 0
	for i=1, #self.layers do
		rect_color({1,1,1,0.8}, "fill", x, y, CANVAS_WIDTH, CANVAS_HEIGHT)
		love.graphics.draw(self.layers[i].canvas, x, y)
		love.graphics.print(tostring(i), x, y)
		rect_color(COL_RED, "line", x, y, CANVAS_WIDTH, CANVAS_HEIGHT)

		x = x + (CANVAS_WIDTH)
		if x + CANVAS_WIDTH > SCREEN_WIDTH then
			x = 0
			y = y + CANVAS_HEIGHT
		end
	end

------------------------------------


self.elevator_speed_cap = -1000
self.elevator_speed_overflow = 0
self.is_reversing_elevator = false
self.is_exploding_elevator = false
self.downwards_elev_progress = 0

function Elevator:do_reverse_elevator(dt)
	self.elevator_speed_cap = -1000
	local speed_cap = self.elevator_speed_cap

	self.elevator_speed = max(self.elevator_speed - dt*100, speed_cap)
	if self.elevator_speed == speed_cap then
		self.elevator_speed_overflow = self.elevator_speed_overflow + dt
	end

	-- exploding bits
	if self.elevator_speed_overflow > 2 or game.debug.instant_end then
		self.is_reversing_elevator = false
		self.is_exploding_elevator = true -- I SHOULDVE MADE A STATE SYSTEM BUT FUCK LOGIC
		self:on_exploding_elevator(dt)
		sounds.elev_burning.source:stop()
		sounds.elev_siren.source:stop()
		return
	end

	sounds.elev_burning.source:play()
	sounds.elev_siren.source:play()
	sounds.elev_burning.source:setVolume(abs(self.elevator_speed/speed_cap))
	sounds.elev_siren.source:setVolume(abs(self.elevator_speed/speed_cap))

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
		for _,p in pairs(self.game.actors) do
			p.friction_y = p.friction_x
			if p.is_player then  p.is_flying = true end

			p.gravity_mult = max(0, 1 - abs(self.elevator_speed / speed_cap))
			p.vy = p.vy - 4
		end

		-- fire particles
		local q = max(0, (abs(self.elevator_speed) - 200)*0.01)
		for i=1, q do
			local x,y = random_range(self.cabin_rect.ax, self.cabin_rect.bx),random_range(self.cabin_rect.ay, self.cabin_rect.by)
			local size = max(4, abs(self.elevator_speed)*0.01)
			local velvar = max(5, abs(self.elevator_speed))
			Particles:fire(x,y,size, nil, velvar)
		end

		-- bg color shift to red
		self.background:shift_to_red(speed_cap)
	end
end

function Elevator:on_exploding_elevator(dt)
	self.game:on_exploding_elevator()
	self.background:on_exploding_elevator()

	self.elevator_speed = 0
	self.flash_alpha = 2
	self.game:screenshake(40)
	self.show_rubble = true
	self.show_cabin = false
	
	-- Crash sfx
	Audio:play("elev_crash")

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
		local x,y = random_range(self.cabin_rect.ax, self.cabin_rect.bx), random_range(self.cabin_rect.ay, self.cabin_rect.by)
		Particles:splash(x,y, 5, nil, nil, 10, 4)
	end

	--reset player gravity
	for _,a in pairs(self.game.actors) do
		a.friction_y = 1
		if a.is_player then  a.is_flying = false end

		a.gravity_mult = 1--max(0, 1 - abs(self.elevator_speed / speed_cap))
		if a.name == "button_big_pressed" then
			a:kill()
		end
	end
end



------------------------------------

-- draw font characters to image
if removeme_itext == 0 then
	removeme_itext = 1

	local text = FONT_CHARACTERS
	local oldcanvas = love.graphics.getCanvas()
	local h = get_text_height(text)
	local x = 1
	local totalw = get_text_width(text) + 2 * #text + 1
	local newcanvas = love.graphics.newCanvas(totalw, h)
	love.graphics.setCanvas(newcanvas)
	for i=1, #text do
		line_color(COL_RED, x, 0, x, h)
		
		local c = utf8.sub(text, i,i)
		local w = get_text_width(c)
		love.graphics.print(c, x, 0)
		
		x = x + w + 2
	end
	line_color(COL_RED, x, 0, x, h)
	love.graphics.setCanvas(oldcanvas)

	newcanvas:newImageData():encode("png", concat("testimgaefile",random_range(0,1),".png"))
end

------------------------------------
-- (in Game:draw_game) testing bounce vectors

function Game:removeme_()
	local p = self.players[1]
	if not p then return end
	local mx, my = CANVAS_WIDTH/2, CANVAS_HEIGHT/2

	local vx, vy = CANVAS_WIDTH/2 - p.x, CANVAS_HEIGHT/2 - p.y
	local nx, ny = math.cos(self.t), math.sin(self.t)
	local bx, by = bounce_vector(vx, vy, nx, ny)

	line_color(COL_WHITE, mx, my, mx + nx*30, my + ny*30)
	line_color(COL_RED,   mx - vx, my - vy, mx, my)
	line_color(COL_GREEN, mx, my, mx + bx, my + by)
end


------------------------------------

-- (in Game:draw_game) displays joystick info like angle and stuff

print_outline(ternary(Input:action_down_any_player("left"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, tostring(Input:action_down_any_player("left")), 40, 60)
print_outline(ternary(Input:action_down_any_player("right"), COL_GREEN, COL_WHITE), COL_BLACK_BLUE, tostring(Input:action_down_any_player("right")), 80, 60)
print_outline(ternary(Input:action_down_any_player("up"), COL_GREEN, COL_WHITE),    COL_BLACK_BLUE, tostring(Input:action_down_any_player("up")), 60, 40)
print_outline(ternary(Input:action_down_any_player("down"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, tostring(Input:action_down_any_player("down")), 60, 80)

local x = 60
local y = 140
local r = 30
love.graphics.circle("line", x, y, r)
love.graphics.line(x, y-r, x, y+r)
love.graphics.line(x-r, y, x+r, y)

-- love.graphics.setColor(COL_GREEN)
-- love.graphics.line(x-AXIS_DEADZONE*r, y-r, x-AXIS_DEADZONE*r, y+r)
-- love.graphics.line(x+AXIS_DEADZONE*r, y-r, x+AXIS_DEADZONE*r, y+r)
-- love.graphics.line(x-r, y-AXIS_DEADZONE*r, x+r, y-AXIS_DEADZONE*r)
-- love.graphics.line(x-r, y+AXIS_DEADZONE*r, x+r, y+AXIS_DEADZONE*r)
-- love.graphics.setColor(COL_WHITE)
love.graphics.setColor(COL_GREEN)
love.graphics.circle("line", x, y, r*AXIS_DEADZONE)
for a = pi/8, pi2, pi/4 do
	local ax = math.cos(a)
	local ay = math.sin(a)
	love.graphics.line(x + AXIS_DEADZONE*ax, y + AXIS_DEADZONE*ay, x + r*ax, y + r*ay)
end
love.graphics.setColor(COL_WHITE)

local function get_axis_angle(joystick, axis_x, axis_y) 
	return math.atan2(joystick:getAxis(axis_y), joystick:getAxis(axis_x))
end
local function get_axis_radius_sqr(joystick, axis_x, axis_y) 
	return distsqr(joystick:getAxis(axis_x), joystick:getAxis(axis_y))
end

local u = Input:get_user(1)
if u ~= nil then
	local j = u.joystick
	circle_color(COL_RED, "fill", x + r*j:getAxis(1), y + r*j:getAxis(2), 1)

	print_outline(COL_WHITE, COL_BLACK_BLUE, "a "..tostring(get_axis_angle(j, 1, 2)), x, y + 60)
	print_outline(COL_WHITE, COL_BLACK_BLUE, "r "..tostring(math.sqrt(get_axis_radius_sqr(j, 1, 2))), x, y + 80)
end


------------------------------------


RAW_INPUT_MAP_DEFAULT_SOLO = {
    left =      {"k_left", "k_a",                   "c_leftxneg", "c_rightxneg", "c_dpleft"},
    right =     {"k_right", "k_d",                  "c_leftxpos", "c_rightxpos", "c_dpright"},
    up =        {"k_up", "k_w",                     "c_leftyneg", "c_rightyneg", "c_dpup"},
    down =      {"k_down", "k_s",                   "c_leftypos", "c_rightypos", "c_dpdown"},
    jump =      {"k_c", "k_b",                      "c_a", "c_b"},
    shoot =     {"k_x", "k_v",                      "c_x", "c_y", "c_triggerright"},
    pause =     {"k_escape", "k_p",                 "c_start"},
    
    ui_select = {"k_c", "k_b", "k_return",          "c_a"},
    ui_back =   {"k_x", "k_escape", "k_backspace",  "c_b"},
    ui_left =   {"k_left", "k_a",                   "c_leftxneg", "c_rightxneg", "c_dpleft"},
    ui_right =  {"k_right", "k_d",                  "c_leftxpos", "c_rightxpos", "c_dpright"},
    ui_up =     {"k_up", "k_w",                     "c_leftyneg", "c_rightyneg", "c_dpup"},
    ui_down =   {"k_down", "k_s",                   "c_leftypos", "c_rightypos", "c_dpdown"},
    ui_reset_keys = {"k_tab", "c_triggerleft"},
    debug_1 = {"k_1"},
    debug_2 = {"k_2"},
    debug_3 = {"k_3"},
    debug_4 = {"k_4"},
}


------------------------------------


local function replace_color_shader(col1_org, col1_new, col2_org, col2_new, col3_org, col3_new)
    local r_org1, g_org1, b_org1 = col1_org[1], col1_org[2], col1_org[3]
    local r_new1, g_new1, b_new1 = col1_new[1], col1_new[2], col1_new[3]
    
    local r_org2, g_org2, b_org2 = col2_org[1], col2_org[2], col2_org[3]
    local r_new2, g_new2, b_new2 = col2_new[1], col2_new[2], col2_new[3]
    
    local r_org3, g_org3, b_org3 = col3_org[1], col3_org[2], col3_org[3]
    local r_new3, g_new3, b_new3 = col3_new[1], col3_new[2], col3_new[3]
    local code = string.format([[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            number eps = 0.01;
            vec4 pixel = Texel(texture, texture_coords);
            if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else {
                return pixel;
            }
        }
    ]], 
        r_org1, r_org1, g_org1, g_org1, b_org1, b_org1, r_new1, g_new1, b_new1,
        r_org2, r_org2, g_org2, g_org2, b_org2, b_org2, r_new2, g_new2, b_new2,
        r_org3, r_org3, g_org3, g_org3, b_org3, b_org3, r_new3, g_new3, b_new3
    )
    return love.graphics.newShader(code)
end

shaders.button_icon_to_red    = replace_color_shader(COL_LIGHT_GRAY, COL_LIGHT_RED,     COL_MID_GRAY, COL_DARK_RED,  COL_LIGHTEST_GRAY, COL_PINK)
shaders.button_icon_to_blue   = replace_color_shader(COL_LIGHT_GRAY, COL_MID_BLUE,      COL_MID_GRAY, COL_DARK_BLUE, COL_LIGHTEST_GRAY, COL_LIGHT_BLUE)
shaders.button_icon_to_yellow = replace_color_shader(COL_LIGHT_GRAY, COL_YELLOW_ORANGE, COL_MID_GRAY, COL_ORANGE,    COL_LIGHTEST_GRAY, COL_LIGHT_YELLOW)
shaders.button_icon_to_def = replace_color_shader(COL_LIGHT_GRAY, COL_LIGHT_GRAY, COL_MID_GRAY, COL_MID_GRAY,    COL_LIGHTEST_GRAY, COL_LIGHTEST_GRAY)

------------------------------------


--

	-- Elevator swing  >> in Game:update_main_game
	if love.math.random(0,10) == 0 then
		self.elev_vx = random_neighbor(50)
		self.elev_vy = random_range(0, 50)
	end
	self.elev_vx = self.elev_vx * 0.9
	self.elev_vy = self.elev_vy * 0.9
	self.elev_x = self.elev_x + self.elev_vx*dt
	self.elev_y = self.elev_y + self.elev_vy*dt
	self.elev_x = self.elev_x * 0.9
	self.elev_y = self.elev_y * 0.9


-- Player mine and cursor
function Player:update_cursor(dt)
	local old_cu_x = self.cu_x
	local old_cu_y = self.cu_y

	local tx = floor(self.mid_x / BLOCK_WIDTH) 
	local ty = floor(self.mid_y / BLOCK_WIDTH) 
	local dx, dy = 0, 0

	-- Target up and down 
	local btn_up = self:button_down("up")
	local btn_down = self:button_down("down")
	if btn_up or btn_down then
		dx = 0
		if btn_up then    dy = -1    end
		if btn_down then  dy = 1     end
	else
		-- By default, target sideways
		dx = self.dir_x
	end

	-- Update target position
	self.cu_x = tx + dx
	self.cu_y = ty + dy

	-- Update target tile
	local target_tile = game.map:get_tile(self.cu_x, self.cu_y)
	self.cu_target = nil
	if target_tile and target_tile.is_solid then
		self.cu_target = target_tile
	end
	
	-- If changed cursor pos, reset cursor
	if (old_cu_x ~= self.cu_x) or (old_cu_y ~= self.cu_y) then
		self.mine_timer = 0
	end
end

function Player:mine(dt)
	if not self.cu_target then   return    end
	
	if self:button_down("shoot") then
		self.mine_timer = self.mine_timer + dt

		if self.mine_timer > self.cu_target.mine_time then
			local drop = self.cu_target.drop
			game.map:set_tile(self.cu_x, self.cu_y, 0)
			--game.inventory:add_item(drop)
		end
	else
		self.mine_timer = 0
	end
end

------------------------------------

-- Elevator speed depends on number of enemies
-- In Game:progress_elevator
local enemies_killed = max(self.cur_wave_max_enemy - self.enemy_count, 0)
local ratio_killed = clamp(enemies_killed / self.cur_wave_max_enemy, 0, 1)
local speed = self.max_elev_speed * ratio_killed
self.elevator_speed = speed

-- Terraria-like world generation
for ix=0, map_w-1 do
	-- Big hill general shape
	local by1 = noise(seed, ix / 7)
	by1 = by1 * 4

	-- Small bumps and details
	local by2 = noise(seed, ix / 3)
	by2 = by2 * 1

	local by = map_mid_h + by1 + by2
	by = floor(by)
	print(concat("by ", by))

	for iy = by, map_h-1 do
		map:set_tile(ix, iy, 1)
	end
end


function Player:is_pressing_opposite_to_wall()
	-- Returns whether the player is near a wall AND is pressing a button
	-- corresponding to the opposite direction to that wall
	-- FIXME: there's a lot of repetition, find a way to fix this?
	local null_filter = function()
		return "cross"
	end
	Collision:move(self.wall_collision_box, self.x, self.y, null_filter)
	
	-- Check for left wall
	local nx = self.x - self.wall_jump_margin 
	local x,y, cols, len = Collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == 1 and self:button_down("right") then
			print("WOW", love.math.random(10,100))
			return true, 1
		end
	end

	-- Check for right wall
	local nx = self.x + self.wall_jump_margin 
	local x,y, cols, len = Collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == -1 and self:button_down("left")then
			return true, -1
		end
	end

	return false, nil
end