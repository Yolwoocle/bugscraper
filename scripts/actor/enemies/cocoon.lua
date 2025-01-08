require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Guns = require "data.guns"
local Timer = require "scripts.timer"

local Cocoon = Enemy:inherit()

function Cocoon:init(x, y, player)
    Cocoon.super.init(self, x,y, images.cocoon, 15, 15)
    self.name = "cocoon"

    self.player_n = player.n or 1

    self.follow_player = false
    self.counts_as_enemy = false

    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1
    
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    
    self.knockback = 0
    
    self.is_immune_to_explosions = true
    self.is_immune_to_electricity = true
    self.is_stompable = false
    self.do_stomp_animation = false
    self.stompable_cooldown_timer = Timer:new(0.5)
    self.stompable_cooldown_timer:start()
    -- self.stomps = 3
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.has_revived = false

    self.gun = player.gun
    
    local skin = player.skin
    self.spr:set_outline(skin.color_palette[1], "round")

    self.sweat_timer = Timer:new(0.7):start()

    -- self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    -- self.sound_death = "cloth_drop"
    -- self.sound_stomp = "cloth_drop"
end

function Cocoon:update(dt)
    self:update_enemy(dt)

    if self.stompable_cooldown_timer:update(dt) then
        self.is_stompable = true
    end

    if self.sweat_timer:update(dt) then
        Particles:sweat(self.x + self.w + 4, self.y - 4)
        self.sweat_timer:start()
    end
end

function Cocoon:on_death(damager, reason)
    if self.has_revived then
        return
    end
    
    self:revive(damager)
end

function Cocoon:revive(damager)    
    if game.players[self.player_n] then
        self:kill()
        return
    end

    local reviver
    if damager and damager.is_player then
        reviver = damager
    elseif damager and damager.is_bullet then
        reviver = damager.player
    elseif damager == nil then
        reviver = damager
    else
        return
    end

    self.has_revived = true

    Particles:image(self.mid_x, self.mid_y, 20, {images.cocoon_fragment_1, images.cocoon_fragment_2}, self.w, nil, nil, 0.5)
    game:frameskip(10)

    local new_player = game:new_player(self.player_n, self.x, self.y)
    game.waves_until_respawn[self.player_n] = {-1, nil}

    new_player:set_invincibility(new_player.max_invincible_time)
    new_player:equip_gun(self.gun)
    for _, upgrade in pairs(game.upgrades) do
        new_player:apply_upgrade(upgrade, true)
    end
    
    if reviver and reviver.is_player then
        local l = math.floor(reviver.life/2)
        local player_life, reviver_life = l, reviver.life - l
        if reviver.life <= 1 then
            player_life = 1
            reviver_life = 1
        end
        Particles:word(new_player.mid_x,  new_player.mid_y - 16,  concat("+", player_life), COL_LIGHT_RED)    
        if math.abs(reviver.life - reviver_life) > 0 then
            Particles:word(reviver.mid_x, reviver.mid_y - 16, concat("-", reviver.life - reviver_life), COL_LIGHT_RED)    
        end 
        new_player:set_life(player_life)
        reviver:set_life(reviver_life)

    elseif reviver == nil then
        new_player:set_life(1)

    end

    if not self.is_dead then
        self:kill()
    end  
end

function Cocoon:draw()
    self:draw_enemy()
    
end

return Cocoon