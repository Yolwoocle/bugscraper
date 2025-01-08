require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local Centipede = Enemy:inherit()

function Centipede:init(x, y, length, parent, params)
    params = params or {
        center_x = x,
        center_y = y,
        angle = 0,
    }
    length = length or 30
    if params.center_x and params.angle then
        x = params.center_x + math.cos(params.angle) * (1 + params.angle) * 4
    end
    if params.center_y and params.angle then
        y = params.center_y + math.sin(params.angle) * (1 + params.angle) * 4
    end
    self.spawn_center_x = params.center_x
    self.spawn_center_y = params.center_y
    self.spawn_angle = params.angle

    Centipede.super.init(self, x, y, images.centipede_body, 10, 10)
    self.name = "centipede"
    self.spr = AnimatedSprite:new({
        head = {images.centipede_head, 1},
        body = {images.centipede_body, 1},
    })
    self.is_flying = true
    self.follow_player = false
    self.life = 7
    self.is_pushable = false
    self.self_knockback_mult = 0.1

    self.is_stompable = false
    self.score = 5

    --self.speed_y = 0--self.speed * 0.5
    self.centipede_spacing = 12
    self.centipede_spring_force = 2

    self.centipede_length = length
    self.centipede_parent = parent
    self.total_centipede_length = parent and parent.total_centipede_length or length
    if length == 0 then
        self:init_centipede_head()
    else
        self:init_centipede_body()
    end

    self:update_speed()
    self.direction = random_range(0, pi2)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.sound_death = "stink_bug_death"
    self.sound_stomp = "stink_bug_death"
end

function Centipede:init_centipede_head()
    self.centipede_type = "head"
    self.spr:set_animation("head")
end

function Centipede:init_centipede_body()
    self.centipede_type = "body"
    self.spr:set_animation("body")

    local child = Centipede:new(self.x, self.y, self.centipede_length - 1, self, {
        center_x = self.spawn_center_x,
        center_y = self.spawn_center_y,
        angle = (self.spawn_angle or 0) + 0.6,
    })
    game:new_actor(child)
    self.centipede_child = child

    table.insert(self.spawned_actors, self.centipede_child)
end

function Centipede:become_head(dt)
    self.centipede_child = nil
    self.centipede_type = "head"
    self.spr:set_animation("head")
    
    local cursor = self
    local size = 0
    local total_size = self.total_centipede_length - self.centipede_length
    while cursor do
        cursor.centipede_length = size
        cursor.total_centipede_length = total_size
        cursor = cursor.centipede_parent
        size = size + 1
    end
end

function Centipede:update_child_total_length(total_length)
    local cursor = self
    while cursor do
        cursor.total_centipede_length = total_length
        cursor = cursor.centipede_child
    end
end

function Centipede:update_speed()
    self.speed = 10 + (20 - clamp(0, self.total_centipede_length, 20))
    self.speed_x = self.speed
    self.speed_y = self.speed
end


function Centipede:update(dt)
    self:update_speed()
    self:update_enemy(dt)

    if self.centipede_child and self.centipede_child.is_dead then
        self:become_head()
    end
    if self.centipede_parent and self.centipede_parent.is_dead then
        self.centipede_parent = nil
        self:update_child_total_length(self.centipede_length)
    end

    if self.centipede_type == "body" then
        if self.centipede_child then
            local ang = math.atan2(self.centipede_child.y - self.y, self.centipede_child.x - self.x)
            self.direction = ang --move_toward_angle(self.direction, , 1)

            self:follow_direction(dt * 20)
        end
    else
        local target = self:get_nearest_player()
        local a
        if target then
            a = get_angle_between_actors(self, target)
        else
            a = self.direction + random_sample({ -1, 1 })
        end
        self.direction = move_toward_angle(self.direction, a, dt)
        self:follow_direction(dt)
    end

    if self.centipede_child then
        self:spring_join(self.centipede_child)
    end
    if self.centipede_parent then
        self:spring_join(self.centipede_parent)
    end


    self.spr:set_rotation(self.direction)
end

function Centipede:spring_join(actor)
    local d = actor_mid_distance(self, actor)
    local force = (self.centipede_spacing - d) * self.centipede_spring_force
    self:apply_force_from(force, actor)
end

function Centipede:follow_direction(dt)
    self.vx = self.vx + math.cos(self.direction) * self.speed
    self.vy = self.vy + math.sin(self.direction) * self.speed
end

function Centipede:draw()
    self:draw_enemy()

    if self.centipede_parent then
        -- line_color(COL_RED, self.mid_x, self.mid_y, self.centipede_parent.mid_x, self.centipede_parent.mid_y)
    end
    -- if self.debug_ang then
    --     line_color(COL_YELLOW, self.x, self.y, self.x + 12*math.cos(self.direction), self.y + 12*math.sin(self.direction))
    -- end
end

function Centipede:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x,
            col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function Centipede:on_death()
    -- for i = 1, random_range_int(3, 5) do
    --     local spawn_x = clamp(self.mid_x - 10, game.level.cabin_rect.ax, game.level.cabin_rect.bx - 20)
    --     local spawn_y = clamp(self.mid_y - 10, game.level.cabin_rect.ay, game.level.cabin_rect.by - 20)
    --     local cloud = PoisonCloud:new(spawn_x, spawn_y)

    --     local d = random_range(0, pi2)
    --     local r = random_range(0, 200)
    --     cloud.vx = math.cos(d) * r
    --     cloud.vy = math.sin(d) * r
    --     game:new_actor(cloud)
    -- end
end

return Centipede
