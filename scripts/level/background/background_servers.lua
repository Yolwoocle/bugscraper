require "scripts.util"
local Background = require "scripts.level.background.background"

local BackgroundServers = Background:inherit()

function BackgroundServers:init(level)
	self:init_background(level)

	self.clear_color = COL_DARK_GREEN
	self.edge_color = COL_LIGHT_GREEN
	self.t = 0

	self.speed = 0

	self.fov = 1.0
	self.row_min_y = -CANVAS_HEIGHT*5
	self.edge_max_y =  CANVAS_HEIGHT*5
	self.max_z = 10
	self.row_height = 60
	self.column_width = 1
	self.server_rows = {}
	self:init_edges()
end

local function new_vec3(x, y, z)
	return {
		x = x,
		y = y,
		z = z,
	}
end
local function new_edge(point_a, point_b, color)
	return {
		type = "edge",
		a = point_a,
		b = point_b,
		color = COL_MID_DARK_GREEN,-- or COL_WHITE,
		draw = function(self, fov, ox, oy)
			local a = self.a
			local b = self.b
			love.graphics.line(
				math.floor(CANVAS_WIDTH/2  + fov * (ox + a.x)/a.z),
				math.floor(CANVAS_HEIGHT/2 + fov * (oy + a.y)/a.z),
				math.floor(CANVAS_WIDTH/2  + fov * (ox + b.x)/b.z),
				math.floor(CANVAS_HEIGHT/2 + fov * (oy + b.y)/b.z)
			)
		end
	}
end
local function new_point(pos, radius, color)
	return {
		type = "point",
		pos = pos,
		radius = radius,
		color = random_sample{COL_GREEN, COL_MID_GREEN, COL_MID_DARK_GREEN},
		text = random_sample{"0", "1"},
		draw = function(self, fov, ox, oy)
			-- love.graphics.circle(
			-- 	"fill",
			-- 	math.floor(CANVAS_WIDTH/2  + fov * (ox + self.pos.x)/self.pos.z),
			-- 	math.floor(CANVAS_HEIGHT/2 + fov * (oy + self.pos.y)/self.pos.z),
			-- 	self.radius / self.pos.z
			-- )
			love.graphics.print(
				self.text,
				math.floor(CANVAS_WIDTH/2  + fov * (ox + self.pos.x)/self.pos.z),
				(CANVAS_HEIGHT/2 + fov * (oy + self.pos.y)/self.pos.z),
				0, 
				0.7 * self.radius / self.pos.z,
				0.7 * self.radius / self.pos.z
			)
		end
	}
end

function BackgroundServers:init_edges()
	self.server_rows = {}

	local padding = CANVAS_WIDTH/2

	local i = 1
	for iy = self.row_min_y, self.edge_max_y, self.row_height do
		local row = {
			y = iy,
			edges = {},
		}
			
		local x_left =  math.floor( padding)
		local x_right = math.floor(-padding)
		local y = math.floor(iy)
		table.insert(row.edges, new_edge( -- left horizontal edge
			new_vec3(x_left, 0, 1),
			new_vec3(x_left, 0, self.max_z),
			self.edge_color
		))
		table.insert(row.edges, new_edge( -- right horizontal edge
			new_vec3(x_right, 0, 1),
			new_vec3(x_right, 0, self.max_z),
			self.edge_color
		))

		for iz = 1, self.max_z, self.column_width do
			table.insert(row.edges, new_edge( -- left vertical edge
				new_vec3(x_left, 0, iz),
				new_vec3(x_left, self.row_height, iz),
				self.edge_color
			))
			table.insert(row.edges, new_edge( -- right vertical edge
				new_vec3(x_right, 0, iz),
				new_vec3(x_right, self.row_height, iz),
				self.edge_color
			))
		end
		for j = 1, 10 do
			table.insert(row.edges, new_point(
				new_vec3(random_range(x_left, x_right), random_range(0, self.row_height), random_range(1, self.max_z)),
				5, COL_WHITE
			))
		end
		table.insert(self.server_rows, row)
		i = i + 1
	end
end

-----------------------------------------------------

function BackgroundServers:update(dt)
	self:update_background(dt)

	local speed = self.speed * dt * 0.5

	self.row_min_y = self.row_min_y + speed
	for _, row in pairs(self.server_rows) do
		row.y = row.y + speed

		local screen_y = CANVAS_HEIGHT/2 + self.fov * row.y/self.max_z
		if screen_y > CANVAS_HEIGHT then
			local new_y = self.row_min_y - self.row_height
			row.y = new_y
			self.row_min_y = new_y
		end
	end
end

-----------------------------------------------------

function BackgroundServers:draw()
	self:draw_background()

	local ox, oy = CANVAS_WIDTH/2, CANVAS_HEIGHT/2

	for i, row in pairs(self.server_rows) do
		local row_y = row.y
		for j, edge in pairs(row.edges) do
			love.graphics.setColor(edge.color)
			edge:draw(self.fov, 0, row_y)
			love.graphics.setColor(1,1,1,1)
		end
	end

	-- print_outline(nil, nil, tostring(self.row_min_y), CANVAS_HEIGHT/2, 0)
end

return BackgroundServers