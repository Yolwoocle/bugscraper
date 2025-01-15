require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local PoisonCloud = Enemy:inherit()
	
function PoisonCloud:init(x, y, spr)
    self:init_fly(x, y)
end

function PoisonCloud:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.poison_cloud, 20, 20)
    self.name = "poison_cloud"
    self.is_flying = true
    self.life = 10

    self.follow_player = false
    self.is_pushable = false
	self.counts_as_enemy = false
    
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_stompable = false
    self.is_killed_on_stomp = false
    self.do_death_effects = false
    
    self.play_sfx = false
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.is_poisonous = true
    self.is_immune_to_electricity = true
    
    self.speed = 0
    self.gravity = 0

    self.friction_x = 0.9
    self.friction_y = self.friction_x
    
    self.damage = 0
    self.is_knockbackable = false

    self.loot = {}
    self.lifespan = random_range(6.0, 10.0)

    self.s_t_mult = random_range(1.8, 2.2)
    self.s_t_offset = random_range(0.0, pi2)
    self.pos_t_mult = random_range(1.8, 2.2)
    self.pos_t_offset = random_range(0.0, pi2)
end

function PoisonCloud:update(dt)
    self:update_poison_cloud(dt)
end

function PoisonCloud:update_poison_cloud(dt)
    self:update_enemy(dt)

    local sx = clamp(self.lifespan*5, 0, 1) * (1 + math.cos(game.t * self.s_t_mult + self.s_t_offset)*0.1)   
    local sy = clamp(self.lifespan*5, 0, 1) * (1 + math.sin(game.t * self.s_t_mult + self.s_t_offset)*0.1)
    local spr_ox = math.cos(game.t * self.pos_t_mult + self.pos_t_offset) * 3.0   
    local spr_oy = math.sin(game.t * self.pos_t_mult + self.pos_t_offset) * 3.0
    self.spr:set_scale(sx, sy)
    self.spr:update_offset(spr_ox, spr_oy)

    self.lifespan = math.max(0.0, self.lifespan - dt)
    if self.lifespan <= 0 then
        self:kill()
    end
end

function PoisonCloud:draw()
	exec_on_canvas(game.smoke_canvas, function() 
        self:draw_enemy()
    end)
end

function PoisonCloud:after_collision(col, other)
    if col.other.is_player then
    end
end

return PoisonCloud