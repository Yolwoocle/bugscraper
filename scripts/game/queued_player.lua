require "scripts.util"
local Class = require "scripts.meta.class"

local QueuedPlayer = Class:inherit()

function QueuedPlayer:init(player_n, input_profile_id, joystick)
    self.t = 0
    self.player_n = player_n
    self.input_profile_id = input_profile_id
    self.joystick = joystick

	self.is_removed = false
    
    self.x = nil
    self.y = nil
end

function QueuedPlayer:update(dt, queued_players)
	
end

function QueuedPlayer:remove()
    self.is_removed = true
end

return QueuedPlayer