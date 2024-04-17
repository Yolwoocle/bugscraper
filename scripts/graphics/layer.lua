require "scripts.util"
local Class = require "scripts.meta.class"

local Layer = Class:inherit()

function Layer:init(width, height)
    self.width = width
    self.height = height

    self.canvas = love.graphics.newCanvas(width, height)
end

function Layer:paint(paint_function, params)
    params = param(params, {})
    local apply_camera = param(params.apply_camera, true)
    local camera = param(params.camera, nil)
    
    exec_on_canvas(self.canvas, function() 
        if apply_camera then
            camera:apply_transform()
        else
            love.graphics.origin()
            love.graphics.scale(1)
        end
        paint_function()
    end)
end

function Layer:draw(x, y)
    x = param(x, 0)
    y = param(y, 0)
    love.graphics.draw(self.canvas, x, y)
end

return Layer