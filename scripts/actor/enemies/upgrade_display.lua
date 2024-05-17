require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"

local utf8 = require "utf8"

local UpgradeDisplay = Prop:inherit()

function UpgradeDisplay:init(x, y)
    self:init_prop(x, y, images.upgrade_jar, 16, 16)
    self.name = "upgrade_display"
    
    self.product = nil
    -- self:select_random_product()
    self.is_focused = false
    
    self.life = 10
    self.loot = {}

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false

    self.player_detection_range_x = 26
    self.player_detection_range_y = 64
    self.target_player = nil
    
	self.sound_damage = "glass_fracture"
	self.sound_death = "glass_break_weak"

    self.animation_t = 0
    self.is_animation_exiting = false
    self.letters = {}
end

function UpgradeDisplay:assign_upgrade(upgrade)
    self.product = upgrade
end

function UpgradeDisplay:update(dt)
    self:update_prop(dt)

    self.is_focused, self.target_player = self:is_player_in_range()

    if self.is_focused then
        self.animation_t = clamp(self.animation_t + dt*2, 0, 1)
        self.is_animation_exiting = false
    else
        self.animation_t = clamp(self.animation_t - dt*2, 0, 1)
        self.is_animation_exiting = true
    end
end

function UpgradeDisplay:is_player_in_range()
	for _, ply in pairs(game.players) do
		local dx = math.abs(self.mid_x - ply.mid_x)
		local dy = math.abs(self.mid_y - ply.mid_y)
		if (dx <= self.player_detection_range_x) and (dy <= self.player_detection_range_y) then
            return true, ply
		end
	end
    return false, nil
end

function UpgradeDisplay:draw()
    if self.product then
        self.product:draw(self.mid_x, self.mid_y)
    end
	self:draw_prop()
    
    self:draw_product()
end

function UpgradeDisplay:on_death(damager, reason)
    game:screenshake(5)
    Particles:image(self.mid_x, self.mid_y, 10, images.glass_shard, self.h)
    if damager and damager.name == "bullet" then
        self:apply()
    end
end

function UpgradeDisplay:apply()
    if self.product then
        game:apply_upgrade(self.product)
        game.level:on_upgrade_display_killed(self)
    end
end

function UpgradeDisplay:draw_product()
    if self.product then
        local x = self.mid_x
        local y = self.mid_y - 64
        local s = ease_out_cubic(clamp(self.animation_t, 0, 1))
        
        love.graphics.setColor(self.product.color)
        draw_centered(images.rays, x, y, game.t, s*0.4, s*0.4)
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