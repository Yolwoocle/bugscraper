require "scripts.util"
local Class = require "scripts.meta.class"
local Loot = require "scripts.actor.loot"
local upgrades = require "data.upgrades"
local enemies = require "data.enemies"
local utf8 = require "utf8"
local images = require "data.images"

local Debug = Class:inherit()

local col_a = {random_range(0, 1), random_range(0, 1), random_range(0, 1), 1}
local col_b = {random_range(0, 1), random_range(0, 1), random_range(0, 1), 1}

function Debug:init(game)
    self.game = game

    self.is_reading_for_f1_action = false
    self.debug_menu = false
    self.colview_mode = false
    self.info_view = false
    self.joystick_view = false
    self.bound_view = false
    self.view_fps = true
    
    self.instant_end = false
    self.layer_view = false
    self.input_view = false

    self.notification_message = ""
    self.notification_timer = 0.0

    local func_damage = function(n)
        return function()
            local p = self.game.players[tonumber(n)]
            if p ~= nil then
                p:do_damage(1)
                p.iframes = 0.0
            end
        end
    end 
    local func_heal = function(n)
        return function()
            local p = self.game.players[tonumber(n)]
            if p ~= nil then
                p:heal(1)
            end
        end
    end 
    self.actions = {
        ["f2"] = {"toggle collision view mode", function()
            self.colview_mode = not self.colview_mode
        end},
        ["f3"] = {"view more info", function()
            self.info_view = not self.info_view
        end},
        ["f4"] = {"view joystick info", function()
            self.joystick_view = not self.joystick_view
        end},
        ["f5"] = {"view input info", function()
            self.input_view = not self.input_view
        end},
        ["f6"] = {"toggle FPS", function()
            self.view_fps = not self.view_fps
        end},
        ["1"] = {"damage P1", func_damage(1)},
        ["2"] = {"damage P2", func_damage(2)},
        ["3"] = {"damage P3", func_damage(3)},
        ["4"] = {"damage P4", func_damage(4)},
        ["5"] = {"heal P1", func_heal(1)},
        ["6"] = {"heal P2", func_heal(2)},
        ["7"] = {"heal P3", func_heal(3)},
        ["8"] = {"heal P4", func_heal(4)},

        ["q"] = {"previous floor",function()
            self.game:set_floor(self.game:get_floor() - 1)
        end},

        ["w"] = {"next floor", function()
            self.game:set_floor(self.game:get_floor() + 1)
        end},
        ["p"] = {"upgrade", function()
            game:apply_upgrade(upgrades.UpgradeEspresso:new())
        end},
        ["t"] = {"particle", function()
            Particles:image(CANVAS_WIDTH/2, CANVAS_HEIGHT/2 + 50, 1, {
                images.bullet_vanish_1,
                images.bullet_vanish_2,
                images.bullet_vanish_3,
                images.bullet_vanish_4,
                images.bullet_vanish_5,
            }, 0, nil, 0, 0, {
                is_solid = false,
                rot = 0,
                vx1 = 0,
                vx2 = 0,
                vy1 = 0,
                vy2 = 0,
                vr1 = 0,
                vr2 = 0,
                life = 0.15,
                is_animated = true
            })
        end},
        ["s"] = {"spawn", function()
            local dung = enemies.SnailShelled:new(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
            game:new_actor(dung)
        end},
        ["r"] = {"start game", function()
            game:start_game()
        end},
        
        ["e"] = {"kill all enemies", function()
            for k,e in pairs(self.game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
        end},
        
        ["i"] = {"toggle instant end", function()
            self.instant_end = not self.instant_end
        end},
        
        ["y"] = {"toggle layer view", function()
            self.layer_view = not self.layer_view
        end},
        
        ["c"] = {"color lerp test", function()
            col_a = {random_range(0, 1), random_range(0, 1), random_range(0, 1), 1}
            col_b = {random_range(0, 1), random_range(0, 1), random_range(0, 1), 1}
        end},
        
        ["b"] = {"toggle cabin view", function()
            game.level.show_cabin = not game.level.show_cabin
        end},
        
        ["g"] = {"next gun for P1", function()
            local p = self.game.players[1]
            if p then
                p:next_gun()
            end
        end},
        ["l"] = {"spawn random loot", function()
            local loot, parms = random_weighted({
                {Loot.Life, 3, loot_type="life", value=1},
		        {Loot.Gun, 3, loot_type="gun"},
            })
            if not loot then return end
            
            local x, y = CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8
            local instance
            local vx = random_neighbor(300)
            local vy = random_range(-200, -500)
            local loot_type = parms.loot_type
            if loot_type == "ammo" or loot_type == "life" or loot_type == "gun" then
                instance = loot:new(x, y, parms.value, vx, vy)
            end 

            game:new_actor(instance)
        end},

        ["z"] = {"zoom -", function()
            self.game:set_zoom(self.game:get_zoom() - 0.1)
        end},
        ["x"] = {"zoom +", function()
            self.game:set_zoom(self.game:get_zoom() + 0.1)
        end},
        
        ["left"] = {"move camera left", function()
            local cam_x, cam_y = self.game:get_camera_position()
            self.game:set_camera_position(cam_x - 8, cam_y)
        end},
        ["right"] = {"move camera right", function()
            local cam_x, cam_y = self.game:get_camera_position()
            self.game:set_camera_position(cam_x + 8, cam_y)
        end},
        ["up"] = {"move camera up", function()
            local cam_x, cam_y = self.game:get_camera_position()
            self.game:set_camera_position(cam_x, cam_y - 8)
        end},
        ["down"] = {"move camera down", function()
            local cam_x, cam_y = self.game:get_camera_position()
            self.game:set_camera_position(cam_x, cam_y + 8)
        end},
    }

    self.action_keys = {}
    for k, v in pairs(self.actions) do
        table.insert(self.action_keys, k)
    end
    table.sort(self.action_keys)
end

function Debug:update(dt)
end

function Debug:debug_action(key, scancode, isrepeat)
	local action = self.actions[scancode]
    if action then
        action[2]()
        self:new_notification("Executed '"..tostring(action[1]).."'")
    else
        self:new_notification("Action not recognized")
    end
end

function Debug:new_notification(msg)
    game.notif = msg
    game.notif_timer = 2.0
end

function Debug:keypressed(key, scancode, isrepeat)
    if isrepeat then return end

    if scancode == "f1"then
        self.is_reading_for_f1_action = true
    else 
        if love.keyboard.isScancodeDown("f1") then
            self:debug_action(key, scancode, isrepeat)
            self.is_reading_for_f1_action = false
            return
        end
    end
end

function Debug:keyreleased(key, scancode, isrepeat)
    if scancode == "f1" and self.is_reading_for_f1_action then
        self.debug_menu = not self.debug_menu
        self.is_reading_for_f1_action = false
    end
end

function Debug:gamepadpressed(joystick, buttoncode)
end

function Debug:gamepadreleased(joystick, buttoncode)
end    

function Debug:gamepadaxis(joystick, axis, value)
end

------------------------------------------

function Debug:draw()
    if self.info_view then
        self:draw_info_view()
    end
    if self.debug_menu then
        self:draw_debug_menu()
    end
    if self.joystick_view then
        self:draw_joystick_view()
    end
    if self.input_view then
        self:draw_input_view()
    end

    if self.view_fps then
        local t = concat(love.timer.getFPS(), "FPS")
        print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t), 0)
    end
