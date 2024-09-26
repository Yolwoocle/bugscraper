require "scripts.util"
local Class = require "scripts.meta.class"
local Vec2 = require "lib.batteries.vec2"
local Vec3 = require "lib.batteries.vec3"

local Renderer3D = Class:inherit()

function Renderer3D:init(object)
	self.object = object or {}

	self.lighting_palette = {color(0xf77622), color(0xfeae34), color(0xfee761), color(0xfee761), COL_WHITE}
    self.line_color = COL_BLACK
end

function Renderer3D:update(dt)
	self.object:apply_transform()
end

function Renderer3D:project_vertex(vertex)
	return Vec2(vertex.x, vertex.y)
end

function Renderer3D:get_shading_color(normal)
	local camera_vec = Vec3(0, 0, 1)
	local dot = math.abs(normal:dot(camera_vec))
	local palette = self.lighting_palette 
	local col = palette[clamp(round(dot * #palette), 1, #palette)]
	return col
end

function Renderer3D:draw()
	local camera_vec = Vec3(0, 0, 1)
	local projected_faces = {}
	for i_face = 1, #self.object.model.faces do
		local face = self.object.model.faces[i_face]
		local projected_face = {}
		local normal = self.object:get_face_normal(i_face)
		local dot = normal:dot(camera_vec)
		if dot < 0 then
			for i_point = 1, #face do
				local vertex = self.object.transformed_vertices[face[i_point]]
				local projected_vertex = self:project_vertex(vertex)
				table.insert(projected_face, projected_vertex.x)
				table.insert(projected_face, projected_vertex.y)
	
			end
	
			exec_color(self:get_shading_color(normal), function()
				love.graphics.polygon("fill", projected_face)
			end)
			table.insert(projected_faces, projected_face)
		end

		
		-- local n1 = self:project_vertex(self.object.transformed_vertices[face[1]])
		-- local n2 = self:project_vertex(self.object.transformed_vertices[face[1]]:vadd(normal))
		-- line_color(COL_WHITE, n1.x, n1.y, n2.x, n2.y)

	end

	exec_color(self.line_color, function()
		for _, face in pairs(projected_faces) do
			for i=1, #face-2, 2 do
				love.graphics.line(face[i], face[i+1], face[i+2], face[i+3])
			end
			love.graphics.line(face[1], face[2], face[#face-1], face[#face])
		end
	end)
end

return Renderer3D