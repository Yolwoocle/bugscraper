local a = {
	off = {
        enter = function(state)
            game.camera:set_position(0, 0)
            game.camera:set_target_offset(0, 0)

            self.is_hole_stencil_enabled = false
            self.new_wave_progress = 0.0
        end,
		update = function(state, dt)
			self.is_hole_stencil_enabled = false
		end
    },
	wait = {
		update = function(state, dt)
			if self.hole_stencil_start_timer:update(dt) then
				return "grow"
			end
		end
    }, 
	grow = {
        enter = function(state)
            self.is_hole_stencil_enabled = true
        end,
		update = function(state, dt)
			self:update_hole_stencil(dt)
			
			if self.hole_stencil_radius >= CANVAS_WIDTH*0.5 then
				return "on"
			end
		end
    },
	on = {
        enter = function(state)
            self.world_generator:generate_cafeteria()
            self:assign_cafeteria_upgrades()
            
            game.camera:set_x_locked(false)
            game.camera:set_y_locked(true)
        end,
		update = function(state, dt)
			self:update_hole_stencil(dt)
            
			if self:can_exit_cafeteria() then
				return "shrink"
			end
		end
    },
    shrink = {
        enter = function(state)
            game:kill_all_active_enemies()
            self:end_cafeteria()
            self.new_wave_progress = math.huge
            self.force_next_wave_flag = true
            self.do_not_spawn_enemies_on_next_wave_flag = true
            self:new_wave_buffer_enemies()
        end,
		update = function(state, dt)
			self:update_hole_stencil(dt)
			if self.hole_stencil_radius <= 0 then
				return "off"
			end
		end
    }
}