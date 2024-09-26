require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Loot = require "scripts.actor.loot"
local Sprite = require "scripts.graphics.sprite"
local guns = require "data.guns"

local utf8 = require "utf8"

local GunDisplay = Prop:inherit()

function GunDisplay:init(x, y, gun)
    self:init_prop(x, y, images.gun_display, 16, 16)
    self.name = "gun_display"
    
    self.gun = gun or guns.Triple:new(nil)
	self.counts_as_enemy = false

    self.life = 15

    self.dissapear_life = 14
    self.loot = {}

    self.gravity = self.default_gravity
    self.is_flying = false

    self.is_pushable = false
    self.is_knockbackable = true

    self.is_stompable = true
    self.is_killed_on_stomp = false
    self.stomps = 500
    self.damage_on_stomp = 5

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false

    self.player_detection_range_x = 26
    self.player_detection_range_y = 64
    self.target_players = {}

    self.friction_x = 0.9
    self.self_knockback_mult = 0.7
    self.vertical_bounce_multiplier = 0.8
    
    self.rot_mult = 0.06

	self.sound_damage = {"impactglass_light_001", "impactglass_light_002", "impactglass_light_003", "impactglass_light_004"}
	self.sound_death = "glass_break_weak"

    self.max_dissapear_life = 10
    self.dissapear_life = self.max_dissapear_life

	self.max_blink_timer = 0.1
	self.blink_timer = self.max_blink_timer
	self.blink_is_shown = true

    self.spr.rot = random_range(0, pi*2)
    self.spr:set_scale(0.5, 0.5)

    self.gun_spr = Sprite:new(self.gun.spr)
end

function GunDisplay:assign_upgrade(upgrade)
    self.product = upgrade
end

function GunDisplay:update(dt)
    self:update_prop(dt)

    -- scotch
    if self.buffer_vx then
        self.vx = self.buffer_vx
        self.buffer_vx = nil
    end
    -- scotch
    if self.buffer_vy then
        self.vy = self.buffer_vy
        self.buffer_vy = nil
    end

    local r = (self.spr.rot + self.vx * self.rot_mult * dt)
    self.spr:set_rotation(r)
    self.gun_spr:set_rotation(r)

    self.gun.x = self.mid_x
    self.gun.y = self.mid_y
    self.gun.rot = self.spr.rot
    
    -- Copy pasted from Loot. Is this a bad coding habit? Too bad.
    self.dissapear_life = self.dissapear_life - dt
	if self.dissapear_life < self.max_dissapear_life * 0.5 then
		self.blink_timer = self.blink_timer - dt
		
		if self.blink_timer < 0 then
			local val = self.max_blink_timer
			if self.dissapear_life < self.max_dissapear_life * 0.25 then
				val = self.max_blink_timer * .5
			end
			self.blink_timer = val
			self.blink_is_shown = not self.blink_is_shown
		end
	end 
	self.spr:set_color(ternary(self.blink_is_shown, COL_WHITE, {1,1,1, 0.5}))
	self.gun_spr:set_color(ternary(self.blink_is_shown, COL_WHITE, {1,1,1, 0.5}))

    if self.dissapear_life < 0 then
        self:remove()
    end
end

function GunDisplay:draw()
    if self.gun and self.blink_is_shown then
        -- self.gun:draw()
        self.gun_spr:draw(self.x, self.y, self.w, self.h, self:is_flashing_white() and draw_white)
    end
	self:draw_prop() 
end

function GunDisplay:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 10, images.glass_shard, self.h)

    local dropped = Loot.Gun:new(self.x, self.y, nil, random_neighbor(20), -random_range(10, 30), self.gun)
    game:new_actor(dropped)
end

function GunDisplay:after_collision(col, other)
    if col.type ~= "cross" then
        local s = 0
        if col.normal.y == 0 then
            self.buffer_vx = col.normal.x * math.abs(self.vx)
            s = math.abs(self.buffer_vx)
        end
        if col.normal.x == 0 then
            self.buffer_vy = col.normal.y * math.abs(self.vy) * self.vertical_bounce_multiplier
            s = math.abs(self.buffer_vy)
        end

        if math.abs(s) > 30 then
            Audio:play(self.sound_damage, clamp(math.abs(s) / 200, 0.3, 0.6), 0.7)
        end
    end
end

function GunDisplay:on_stomped(stomper)
    self:apply_force_from(500 * self.self_knockback_mult, stomper)
end

return GunDisplay