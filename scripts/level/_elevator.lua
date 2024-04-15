require "scripts.util"
local Class = require "scripts.meta.class"

local images = require "data.images"
local sounds = require "data.sounds"

local ElevatorBackground = Class:inherit()

function ElevatorBackground:init(level)
    self.level = level
end

function ElevatorBackground:update(dt)
	self:progress_elevator(dt)
end

function ElevatorBackground:draw()
	--
end


function ElevatorBackground:progress_elevator(dt)
	-- from me in the past: this is stupid, we should've used game state or something
	-- from me in the future: yeah thanks dickhead
	if self.level.is_exploding_elevator then
		self:do_exploding_elevator(dt)
		return
	end
	if self.level.is_reversing_elevator then
		self:do_reverse_elevator(dt)
		return
	end

	-- Only switch to next floor until all enemies killed
	if not self.door_animation and self.game.enemy_count <= 0 then
		self.game.enemy_count = 0
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
		self.floor_progress = 5.2
		
		self.door_animation = false
		self.draw_enemies_in_bg = false
		self.door_offset = 0
	end
end

function ElevatorBackground:update_door_offset(dt)
	-- 4+: closed doors / 4-3: open doors / 3-2: idle / 2-1: close doors
	if self.floor_progress > 4 then
		self.door_offset = 0

	elseif self.floor_progress > 3 then
		self.door_offset = lerp(self.door_offset, 54, 0.1)
		sounds.elev_door_open.source:play()

	elseif self.floor_progress > 2 then
		self.door_offset = 54

	elseif self.floor_progress > 1 then
		self.door_offset = lerp(self.door_offset, 0, 0.1)
		sounds.elev_door_close.source:play()
		self:activate_enemy_buffer()
	end
end

function ElevatorBackground:update_door_anim(dt)
	self:update_door_offset(dt)

	-- Elevator speed
	if 5 > self.floor_progress and self.floor_progress > 3 then
		-- Slow down
		self.elevator_speed = max(0, self.elevator_speed - 18)
	
	elseif 1 > self.floor_progress then
		-- Speed up	
		self.elevator_speed = min(self.elevator_speed + 10, self.def_elevator_speed)
	end

	-- Switch to next floor if just opened doors
	if self.floor_progress < 4.2 and not self.has_switched_to_next_floor then
		self.has_switched_to_next_floor = true
		self:next_floor()
	end
end

function ElevatorBackground:next_floor(old_floor)
	self.floor = self.floor + 1
	if self.floor-1 == 0 then
		self.game:start_game()
	else
		local pitch = 0.8 + 0.5 * clamp(self.floor / self.max_floor, 0, 3)
		Audio:play("elev_ding", 0.8, pitch)
	end
end


return ElevatorBackground