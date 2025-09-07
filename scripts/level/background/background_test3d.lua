local Class = require "scripts.meta.class"

local truncated_ico = require "data.models.truncated_ico"
local Background = require "scripts.level.background.background"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"
local images     = require "data.images"

local BackgroundTest3D = Background:inherit()

function BackgroundTest3D:init(level)
	self.super.init(self, level)
	self.name = "background_test_3d"

    self.def_ball_scale = 24
	
	local object_3d = Object3D:new(truncated_ico)
    object_3d.scale:sset(self.def_ball_scale)
    object_3d.position.x = 200
    object_3d.position.y = 200
    object_3d.position.z = 100
	-- self.renderer.lighting_palette = self.ball_lighting_palette

    self.renderer = Renderer3D:new({object_3d}, {
		orthographic = true,
		-- wireframe = true,
	})

	self.t = 0.0

end

function BackgroundTest3D:update(dt)
	self.super.update(self, dt)

	self.t = self.t + dt
    self.renderer.objects[1].position.x = 0 + math.cos(self.t) * 50
    self.renderer.objects[1].position.y = 0 + math.sin(self.t) * 50
    self.renderer.objects[1].rotation.x = self.renderer.objects[1].rotation.x + dt
    self.renderer.objects[1].rotation.y = self.renderer.objects[1].rotation.y + dt

	self.renderer:update(dt)
end

function BackgroundTest3D:draw()
	BackgroundTest3D.super.draw(self)
	self.renderer:draw()
end

return BackgroundTest3D