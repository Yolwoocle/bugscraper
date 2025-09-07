require "scripts.util"
local shaders = require "data.shaders"

local Class = require "scripts.meta.class"

local Layer = Class:inherit()

function Layer:init(width, height)
    self.width = width
    self.height = height

    self.canvas = love.graphics.newCanvas(width, height)
    self.blur = false
    self.blur_radius = 2

    self.draw_color = nil
end

function Layer:paint(paint_function, params)
    params = param(params, {})
    local apply_camera = param(params.apply_camera, true)
    local camera = param(params.camera, nil)
    
    exec_on_canvas(self.canvas, function() 
        if apply_camera then
            camera:push()
        end
        paint_function()
        if apply_camera then
            camera:pop()
        end
    end)
end

function Layer:draw(x, y)
    x = param(x, 0)
    y = param(y, 0)
    if self.blur then
        shaders.blur_shader:send("r", self.blur_radius)
		exec_using_shader(shaders.blur_shader, function()
            love.graphics.draw(self.canvas, x, y)
        end)

    elseif self.draw_color then
        shaders.draw_in_color:send("fillColor", self.draw_color)
		exec_using_shader(shaders.draw_in_color, function()
            love.graphics.draw(self.canvas, x, y)
        end)

    else
        love.graphics.draw(self.canvas, x, y)
    end
end

return Layer