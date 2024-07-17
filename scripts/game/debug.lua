require "scripts.util"
local Class = require "scripts.meta.class"
local Loot = require "scripts.actor.loot"
local upgrades = require "data.upgrades"
local enemies = require "data.enemies"
local utf8 = require "utf8"
local images = require "data.images"
local debug_draw_waves = require "scripts.debug.draw_waves"
local Segment = require "scripts.math.segment"
local Rect = require "scripts.math.rect"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D  = require "scripts.graphics.3d.object_3d"
local truncated_ico = require "data.models.truncated_ico"
local honeycomb_panel = require "data.models.honeycomb_panel"
local backgrounds     = require "data.backgrounds"
local StateMachine = require "scripts.state_machine"
local vec3         = require "lib.batteries.vec3"
local Timer = require "scripts.timer"

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
    self.view_fps = false
    
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

    self.removeme_i = 0
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
        ["f6"] = {"toggle UI", function()
            self.game.game_ui.is_visible = not self.game.game_ui.is_visible
            self.game.is_game_ui_visible = not self.game.is_game_ui_visible
        end},
        ["f7"] = {"toggle speedup", function()
            _G_t = 0
            _G_do_fixed_framerate = not _G_do_fixed_framerate
        end},
        ["h"] = {"toggle help menu", function()
            self.debug_menu = not self.debug_menu
        end},
        ["f"] = {"toggle FPS", function()
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
        ["a"] = {"-10 floors",function()
            self.game:set_floor(self.game:get_floor() - 10)
        end},
        ["s"] = {"+10 floors", function()
            self.game:set_floor(self.game:get_floor() + 10)
        end},

        ["u"] = {"upgrade", function()
            game:apply_upgrade(upgrades.UpgradeSoda:new())
        end},
        ["t"] = {"particle", function()
			local cabin_rect = game.level.cabin_rect
        
            local cabin_rect = game.level.cabin_rect
			Particles:falling_grid(cabin_rect.ax +   16,      cabin_rect.ay + 6*16 + 0*8)
			Particles:falling_grid(cabin_rect.bx - 7*16, cabin_rect.ay + 6*16 + 0*8)

            -- Particles:word(CANVAS_WIDTH/2, CANVAS_HEIGHT/2+100, "HELLO!!", COL_WHITE, 1)
            for i = 1, 50 do
                -- Particles:spark(CANVAS_WIDTH/2, CANVAS_HEIGHT/2 + 50)
            end
        end},
        ["d"] = {"spawn", function()
            -- local arc = enemies.ElectricArc:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.9)
            -- print_debug("nil?", game.players[1] == nil)
            -- arc:set_arc_target(game.players[1])
            -- game:new_actor(arc)

            -- local arc = enemies.ElectricRays:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.5)
            -- local arc = enemies.ShovelBee:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.5);
            -- local arc = enemies.FlyBuddy:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.5);
            -- game:new_actor(arc)

            -- for _, player in pairs(game.players) do
			-- 	local arc = enemies.ElectricArc:new(CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5)
			-- 	arc:set_arc_target(player)
			-- 	arc.arc_damage = 2.5
			-- 	game:new_actor(arc)
			-- end

            -- local arc = enemies.Centipede:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8, 15)
            -- game:new_actor(arc)

            -- local arc = enemies.ElectricRays:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8, 3)
            -- game:new_actor(arc)

            -- local arc = enemies.Explosion:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8, 32)
            -- game:new_actor(arc)

            local arc = enemies.DrillBee:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8)
            game:new_actor(arc)

            -- local arc = enemies.BigBug:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8)
            -- game:new_actor(arc)

            -- local arc = enemies.ElectricRays:new(CANVAS_WIDTH*random_range(0, 1), CANVAS_HEIGHT*random_range(0, 1), 5)
            -- game:new_actor(arc)

            -- local arc = enemies.ShovelBee:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8)
            -- game:new_actor(arc)

            -- local arc = enemies.Grasshopper:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.8)
            -- game:new_actor(arc)

            -- local arc = enemies.ElectricArc:new(CANVAS_WIDTH/2, CANVAS_HEIGHT*0.5)
            -- arc:set_segment(CANVAS_WIDTH*0.8, CANVAS_HEIGHT/2, CANVAS_WIDTH/2, CANVAS_HEIGHT)
            -- game:new_actor(arc)
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
        
        -- ["i"] = {"toggle instant end", function()
        --     self.instant_end = not self.instant_end
        -- end},
        ["i"] = {"toggle god mode", function()
            for _, player in pairs(game.players) do
                player.debug_god_mode = not player.debug_god_mode
            end
        end},
        
        ["y"] = {"toggle layer view", function()
            self.layer_view = not self.layer_view
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
        
        -- ["left"] = {"move camera left", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game:set_camera_position(cam_x - 8, cam_y)
        -- end},
        -- ["right"] = {"move camera right", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game:set_camera_position(cam_x + 8, cam_y)
        -- end},
        -- ["up"] = {"move camera up", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game:set_camera_position(cam_x, cam_y - 8)
        -- end},
        -- ["down"] = {"move camera down", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game:set_camera_position(cam_x, cam_y + 8)
        -- end},
        ["space"] = {"screenshot", function()
		    game:screenshot()
        end},

        ["m"] = {"wave info to file", function()
            local canvas_ = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT * 10)
            local old_canvas = love.graphics.getCanvas()
            love.graphics.setCanvas(canvas_)
            love.graphics.clear(COL_BLACK)
            debug_draw_waves({x=CANVAS_CENTER[1], y=0})
            love.graphics.setCanvas(old_canvas)
            save_canvas_as_file(canvas_, os.date('bugscraper_waves_%Y-%m-%d_%H-%M-%S.png'), "png")
        end},

        ["n"] = {"toggle frame-by-frame", function()
            _G_frame_by_frame_mode = not _G_frame_by_frame_mode
        end},

        ["o"] = {"", function()
            self:tuto_next()
        end}
    }
    
    self.action_keys = {}
    for k, v in pairs(self.actions) do
        table.insert(self.action_keys, k)
    end
    table.sort(self.action_keys)