end

function Debug:draw_input_view()
    local spacing = 70
    local x = 0
    for i = 1, MAX_NUMBER_OF_PLAYERS do
        local u = Input:get_user(i)
        if u then
            self:draw_input_view_for(u, x)
            x = x + spacing
        end
    end
end

function Debug:draw_input_view_for(user, x)
    local actions = {
        "left",
        "right",
        "up",
        "down",
        "jump",
        "shoot",
        "pause",
        "ui_select",
        "ui_back",
        "ui_left",
        "ui_right",
        "ui_up",
        "ui_down",
        "ui_reset_keys",
        "split_keyboard",
        "leave_game",
        "debug",
    }
    for i, a in ipairs(actions) do
        print_outline(nil, nil, concat(a, ": ", user.action_states[a].state), x, 14*i)
    end
end

function Debug:draw_joystick_view()
    local spacing = 70
    local i = 0
    for _, joy in pairs(love.joystick.getJoysticks()) do
        self:draw_joystick_view_for(joy, i*spacing, 20, 1, 2)
        i = i + 1
        self:draw_joystick_view_for(joy, i*spacing, 20, 3, 4)
        i = i + 1
    end
end

function Debug:draw_joystick_view_for(joystick, x, y, axis_x, axis_y)
    local user_n = Input:get_joystick_user_n(joystick)
    local name = concat(utf8.sub(joystick:getName(), 1, 4), "...", utf8.sub(joystick:getName(), -4, -1))
	print_outline(COL_WHITE, COL_BLACK_BLUE, name, x+30, y+20)
	print_outline(COL_WHITE, COL_BLACK_BLUE, concat("(P", user_n, ")"), x+30, y+30)

	print_outline(ternary(Input:action_down(user_n, "left"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("left"), "✅", "❎"), x+30, y+60)
	print_outline(ternary(Input:action_down(user_n, "right"), COL_GREEN, COL_WHITE), COL_BLACK_BLUE, ternary(Input:action_down_any_player("right"), "✅", "❎"), x+70, y+60)
	print_outline(ternary(Input:action_down(user_n, "up"), COL_GREEN, COL_WHITE),    COL_BLACK_BLUE, ternary(Input:action_down_any_player("up"), "✅", "❎"), x+50, y+40)
	print_outline(ternary(Input:action_down(user_n, "down"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("down"), "✅", "❎"), x+50, y+80)
	
	local ox = x+60
	local oy = y+140
	local r = 30
	love.graphics.setColor(COL_GREEN)
    circle_color({0,0,0,0.5}, "fill", ox, oy, r)
    circle_color(COL_WHITE, "line", ox, oy, r)
	love.graphics.line(ox, oy-r, ox, oy+r)
	love.graphics.line(ox-r, oy, ox+r, oy)
	
	-- love.graphics.setColor(COL_GREEN)
	-- love.graphics.line(x-AXIS_DEADZONE*r, y-r, x-AXIS_DEADZONE*r, y+r)
	-- love.graphics.line(x+AXIS_DEADZONE*r, y-r, x+AXIS_DEADZONE*r, y+r)
	-- love.graphics.line(x-r, y-AXIS_DEADZONE*r, x+r, y-AXIS_DEADZONE*r)
	-- love.graphics.line(x-r, y+AXIS_DEADZONE*r, x+r, y+AXIS_DEADZONE*r)
	-- love.graphics.setColor(COL_WHITE)
    local deadzone = Options:get("axis_deadzone_p"..tostring(user_n)) or AXIS_DEADZONE

	love.graphics.setColor(COL_GREEN)
	love.graphics.circle("line", ox, oy, r*deadzone)
	for a = pi/8, pi2, pi/4 do
		local ax = math.cos(a)
		local ay = math.sin(a)
		love.graphics.line(ox + deadzone*ax*r, oy + deadzone*ay*r, ox + r*ax, oy + r*ay)
	end
	love.graphics.setColor(COL_WHITE)
	
	local function get_axis_angle(j, ax, ay) 
		return math.atan2(j:getAxis(ay), j:getAxis(ax))
	end
	local function get_axis_radius_sqr(j, ax, ay) 
		return distsqr(j:getAxis(ax), j:getAxis(ay))
	end
	
	local u = Input:get_user(user_n)
	if u ~= nil then
		local j = joystick
		circle_color(COL_RED, "fill", ox + r*j:getAxis(axis_x), oy + r*j:getAxis(axis_y), 2)
	
        local val_x = round(j:getAxis(axis_x), 3)
        local val_y = round(j:getAxis(axis_y), 3)
        local val_a = round(get_axis_angle(j, 1, 2), 3)
        local val_r = round(math.sqrt(get_axis_radius_sqr(j, 1, 2)), 3)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "x "..tostring(val_x), ox - 20, oy + 40)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "y "..tostring(val_y), ox - 20, oy + 50)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "a "..tostring(val_a), ox - 20, oy + 60)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "r "..tostring(val_r), ox - 20, oy + 70)
	end
