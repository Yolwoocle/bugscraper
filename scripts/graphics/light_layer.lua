require "scripts.util"
local shaders = require "data.shaders"

local Layer = require "scripts.graphics.layer"

local LightLayer = Layer:inherit()

function LightLayer:init(width, height, light_world)
    self.is_light_layer = true
    self.width = width
    self.height = height

    self.canvas = love.graphics.newCanvas(width, height)
    self.blur = false
    self.blur_radius = 2

    self.light_world = light_world
end

function LightLayer:update_lights(dt)
end

function LightLayer:paint(paint_function, params)
    params = param(params, {})
    local apply_camera = param(params.apply_camera, true)
    local camera = param(params.camera, nil)
      
    exec_on_canvas({self.canvas, stencil=true}, function()
        if apply_camera then
            camera:push()
        else
            love.graphics.origin()
            love.graphics.scale(1)
        end
		love.graphics.clear()
        
        love.graphics.setStencilState("replace", "always", 1)
        love.graphics.setColorMask(false)
        self.light_world:paint()

        love.graphics.setStencilState("keep", "less", 1)
        love.graphics.setColorMask(true)
		
        paint_function()
		love.graphics.setStencilState()

        if apply_camera then
            camera:pop()
        end
	end)
end

function LightLayer:draw(x, y)
    x = param(x, 0)
    y = param(y, 0)
    if self.blur then
        shaders.blur_shader:send("r", self.blur_radius)
		exec_using_shader(shaders.blur_shader, function()
            love.graphics.draw(self.canvas, x, y)
        end)
    else
        love.graphics.draw(self.canvas, x, y)
    end
end

return LightLayer