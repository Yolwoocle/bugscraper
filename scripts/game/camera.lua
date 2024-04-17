require "scripts.util"
local Class = require "scripts.meta.class"

local Camera = Class:inherit()

function Camera:init()
    self.x = 0.0
    self.y = 0.0
    self.ox = 0.0
    self.oy = 0.0
    self.zoom = 1.0

    self.screenshake_q = 0.0
	self.screenshake_speed = 20

    self:reset()
end

function Camera:update(dt)
	if not Options:get("screenshake_on") then self.ox, self.oy = 0,0 end

    self:apply_screenshake(dt)
end

function Camera:apply_screenshake(dt)
	-- Screenshake
	self.screenshake_q = max(0, self.screenshake_q - self.screenshake_speed * dt)

	local multiplier = Options:get("screenshake")
	local q = self.screenshake_q * multiplier
	local ox, oy = random_neighbor(q), random_neighbor(q)

	if abs(ox) >= 0.2 then   ox = sign(ox) * max(abs(ox), 1)   end 
	if abs(oy) >= 0.2 then   oy = sign(oy) * max(abs(oy), 1)   end 

	self.ox = ox
	self.oy = oy
end

function Camera:screenshake(q)
	if not Options:get('screenshake_on') then  return   end
    self.screenshake_q = math.max(self.screenshake_q, q)
end

function Camera:get_real_position()
    return self.x + self.ox, self.y + self.oy
end

function Camera:get_position()
    return self.x, self.y
end

function Camera:set_position(x, y)
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
    self.ox = 0
    self.y = 0
    self.oy = 0
    self.zoom = 1
end

function Camera:apply_transform()
    local x, y = self:get_real_position()

    love.graphics.origin()
	love.graphics.scale(1)
	love.graphics.translate(-x, -y)
	love.graphics.scale(self.zoom)
end

return Camera