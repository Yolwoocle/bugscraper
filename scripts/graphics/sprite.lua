require "scripts.util"
local Class = require "scripts.meta.class"
local shaders = require "data.shaders"
local images  = require "data.images"

local Sprite = Class:inherit()

function Sprite:init(image, anchor, params)
    params = params or {}
    self.image = image
    if image then
        self.w = self.image:getWidth()
        self.h = self.image:getHeight()
    else
        self.w = 1
        self.h = 1
    end

    self.ox = 0
    self.oy = 0

    self.rot = 0

    self.sx = 1
    self.sy = 1

    self.flip_x = false
    self.flip_y = false

    self.color = COL_WHITE
    self.outline = nil
    self.shader = nil
    self.white_flash_timer = shaders.white_shader

    self.is_spritesheet = false
    self.spritesheet_tile = 1
    self.spritesheet_tile_count_x = 1
    self.spritesheet_tile_count_y = 1
    if self.image then
        self.spritesheet_tile_w = self.image:getWidth()
        self.spritesheet_tile_h = self.image:getHeight()
        self.spritesheet_quad = love.graphics.newQuad(0, 0,
            self.image:getWidth(), self.image:getHeight(),
            self.image:getWidth(), self.image:getHeight()
        )
    else
        self.spritesheet_tile_w = 1
        self.spritesheet_tile_h = 1
        self.spritesheet_quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
    end

    if params.spritesheet then
        self:set_spritesheet(self.image, params.spritesheet.tile_count_x, params.spritesheet.tile_count_y)
    end

    self.is_visible = true
    self.anchor = anchor or SPRITE_ANCHOR_CENTER_BOTTOM
end

function Sprite:set_visible(val)
    self.is_visible = val
end

function Sprite:set_spritesheet(image, tile_count_x, tile_count_y)
    tile_count_x = tile_count_x or 1
    tile_count_y = tile_count_y or 1

    self.is_spritesheet = (image ~= nil)

    if self.is_spritesheet then
        self.image = image

        self.spritesheet_tile = 1
        self.spritesheet_tile_count_x = tile_count_x
        self.spritesheet_tile_count_y = tile_count_y
        self.spritesheet_tile_w = image:getWidth()  / tile_count_x
        self.spritesheet_tile_h = image:getHeight() / tile_count_y

        self.w = self.spritesheet_tile_w
        self.h = self.spritesheet_tile_h

        self:set_spritesheet_tile(1)
    end
end

function Sprite:set_spritesheet_tile(tile)
    self.spritesheet_tile = tile

    local frame0 = (self.spritesheet_tile - 1)

    self.spritesheet_quad:setViewport(
        self.spritesheet_tile_w * (frame0 % self.spritesheet_tile_count_x),
        self.spritesheet_tile_h * math.floor(frame0 / self.spritesheet_tile_count_x),
        self.spritesheet_tile_w, self.spritesheet_tile_h, self.image:getDimensions()
    )
end

function Sprite:set_image(image)
    self.image = image
    self.w = image:getWidth()
    self.h = image:getHeight()
end

function Sprite:update_offset(ox, oy)
    self.ox = ox or self.ox
    self.oy = oy or self.oy
end

function Sprite:get_rotation()
    return self.rot
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
        self.anchor = anchor_x .. anchor_y
    end
end

function Sprite:get_x_anchor()
    return self.anchor:sub(1, 1)
end

function Sprite:get_y_anchor()
    return self.anchor:sub(2, 2)
end

function Sprite:get_anchor_offset(w, h)
    w = param(w, 0)
    h = param(h, 0)

    local spr_w = self.w * self.sx
    local spr_h = self.h * self.sy
    local anchor_x, anchor_y = self:get_x_anchor(), self:get_y_anchor()

    local x, y
    if anchor_x == SPRITE_ANCHOR_AXIS_START then
        x = spr_w / 2
    elseif anchor_x == SPRITE_ANCHOR_AXIS_CENTER then
        x = w / 2
    elseif anchor_x == SPRITE_ANCHOR_AXIS_END then
        x = w - spr_w / 2
    end

    if anchor_y == SPRITE_ANCHOR_AXIS_START then
        y = spr_h / 2
    elseif anchor_y == SPRITE_ANCHOR_AXIS_CENTER then
        y = h / 2
    elseif anchor_y == SPRITE_ANCHOR_AXIS_END then
        y = h - spr_h / 2
    end

    -- return math.floor(x * self.sx), math.floor(y * self.sy)
    return math.floor(x), math.floor(y)
end

function Sprite:set_color(color)
    self.color = color
end

function Sprite:set_shader(shader)
    self.shader = shader
end

function Sprite:reset_shader()
    self.shader = nil
end

function Sprite:set_flashing_white(value)
    self.is_flashing_white = value
    if value then
        self:set_shader(self.white_flash_timer)
    else
        self:reset_shader()
    end
end

function Sprite:set_solid(enabled)
    self.is_solid_color = enabled
end

function Sprite:set_outline(color, type)
    if color == nil then
        self.outline = nil
    else
        self.outline = {
            color = color,
            type = type, -- "round" or "square"
        }
    end
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
    local spr_w2 = floor(self.w / 2)
    local spr_h2 = floor(self.h / 2)
    return spr_w2 - self.ox, spr_h2 - self.oy
end

function Sprite:draw(x, y, w, h, custom_draw)
    -- This function is HORRENDOUSLY ugly. Refactor it some day. Whatever it works 
    if not self.is_visible then
        return
    end

    local draw_func = love.graphics.draw
    if custom_draw then
        draw_func = custom_draw
    end

    local spr_w = self.w
    local spr_h = self.h

    local scale_x = ternary(self.flip_x, -1, 1) * self.sx
    local scale_y = ternary(self.flip_y, -1, 1) * self.sy

    local anchor_ox, anchor_oy = self:get_anchor_offset(w, h)
    local sprite_ox, sprite_oy = self:get_sprite_offset()

    local old_shader
    if self.shader then
        old_shader = love.graphics.getShader()
        love.graphics.setShader(self.shader)
    end
    
    if self.is_solid_color then
		shaders.draw_in_color:sendColor("fillColor", self.color)
        love.graphics.setShader(shaders.draw_in_color)
    end

    exec_color(self.color, function()
        if self.outline then
            if self.is_spritesheet then
                draw_spritesheet_with_outline(self.outline.color, self.outline.type, self.image, self.spritesheet_quad,
                    x + anchor_ox, y + anchor_oy, self.rot,
                    scale_x, scale_y, sprite_ox, sprite_oy)
            else
                draw_with_outline(self.outline.color, self.outline.type, self.image, x + anchor_ox, y + anchor_oy,
                    self.rot,
                    scale_x, scale_y, sprite_ox, sprite_oy)
            end
        end

        if self.is_spritesheet then
            -- game.camera:reset_transform()
            love.graphics.draw(self.image, self.spritesheet_quad, x + anchor_ox, y + anchor_oy, self.rot, scale_x,
                scale_y, sprite_ox, sprite_oy)
        else
            draw_func(self.image, x + anchor_ox, y + anchor_oy, self.rot, scale_x, scale_y, sprite_ox, sprite_oy)
        end

        -- draw_func(self.image, x + anchor_ox, y + anchor_oy, self.rot, scale_x, scale_y, spr_w/2, spr_h)
    end)
    if self.shader or self.is_solid_color then
        love.graphics.setShader(old_shader)
    end
end

return Sprite
