require "scripts.util"
local Class = require "scripts.meta.class"

local Sprite = Class:inherit()

function Sprite:init(image)
    self.image = image

    self.ox = 0
    self.oy = 0

    self.rot = 0

    self.sx = 1
    self.sy = 1

    self.flip_x = false
    self.flip_y = false

    self.color = COL_WHITE

    self.anchor = SPRITE_ANCHOR_CENTER_BOTTOM
end

function Sprite:set_image(image)
    self.image = image
end

function Sprite:update_offset(ox, oy)
    self.ox = ox or self.ox
    self.oy = oy or self.oy
end

function Sprite:set_rotation(rot)
    self.rot = rot
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

function Sprite:set_anchor(anchor_x, anchor_y)
    if anchor_y == nil then
        self.anchor = anchor_x
    else
        self.anchor = anchor_x..anchor_y
    end
end

function Sprite:get_x_anchor()
    return self.anchor:sub(1, 1)
end

function Sprite:get_y_anchor()
    return self.anchor:sub(2, 2)
end

function Sprite:get_anchor_offset(w, h)
	local spr_w = self.image:getWidth()
	local spr_h = self.image:getHeight()
    local anchor_x, anchor_y = self:get_x_anchor(), self:get_y_anchor()

    local x, y
    if anchor_x == SPRITE_ANCHOR_START then
        x = spr_w / 2
    elseif anchor_x == SPRITE_ANCHOR_CENTER then
        x = w / 2
    elseif anchor_x == SPRITE_ANCHOR_END then
        x = w - spr_w / 2
    end

    if anchor_y == SPRITE_ANCHOR_START then
        y = spr_h / 2
    elseif anchor_y == SPRITE_ANCHOR_CENTER then
        y = h / 2
    elseif anchor_y == SPRITE_ANCHOR_END then
        y = h - spr_h / 2
    end

    return math.floor(x), math.floor(y)
end

function Sprite:set_color(color)
    self.color = color
end

function Sprite:update(dt)
	--
end


function Sprite:get_total_offset_position(x, y, w, h)
    local anchor_ox, anchor_oy = self:get_anchor_offset(w, h)
    local sprite_ox, sprite_oy = self:get_sprite_offset()

    return x + anchor_ox - sprite_ox, y + anchor_oy - sprite_oy
end

function Sprite:get_total_centered_offset_position(x, y, w, h)
    local anchor_ox, anchor_oy = self:get_anchor_offset(w, h)

    return x + anchor_ox + self.ox, y + anchor_oy + self.oy
end

function Sprite:get_sprite_offset()
	local spr_w2 = floor(self.image:getWidth() / 2)
	local spr_h2 = floor(self.image:getHeight() / 2)
    return spr_w2 - self.ox, spr_h2 - self.oy
end

function Sprite:draw(x, y, w, h, custom_draw)
    local draw_func = love.graphics.draw
    if custom_draw then
        draw_func = custom_draw 
    end
    
	local scale_x = ternary(self.flip_x, -1, 1) * self.sx
	local scale_y = ternary(self.flip_y, -1, 1) * self.sy

    local anchor_ox, anchor_oy = self:get_anchor_offset(w, h)
    local sprite_ox, sprite_oy = self:get_sprite_offset()

    exec_color(self.color, function()
        draw_func(self.image, x + anchor_ox, y + anchor_oy, self.rot, scale_x, scale_y, sprite_ox, sprite_oy)
    end)

    local dx, dy = self:get_total_offset_position(x, y, w, h)
    love.graphics.circle("fill", dx, dy, 1)
end

return Sprite