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

    self.anim_frame_len = 0.4
    self.anim_frames = {images.slug1, images.slug2}
end

return Slug