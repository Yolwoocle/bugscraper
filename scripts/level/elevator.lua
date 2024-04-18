require "scripts.util"
local Class = require "scripts.meta.class"
local ElevatorDoor = require "scripts.level.elevator_door"

local images = require "data.images"
local sounds = require "data.sounds"

local Elevator = Class:inherit()

function Elevator:init(level)
    self.level = level

	self.door = ElevatorDoor:new(self.level.cabin_x + 154, self.level.cabin_y + 122)
	self.door:close()

	self.floor_progress = 0.0
	self.door_animation = false
	self.has_switched_to_next_floor = false 
	self.draw_enemies_in_bg = false

	self.clock_ang = pi
end

function Elevator:update(dt)
	self:update_door_animation(dt)
end

function Elevator:update_door_animation(dt)
	self.door:update(dt)
	if self.floor_progress == 0 then return end

	--  4+: closed doors / 4-3: open doors / 3-2: idle / 2-1: close doors
	-- 0-1: closed doors / 1-2: open doors / 2-3: idle / 3+: close doors
	if 0 < self.floor_progress and self.floor_progress <= 1 then
		self.door:close()
	
	elseif self.floor_progress <= 2 then
		self.door:open()
		sounds.elev_door_open.source:play()
	
	elseif self.floor_progress <= 3 then
		-- Opened door
	
	elseif self.floor_progress <= 4 then
		if self.level:get_floor_type() == FLOOR_TYPE_NORMAL then
			self.door:close()
			sounds.elev_door_close.source:play()
		end
		self.level:activate_enemy_buffer()
	end
end

function Elevator:set_floor_progress(val)
	self.floor_progress = val
end

---------------------------------------------

function Elevator:draw(enemy_buffer)
	local x, y = self.level.door_ax, self.level.door_ay
	local w, h = self.level.door_bx - self.level.door_ax+1, self.level.door_by - self.level.door_ay+1
	rect_color(self.level.background.clear_color, "fill", x, y, w, h);

	-- Draw buffered enemies
	for i,e in pairs(enemy_buffer) do
		e:draw()
	end

	self:draw_cabin()
end


function Elevator:draw_cabin()
	local cabin_x, cabin_y = self.level.cabin_x, self.level.cabin_y 

	self.door:draw()

	-- Cabin background
	gfx.draw(images.cabin_bg, cabin_x, cabin_y)
	gfx.draw(images.cabin_bg_ambient_occlusion, cabin_x, cabin_y)
	
	self:draw_counter()
end

function Elevator:draw_counter()
	local cabin_x, cabin_y = self.level.cabin_x, self.level.cabin_y 

	-- Level counter clock thing
	local x1, y1 = cabin_x + 207.5, cabin_y + 89
	self.clock_ang = lerp(self.clock_ang, pi + clamp(self.level.floor / self.level.max_floor, 0, 1) * pi, 0.1)
	local a = self.clock_ang
	gfx.line(x1, y1, x1 + cos(a)*11, y1 + sin(a)*11)
	
	-- Level counter
	gfx.setFont(FONT_7SEG)
	print_color(COL_WHITE, string.sub("00000"..tostring(self.level.floor), -3, -1), 198+16*2, 97+16*2)
	gfx.setFont(FONT_REGULAR)
end


return Elevator