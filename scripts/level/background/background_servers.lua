require "scripts.util"
local Background = require "scripts.level.background.background"
local vec3 = require "lib.batteries.vec3"

local BackgroundServers = Background:inherit()

-- This background doesn't use BackgroundLayer3D because it was made even before Renderer3D.
-- I don't feel like porting everything to the new system so this shall do. 

function BackgroundServers:init(level)
	self.super.init(self, level)
	self.name = "background_servers"

	-- self.clear_color = COL_DARK_GREEN
	self.clear_color = COL_BLACK_BLUE
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
	return vec3(x, y, z) 
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
	local all_edges = {}

	local function insert_new_edge(row, edge)
		edge.row = row
		table.insert(all_edges, edge)
		table.insert(row.edges, edge)
	end

	local i = 1
	for iy = self.row_min_y, self.edge_max_y, self.row_height do
		local row = {
			y = iy,
			edges = {},
		}
			
		local x_left =  math.floor( padding)
		local x_right = math.floor(-padding)
		local y = math.floor(iy)
		insert_new_edge(row, new_edge( -- left horizontal edge
			new_vec3(x_left, 0, 1),
			new_vec3(x_left, 0, self.max_z),
			self.edge_color
		))
		insert_new_edge(row, new_edge( -- right horizontal edge
			new_vec3(x_right, 0, 1),
			new_vec3(x_right, 0, self.max_z),
			self.edge_color
		))

		local iz0 = 0.9
		for iz = iz0, self.max_z, self.column_width do
			insert_new_edge(row, new_edge( -- left vertical edge
				new_vec3(x_left, 0, iz),
				new_vec3(x_left, self.row_height, iz),
				self.edge_color
			))
			insert_new_edge(row, new_edge( -- right vertical edge
				new_vec3(x_right, 0, iz),
				new_vec3(x_right, self.row_height, iz),
				self.edge_color
			))
		end

		local nb_cables = random_range_int(0, 1)
		for j = 1, nb_cables do -- cables
			local iz1 = iz0 + random_range_int(0, self.max_z/self.column_width) * self.column_width
			local iz2 = iz0 + random_range_int(0, self.max_z/self.column_width) * self.column_width

			local pos1 = new_vec3(x_left,  random_range(0, self.row_height), iz1)
			local pos2 = new_vec3(x_right, random_range(0, self.row_height), iz2)

			local nb_segments = 10
			local step_vec = pos2:vsub(pos1):sdiv(nb_segments)
			local cur_pos = pos1:copy()
			local drip = random_range(40, 100)
			for i=1, nb_segments do
				local ipos1 = cur_pos:copy()
				local ipos2 = cur_pos:vadd(step_vec)
				local oy1 = square_parabola((i-1) / nb_segments) * drip
				local oy2 = square_parabola(i / nb_segments) * drip
				ipos1:saddi(0, oy1, 0)
				ipos2:saddi(0, oy2, 0)
				insert_new_edge(row, new_edge( -- left vertical edge
					ipos1, ipos2,
					self.edge_color
				))
				cur_pos:vaddi(step_vec)
			end
		end

		for j = 1, 10 do -- flying bits
			insert_new_edge(row, new_point(
				new_vec3(random_range(x_left, x_right), random_range(0, self.row_height), random_range(1, self.max_z)),
				5, COL_WHITE
			))
		end

		table.insert(self.server_rows, row)
		i = i + 1
	end

	table.sort(all_edges, function(a, b) 
		local az, bz
		if a.type == "edge" then
			az = math.huge
		else
			az = a.pos.z
		end
		if b.type == "edge" then
			bz = math.huge
		else
			bz = b.pos.z
		end
		return az > bz
	end)

	self.all_edges = all_edges
end

-----------------------------------------------------

function BackgroundServers:update(dt)
	self.super.update(self, dt)

	local speed = self:get_speed() * dt * 0.5

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
	BackgroundServers.super.draw(self)

	for i, edge in ipairs(self.all_edges) do
		local row_y = edge.row.y

		love.graphics.setColor(edge.color)
		edge:draw(self.fov, 0, row_y)
		love.graphics.setColor(1,1,1,1)
	end

	-- print_outline(nil, nil, tostring(self.row_min_y), CANVAS_HEIGHT/2, 0)
end

return BackgroundServers