require "scripts.util"
local Class = require "scripts.meta.class"
local Enemies = require "data.enemies"
local TileMap = require "scripts.level.tilemap"
local WorldGenerator = require "scripts.level.worldgenerator"
local Background = require "scripts.level.background.background_servers"
local Elevator = require "scripts.level.elevator"

local images = require "data.images"
local sounds = require "data.sounds"
local waves = require "data.waves"
local utf8 = require "utf8"

local Level = Class:inherit()

function Level:init(game)
    self.game = game

	-- Map & world gen
	self.map = TileMap:new(30, 17)
	self.shaft_w, self.shaft_h = 26, 14
	self.world_generator = WorldGenerator:new(self.map)
	self.world_generator:generate(10203)
	self.world_generator:make_box(self.shaft_w, self.shaft_h)
	
	-- Bounding box
	-- Don't try to understand, all you have to know is that it puts collision 
	-- boxes around the elevator shaft
	local map_w = self.map.width * BW
	local map_h = self.map.height * BW
	local box_ax = self.world_generator.box_ax
	local box_ay = self.world_generator.box_ay
	local box_bx = self.world_generator.box_bx
	local box_by = self.world_generator.box_by
	self.boxes = {
		{name="box_up",     is_solid = false, x = -BW, y = -BW,  w=map_w + 2*BW,     h=BW + box_ay*BW},
		{name="box_down", is_solid = false, x = -BW, y = (box_by+1)*BW,  w=map_w + 2*BW,     h=BW*box_ay},
		{name="box_left", is_solid = false, x = -BW,  y = -BW,   w=BW + box_ax * BW, h=map_h + 2*BW},
		{name="box_right", is_solid = false, x = BW*(box_bx+1), y = -BW, w=BW*box_ax, h=map_h + 2*BW},
	}
	for i,box in pairs(self.boxes) do   Collision:add(box)   end

	-- Cabin stats
	local bw = BLOCK_WIDTH
	self.cabin_x, self.cabin_y = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_ax, self.cabin_ay = self.world_generator.box_ax*bw, self.world_generator.box_ay*bw
	self.cabin_bx, self.cabin_by = self.world_generator.box_bx*bw, self.world_generator.box_by*bw
	self.door_ax, self.door_ay = self.cabin_x+154, self.cabin_x+122
	self.door_bx, self.door_by = self.cabin_y+261, self.cabin_y+207

	-- Level info
	self.floor = 0 --Floor n°
	self.max_floor = #waves
	
	self.door_animation = false
	self.door_offset = 0
	self.has_switched_to_next_floor = false

	self.floor_progress = 0.0
	self.level_speed = 0
	self.def_level_speed = 400
	self.elev_x, self.elev_y = 0, 0
	self.elev_vx, self.elev_vy = 0, 0
    
	self.flash_alpha = 0
	self.show_cabin = true
	self.show_rubble = false

	self.is_on_win_screen = false

    self.enemy_buffer = {}

	self.elevator = Elevator:new(self)
	self.background = Background:new(self)
	self.background:set_def_speed(self.def_level_speed)
end

function Level:update(dt)
	self:update_elevator_progress(dt)
	self.elevator:set_floor_progress(self.floor_progress)
	self.background:set_speed(self.level_speed)

	self.map:update(dt)
	self.background:update(dt)
	self.elevator:update(dt)
	
	self.flash_alpha = max(self.flash_alpha - dt, 0)
end

function Level:update_elevator_progress(dt)
	-- Only switch to next floor until all enemies killed
	if not self.door_animation and game.enemy_count <= 0 then
		game.enemy_count = 0
		
		self.door_animation = true
		self.has_switched_to_next_floor = false
		self:new_wave_buffer_enemies(dt)
	end

	-- Update door animation
	if self.door_animation then
		self.floor_progress = self.floor_progress - dt

		-- Manage elevator speed
		if 5 > self.floor_progress and self.floor_progress > 3 then
			-- Slow down
			self.level_speed = max(0, self.level_speed - 18)
		
		elseif 1 > self.floor_progress then
			-- Speed up	
			self.level_speed = min(self.level_speed + 10, self.def_level_speed)
		end

		-- Go to next floor once animation is finished
		if self.floor_progress <= 0 then
			self.floor_progress = 5.0
			
			self.door_animation = false
			self.draw_enemies_in_bg = false
			self.elevator.door:close()
		end

		-- Switch to next floor if just opened doors
		if self.floor_progress < 4.2 and not self.has_switched_to_next_floor then
			self.has_switched_to_next_floor = true
			self:next_floor()
		end

	end
end

function Level:next_floor(old_floor)
	self.floor = self.floor + 1
	if self.floor-1 == 0 then
		self.game:start_game()
	else
		local pitch = 0.8 + 0.5 * clamp(self.floor / self.max_floor, 0, 3)
		Audio:play("elev_ding", 0.8, pitch)
	end
end

function Level:new_endless_wave()
	local min = 8
	local max = 16
	return {
		min = min,
		max = max,
		enemies = {
			{Enemies.Larva, random_range(1,6)},
			{Enemies.Fly, random_range(1,6)},
			{Enemies.Slug, random_range(1,6)},
			{Enemies.Mosquito, random_range(1, 6)},

			{Enemies.SnailShelled, random_range(1,4)},
			{Enemies.HoneypotAnt, random_range(1,4)},
			{Enemies.SpikedFly, random_range(1,4)},
			{Enemies.Grasshopper, random_range(1,4)},
			{Enemies.MushroomAnt, random_range(1,4)},
			{Enemies.Spider, random_range(1,4)},
		},
	}
end

