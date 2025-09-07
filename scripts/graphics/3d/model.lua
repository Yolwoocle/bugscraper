 require "scripts.util"
local Class = require "scripts.meta.class"
local batteries = require "lib.batteries"
local Vec3 = batteries.vec3

local Model = Class:inherit()

function Model:init(vertices, tris, edges)
	self.vertices = vertices or {}
	self.faces = tris or {}
    self.edges = edges or {}

    for i=1, #self.vertices do
        self.vertices[i] = Vec3(
            self.vertices[i][1],
            self.vertices[i][2],
            self.vertices[i][3]
        )
    end
end

function Model:clone()  
    return Model:new(copy_table_deep(self.vertices), copy_table_deep(self.faces))
end

return Model