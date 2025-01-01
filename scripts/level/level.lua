require "scripts.util"
local Class = require "scripts.meta.class"
local Timer = require "scripts.timer"
local Rect = require "scripts.math.rect"
local Enemies = require "data.enemies"
local TileMap = require "scripts.level.tilemap"
local WorldGenerator = require "scripts.level.world_generator"
local BackgroundTest3D = require "scripts.level.background.background_test3d"
local BackgroundBeehive = require "scripts.level.background.background_beehive"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local BackgroundFinal = require "scripts.level.background.background_final"
local BackgroundDots = require "scripts.level.background.background_dots"
local Elevator = require "scripts.level.elevator"
local Wave = require "scripts.level.wave"
local StateMachine = require "scripts.state_machine"
local BackroomGroundFloor = require "scripts.level.backrooms.backroom_ground_floor"

local images = require "data.images"
local sounds = require "data.sounds"
local upgrades = require "data.upgrades"
local waves = require "data.waves"
local enemies = require "data.enemies"
local utf8 = require "utf8"

local Level = Class:inherit()

function Level:init(game, backroom)
    self.game = game
	
	-- Map & world gen
	self.map = TileMap:new(120, 17)
	self.world_generator = WorldGenerator:new(self.map)

	local shaft_w, shaft_h = 26, 14
	local shaft_rect = Rect:new(2, 2, 2+shaft_w-1, 2+shaft_h-1)
	self.world_generator:set_shaft_rect(shaft_rect)
	self.world_generator:reset()
	self.world_generator:generate_cabin()

	-- Cabin stats
	local bw = BLOCK_WIDTH
	local cabin_ax, cabin_ay = shaft_rect.ax,   shaft_rect.ay
	local cabin_bx, cabin_by = shaft_rect.bx+1, shaft_rect.by+1
	local door_ax, door_ay = cabin_ax*BW+154, cabin_ax*BW+122
	local door_bx, door_by = cabin_ay*BW+261, cabin_ay*BW+207
	self.door_rect = Rect:new(door_ax, door_ay, door_bx, door_by)

	self:set_bounds(Rect:new(unpack(RECT_GROUND_FLOOR_PARAMS)))

	self.kill_zone = Rect:new(-400000, -400000, 400000, CANVAS_HEIGHT + BW*6)

	-- Level info
	self.floor = 0 --Floor n°
	self.max_floor = #waves
	self.current_wave = nil
	self.next_wave_to_set = nil
	
	self.new_wave_animation_state_machine = self:get_new_wave_animation_state_machine()
	self.new_wave_progress = 0.0
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
	-- self.background = BackgroundTest3D:new(self)
	self.background = BackgroundDots:new(self)
	-- self.background = BackgroundBeehive:new(self)
	self.background:set_def_speed(self.def_level_speed)
	
	self.backroom = backroom or BackroomGroundFloor:new()
	self.backroom_animation_state_machine = self:get_backroom_animation_state_machine() 
	
	self.force_backroom_end_flag = false
	self.force_next_wave_flag = false
	self.do_not_spawn_enemies_on_next_wave_flag = false
	
	self.canvas = love.graphics.newCanvas(CANVAS_WIDTH*2, CANVAS_HEIGHT)
	self.buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH*2, CANVAS_HEIGHT)
	self.is_hole_stencil_enabled = true
	self.hole_stencil_pause_radius = CANVAS_WIDTH
	self.hole_stencil_max_radius = CANVAS_WIDTH*2
	self.hole_stencil_start_timer = Timer:new(1.0)
	self.hole_stencil_radius = 0
	self.hole_stencil_radius_speed = 0
	self.hole_stencil_radius_accel = 300
	self.hole_stencil_radius_accel_sign = 1

	self.elevator_crashing_sound = sounds.elev_burning.source
	self.elevator_alarm_sound = sounds.elev_siren.source
	self.elevator_crash_sound = sounds.elev_crash.source

	self.ending_timer = Timer:new(15)

	self.has_run_ready = false
end

function Level:ready()
	self:set_backroom_on()
	self.has_run_ready = true
end

