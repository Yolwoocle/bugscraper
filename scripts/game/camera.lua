require "scripts.util"
local Class = require "scripts.meta.class"

local Camera = Class:inherit()

function Camera:init()
    self.x = 0.0
    self.y = 0.0
    self.ox = 0.0
    self.oy = 0.0
    self.zoom = 1.0
    self.rot = 0.0
    
    self.w = CANVAS_WIDTH
    self.h = CANVAS_HEIGHT

    self.min_x, self.max_x = 0, CANVAS_WIDTH
    self.min_y, self.max_y = 0, CANVAS_HEIGHT
    self.target_x = 0.0
    self.target_y = 0.0
    self.target_ox = 0.0
    self.target_oy = 0.0

    self.follow_speed = 5
    self.max_speed = 300

    self.screenshake_q = 0.0
	self.screenshake_speed = 20

    self.is_x_locked = true
    self.is_y_locked = true

    self:reset()
end

function Camera:update(dt)
	if not Options:get("screenshake_on") then self.ox, self.oy = 0,0 end
    
    self:follow_players(dt)  
    self:clamp_camera_position(dt)
    self:follow_target(dt)

    -- self:update_screenshake(dt)
end

function Camera:follow_target(dt)
    local tx = clamp(self.target_x + self.target_ox, self.min_x, self.max_x)
    local ty = clamp(self.target_y + self.target_oy, self.min_y, self.max_y)
    local speed = math.min(dist(self.x, self.y, tx, ty) * self.follow_speed, self.max_speed)
    self.x = move_toward(self.x, tx, speed * dt)
    self.y = move_toward(self.y, ty, speed * dt)
end

function Camera:clamp_camera_position(dt)
    self.x = clamp(self.x, self.min_x, self.max_x)
    self.y = clamp(self.y, self.min_y, self.max_y)
    self.target_x = clamp(self.target_x, self.min_x, self.max_x)
    self.target_y = clamp(self.target_y, self.min_y, self.max_y)
end

function Camera:follow_players(dt)
    if Input:get_number_of_users() == 0 or (self.is_x_locked and self.is_y_locked) then 
        return
    end 

    local total_n = game:get_number_of_alive_players()
    local mid_x = 0
    local mid_y = 0
    for i = 1, MAX_NUMBER_OF_PLAYERS do 
        local player = game.players[i]
        if player then
            mid_x = mid_x + (player.x / total_n)
            mid_y = mid_y + (player.y / total_n)
        end
    end

    if not self.is_x_locked then
        self.target_x = mid_x - self.w/2
    end
    if not self.is_y_locked then
        self.target_y = mid_y - self.h/2
    end
end

function Camera:update_screenshake(dt)
	-- Screenshake
	self.screenshake_q = max(0, self.screenshake_q - self.screenshake_speed * dt)

	local base_mult = Options:get("screenshake")
    local multiplayer_mult = clamp(1 / Input:get_number_of_users(), 0, 1)
	local q = self.screenshake_q * base_mult * multiplayer_mult
	local ox, oy = random_neighbor(q), random_neighbor(q)

	-- if abs(ox) >= 0.2 then   ox = sign(ox) * max(abs(ox), 1)   end 
	-- if abs(oy) >= 0.2 then   oy = sign(oy) * max(abs(oy), 1)   end 

	self.ox = ox
	self.oy = oy
end

function Camera:screenshake(q)
	if not Options:get('screenshake_on') then  return   end
    self.screenshake_q = math.max(self.screenshake_q, q)
end

function Camera:get_x_locked()
    return self.is_x_locked
end

function Camera:set_x_locked(val)
    self.is_x_locked = val
end

function Camera:get_y_locked()
    return self.is_y_locked
end

function Camera:set_y_locked(val)
    self.is_y_locked = val
end

function Camera:get_real_position()
    return self.x + self.ox, self.y + self.oy
end

function Camera:get_target_position()
    return self.target_x, self.target_y
end

function Camera:set_target_position(x, y)
    self.target_x = x
    self.target_y = y
end

function Camera:get_target_offset()
    return self.target_ox, self.target_oy
end

function Camera:set_target_offset(x, y)
    self.target_ox = x
    self.target_oy = y
end

function Camera:get_position()
    return self.x, self.y
end

function Camera:set_position(x, y)
    self:set_target_position(x, y)
    self.x = x
    self.y = y
end

function Camera:get_zoom()
    return self.zoom
end

function Camera:set_zoom(zoom)
    self.zoom = zoom
end

function Camera:reset()
    self.x = 0
    self.y = 0

    self.ox = 0
    self.oy = 0
    self.target_ox = 0
    self.target_oy = 0

    self.rot = 0
    self.zoom = 1
end

function Camera:reset_transform()
    love.graphics.origin()
	love.graphics.scale(1)
end

function Camera:apply_transform()
    self:reset_transform()

    local x, y = self:get_real_position()
	love.graphics.translate(math.floor(-x), math.floor(-y))
    love.graphics.rotate(self.rot)
	love.graphics.scale(self.zoom)
end

return Camera