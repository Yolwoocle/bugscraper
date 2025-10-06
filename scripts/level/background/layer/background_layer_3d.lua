require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local images = require "data.images"

local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local BackgroundLayer3D = BackgroundLayer:inherit()

function BackgroundLayer3D:init(background, parallax, params)
    params = params or {}
    BackgroundLayer3D.super.init(self, background, parallax, params)

    self.tile_h = params.tile_h or 100
    self.tile_count = params.tile_count or 1
    self.tile_max_y = params.tile_max_y or 100
    self.tile_min_y = params.tile_min_y or (-self.tile_max_y or -100)

    self.highest_tile_y = 0
    self.lowest_tile_y = 0

    local objects = {}
    for i=1, self.tile_count do
        local object_3d = Object3D:new(params.model)

        local sx = params.object_scale or (params.object_scale_x or 100.0)
        local sy = params.object_scale or (params.object_scale_y or -100.0)
        local sz = params.object_scale or (params.object_scale_z or 100.0)
        object_3d.scale:sset(sx, sy, sz)

        object_3d.position.x = param(params.object_x, 0)
        object_3d.position.y = param(params.object_y, 0) - (i-1)*self.tile_h
        object_3d.position.z = param(params.object_z, 0)

        object_3d.rotation.x = param(params.object_rot_x, 0)
        object_3d.rotation.y = param(params.object_rot_y, 0)
        object_3d.rotation.z = param(params.object_rot_z, 0)

        self.highest_tile_y = max(self.highest_tile_y, object_3d.position.y)
        self.lowest_tile_y = min(self.lowest_tile_y, object_3d.position.y)

        table.insert(objects, object_3d)
    end

    self.renderer = Renderer3D:new(objects)

	self.renderer.orthographic = param(params.orthographic, false)
	self.renderer.fov = param(params.fov, 300)
	self.renderer.render_offset.x = param(params.render_offset, CANVAS_CENTER[1])
	self.renderer.render_offset.y = param(params.render_offset, CANVAS_CENTER[2])

	self.renderer.line_color = param(params.line_color, COL_DARKEST_GRAY)
	self.renderer.lighting_palette = param(params.lighting_palette, self.renderer.lighting_palette)

    self.renderer:update(0)
end

function BackgroundLayer3D:update(dt)
    BackgroundLayer3D.super.update(self, dt)

    self.renderer:update(dt)
    for i=1, #self.renderer.objects do
        local obj = self.renderer.objects[i]
        -- this will probably drift if it runs for a long time bc of floating point but whatever 
        obj.position.y = obj.position.y + self.background:get_speed() * dt  

        if obj.position.y > self.tile_max_y then
            obj.position.y = obj.position.y - self.tile_h * self.tile_count 
        end
        if obj.position.y < self.tile_min_y then
            obj.position.y = obj.position.y + self.tile_h * self.tile_count 
        end
    end
end

function BackgroundLayer3D:draw()
    BackgroundLayer3D.super.draw(self)

    self.renderer:draw()
end

return BackgroundLayer3D