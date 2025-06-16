require "scripts.util"
local images = require "data.images"

local ElevatorDoor = require "scripts.level.door.elevator_door"
local sounds = require "data.sounds"

local ElevatorDoorTrapdoor = ElevatorDoor:inherit()

function ElevatorDoorTrapdoor:init(x, y, w, h, image, params)
	params = params or {}
	ElevatorDoorTrapdoor.super.init(self, x, y, w or 43, h or 37)

	self.mesh_vertices = {
		{0, 0,   0, 0,   1, 1, 1, 1},
		{w, 0,   1, 0,   1, 1, 1, 1},
		{w, h,   1, 1,   1, 1, 1, 1},
		{0, h,   0, 1,   1, 1, 1, 1},
	}

	self.mesh = love.graphics.newMesh(self.mesh_vertices, "fan", "dynamic")
	self:set_image(image)

	self.direction = params.direction or "up"

	self.t = 0
end

function ElevatorDoorTrapdoor:set_image(image)
	self.image = image
	self.mesh:setTexture(image)
end

function ElevatorDoorTrapdoor:update(dt)
	ElevatorDoorTrapdoor.super.update(self, dt)

	self.t = self.t + dt
	self:update_mesh(dt)
end

function ElevatorDoorTrapdoor:update_mesh(dt)
	local w, h = self.w, self.h
	local a = (1 - self.offset) * (pi/2 + pi/4) - pi/4
	local mesh_vertices
	if self.direction == "up" then
		mesh_vertices = {
			{0, 0,   0, 0,   1, 1, 1, 1},
			{w, 0,   1, 0,   1, 1, 1, 1},
			{w+math.cos(a)*5, h*math.sin(a),   1, 1,   1, 1, 1, 1},
			{0-math.cos(a)*5, h*math.sin(a),   0, 1,   1, 1, 1, 1},
		}

	elseif self.direction == "down" then
		mesh_vertices = {
			{0-math.cos(a)*5, h*(1 - math.sin(a)),   1, 0,   1, 1, 1, 1},
			{w+math.cos(a)*5, h*(1 - math.sin(a)),   0, 0,   1, 1, 1, 1},			
			{w, h,   0, 1,   1, 1, 1, 1},
			{0, h,   1, 1,   1, 1, 1, 1},
		}

	end


	for i = 1, #mesh_vertices do
		self.mesh:setVertex(i, mesh_vertices[i])
	end
end

function ElevatorDoorTrapdoor:draw()
end

function ElevatorDoorTrapdoor:draw_front()
    love.graphics.draw(self.mesh, self.x, self.y)
end

return ElevatorDoorTrapdoor