end

function Debug:update(dt)
    if not game.debug_mode then return end
    self:update_input_view(1/60)    

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
    if not game.debug_mode then return end

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
        local t = concat(love.timer.getFPS(), "FPS\n")
        print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t), 0)
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
        self:draw_joystick_view_for(joy, i*spacing, -20, "leftx", "lefty", true)
        i = i + 1
        self:draw_joystick_view_for(joy, i*spacing, -20, "rightx", "righty")
        i = i + 1
    end
end

function Debug:draw_joystick_view_for(joystick, x, y, axis_x, axis_y, is_first)
    local user_n = Input:get_joystick_user_n(joystick)
    local name = concat(utf8.sub(joystick:getName(), 1, 10), "...", utf8.sub(joystick:getName(), -10, -1))
    
    if is_first then
        print_outline(COL_WHITE, COL_BLACK_BLUE, name, x+30, y+20)
        print_outline(COL_WHITE, COL_BLACK_BLUE, concat("(Ply '", user_n, "')"), x+30, y+30)
    end

	-- print_outline(ternary(Input:action_down(user_n, "left"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("left"), "✅", "❎"), x+30, y+60)
	-- print_outline(ternary(Input:action_down(user_n, "right"), COL_GREEN, COL_WHITE), COL_BLACK_BLUE, ternary(Input:action_down_any_player("right"), "✅", "❎"), x+70, y+60)
	-- print_outline(ternary(Input:action_down(user_n, "up"), COL_GREEN, COL_WHITE),    COL_BLACK_BLUE, ternary(Input:action_down_any_player("up"), "✅", "❎"), x+50, y+40)
	-- print_outline(ternary(Input:action_down(user_n, "down"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("down"), "✅", "❎"), x+50, y+80)
	
	local ox = x+60
	local oy = y+80
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
		return math.atan2(j:getGamepadAxis(ay), j:getGamepadAxis(ax))
	end
	local function get_axis_radius_sqr(j, ax, ay) 
		return distsqr(j:getGamepadAxis(ax), j:getGamepadAxis(ay))
	end
	
	local u = Input:get_user(user_n)
    local j = joystick
	if u ~= nil then
		circle_color(COL_RED, "fill", ox + r*j:getGamepadAxis(axis_x), oy + r*j:getGamepadAxis(axis_y), 2)
	
        local val_x = round(j:getGamepadAxis(axis_x), 3)
        local val_y = round(j:getGamepadAxis(axis_y), 3)
        local val_a = round(get_axis_angle(j, axis_x, axis_y), 3)
        local val_r = round(math.sqrt(get_axis_radius_sqr(j, axis_x, axis_y)), 3)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "x "..tostring(val_x), ox - 20, oy + 40)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "y "..tostring(val_y), ox - 20, oy + 50)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "a "..tostring(val_a), ox - 20, oy + 60)
		print_outline(COL_WHITE, COL_BLACK_BLUE, "r "..tostring(val_r), ox - 20, oy + 70)
	end

    if is_first then 
        local zl = j:getGamepadAxis("triggerleft")
        local zr = j:getGamepadAxis("triggerright")
        print_outline(COL_WHITE, COL_BLACK_BLUE, concat("ZL ", zl), ox - 20, oy + 80)
        print_outline(COL_WHITE, COL_BLACK_BLUE, concat("ZR ", zr), ox - 20, oy + 90)
    end
    
    local keys = ternary(is_first, {
        "a",
        "b",
        "x",
        "y",
        "back",
        "start",
        "leftstick",
        "rightstick",
    },
    {
        "leftshoulder",
        "rightshoulder",
        "dpup",
        "dpdown",
        "dpleft",
        "dpright",
        -- "misc1",
        -- "paddle1",
        -- "paddle2",
        -- "paddle3",
        -- "paddle4",
        -- "touchpad",
    })
    for i, key in ipairs(keys) do
        local txt = concat(key, " ", ternary(j:isGamepadDown(key), "✅", "❎"))
        print_outline(COL_WHITE, COL_BLACK_BLUE, txt, ox - 20, oy + 90 + 10*i)
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
		users_str = concat(users_str, "{", k, ":", player.n, "(", player.input_profile_id, ")", "}, ")
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

    local queued_players_str = "{"
	for k, player in pairs(game.queued_players) do
		queued_players_str = concat(queued_players_str, player.player_n, ": ", param(player.is_pressed, "nil"), ", ")
	end
    queued_players_str = queued_players_str.."}"

	
	-- Print debug info
	local txt_h = get_text_height(" ")
	local txts = {
		concat("FPS: ",love.timer.getFPS(), " / frmRpeat: ",self.game.frame_repeat, " / frame: ",frame),
		concat("LÖVE version: ", string.format("%d.%d.%d - %s", love.getVersion())),
		concat("game state: ", game.game_state),
		concat("memory used ", collectgarbage("count")),
		concat("n° of active audio sources: ", love.audio.getActiveSourceCount()),
		concat("n° of actors: ", #self.game.actors, " / ", self.game.actor_limit),
		concat("n° of enemies: ", self.game:get_enemy_count()),
		concat("n° of particles: ", Particles:get_number_of_particles()),
		concat("n° collision items: ", Collision.world:countItems()),
		concat("real_wave_n ", self.game.debug2),
		concat("number_of_alive_players ", self.game:get_number_of_alive_players()),
		concat("menu_stack ", #self.game.menu_manager.menu_stack),
		players_str,
		users_str,
		joystick_user_str,
		joystick_str,
		wave_resp_str, 
        concat("queued_players ", queued_players_str),
		"",
	}

	for i=1, #txts do  print_label(txts[i], 0, 0+txt_h*(i-1)) end

	for _, e in pairs(self.game.actors) do
		love.graphics.circle("fill", e.x, e.y, 1)
	end

	self.game.level.world_generator:draw()
	draw_log() 
end

----------------------------------------------------------------------------------------------------------

local state_timer = Timer:new(3.0)

local function tuto_text(str, ox, oy, duration)
    local lines = {}
    local split = split_str(str, " ")
    local max_line_len = 250
    local cur_line = ""
    local h = 0
    for i = 1, #split - 1 do
        local word = split[i]
        local next_cur_line = cur_line.." "..word
        if get_text_width(next_cur_line) > max_line_len then
            table.insert(lines, cur_line)
            h = h + get_text_height()
            cur_line = word
        else
            cur_line = next_cur_line
        end
    end 
    table.insert(lines, cur_line.." "..split[#split])
    h = h + get_text_height()
    -- assert(false, table_to_str(lines))

    ox = ox or 0
    oy = oy or 0
    duration = duration or state_timer.duration - 1.5
    local y = CANVAS_CENTER[2] - 32 + oy - h/2
    for _, line in pairs(lines) do
        Particles:word(CANVAS_CENTER[1] + ox, y, line, nil, duration or 3, nil, nil, 1/60)
        y = y + 16
    end
end


local renderer = Renderer3D:new(Object3D:new(truncated_ico))
renderer.object:set_scale(vec3(0, 0, 0))
renderer.object.position.x = CANVAS_CENTER[1]
renderer.object.position.y = CANVAS_CENTER[2]
renderer.object.position.z = 20

local renderer_2 = Renderer3D:new(Object3D:new(truncated_ico))
renderer_2.object:set_scale(vec3(35, 35, 35))
renderer_2.visible = false
renderer_2.show_vertices = true

local background_servers = backgrounds.BackgroundServers:new()
background_servers.speed = 50 * 5

local tuto_arrow_scale = 0

local vertex_list_scroll_y = 0 

local tuto_state_machine = StateMachine:new({
    ["1"] = {
        enter = function(state)
            renderer.object.scale:sset(0)

            renderer.object.position.x = CANVAS_CENTER[1]
            renderer.object.position.y = CANVAS_CENTER[2]
            renderer.object.position.z = 20
            renderer_2.visible = false
        end
    },
    ["2"] = {
        enter = function(state)
            state_timer:start(3.0)

            renderer.object:set_target_scale(vec3(35, 35, 35))
            tuto_text("How do computers display 3D objects?")
        end,
        update = function(state, dt)
            renderer.object.rotation:saddi(1/30, 1/30, 0)
        end
    },
    ["3"] = {
        enter = function(state)
            state_timer:start(8.0)
            renderer.visible = false
            renderer_2.visible = true
            renderer_2.object:set_position(renderer.object.position)
            renderer_2.lighting_palette = {{1, 1, 1, 0}}
            renderer_2.line_color = COL_WHITE
            renderer_2.backface_culling = false

            -- renderer.object:set_target_position(vec3(CANVAS_CENTER[1] + 60, CANVAS_CENTER[2] + 20, 0))
            renderer_2.object:set_position(vec3(CANVAS_CENTER[1], CANVAS_CENTER[2] + 20, 0))
            renderer_2.object:set_target_position(vec3(CANVAS_CENTER[1] + 60, CANVAS_CENTER[2] + 20, 0))
            tuto_text([[Rasterization is the process of converting numbers reprsenting 3D points to shapes on a flat screen.]])

            tuto_arrow_scale = 0
        end,
        update = function(state, dt)
            tuto_arrow_scale = lerp(tuto_arrow_scale, 1, 0.2)
            renderer.object.rotation:saddi(1/30, 1/30, 0)
            renderer_2.object.rotation:vset(renderer.object.rotation:copy())

            vertex_list_scroll_y = vertex_list_scroll_y - 8 * dt
        end,
        draw = function(state)
            local x = CANVAS_CENTER[1] - 120
            local y = CANVAS_CENTER[2] + 20 - 50
            local h = 100
            local i = 1
            for iy = y - h/2 + vertex_list_scroll_y, y + h, 16 do
                if iy > y and iy < y + h then
                    local vertex = renderer.object.model.vertices[i]
                    local v = 1 - math.abs((iy - (y + h/2)) / (h/2))
                    print_outline({1, 1, 1, v}, COL_DARK_GREEN, string.format("{%.1f, %.1f, %.1f}", vertex.x, vertex.y, vertex.z), x, iy)
                end
                i = i + 1
            end
        end
    }
}, "1")

function Debug:tuto_next()
    if tuto_state_machine then
        state_timer:stop()
        local s = tonumber(tuto_state_machine.current_state_name) + 1
        if tuto_state_machine.states[tostring(s)] == nil then
            s = 1
        end
        tuto_state_machine:set_state(tostring(s))
    end
end

function Debug:update_input_view(dt)
    background_servers:update(1/60)
    tuto_state_machine:update(dt)
    renderer:update(dt)
    renderer_2:update(dt)

    if state_timer:update(dt) then
        self:tuto_next()
    end
end

function Debug:draw_input_view()
    background_servers:draw()
    
    Particles:draw_layer(PARTICLE_LAYER_BACK)
    Particles:draw_layer(PARTICLE_LAYER_NORMAL)
    Particles:draw_layer(PARTICLE_LAYER_SHADOWLESS)
    
    draw_centered(images._tuto_arrow, CANVAS_CENTER[1], CANVAS_CENTER[2] + 20, 0, tuto_arrow_scale)

    renderer_2:draw()
    renderer:draw()
    tuto_state_machine:draw()
end

----------------------------------------------------------------------------------------------------------


function Debug:draw_colview()
    game.camera:apply_transform()
    
	local items, len = Collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = Collision.world:getRect(it)
		rect_color({0,1,0,.2},"fill", x, y, w, h)
		rect_color({0,1,0,.5},"line", x, y, w, h)
	end
    local level = game.level
    if level then
        rect_color(COL_RED, "line", level.cabin_rect.x, level.cabin_rect.y, level.cabin_rect.w, level.cabin_rect.h)
        rect_color(COL_CYAN, "line", level.cabin_inner_rect.x, level.cabin_inner_rect.y, level.cabin_inner_rect.w, level.cabin_inner_rect.h)
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