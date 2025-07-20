require "scripts.util"
local Class = require "scripts.meta.class"

local ActorManager = Class:inherit()

function ActorManager:init(game, actors)
    self.game = game
    self.actors = actors

	self.actor_limit = 150
    
    self.sort_actors_flag = false
    self.apply_bounds_clamping = true
end

function ActorManager:update(dt)
    if self.sort_actors_flag then
		table.sort(self.actors, function(a, b)
			if a.z == b.z then
				return a.creation_index > b.creation_index
			end
			return a.z > b.z
		end)
		self.sort_actors_flag = false
	end

	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]

		if not actor.is_removed and actor.is_active then
			actor:update(dt)
			if actor.is_affected_by_bounds and self.apply_bounds_clamping then
				actor:clamp_to_bounds(self.game.level.cabin_inner_rect)
			end

			if not self.game.level.kill_zone:is_point_in_inclusive(actor.mid_x, actor.mid_y) then
				actor:kill()
			end
		end

		if actor.is_removed then
			actor:final_remove()
			table.remove(self.actors, i)
		end
	end
end

function ActorManager:new_actor(actor)
    if not actor then
		return
	end
	if #self.actors >= self.actor_limit then
		actor:remove()
		actor:final_remove()
		return actor
	end
    
	self.sort_actors_flag = true
	table.insert(self.actors, actor)

	game:on_new_actor(actor)

	return actor
end

function ActorManager:get_enemy_count()
    local enemy_count = 0
	for _, actor in pairs(self.actors) do
		if actor.is_active and actor.counts_as_enemy then
			enemy_count = enemy_count + 1
		end
	end
	return enemy_count
end


function ActorManager:remove_all_active_enemies()
	for _, actor in pairs(self.actors) do
		if actor.is_active and actor.counts_as_enemy then
			actor:remove()
		end
	end
end

function ActorManager:kill_all_active_enemies()
	for _, actor in pairs(self.actors) do
		if actor.is_active and actor.counts_as_enemy then
			actor:kill()
		end
	end
end

function ActorManager:kill_all_enemies()
	for _, actor in pairs(self.actors) do
		if actor.counts_as_enemy then
			actor:kill()
		end
	end
end

function ActorManager:kill_actors_with_name(name)
	for _, actor in pairs(self.actors) do
		if actor.name == name then
			actor:kill()
		end
	end
end

return ActorManager