function Level:update(dt)
	if not self.has_run_ready then
		self:ready()
	end

	self:update_elevator_progress(dt)
	self.elevator:set_floor_progress(self.new_wave_progress)
	self.background:set_speed(self.level_speed)
	self.background:set_def_speed(self.def_level_speed)

	self.map:update(dt)
	self.background:update(dt)
	self.elevator:update(dt)
	if self.backroom then
		self.backroom:update(dt)
	end

	self.flash_alpha = max(self.flash_alpha - dt, 0)
	self:update_ending(dt)
	
	self.backroom_animation_state_machine:update(dt)
end

function Level:set_bounds(rect)
	self.cabin_rect = rect:clone():scale(BW)
	self.cabin_inner_rect = self.cabin_rect:clone():expand(-BW)
end

function Level:check_for_next_wave(dt)
	local conditions_for_new_wave = (game.game_state == GAME_STATE_PLAYING) and (#self.enemy_buffer == 0) and (game:get_enemy_count() <= 0)
	if conditions_for_new_wave or self.force_next_wave_flag then
		self:begin_next_wave_animation()
		self.force_next_wave_flag = false
	end
end

function Level:begin_next_wave_animation()
	local buffer_enemies = true
	if self.do_not_spawn_enemies_on_next_wave_flag then
		self.do_not_spawn_enemies_on_next_wave_flag = false
		buffer_enemies = false
	end
	if buffer_enemies then
		self:new_wave_buffer_enemies()
	end
	self.new_wave_progress = self.slowdown_timer_override or 1.0
	self.new_wave_animation_state_machine:set_state("slowdown")
end


function Level:get_new_wave_animation_state_machine()
	return StateMachine:new({
		off = {
			enter = function(state)
				self.new_wave_progress = 0.0
			end,
			update = function(state, dt)
				self:check_for_next_wave(dt)
			end,
		},
		slowdown = {	
			update = function(state, dt)
				self.level_speed = max(0, self.level_speed - 18)
		
				if self.new_wave_progress <= 0 then
					return "opening"
				end
			end
		},
		opening = {
			enter = function(state)
				self.elevator:open_door(ternary(self:is_on_cafeteria(), nil, 1.4))
				self.current_wave:show_title()
				self:increment_floor()
				self.new_wave_progress = 1.0
			end,
			update = function(state, dt)
				if self.new_wave_progress <= 0 then
					self.new_wave_progress = 0.4
					self:activate_enemy_buffer()
					return "on"
				end
			end,
		},
		on = {
			update = function(state, dt)
				local condition_normal = (not self:is_on_cafeteria() and self.new_wave_progress <= 0) 
				if condition_normal then
					return "closing"
				end
			end,
		},
		closing = {
			enter = function(state)
				self.new_wave_progress = 1.0
				self.elevator:close_door()
			end,
			update = function(state, dt)
				if self.new_wave_progress <= 0 then
					return "speedup"
				end
			end,
		},
		speedup = {
			enter = function(state)
				self.new_wave_progress = 1.0
			end,
			update = function(state, dt)
				self.level_speed = min(self.level_speed + 10, self.def_level_speed)
		
				if self.new_wave_progress <= 0 then
					return "off"
				end
			end,
		}
	}, "off")
end


function Level:update_elevator_progress(dt)
	self.new_wave_progress = math.max(0, self.new_wave_progress - dt)
	self.new_wave_animation_state_machine:update(dt)
end


function Level:on_door_close()
	if game.game_state == GAME_STATE_WAITING then
		self:activate_enemy_buffer()
	end
end

function Level:set_background(background)
	self.background = background
	self.background:set_level(self)
end

function Level:increment_floor()
	local pitch = 0.8 + 0.5 * clamp(self.floor / self.max_floor, 0, 2)
	Audio:play("elev_ding", 0.8, pitch)

	self.floor = self.floor + 1
end

function Level:new_endless_wave()
	local min = 12
	local max = 25
	return Wave:new({
		min = min,
		max = max,
		music = "w1",
		enemies = {
			{Enemies.Larva, random_range(1,6)},
			{Enemies.Woodlouse, random_range(1,6)},
			{Enemies.Fly, random_range(1,6)},
			{Enemies.Slug, random_range(1,6)},
			{Enemies.Bee, random_range(1, 6)},

			{Enemies.StinkBug, random_range(1,4)},
			{Enemies.Boomshroom, random_range(1,4)},
			{Enemies.SnailShelled, random_range(1,4)},
			{Enemies.HoneypotAnt, random_range(1,4)},
			{Enemies.SpikedFly, random_range(1,4)},
			{Enemies.Grasshopper, random_range(1,4)},
			{Enemies.MushroomAnt, random_range(1,4)},
			{Enemies.Spider, random_range(1,4)},
		},
	})
end

function Level:get_new_wave(wave_n, unclamped_wave_n) --scotch: there shouldn't be unclamped_wave_n
	local wave = waves[wave_n]
	if self.game.endless_mode then
		wave = self:new_endless_wave()
	end
	return wave
end

function Level:get_floor_type()
	if not self.current_wave then
		return FLOOR_TYPE_NORMAL 
	end
	return self.current_wave:get_floor_type()
end

function Level:get_current_wave()
	return self.current_wave
end

function Level:set_current_wave(wave)
	self.current_wave = wave
end

function Level:buffer_actor(actor)
	table.insert(self.enemy_buffer, actor)
end

function Level:new_wave_buffer_enemies()
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		if self.game.waves_until_respawn[i][1] ~= -1 then
			self.game.waves_until_respawn[i][1] = math.max(0, self.game.waves_until_respawn[i][1] - 1)
		end
	end

	-- Spawn a bunch of enemies
	local wave_n = clamp(self.floor + 1, 1, #waves) -- floor+1 because the floor indicator changes before enemies are spawned
	local wave = self:get_new_wave(wave_n, self.floor+1)
	
	self.enemy_buffer = wave:spawn(self.door_rect)
	
	wave:enable_wave_side_effects(self)
	if self.background.change_clear_color then
		self.background:change_clear_color()
	end
	
	self:set_current_wave(wave)
end

function Level:activate_enemy_buffer()
	for k, e in pairs(self.enemy_buffer) do
		e:set_active(true)
	end
	self.enemy_buffer = {}
end

-----------------------------------------------------

function Level:begin_backroom(backroom)
	self.backroom = backroom
	self.backroom:on_enter()

	self.backroom_animation_state_machine:set_state("wait")
	self.hole_stencil_radius = 0
	self.hole_stencil_radius_accel_sign = 1
	
	self.hole_stencil_start_timer:start()
end

function Level:set_backroom_on()
	self.backroom_animation_state_machine:set_state("on")
	self.hole_stencil_radius = CANVAS_WIDTH*2
end

function Level:get_backroom_animation_state_machine(dt)
	return StateMachine:new({
		off = {
			enter = function(state)
				self.is_hole_stencil_enabled = false
				self.new_wave_progress = 0.0
			end,
			update = function(state, dt)
				self.is_hole_stencil_enabled = false
			end
		},
		wait = {
			update = function(state, dt)
				if self.hole_stencil_start_timer:update(dt) then
					return "grow"
				end
			end
		},
		grow = {
			enter = function(state)
				self.is_hole_stencil_enabled = true
			end,
			update = function(state, dt)
				self:update_hole_stencil(dt)
				
				if self.hole_stencil_radius >= CANVAS_WIDTH*0.5 then
					return "on"
				end
			end
		},
		on = {
			enter = function(state)
				if self.backroom then
					self.backroom:generate(self.world_generator)
					self.backroom:on_fully_entered()
				end
				
				self.game.camera:set_x_locked(false)
				self.game.camera:set_y_locked(true)
			end,
			update = function(state, dt)
				self:update_hole_stencil(dt)
				
				if self:can_exit_backroom() then
					self.backroom:on_exit()
					return "shrink"
				end
			end
		},
		shrink = {
			enter = function(state)
				game:remove_all_active_enemies()
				self:end_backroom()
				
				self.new_wave_progress = math.huge
				self.force_next_wave_flag = true
				self.do_not_spawn_enemies_on_next_wave_flag = true
				self:new_wave_buffer_enemies()
			end,
			update = function(state, dt)
				self:update_hole_stencil(dt)
				if self.hole_stencil_radius <= 0 then
					return "off"
				end
			end,
			exit = function(state)
				game.camera:set_position(0, 0)
				game.camera:set_target_offset(0, 0)
			end,
		}
	}, "off")
end


function Level:can_exit_backroom()
	if self.force_backroom_end_flag then
		self.force_backroom_end_flag = false
		return true
	end

	if self.backroom then
		return self.backroom:can_exit()
	end
	return false
end


function Level:update_hole_stencil(dt)
	self.hole_stencil_radius_speed = self.hole_stencil_radius_speed + self.hole_stencil_radius_accel_sign * self.hole_stencil_radius_accel * dt
	
	self.hole_stencil_radius = self.hole_stencil_radius + self.hole_stencil_radius_speed * dt
	self.hole_stencil_radius = clamp(self.hole_stencil_radius, 0, self.hole_stencil_max_radius)
end


function Level:is_on_cafeteria()
	return self:get_floor_type() == FLOOR_TYPE_CAFETERIA
end


function Level:end_backroom()
	self.world_generator:generate_cabin()

	self.hole_stencil_radius = CANVAS_WIDTH
	self.hole_stencil_radius_speed = 0
	self.hole_stencil_radius_accel_sign = -1
	self.new_wave_progress = 1.0
	self.elevator:close_door()
	self.new_wave_animation_state_machine:set_state("closing")

	game.camera:set_x_locked(true)
	game.camera:set_y_locked(true)
	game.camera:set_target_position(0, 0)
end


function Level:on_upgrade_display_killed(display)
	for _, actor in pairs(game.actors) do
		if actor ~= self and actor.name == "upgrade_display" then
			actor:kill()
		end
	end

	local current_disk = game.music_player.current_disk
	local time = 0.0
	if current_disk and current_disk.current_source then
		local current_source = current_disk.current_source
        time = current_source:tell()
	end
	
	game.music_player:set_disk("cafeteria_empty")
	game.camera:set_target_offset(-64, 0)
	if game.music_player.current_disk and game.music_player.current_disk.current_source then
		local source = game.music_player.current_disk.current_source
		source:seek(time)
	end

	if self.backroom and self.backroom.name == "cafeteria" then
		self.backroom:open_door()	
	end
end

-----------------------------------------------------

function Level:draw_with_hole(draw_func, stencil_test)
	stencil_test = stencil_test or "less"

	exec_on_canvas(self.buffer_canvas, function()
		game.camera:pop()
		
		love.graphics.clear()
		draw_func()
		
		game.camera:push()
	end)

	-- Draw stencil shape
	exec_on_canvas({self.canvas, stencil=true}, function()
		game.camera:pop()
		love.graphics.clear()
		
		if self.is_hole_stencil_enabled then
			love.graphics.setStencilState("replace", "always", 1)
			love.graphics.setColorMask(false)
			love.graphics.clear()
			love.graphics.circle("fill", (self.door_rect.ax + self.door_rect.bx)/2, (self.door_rect.ay + self.door_rect.by)/2, self.hole_stencil_radius)

			love.graphics.setStencilState("keep", stencil_test, 1)
			love.graphics.setColorMask(true)
		end
		
		love.graphics.draw(self.buffer_canvas)
		
		love.graphics.setStencilState()
		game.camera:push()
	end)
	love.graphics.draw(self.canvas, 0, 0)
end


function Level:draw()
	-- hack to get the cafeteria backgrounds to work
	local is_on_backroom = (self.backroom_animation_state_machine.current_state_name ~= "off")
	if is_on_backroom then
		if self.backroom and self.backroom.draw then
			self.backroom:draw()
		end
	else
		self.background:draw()
	end
	
	self:draw_with_hole(function()
		if is_on_backroom then
			self.background:draw()
		end
		self.map:draw()
		
		if self.show_cabin then
			self.elevator:draw(self.enemy_buffer, self.new_wave_progress)
		end
	end)
	if self.show_cabin then
		self.elevator:draw_counter()
	end
end


function Level:draw_front(x,y)
	if self.backroom and self.is_hole_stencil_enabled then
		self:draw_with_hole(function()
			self.backroom:draw_front()
		end, "gequal")
	end

	self:draw_with_hole(function()
		self:draw_rubble()
		
		if self.show_cabin then
			self.elevator:draw_front()
		end
	end)
end


function Level:draw_win_screen()
	if game.game_state ~= GAME_STATE_WIN then
		return
	end

	local old_font = love.graphics.getFont()
	love.graphics.setFont(FONT_PAINT)

	local text = Text:text("game.congratulations")
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
			love.graphics.setColor(col)
			love.graphics.print(chr, text_x + ox, 40 + oy)

			text_x = text_x + get_text_width(chr) + 1
		end
	end

	love.graphics.setFont(old_font)
	
	-- Win stats
	local iy = 0
	local ta = {}
	table.insert(ta, Text:text("game.win_thanks"))
	table.insert(ta, Text:text("game.win_wishlist"))
	table.insert(ta, Text:text("game.win_prompt"))

	for k,v in pairs(ta) do
		local t = self.game.t + iy*0.2
		local ox, oy = cos(t*4)*5, sin(t*4)*5
		local mx = CANVAS_WIDTH / 2

		print_centered_outline(COL_WHITE, COL_BLACK_BLUE, v, mx+ox, 80+iy*14 +oy)
		iy = iy + 1
	end
end


function Level:draw_ui()
	self:draw_win_screen()

	if self.flash_alpha > 0 then
		rect_color({1,1,1,self.flash_alpha}, "fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	end
end


function Level:draw_rubble()
	if self.show_rubble then
		love.graphics.draw(images.cabin_rubble, 0*BW, 11*BW)
	end
end

---------------------------------------------

function Level:on_red_button_pressed()
	self.is_reversing_elevator = true
	self.ending_timer:set_duration(10)
	self.ending_timer:start()
	self.elevator_crashing_sound:play()
	self.elevator_alarm_sound:play()
end


function Level:update_ending(dt)
	if game.game_state == GAME_STATE_ELEVATOR_BURNING then
		self.level_speed = math.max(self.level_speed - 5, -self.def_level_speed*2)
		if self.background.change_clear_color then
			self.background:change_clear_color({COL_ORANGE, {COL_LIGHT_RED, COL_DARK_RED, COL_LIGHT_YELLOW}})
		end
		
		if self.level_speed < 0 then
			game:screenshake(math.abs(self.level_speed)/200)
			local r = self.level_speed / self.def_level_speed
			self.elevator_crashing_sound:setVolume(r)
			self.elevator_alarm_sound:setVolume(r)
		end

		if self.ending_timer:update(dt) then
			game:on_elevator_crashed()
		end
		
	elseif game.game_state == GAME_STATE_WIN then
		self.level_speed = 0
		self:update_win_screen()
	end
end


function Level:on_elevator_crashed()
	if self.background.set_clear_color then
		self.background:set_clear_color({COL_BLACK_BLUE, {COL_VERY_DARK_GRAY, COL_DARK_GRAY}})
	end
	if self.background.init_bg_particles then
		self.background:init_bg_particles()
	end
	self.elevator_crashing_sound:stop()
	self.elevator_alarm_sound:stop()
	self.elevator_crash_sound:play()

	self.game:screenshake(30)
	self.world_generator:generate_end_rubble()
	self.level_speed = 0
	self:set_bounds(Rect:new(-1, -3, 31, 18))
	self.flash_alpha = 1.5

	game:kill_all_active_enemies()
	-- self.game.game_ui:flash()

	self.show_rubble = true
	self.show_cabin = false
	self.is_reversing_elevator = false
end


function Level:update_win_screen(dt)
	for i = 2, #self.world_generator.end_rubble_slices do
		local slice = self.world_generator.end_rubble_slices[i]
		local slice_up = self.world_generator.end_rubble_slices[i+1]
		for ix = slice.ax, slice.bx do
			if (random_range(0, 1) <= 0.1) and ((not slice_up) or (slice_up and not slice_up:is_point_in_inclusive(ix, slice.ay-1))) then
				Particles:fire(ix*BW + random_range(0, BW), slice.ay*BW, 5, nil, nil, -60)
			end
		end
	end 
end

-- function Level:do_exploding_elevator(dt)
-- 	local x,y = random_range(self.cabin_ax, self.cabin_bx), 16*BW
-- 	local mw = CANVAS_WIDTH/2
-- 	y = 16*BW-8 - max(0, lerp(BW*4-8, -16, abs(mw-x)/mw))
-- 	local size = random_range(4, 8)
-- 	Particles:fire(x,y,size, nil, 80, -5)
-- end

function Level:get_floor()
	return self.floor
end


function Level:set_floor(val)
	self.floor = val
end


return Level