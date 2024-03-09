-- This file is for functions, classes that are unused but I figure
-- I might have an use for later on. 

--
------------------------------------


local function replace_color_shader(col1_org, col1_new, col2_org, col2_new, col3_org, col3_new)
    local r_org1, g_org1, b_org1 = col1_org[1], col1_org[2], col1_org[3]
    local r_new1, g_new1, b_new1 = col1_new[1], col1_new[2], col1_new[3]
    
    local r_org2, g_org2, b_org2 = col2_org[1], col2_org[2], col2_org[3]
    local r_new2, g_new2, b_new2 = col2_new[1], col2_new[2], col2_new[3]
    
    local r_org3, g_org3, b_org3 = col3_org[1], col3_org[2], col3_org[3]
    local r_new3, g_new3, b_new3 = col3_new[1], col3_new[2], col3_new[3]
    local code = string.format([[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            number eps = 0.01;
            vec4 pixel = Texel(texture, texture_coords);
            if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else if (%f - eps <= pixel.r && pixel.r <= %f + eps  &&  %f - eps <= pixel.g && pixel.g <= %f + eps  &&  %f - eps <= pixel.b && pixel.b <= %f + eps){
                return vec4(%f, %f, %f, 1.0);
            } else {
                return pixel;
            }
        }
    ]], 
        r_org1, r_org1, g_org1, g_org1, b_org1, b_org1, r_new1, g_new1, b_new1,
        r_org2, r_org2, g_org2, g_org2, b_org2, b_org2, r_new2, g_new2, b_new2,
        r_org3, r_org3, g_org3, g_org3, b_org3, b_org3, r_new3, g_new3, b_new3
    )
    return love.graphics.newShader(code)
end

shaders.button_icon_to_red    = replace_color_shader(COL_LIGHT_GRAY, COL_LIGHT_RED,     COL_MID_GRAY, COL_DARK_RED,  COL_LIGHTEST_GRAY, COL_PINK)
shaders.button_icon_to_blue   = replace_color_shader(COL_LIGHT_GRAY, COL_MID_BLUE,      COL_MID_GRAY, COL_DARK_BLUE, COL_LIGHTEST_GRAY, COL_LIGHT_BLUE)
shaders.button_icon_to_yellow = replace_color_shader(COL_LIGHT_GRAY, COL_YELLOW_ORANGE, COL_MID_GRAY, COL_ORANGE,    COL_LIGHTEST_GRAY, COL_LIGHT_YELLOW)
shaders.button_icon_to_def = replace_color_shader(COL_LIGHT_GRAY, COL_LIGHT_GRAY, COL_MID_GRAY, COL_MID_GRAY,    COL_LIGHTEST_GRAY, COL_LIGHTEST_GRAY)

------------------------------------


--

	-- Elevator swing  >> in Game:update_main_game
	if love.math.random(0,10) == 0 then
		self.elev_vx = random_neighbor(50)
		self.elev_vy = random_range(0, 50)
	end
	self.elev_vx = self.elev_vx * 0.9
	self.elev_vy = self.elev_vy * 0.9
	self.elev_x = self.elev_x + self.elev_vx*dt
	self.elev_y = self.elev_y + self.elev_vy*dt
	self.elev_x = self.elev_x * 0.9
	self.elev_y = self.elev_y * 0.9


-- Player mine and cursor
function Player:update_cursor(dt)
	local old_cu_x = self.cu_x
	local old_cu_y = self.cu_y

	local tx = floor(self.mid_x / BLOCK_WIDTH) 
	local ty = floor(self.mid_y / BLOCK_WIDTH) 
	local dx, dy = 0, 0

	-- Target up and down 
	local btn_up = self:button_down("up")
	local btn_down = self:button_down("down")
	if btn_up or btn_down then
		dx = 0
		if btn_up then    dy = -1    end
		if btn_down then  dy = 1     end
	else
		-- By default, target sideways
		dx = self.dir_x
	end

	-- Update target position
	self.cu_x = tx + dx
	self.cu_y = ty + dy

	-- Update target tile
	local target_tile = game.map:get_tile(self.cu_x, self.cu_y)
	self.cu_target = nil
	if target_tile and target_tile.is_solid then
		self.cu_target = target_tile
	end
	
	-- If changed cursor pos, reset cursor
	if (old_cu_x ~= self.cu_x) or (old_cu_y ~= self.cu_y) then
		self.mine_timer = 0
	end
end

function Player:mine(dt)
	if not self.cu_target then   return    end
	
	if self:button_down("shoot") then
		self.mine_timer = self.mine_timer + dt

		if self.mine_timer > self.cu_target.mine_time then
			local drop = self.cu_target.drop
			game.map:set_tile(self.cu_x, self.cu_y, 0)
			--game.inventory:add_item(drop)
		end
	else
		self.mine_timer = 0
	end
end

------------------------------------

-- Elevator speed depends on number of enemies
-- In Game:progress_elevator
local enemies_killed = max(self.cur_wave_max_enemy - self.enemy_count, 0)
local ratio_killed = clamp(enemies_killed / self.cur_wave_max_enemy, 0, 1)
local speed = self.max_elev_speed * ratio_killed
self.elevator_speed = speed

-- Terraria-like world generation
for ix=0, map_w-1 do
	-- Big hill general shape
	local by1 = noise(seed, ix / 7)
	by1 = by1 * 4

	-- Small bumps and details
	local by2 = noise(seed, ix / 3)
	by2 = by2 * 1

	local by = map_mid_h + by1 + by2
	by = floor(by)
	print(concat("by ", by))

	for iy = by, map_h-1 do
		map:set_tile(ix, iy, 1)
	end
end


function Player:is_pressing_opposite_to_wall()
	-- Returns whether the player is near a wall AND is pressing a button
	-- corresponding to the opposite direction to that wall
	-- FIXME: there's a lot of repetition, find a way to fix this?
	local null_filter = function()
		return "cross"
	end
	Collision:move(self.wall_collision_box, self.x, self.y, null_filter)
	
	-- Check for left wall
	local nx = self.x - self.wall_jump_margin 
	local x,y, cols, len = Collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == 1 and self:button_down("right") then
			print("WOW", love.math.random(10,100))
			return true, 1
		end
	end

	-- Check for right wall
	local nx = self.x + self.wall_jump_margin 
	local x,y, cols, len = Collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == -1 and self:button_down("left")then
			return true, -1
		end
	end

	return false, nil
end