function Level:construct_new_wave(wave_n)
	local wave = waves[wave_n]
	if self.game.endless_mode then
		-- Wave on endless mode
		wave = self:new_endless_wave()
	end
	local n = love.math.random(wave.min, wave.max)

	local output = {}
	for i=1, n do
		local enemy_class = random_weighted(wave.enemies)
		table.insert(output, {
			enemy_class = enemy_class
		})
	end

	for i = 1, MAX_NUMBER_OF_PLAYERS do
		if self.game.waves_until_respawn[i] ~= -1 then
			self.game.waves_until_respawn[i] = math.max(0, self.game.waves_until_respawn[i] - 1)
		end
	end

	if game:get_number_of_alive_players() < Input:get_number_of_users() then
		for i = 1, MAX_NUMBER_OF_PLAYERS do
			if self.game.waves_until_respawn[i] ~= -1 and self.game.waves_until_respawn[i] == 0 then
				table.insert(output, {
					enemy_class = Enemies.Cocoon,
					extra_info = i,
				})
			end
		end
	end

	return output
end

function Level:new_wave_buffer_enemies()
	-- Spawn a bunch of enemies
	local bw = BLOCK_WIDTH
	local wg = self.game.world_generator
	
	self.enemy_buffer = {}

	local wave_n = clamp(self.floor + 1, 1, #waves) -- floor+1 because the floor indicator changes before enemies are spawned
	local wave = self:construct_new_wave(wave_n)

	if self.background.change_bg_color then
		self.background:change_bg_color(wave_n)
	end

	for i=1, #wave do
		local x = love.math.random(self.door_ax + 16, self.door_bx - 16)
		local y = love.math.random(self.door_ay + 16, self.door_by - 16)

		local enemy_class = wave[i].enemy_class
		local extra_info = wave[i].extra_info
		
		local args = {} 
		if enemy_class == Enemies.ButtonBigGlass then
			x = floor(CANVAS_WIDTH/2 - 58/2)
			y = self.door_by - 45
		end
		if enemy_class == Enemies.Cocoon then
			args = {extra_info}
		end
		local enemy_instance = enemy_class:new(x,y, unpack(args))

		-- If button is summoned, last wave happened
		if enemy_instance.name == "button_big_glass" then
			self.game:on_button_glass_spawn(enemy_instance)
		else
			-- Center enemy
			enemy_instance.x = floor(enemy_instance.x - enemy_instance.w/2)
			enemy_instance.y = floor(enemy_instance.y - enemy_instance.h/2)
		end
		
		-- Prevent collisions with floor
		if enemy_instance.y+enemy_instance.h > self.door_by then
			enemy_instance.y = self.door_by - enemy_instance.h
		end
		Collision:remove(enemy_instance)
		table.insert(self.enemy_buffer, enemy_instance)
	end
end


function Level:activate_enemy_buffer()
	for k, e in pairs(self.enemy_buffer) do
		e:add_collision()
		self.game:new_actor(e)
	end
	self.enemy_buffer = {}
end

-----------------------------------------------------

function Level:draw()
	self.background:draw()

	self.map:draw()
	if self.show_cabin then
		self.elevator:draw(self.enemy_buffer)
	end
end

function Level:draw_win_screen()
	if not self.is_on_win_screen then
		return
	end

	local old_font = gfx.getFont()
	gfx.setFont(FONT_PAINT)

	local text = "CONGRATULATIONS! "
	local w = get_text_width(text, FONT_PAINT)
	local text_x1 = floor((CANVAS_WIDTH - w)/2)

	for i=1, #LOGO_COLS + 1 do
		local text_x = text_x1
		for i_chr=1, #text do
			local chr = utf8.sub(text, i_chr, i_chr)
			local t = self.game.t + i_chr*0.04
			local ox, oy = cos(t*4 + i*.2)*8, sin(t*4 + i*.2)*8
			
			local col = LOGO_COLS[i]
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
	-- for k,v in pairs(self.game.stats) do
	-- 	local val = v
	-- 	local key = k
	-- 	if k == "time" then val = time_to_string(v) end
	-- 	if k == "floor" then val = concat(v, " / ", self.game.elevator.max_floor) end
	-- 	if k == "max_combo" then key = "max combo" end
	-- 	table.insert(ta, concat(k,": ",val))
	-- end
	table.insert(ta, "Pause to exit")

	for k,v in pairs(ta) do
		local t = self.game.t + iy*0.2
		local ox, oy = cos(t*4)*5, sin(t*4)*5
		local mx = CANVAS_WIDTH / 2

		print_centered_outline(COL_WHITE, COL_BLACK_BLUE, v, mx+ox, 80+iy*14 +oy)
		iy = iy + 1
	end
end

function Level:draw_front(x,y)
	self:draw_rubble()
	
	if self.show_cabin then
		gfx.draw(images.cabin_walls, self.cabin_x, self.cabin_y)
	end
end

function Level:draw_ui()
	self:draw_win_screen()

	if self.flash_alpha then
		rect_color({1,1,1,self.flash_alpha}, "fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	end
end

function Level:draw_rubble()
	if not self.show_rubble then
		return
	end

	gfx.draw(images.cabin_rubble, self.cabin_x, (16-5)*BW)
end

function Level:on_red_button_pressed()
	self.is_reversing_elevator = true
end

function Level:do_exploding_elevator(dt)
	local x,y = random_range(self.cabin_ax, self.cabin_bx), 16*BW
	local mw = CANVAS_WIDTH/2
	y = 16*BW-8 - max(0, lerp(BW*4-8, -16, abs(mw-x)/mw))
	local size = random_range(4, 8)
	Particles:fire(x,y,size, nil, 80, -5)
end

function Level:get_floor()
	return self.floor
end
function Level:set_floor(val)
	self.floor = val
end

return Level