end

function Debug:draw_debug_menu()
    local x = 0
    local y = 0
    local max_w = 0
    for i, button in pairs(self.action_keys) do
        local action = self.actions[button]
        local text = concat("[", button, "]: ", action[1])
        local w = get_text_width(text)
        if w > max_w then
            max_w = w
        end

        rect_color({0,0,0,0.5}, "fill", x, y, get_text_width(text), 10)
        print_outline(nil, nil, text, x, y)
        y = y + 12
        if y +12 >= CANVAS_HEIGHT then
            y = 0
            x = x + max_w
            max_w = 0
        end
    end
end

function Debug:draw_info_view()
	local players_str = "players: "
	for k, player in pairs(self.game.players) do
		players_str = concat(players_str, "{", k, ":", player.n, "}, ")
	end

	local users_str = "users: "	
	for k, player in pairs(Input.users) do
		users_str = concat(users_str, "{", k, ":", player.n, "}, ")
	end
	
	local joystick_user_str = "joysticks_to_users: "	
	for joy, user in pairs(Input.joystick_to_user_map) do
		joystick_user_str = concat(joystick_user_str, "{", string.sub(joy:getName(),1,4), "... ", ":", user.n, "}, ")
	end
	
	local joystick_str = "joysticks: "	
	for _, joy in pairs(love.joystick.getJoysticks()) do
		joystick_str = concat(joystick_str, "{", string.sub(joy:getName(),1,4), "...}, ")
	end
	
	local wave_resp_str = "waves_until_respawn "	
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		wave_resp_str = concat(wave_resp_str, "{", i, ":", self.game.waves_until_respawn[i], "}, ")
	end

	
	-- Print debug info
	local txt_h = get_text_height(" ")
	local txts = {
		concat("FPS: ",love.timer.getFPS(), " / frmRpeat: ",self.game.frame_repeat, " / frame: ",frame),
		concat("LÖVE version: ", string.format("%d.%d.%d - %s", love.getVersion())),
		concat("game state: ", game.game_state),
		concat("level.level_speed: ", game.level.level_speed),
		concat("cam pos:  ", concatsep({game.camera:get_position()})),
		concat("cam tpos: ", concatsep({game.camera:get_target_position()})),
		concat("n° of active audio sources: ", love.audio.getActiveSourceCount()),
		concat("n° of actors: ", #self.game.actors, " / ", self.game.actor_limit),
		concat("n° of enemies: ", self.game:get_enemy_count()),
		concat("n° collision items: ", Collision.world:countItems()),
		concat("windowed_w: ", Options:get("windowed_width")),
		concat("windowed_h: ", Options:get("windowed_height")),
		concat("real_wave_n ", self.game.debug2),
		concat("number_of_alive_players ", self.game:get_number_of_alive_players()),
		concat("menu_stack ", #self.game.menu_manager.menu_stack),
		players_str,
		users_str,
		joystick_user_str,
		joystick_str,
		wave_resp_str, 
		"",
	}

	for i=1, #txts do  print_label(txts[i], 0, 0+txt_h*(i-1)) end

	for _, e in pairs(self.game.actors) do
		love.graphics.circle("fill", e.x, e.y, 1)
	end

	self.game.level.world_generator:draw()
	draw_log()
    
    local w = 255
    -- local col_a = color(0x0c00b8)
    -- local col_b = color(0xb82609)
    -- local col_a = color(0xe43b44)
    -- local col_b = color(0xfee761c)
    -- rect_color(col_a, "fill", 0, 25, w/2, 25)
    -- rect_color(col_b, "fill", w/2, 25, w/2, 25)
    -- for ix=0, w do
    --     rect_color(lerp_color(col_a, col_b, ix/w), "fill", ix, 50, 1, 25)
    --     rect_color(lerp_color_radial(col_a, col_b, ix/w), "fill", ix, 75, 1, 25)
    --     rect_color(move_toward_color(col_a, col_b, ix/w), "fill", ix, 100, 1, 25)
    --     rect_color(move_toward_color_radial(col_a, col_b, ix/w), "fill", ix, 120, 1, 25)
    -- end
end

function Debug:draw_colview()
    game.camera:apply_transform()
    
	local items, len = Collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = Collision.world:getRect(it)
		rect_color({0,1,0,.2},"fill", x, y, w, h)
		rect_color({0,1,0,.5},"line", x, y, w, h)
	end

    game.camera:reset_transform()
end

function Debug:draw_layers()
    local x = 0
	local y = 0
	for i=1, #self.game.layers do
		rect_color({1,1,1,0.8}, "fill", x, y, CANVAS_WIDTH, CANVAS_HEIGHT)
		love.graphics.draw(self.game.layers[i].canvas, x, y)
		print_outline(nil, nil, concat(i, " ", LAYER_NAMES[i]), x, y, nil, nil, 2)
		rect_color(COL_RED, "line", x, y, CANVAS_WIDTH, CANVAS_HEIGHT)

		x = x + (CANVAS_WIDTH)
		if x + CANVAS_WIDTH > SCREEN_WIDTH then
			x = 0
			y = y + CANVAS_HEIGHT
		end
	end
end

return Debug