require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Slug = Enemy:inherit()

function Slug:init(x, y)
    self:init_enemy(x, y, images.slug1, 14, 9)
    self.name = "slug"
    self.follow_player = true

    self.gravity = self.default_gravity * 0.5

    self.def_speed_x = self.speed_x

    self.anim_frame_len = 0.4
    self.anim_frames = {images.slug1, images.slug2}

    self.score = 10

    self.sound_death = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
    self.sound_stomp = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
end

function Slug:update(dt)
    self:update_enemy(dt)

    self.speed_x = ternary(self.is_grounded, self.def_speed_x, self.def_speed_x * 0.5)
end

function Slug:draw()
    self:draw_enemy()
end

return Slug