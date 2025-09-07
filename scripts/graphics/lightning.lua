require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local images = require "data.images"
local Class = require "scripts.meta.class"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"
local shaders = require "data.shaders"

local utf8 = require "utf8"

local Lightning = Class:inherit()

function Lightning:init(params)
    params = param(params, {})

    self.min_step_size =   param(params.min_step_size, 4)
    self.max_step_size =   param(params.max_step_size, 10)
    self.max_steps =       param(params.max_steps, 300)
    self.min_line_width =  param(params.min_line_width, 1)
    self.max_line_width =  param(params.max_line_width, 3)
    self.jitter_width =    param(params.jitter_width, 3)
    self.palette =         param(params.palette, {
        COL_LIGHT_YELLOW,
        COL_ORANGE,
        COL_YELLOW_ORANGE,
        COL_WHITE,
    })
    self.style =           param(params.style, LIGHTNING_STYLE_NORMAL)
    self.animation =       param(params.style, LIGHTNING_ANIMATION_JITTER)
    self.coordinate_mode = param(params.coordinate_mode, LIGHNING_COORDINATE_MODE_CARTESIAN)

    self.color = self.palette[1]
    self.segments = {}

    self.debug_col = {random_range(0, 1), random_range(0, 1), random_range(0, 1), 1}
end

function Lightning:convert_segment(ax, ay, bx, by)
    if self.coordinate_mode == LIGHNING_COORDINATE_MODE_POLAR then
        ax, ay = math.cos(ay) * ax, math.sin(ay) * ax
        bx, by = math.cos(by) * bx, math.sin(by) * bx
    end
    return Segment:new(ax, ay, bx, by)
end

function Lightning:new_segment(ax, ay, bx, by)
    local line_width = random_range(self.min_line_width, self.max_line_width)
    local segment = self:convert_segment(ax, ay, bx, by)

    table.insert(self.segments, {
        color = self.color,
        line_width = line_width,
        segment = segment,
    })
end

function Lightning:generate(segment)
    self.segments = {}

    local dir_x, dir_y = segment:get_direction()
    local normal_x, normal_y = get_orthogonal(dir_x, dir_y)
    local length = segment:get_length()

    local t = 0.0
    local i = 1
    local last_x, last_y = segment.ax, segment.ay
    self.color = random_sample(self.palette)
    while t < length - self.max_step_size and i <= self.max_steps do
        local step = random_range(self.min_step_size, self.max_step_size)
        local jitter_offset = random_neighbor(self.jitter_width)

        t = t + step
        local new_x = segment.ax + dir_x*t + normal_x*jitter_offset 
        local new_y = segment.ay + dir_y*t + normal_y*jitter_offset

        self:new_segment(last_x, last_y, new_x, new_y)

        last_x, last_y = new_x, new_y
        i = i + 1
    end

    self:new_segment(last_x, last_y, segment.bx, segment.by)
end

function Lightning:draw(ox, oy, params)
    ox = param(ox, 0)
    oy = param(oy, 0)
    params = param(params, {})
    
    if self.style == LIGHTNING_STYLE_NORMAL then
        local old_width = love.graphics.getLineWidth()
        for i, point in pairs(self.segments) do
            love.graphics.setLineWidth(point.line_width) 
            line_color(point.color, ox + point.segment.ax, oy + point.segment.ay, ox + point.segment.bx, oy + point.segment.by)
        end
    
        love.graphics.setLineWidth(old_width)
    
    elseif self.style == LIGHTNING_STYLE_BITS then
        for i, point in pairs(self.segments) do
            local img = ternary(point.line_width < lerp(self.min_line_width, self.max_line_width, 0.5), images.particle_bit_zero_dark, images.particle_bit_one_dark)
            love.graphics.draw(img, ox + point.segment.bx, oy + point.segment.by)
        end
        
    elseif self.style == LIGHTNING_STYLE_THORNS then        
        local draw = function(oox, ooy)
            for i, point in pairs(self.segments) do
                draw_centered(images.thorn_ball, oox + ox + point.segment.ax, ooy + oy + point.segment.ay)
            end
            local point = self.segments[#self.segments]
            if point then
                draw_centered(images.thorn_ball, oox + ox + point.segment.bx, ooy + oy + point.segment.by)
            end
        end

        love.graphics.setShader(shaders.draw_in_color)
        if params.thorns_outline then
            shaders.draw_in_color:sendColor("fillColor", params.thorns_outline)
            draw(-1, 0)
            draw(1, 0)
            draw(0, 1)
            draw(0, -1)
        end

        love.graphics.setShader()
        draw(0, 0)
        -- shaders.draw_in_color:sendColor("fillColor", self.debug_col)
    end
end

return Lightning