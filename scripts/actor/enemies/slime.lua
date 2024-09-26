require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Slime = Enemy:inherit()

function Slime:init(x, y, size)
    size = size or 5

    self:init_enemy(x, y, images.slug1, 16, 16)
    self.name = "slug"
    self.follow_player = true

    self.gravity = self.default_gravity * 0.5

    self:set_size(size)

    self.anim_frame_len = 0.4
    self.anim_frames = {images.slug1, images.slug2}
end

function Slime:set_size(size)
    if size > 0 then
        self.speed_x = 20 * (1/size)
    else
        self.speed_x = 20
    end
    self.def_speed_x = self.speed_x

    self.size = size
    self.spr:set_scale(size, size)
    self:set_dimensions(16*size, 14*size)
end

function Slime:update(dt)
    self:update_enemy(dt)

    self.speed_x = ternary(self.is_grounded, self.def_speed_x, self.def_speed_x * 0.5)
end

function Slime:on_death()
    if self.size > 1 then
        local child_1 = Slime:new(self.x, self.y, self.size-1)
        local child_2 = Slime:new(self.x, self.y, self.size-1)
        game:new_actor(child_1)
        game:new_actor(child_2)
    end
end

function Slime:draw()
    self:draw_enemy()

    rect_color({1, 1, 0, 0.5}, "fill", self.x, self.y, self.w, self.h)
    rect_color({1, 1, 0}, "line", self.x, self.y, self.w, self.h)
end

return Slime