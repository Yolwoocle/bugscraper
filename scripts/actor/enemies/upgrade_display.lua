require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local CollisionInfo = require "scripts.physics.collision_info"

local utf8 = require "utf8"

local UpgradeDisplay = Prop:inherit()

function UpgradeDisplay:init(x, y)
    UpgradeDisplay.super.init(self, x, y, images.upgrade_jar, 28, 28)
    self.name = "upgrade_display"
    
    self.product = nil
    -- self:select_random_product()
    self.has_player_in_range = false
    self.is_focused = false
    self.is_stompable = false
    self.is_killed_on_stomp = true
    self.do_stomp_animation = false
    self.is_affected_by_bounds = false

    self.life = 20
    self.loot = {}

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false

    self.player_detection_range_x = 26
    self.player_detection_range_y = 64
    self.target_players = {}
    
	self.sound_damage = "glass_fracture"
	-- self.sound_death = "glass_break_weak"
	self.sound_death = "sfx_actor_upgrade_display_break_{01-04}"

    self.animation_t = 0
    self.is_animation_exiting = false
    self.letters = {}

    self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_SEMISOLID,
        is_slidable = true,

        walk_sound = "sfx_player_footstep_metal_{01-10}",
        slide_sound = "sfx_player_wall_slide_metal_{01-02}",
        land_sound = "sfx_player_footstep_land_metal_{01-04}",
    }
end

function UpgradeDisplay:assign_upgrade(upgrade)
    self.product = upgrade
end

function UpgradeDisplay:update(dt)
    UpgradeDisplay.super.update(self, dt)

    self:update_focus(dt)

    if self.is_focused then
        self.animation_t = clamp(self.animation_t + dt*2, 0, 1)
        self.is_animation_exiting = false
    else
        self.animation_t = clamp(self.animation_t - dt*2, 0, 1)
        self.is_animation_exiting = true
    end
end

function UpgradeDisplay:has_new_target_player(players)
    if #self.target_players == 0 then
        return true
    end
    if #players > #self.target_players then
        return true
    end
    return false
end

function UpgradeDisplay:update_focus(dt)
    local in_range, players = self:is_player_in_range()
    local has_new_target = self:has_new_target_player(players)
    if not in_range then
        self.is_focused = false
        
    elseif (not self.has_player_in_range and in_range) or has_new_target then
        if not self.is_focused then
            self:on_focus()
        end
        self.is_focused = true
        for _, enemy in pairs(game.actors) do
            if self ~= enemy and enemy.name == "upgrade_display" then
                enemy:set_focused(false)
            end
        end
    end

    self.z = ternary(self.is_focused, -10, 0)
    
    self.has_player_in_range = in_range 
    self.target_players = players
end

function UpgradeDisplay:set_focused(value)
    self.is_focused = value
end

function UpgradeDisplay:on_focus()
    self:play_sound("sfx_upgrades_general_hover")
end

function UpgradeDisplay:is_player_in_range()
    local found = false
    local players = {}
	for _, ply in pairs(game.players) do
		local dx = math.abs(self.mid_x - ply.mid_x)
		local dy = math.abs(self.mid_y - ply.mid_y)
		if (dx <= self.player_detection_range_x) and (dy <= self.player_detection_range_y) then
            found = true
            table.insert(players, ply)
		end
	end
    return found, players
end

function UpgradeDisplay:draw()
    if self.product then
        self.product:draw(self.mid_x, self.mid_y)
    end
	UpgradeDisplay.super.draw(self)
    
    self:draw_product()
end

function UpgradeDisplay:on_death(damager, reason)
    game:screenshake(5)
    Particles:image(self.mid_x, self.mid_y, 40, images.glass_shard, self.h)

    if (damager and damager.name == "bullet") or (reason == "stomped") then
        self:apply()
    end
end

function UpgradeDisplay:apply()
    if self.product then
        self:play_sound(self.product.activate_sound)

        game:apply_upgrade(self.product)
        game.level:on_upgrade_display_killed(self)
        
        Particles:collected_upgrade(self.mid_x, self.mid_y, self.product.sprite, self.product.color)
    end
end

function UpgradeDisplay:draw_product()
    if self.product then
        local x = self.mid_x
        local y = self.mid_y - 64
        local s = ease_out_cubic(clamp(self.animation_t, 0, 1))
        
        love.graphics.setColor(self.product.palette[3])
        draw_centered(images.rays_big, x, y, 0.6*game.t, s*0.2)
        love.graphics.setColor(self.product.palette[2])
        draw_centered(images.rays_big, x, y, -0.8*game.t, s*0.18)
        love.graphics.setColor(self.product.palette[1])
        draw_centered(images.rays_big, x, y, game.t, s*0.15)
        love.graphics.setColor(COL_WHITE)
    
        self.product:draw(x, y, s)
        self:draw_text(x, y - 52, self.product:get_title(), self.product.color, 2)
        self:draw_text(x, y - 30, self.product:get_description())
    end
end

function UpgradeDisplay:draw_text(x, y, text, col, s)
    col = param(col, COL_WHITE)
    s = param(s, 1)

    local total_w = get_text_width(text) * s
    local text_x = x - total_w/2
    for i=1, #text do
        local t = (#text - i)/#text + self.animation_t*2 - 1
        local c = utf8.sub(text, i, i)
        local w = get_text_width(c) * s
        if t > 0 then
            local oy = ease_out_cubic(clamp(t, 0, 1)) * (-4) 
            print_outline(col, COL_BLACK_BLUE, c, text_x, y + oy, nil, nil, s)
        end
        text_x = text_x + w
    end
end

return UpgradeDisplay