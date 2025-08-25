require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"

local utf8 = require "utf8"

local PlayerTrigger = Prop:inherit()

function PlayerTrigger:init(x, y, w, h, trigger_func, params)
    params = params or {}
    PlayerTrigger.super.init(self, x, y, images.empty, w, h)
    self.name = "cutscene_trigger"
    
    self.gravity = 0
    self.loot = {}

	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.trigger_func = trigger_func
    self.min_player_trigger = param(params.min_player_trigger, 0) -- 0 = all players need to join 
    self.max_triggers = param(params.triggers, 1)
    self.condition_func = param(params.condition_func, function() return true end)
    self.triggers = self.max_triggers

    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false

    self.rect = Rect:new(self.x, self.y, self.w, self.h)
end

function PlayerTrigger:update(dt)
    PlayerTrigger.super.update(self, dt)

    self.rect = Rect:new(self.x, self.y, self.x+self.w, self.y+self.h)

    local n = 0
    for _, p in pairs(game.players) do
        if self.rect:rectangle_intersection(Rect:new(p.x, p.y, p.x+p.w, p.y+p.h)) then
            n = n + 1
        end
    end

    local cond_all = (self.min_player_trigger == 0 and n == game:get_number_of_alive_players())
    local cond_min = (self.min_player_trigger > 0 and n >= self.min_player_trigger)
    local cond_extra = self.condition_func()
    if (n > 0) and (cond_all or cond_min) and cond_extra then
        self:trigger()
    end
end

function PlayerTrigger:trigger()
    if self.triggers <= 0 then
        return
    end
    self.triggers = self.triggers - 1
    self.trigger_func(self)
end
function PlayerTrigger:draw()
    PlayerTrigger.super.draw(self)
end

return PlayerTrigger