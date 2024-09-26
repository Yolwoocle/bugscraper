require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"

local Centipede = Enemy:inherit()
	
function Centipede:init(x, y, length, parent)
    length = length or 10

    self:init_enemy(x,y, images.stink_bug_1, 10, 10)
    self.name = "centipede"
    self.is_flying = true
    self.follow_player = false
    self.life = 10
    self.is_pushable = true
    self.self_knockback_mult = 0.1

    self.is_stompable = false

    --self.speed_y = 0--self.speed * 0.5
    self.centipede_spacing = 16
    self.centipede_spring_force = 2

    self.centipede_length = length
    self.centipede_parent = parent
    if length == 0 then 
        self:init_centipede_head()
    else
        self:init_centipede_body()
    end
    
    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.direction = random_range(0, pi2)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.05
    self.anim_frames = {images.stink_bug_1, images.stink_bug_1}
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    self.sound_death = "stink_bug_death"
    self.sound_stomp = "stink_bug_death"
end

function Centipede:init_centipede_head()
    self.centipede_type = "head"
end

function Centipede:init_centipede_body()
    self.centipede_type = "body"
    
    local child = Centipede:new(self.x, self.y, self.centipede_length-1, self)
    game:new_actor(child)
    self.centipede_child = child
end

function Centipede:update(dt)
    self:update_enemy(dt)

    if self.centipede_child and self.centipede_child.is_dead then
        self.centipede_child = nil
        self.centipede_type = "head"
    end
    if self.centipede_parent and self.centipede_parent.is_dead then
        self.centipede_parent = nil
    end

    if self.centipede_type == "body" then
        if self.centipede_child then
            local ang = math.atan2(self.centipede_child.y - self.y, self.centipede_child.x - self.x)
            self.direction = ang--move_toward_angle(self.direction, , 1)
            
            self:follow_direction(dt*20)           
        end
    else
        local target = self:get_nearest_player()
        local a
        if target then
            a = get_angle_between_actors(self, target)
        else
            a = self.direction + random_sample({-1, 1})
        end
        self.direction = move_toward_angle(self.direction, a, dt * 3)
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
        line_color(COL_RED, self.x, self.y, self.centipede_parent.x, self.centipede_parent.y)
    end
    -- if self.debug_ang then
    --     line_color(COL_YELLOW, self.x, self.y, self.x + 12*math.cos(self.direction), self.y + 12*math.sin(self.direction))
    -- end
end

function Centipede:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
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