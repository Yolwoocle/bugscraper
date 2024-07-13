require "scripts.util"
local Class = require "scripts.meta.class"
local Model = require "scripts.graphics.3d.model"
local Vec3 = require "lib.batteries.vec3"

local Object3D = Class:inherit()

function Object3D:init(model, x, y, z)
	self.position = Vec3(x or 0, y or 0, z or 0)
    self.rotation = Vec3(0, 0, 0)
	self.scale = Vec3(1, 1, 1)

    self.model = model or Model:new()
    self.transformed_vertices = {}
    for i=1, #self.model.vertices do
        self.transformed_vertices[i] = self.model.vertices[i]:copy()
    end
end

function Object3D:get_transformed_vertex(i_vertex)
    return self.transformed_vertices[i_vertex]
end

function Object3D:reset_transform()
    for i=1, #self.transformed_vertices do
        self.transformed_vertices[i] = self.model.vertices[i]:copy()
    end
end

function Object3D:apply_rotation_x(angle)
    local verts = self.transformed_vertices
    local cosang = math.cos(angle)
    local sinang = math.sin(angle)
    for i=1, #verts do
        local y = verts[i].y
        local z = verts[i].z
        self.transformed_vertices[i].y = y*cosang - z*sinang
        self.transformed_vertices[i].z = z*cosang + y*sinang
    end
end

function Object3D:apply_rotation_y(angle)
    local verts = self.transformed_vertices
    local cosang = math.cos(angle)
    local sinang = math.sin(angle)
    for i=1, #verts do
        local x = verts[i].x
        local z = verts[i].z
        self.transformed_vertices[i].x = x*cosang - z*sinang
        self.transformed_vertices[i].z = z*cosang + x*sinang
    end
end

function Object3D:apply_rotation_z(angle)
    local verts = self.transformed_vertices
    local cosang = math.cos(angle)
    local sinang = math.sin(angle)
    for i=1, #verts do
        local x = verts[i].x
        local y = verts[i].y
        self.transformed_vertices[i].x = x*cosang - y*sinang
        self.transformed_vertices[i].y = y*cosang + x*sinang
    end
end

function Object3D:apply_transform()
    self:reset_transform()
    self:apply_rotation_to_vertices()
    for i=1, #self.transformed_vertices do
        self:apply_scale_and_translation_to_vertex(i)
    end
end

function Object3D:apply_rotation_to_vertices()
    self:apply_rotation_x(self.rotation.x)
    self:apply_rotation_y(self.rotation.y)
    self:apply_rotation_z(self.rotation.z)
end

function Object3D:apply_scale_and_translation_to_vertex(vertex_id)
    local vertex = self.transformed_vertices[vertex_id]
    if not vertex then
        return
    end

    local new_x = vertex.x
    local new_y = vertex.y
    local new_z = vertex.z
    
    new_x = new_x * self.scale.x
    new_y = new_y * self.scale.y
    new_z = new_z * self.scale.z
    
    new_x = new_x + self.position.x
    new_y = new_y + self.position.y
    new_z = new_z + self.position.z
    
    self.transformed_vertices[vertex_id].x = new_x
    self.transformed_vertices[vertex_id].y = new_y
    self.transformed_vertices[vertex_id].z = new_z
end

function Object3D:get_face_normal(i_face)
    local face = self.model.faces[i_face]
    local p1 = self.transformed_vertices[face[1]]
    local p2 = self.transformed_vertices[face[2]]
    local p3 = self.transformed_vertices[face[3]]
    -- assert(false, table_to_str(p1)..table_to_str(p2)..table_to_str(p3))
    local edge1 = p2:vsub(p1)
    local edge2 = p3:vsub(p1)
    local normal = edge1:cross(edge2)
    normal:normalisei()

    return normal
end

return Object3D