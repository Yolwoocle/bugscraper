require "scripts.util"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local guns = require "data.guns"

local utf8 = require "utf8"

local Explosion = Prop:inherit()

function Explosion:init(x, y, args)
    -- radius, resolution, screenshake
    args = args or {}

    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "explosion"

    self.use_gun = param(args.use_gun, true)
    self.explosion_damage = param(args.explosion_damage, 1)
    self.override_enemy_damage = param(args.override_enemy_damage, 6)
    self.radius = param(args.radius, 32)
    self.resolution = param(args.resolution, 32)
    self.screenshake = param(args.screenshake, 8)

    self.do_killed_smoke = false
	self.play_sfx = false
    self.gun = guns.unlootable.ExplosionGun:new(self, self.radius, self.explosion_damage, self.resolution, {
        override_enemy_damage = self.override_enemy_damage
    })
end

function Explosion:update(dt)
    self:update_prop(dt)

    if not self.is_dead then
        if self.use_gun then
            self.gun:shoot(0, self, self.mid_x, self.mid_y, math.cos(0), math.sin(0))
        end
        game:screenshake(self.screenshake)
        game:frameskip(5)
        Audio:play("explosion")
        Particles:explosion(self.mid_x, self.mid_y, self.radius + 8)
        -- Particles:static_image(images._test_anim_explosion, self.mid_x, self.mid_y, 0, 1)

        self:kill()      
    end
end

function Explosion:draw()
    -- self:draw_prop()
end

return Explosion