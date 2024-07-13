require "scripts.util"
local Class = require "scripts.meta.class"
local batteries = require "lib.batteries"
local Vec3 = batteries.vec3

local Model = Class:inherit()

function Model:init(vertices, tris)
	self.vertices = vertices or {}
	self.faces = tris or {}

    for i=1, #self.vertices do
        self.vertices[i] = Vec3(
            self.vertices[i][1],
            self.vertices[i][2],
            self.vertices[i][3]
        )
    end
end

function Model:clone()
    return Model:new(copy_table(self.vertices), copy_table(self.faces))
end

return Model