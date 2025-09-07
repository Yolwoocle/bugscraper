require "scripts.util"
local Class = require "scripts.meta.class"
local Vec2 = require "lib.batteries.vec2"
local Vec3 = require "lib.batteries.vec3"

local Renderer3D = Class:inherit()

function Renderer3D:init(objects, params)
	params = params or {}

	self.objects = objects or {}

	self.orthographic = param(params.orthographic, true)
	self.wireframe = param(params.wireframe, false)
	self.fov = param(params.fov, 60)

	if self.orthographic then
		self.render_offset = Vec2(0, 0)
	else
		self.render_offset = Vec2(unpack(param(params.render_offset, {CANVAS_WIDTH/2, CANVAS_HEIGHT/2})))
	end
	self.lighting_palette = {color(0xf77622), color(0xfeae34), color(0xfee761), color(0xfee761), COL_WHITE}
    self.line_color = COL_BLACK
end

function Renderer3D:update(dt)
	for _, object in pairs(self.objects) do
		object:apply_transform()
	end
end

function Renderer3D:project_vertex(vertex)
	if self.orthographic then
		return self.render_offset + Vec2(vertex.x, vertex.y)
	else
		return self.render_offset + self.fov * Vec2(vertex.x, vertex.y):scalar_div(vertex.z)
	end
end

function Renderer3D:get_shading_color(normal)
	local camera_vec = Vec3(0, 0, 1)
	local dot = math.abs(normal:dot(camera_vec))
	local palette = self.lighting_palette 
	local col = palette[clamp(round(dot * #palette), 1, #palette)]
	return col
end

function Renderer3D:draw()
	for _, object in pairs(self.objects) do
		self:draw_object(object)
	end
end

function Renderer3D:draw_object(object)
	local camera_vec = Vec3(0, 0, 1)
	local projected_vertices = {}
	local drawn_faces = {}
	for i_face = 1, #object.model.faces do
		local face = object.model.faces[i_face]
		local normal = object:get_face_normal(i_face)
		local dot = normal:dot(camera_vec)
		if dot < 0 then
			for i_point = 1, #face do
				local i_vertex = face[i_point]
				if not projected_vertices[i_vertex] then
					local vertex = object.transformed_vertices[i_vertex]
					local projected_vertex = self:project_vertex(vertex)
					projected_vertices[i_vertex] = projected_vertex
				end
			end
			
			if not self.wireframe then
				local projected_face = {}
				for i_point = 1, #face do
					table.insert(projected_face, projected_vertices[face[i_point]].x)
					table.insert(projected_face, projected_vertices[face[i_point]].y)
				end
				exec_color(self:get_shading_color(normal), function()
					love.graphics.polygon("fill", projected_face)
				end)
			end
			table.insert(drawn_faces, i_face) -- TODO FIXME: there is a lot of repetition 
		end
	end
	
	for i_edge = 1, #object.model.edges do
		local edge = object.model.edges[i_edge]
		for i=1, #edge do
			local i_vertex = edge[i]
			if not projected_vertices[i_vertex] then
				local vertex = object.transformed_vertices[i_vertex]
				local projected_vertex = self:project_vertex(vertex)
				projected_vertices[i_vertex] = projected_vertex
			end
		end
	end

	exec_color(self.line_color, function()
		for _, face_i in pairs(drawn_faces) do
			local face = object.model.faces[face_i]
			for i=1, #face do
				local a = projected_vertices[face[i]]
				local b = projected_vertices[face[mod_plus_1(i+1, #face)]]
				love.graphics.line(a.x, a.y, b.x, b.y)
			end
		end

		for _, edge in pairs(object.model.edges) do
			local a = projected_vertices[edge[1]]
			local b = projected_vertices[edge[2]]
			love.graphics.line(a.x, a.y, b.x, b.y)
		end
	end)
end

return Renderer3D