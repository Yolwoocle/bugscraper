require "scripts.util"
local Class = require "scripts.meta.class"

local Sprite = Class:inherit()

function Sprite:init(image)
    self.image = image

    self.ox = 0
    self.oy = 0

    self.sx = 1
    self.sy = 1

    self.flip_x = false
    self.flip_y = false
end

function Sprite:set_image(image)
    self.image = image
end

function Sprite:update_offset(ox, oy)
    self.ox = ox or self.ox
    self.oy = oy or self.oy
end

function Sprite:get_offset_position(x, y)
    return x + self.ox, y + self.oy
end

function Sprite:set_scale(sx, sy)
    self.sx = sx or self.sx
    self.sy = sy or self.sy
end

function Sprite:set_flip_x(flip_x)
    self.flip_x = flip_x
end

function Sprite:set_flip_y(flip_y)
    self.flip_y = flip_y
end

function Sprite:update(dt)
	--
end

function Sprite:draw(x, y, custom_draw)
    local drw_func = love.graphics.draw
    if custom_draw then
        drw_func = custom_draw 
    end
    
	local scale_x = ternary(self.flip_x, -1, 1) * self.sx
	local scale_y = ternary(self.flip_y, -1, 1) * self.sy

	local spr_w2 = floor(self.image:getWidth() / 2)
	local spr_h2 = floor(self.image:getHeight() / 2)

    drw_func(self.image, x, y, self.rot, scale_x, scale_y, spr_w2 - self.ox, spr_h2 - self.oy)
end

return Sprite