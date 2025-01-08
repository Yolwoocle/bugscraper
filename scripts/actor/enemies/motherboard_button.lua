require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Explosion = require "scripts.actor.enemies.explosion"

local utf8 = require "utf8"

local MotherboardButton = Prop:inherit()

function MotherboardButton:init(x, y, parent)
    self:init_prop(x, y, images.motherboard_button, 48, 32)
    self.name = "motherboard_button"
    
    self.gravity = 0
    self.life = 10
    self.loot = {}

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = true

    self.parent_damage = 20
    
    self.parent = parent
    self.score = 10
	-- self.sound_damage = "glass_fracture"
	-- self.sound_death = "glass_break_weak"
end

function MotherboardButton:update(dt)
    self:update_prop(dt)

end

function MotherboardButton:draw()
	self:draw_prop()
end

function MotherboardButton:after_collision(col, other)
    if col.other.is_player and not self.is_dead then
        self:kill()
        self.parent:do_damage(self.parent_damage)
        self.parent:on_motherboard_button_pressed(self)

        col.other:apply_force_from(2000, {x = col.other.x, y = self.y})

        game:new_actor(Explosion:new(self.mid_x, self.mid_y, {
            explosion_damage = 0,
            override_enemy_damage = 0,
            use_gun = false,
        }))
    end
end


return MotherboardButton