require "scripts.util"
local shaders = require "data.shaders"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"

local Layer = require "scripts.graphics.layer"

local LightLayer = Layer:inherit()

function LightLayer:init(width, height)
    self.is_light_layer = true
    self.width = width
    self.height = height

    self.canvas = love.graphics.newCanvas(width, height)
    self.blur = false
    self.blur_radius = 2

    self.bounds = Rect:new(-4000, -16, 4000, 15*16 + 3)
    self.lights = {
        Light:new(CANVAS_WIDTH/2,     -32, pi*0.5, pi*0.1,  800, self.bounds, false),
        Light:new(500,                -32, pi*0.7, pi*0.05, 800, self.bounds, false),
        Light:new(CANVAS_WIDTH - 500, -32, pi*0.3, pi*0.05, 800, self.bounds, false),
    }
end

function LightLayer:paint(paint_function, params)
    params = param(params, {})
    local apply_camera = param(params.apply_camera, true)
    local camera = param(params.camera, nil)
      
    exec_on_canvas({self.canvas, stencil=true}, function()
        if apply_camera then
            camera:apply_transform()
        else
            love.graphics.origin()
            love.graphics.scale(1)
        end
		love.graphics.clear()
        
        love.graphics.stencil(function()
            for _, light in pairs(self.lights) do
                light:draw()
            end
        end, "replace")
        love.graphics.setStencilTest("less", 1)
		
        paint_function()
		
		love.graphics.setStencilTest()
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