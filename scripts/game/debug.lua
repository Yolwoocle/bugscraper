require "scripts.util"
local Class            = require "scripts.meta.class"
local Loot             = require "scripts.actor.loot"
local upgrades         = require "data.upgrades"
local enemies          = require "data.enemies"
local utf8             = require "utf8"
local images           = require "data.images"
local debug_draw_waves = require "scripts.debug.draw_waves"
local Segment          = require "scripts.math.segment"
local Rect             = require "scripts.math.rect"
local Renderer3D       = require "scripts.graphics.3d.renderer_3d"
local Object3D         = require "scripts.graphics.3d.object_3d"
local truncated_ico    = require "data.models.truncated_ico"
local honeycomb_panel  = require "data.models.honeycomb_panel"
local Segment          = require "scripts.math.segment"
local Rect             = require "scripts.math.rect"
local Cutscene         = require "scripts.game.cutscene"
local cutscenes        = require "data.cutscenes"
local Scene            = require "scripts.game.cutscene_scene"
local Class            = require "scripts.meta.class"
local AnimatedSprite   = require "scripts.graphics.animated_sprite"
local Sprite           = require "scripts.graphics.sprite"
local skins            = require "data.skins"
local BackroomCredits = require "scripts.level.backroom.backroom_credits"
local shaders         = require "data.shaders"

local Debug            = Class:inherit()

local col_a            = { random_range(0, 1), random_range(0, 1), random_range(0, 1), 1 }
local col_b            = { random_range(0, 1), random_range(0, 1), random_range(0, 1), 1 }

function Debug:init(game)
    self.game = game

    self.frame = 0  

    self.is_reading_for_f1_action = false
    self.debug_menu = false
    self.colview_mode = false
    self.actor_info_view = false
    self.info_view = false
    self.joystick_view = false
    self.bound_view = false
    self.view_fps = false

    self.instant_end = false
    self.layer_view = false
    self.input_view = false
    self.title_junk = true

    self.notification_message = ""
    self.notification_timer = 0.0

    local func_damage = function(n)
        return function()
            local p = self.game.players[tonumber(n)]
            if p ~= nil then
                p:do_damage(1)
                p.invincible_time = 0.0
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
        ["f2"] = { "toggle collision view mode", function()
            self.colview_mode = not self.colview_mode
        end, do_not_require_ctrl = true },
        ["f3"] = { "view more info", function()
            self.info_view = not self.info_view
        end, do_not_require_ctrl = true },
        ["f4"] = { "view joystick info", function()
            self.joystick_view = not self.joystick_view
        end, do_not_require_ctrl = true },
        ["f5"] = { "view input info", function()
            self.input_view = not self.input_view
        end, do_not_require_ctrl = true },
        ["f6"] = { "toggle UI", function()
            self.game.game_ui.is_visible = not self.game.game_ui.is_visible
            self.game.is_game_ui_visible = not self.game.is_game_ui_visible
        end, do_not_require_ctrl = true },
        ["f7"] = { "toggle speedup", function()
            _G_t = 0
            _G_speedup = not _G_speedup
            if _G_speedup then
                _G_frame_repeat = 4
            else
                _G_frame_repeat = 1
            end
        end, do_not_require_ctrl = true },
        ["f8"] = { "toggle actor info view mode", function()
            self.actor_info_view = not self.actor_info_view
        end, do_not_require_ctrl = true },
        ["f12"] = { "get draw info", function()
            print("-----------------------")
            for key, val in pairs(__times) do
                print(key, ":", round(100 * (val.t) / (1/60), 2), "%")
            end
            print("-----------------------")
        end },
        
        ["u"] = { "spawn ceo", function()
            local ac = game:new_actor(enemies.NPC:new(866, 223, {
                npc_name = "ceo",
                animations = {
                    normal = {images.ceo_npc_idle, 0.2, 4},
                    airborne = {images.ceo_npc_airborne, 0.2, 1},
                    jetpack = {images.ceo_npc_jetpack, 0.2, 1},
                },
                dialogue_key = "dialogue.npc.noba",
                flip_x = true,
            }))
            ac.gravity = 0
        end},
        
        ["v"] = { "__jackofalltrades", function()
            -- Audio:play("sfx_boss_mrdung_ball_hit_{01-06}", 2.0)
            
            local sk = enemies.Shopkeeper:new(35*16, 13*16)
            game:new_actor(sk)

            -- game.level:set_bounds(Rect:new(unpack(RECT_CEO_OFFICE_PARAMS)))
            -- game:play_cutscene("enter_ceo_office")

            -- game.is_light_on = true
            -- game.level.backroom.show_basement_bg = true

            -- game.game_ui.ending_counter_text = "12345"
            -- Particles:speed_line(game.players[1].x, game.players[1].y, 1)

            ------------------------------
            ---
            -- game:new_game({ 
            --     backroom = BackroomCredits:new(),
            --     iris_params = {0, 0, 0, 0, 0}
            -- })

            ------------------------------

            --[[
            local points = {}
            local cx = game.level.door_rect.ax / 2 + game.level.door_rect.bx / 2
            local cy = game.level.door_rect.ay / 2 + game.level.door_rect.by / 2
            
            for i=0, 19 do
                table.insert(points, {cx + math.cos(pi/2 + pi2*i/20)* 100, cy + math.sin(pi/2 + pi2*i/20)* 100})
            end

            local e = enemies.ProgressingArc:new(100, 100, {
                points = points,
                interval_size = 150,
                progress_speed = 80,
                arc_params = {
                    lightning_params = {
                        style = LIGHTNING_STYLE_THORNS, 
                        min_step_size = 10,
                        max_step_size = 10,
                        min_line_width = 0,
                        max_line_width = 0,
                        jitter_width = 0,
                    }
                }
            })
            game:new_actor(e)
            --]]

            -----------------------------

            -- Particles:dead_player(200, 200, images.mio_dead, {COL_RED}, 1)

            --[[
            -- local e = enemies.StinkBug:new(15, 62)
            -- game:new_actor(e)
            -- e:kill()
            local x, y = 14, 56

            local n = 11
            -- for i = 1, n do
                local spawn_x = clamp(x, game.level.cabin_rect.ax, game.level.cabin_rect.bx - 20)
                local spawn_y = clamp(y, game.level.cabin_rect.ay, game.level.cabin_rect.by - 20)
                local cloud = enemies.PoisonCloud:new(spawn_x, spawn_y)
                
                local d = (8/11) * pi2 + 0.2
                local r = 100
                cloud.vx = math.cos(d) * r
                cloud.vy = math.sin(d) * r
                game:new_actor(cloud)
            -- end
            -- local cloud = enemies.PoisonCloud:new(spawn_x, spawn_y)
            -- local d = (10/11) * pi2 + 0.2
            -- local r = 100
            -- cloud.vx = math.cos(d) * r
            -- cloud.vy = math.sin(d) * r
            -- game:new_actor(cloud)
            --]]
        end },
        ["j"] = { "frameskip", function()
            game:frameskip(60)
        end },
        ["k"] = { "shorter", function()
        end },
        ["f"] = { "toggle FPS", function()
            self.view_fps = not self.view_fps
        end },
        ["1"] = { "damage P1", func_damage(1) },
        ["2"] = { "damage P2", func_damage(2) },
        ["3"] = { "damage P3", func_damage(3) },
        ["4"] = { "damage P4", func_damage(4) },
        ["5"] = { "heal P1", func_heal(1) },
        ["6"] = { "heal P2", func_heal(2) },
        ["7"] = { "heal P3", func_heal(3) },
        ["8"] = { "heal P4", func_heal(4) },

        ["q"] = { "previous floor", function()
            self.game:set_floor(self.game:get_floor() - 1)
        end },
        ["w"] = { "next floor", function()
            self.game:set_floor(self.game:get_floor() + 1)
        end },
        ["a"] = { "-10 floors", function()
            self.game:set_floor(self.game:get_floor() - 20)
        end },
        ["s"] = { "+10 floors", function()
            self.game:set_floor(self.game:get_floor() + 20)
        end },
        ["h"] = { "show help", function()
            self.debug_menu = not self.debug_menu
        end },

        -- ["u"] = { "toggle title junk ui", function()
        --     self.title_junk = not self.title_junk
        -- end },
        ["c"] = { "skip cutscene", function()
            game.skip_scene_flag = true
        end },
        ["d"] = { "spawn", function()
            -- game.menu_manager:set_menu("debug_command")
            local cloud = enemies.ArumTitanBoss:new(CANVAS_CENTER[1], CANVAS_CENTER[2])
            cloud:set_position(cloud.x - cloud.w/2, cloud.y - cloud.h/2)
            game:new_actor(cloud)
        end },
        ["o"] = { "toggle invincibility", function()
            for _, player in pairs(game.players) do
                player.invincible_time = math.huge
                player.max_invincible_time = math.huge
            end
        end },
        ["r"] = { "start game", function()
            for _, p in pairs(game.players) do
                p:set_position(CANVAS_CENTER[1], CANVAS_CENTER[2])
            end
            game.can_start_game = true
            game.camera:reset()
            game:start_game()

            for k, e in pairs(self.game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
        end },

        ["e"] = { "kill all enemies", function()
            for k, e in pairs(self.game.actors) do
                if e.is_enemy then
                    e:kill()
                end
            end
        end },

        -- ["i"] = {"toggle instant end", function()
        --     self.instant_end = not self.instant_end
        -- end},
        ["i"] = { "toggle god mode", function()
            for _, player in pairs(game.players) do
                player.debug_god_mode = not player.debug_god_mode
                player:update_debug_god_mode(0)
            end
        end },

        ["y"] = { "toggle layer view", function()
            self.layer_view = not self.layer_view
        end },

        ["b"] = { "toggle cabin view", function()
            game.level.show_cabin = not game.level.show_cabin
        end },

        ["g"] = { "next gun for P1", function()
            local p = self.game.players[1]
            if p then
                p:next_gun()
            end
        end },
        ["l"] = { "spawn random loot", function()
            local loot, parms = random_weighted({
                { Loot.Life, 3, loot_type = "life", value = 1 },
                { Loot.Gun,  3, loot_type = "gun" },
            })
            if not loot then return end

            local x, y = CANVAS_WIDTH / 2, CANVAS_HEIGHT * 0.8
            local instance
            local vx = random_neighbor(300)
            local vy = random_range(-200, -500)
            local loot_type = parms.loot_type
            if loot_type == "ammo" or loot_type == "life" or loot_type == "gun" then
                instance = loot:new(x, y, parms.value, vx, vy)
            end

            game:new_actor(instance)
        end },

        ["z"] = { "zoom -", function()
            self.game.camera:set_zoom(self.game.camera:get_zoom() - 0.1)
        end },
        ["x"] = { "zoom +", function()
            self.game.camera:set_zoom(self.game.camera:get_zoom() + 0.1)
        end },

        -- ["left"] = {"move camera left", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game.camera:set_position(cam_x - 8, cam_y)
        -- end},
        -- ["right"] = {"move camera right", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game.camera:set_position(cam_x + 8, cam_y)
        -- end},
        -- ["up"] = {"move camera up", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game.camera:set_position(cam_x, cam_y - 8)
        -- end},
        -- ["down"] = {"move camera down", function()
        --     local cam_x, cam_y = self.game:get_camera_position()
        --     self.game.camera:set_position(cam_x, cam_y + 8)
        -- end},
        ["space"] = { "screenshot", function()
            game:screenshot()
        end },

        ["m"] = { "wave info to file", function()
            local canvas_ = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT * 10)
            local old_canvas = love.graphics.getCanvas()
            love.graphics.setCanvas(canvas_)
            love.graphics.clear(COL_BLACK)
            debug_draw_waves({ x = CANVAS_CENTER[1], y = 0 })
            love.graphics.setCanvas(old_canvas)
            save_canvas_as_file(canvas_, os.date('bugscraper_waves_%Y-%m-%d_%H-%M-%S.png'), "png")
        end },

        ["n"] = { "toggle frame-by-frame", function()
            _G_frame_by_frame_mode = not _G_frame_by_frame_mode
        end },

        ["p"] = { "start/end profiler", function()
            _G_profiler_on = not _G_profiler_on
            if _G_profiler_on then
                love.profiler.reset()
                love.profiler.start()
            else
                love.profiler.stop()
                print("")
                print("===[[ PROFILER REPORT ]]===")
                print(love.profiler.report(40))
                print("")
                love.profiler.reset()

            end
        end}
    }

    -- self.test_spritesheet = AnimatedSprite:new()
    self.test_sprite = Sprite:new(images.removeme_spritesheet_test, nil, {
        spritesheet = {
            tile_count_x = 3,
            tile_count_y = 1,
        }
    })
    self.test_sprite_t = 0.0

    self.action_keys = {}
    for k, v in pairs(self.actions) do
        table.insert(self.action_keys, k)
    end
    table.sort(self.action_keys)

    self.t = 0.0
end

function Debug:update(dt)
    if not game.debug_mode then return end

    self.t = self.t + dt
    self.frame = self.frame + 1
    if self.set_can_pause_to_true_timer and self.set_can_pause_to_true_timer > 0 then
        self.set_can_pause_to_true_timer = self.set_can_pause_to_true_timer - 1
        if self.set_can_pause_to_true_timer <= 0 then
            game.menu_manager:set_can_pause(true)
        end
    end
end

function Debug:debug_action(key, scancode, isrepeat)
    local action = self.actions[scancode]
    if action then
        if not action.do_not_require_ctrl and not love.keyboard.isScancodeDown("lctrl") then
            return
        end

        action[2]()
        self:new_notification("Executed '" .. tostring(action[1]) .. "'")
    else
        -- self:new_notification("Action not recognized")
    end
end

function Debug:new_notification(msg)
    game.notif = msg
    game.notif_timer = 2.0
end

function Debug:keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    if not game.debug_mode then return end

    if scancode == "f1" then
        game.menu_manager:set_menu("debug_command")
    elseif scancode == "lctrl" then
        self.is_reading_for_f1_action = true
    else
        self:debug_action(key, scancode, isrepeat)
        self.is_reading_for_f1_action = false
    end
end

function Debug:keyreleased(key, scancode, isrepeat)
    if scancode == "lctrl" and self.is_reading_for_f1_action then
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

    game.camera:push()
    if self.joystick_view then
        if game.level.map._removeme_rectangles then
            local rects = game.level.map._removeme_rectangles
            for _, r in pairs(rects) do
                rect_color(COL_YELLOW, "line", r.ax*16, r.ay*16, r.w*16, r.h*16)
            end
        end
    end
    game.camera:pop()

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
        "interact",
        "pause",
        "ui_select",
        "ui_back",
        "ui_left",
        "ui_right",
        "ui_up",
        "ui_down",
        "split_keyboard",
        "debug",
    }
    for i, a in ipairs(actions) do
        print_outline(nil, nil, concat(a, ": ", user.action_states[a].state), x, 14 * i)
    end
end

function Debug:draw_joystick_view()
    local spacing = 70
    local i = 0
    for _, joy in pairs(love.joystick.getJoysticks()) do
        self:draw_joystick_view_for(joy, i * spacing, -20, "leftx", "lefty", true)
        i = i + 1
        self:draw_joystick_view_for(joy, i * spacing, -20, "rightx", "righty")
        i = i + 1
    end
end

function Debug:draw_joystick_view_for(joystick, x, y, axis_x, axis_y, is_first)
    Text:push_font(FONT_MINI)
    local user_n = Input:get_joystick_user_n(joystick)
    local name = concat(utf8.sub(joystick:getName(), 1, 10), "...", utf8.sub(joystick:getName(), -10, -1))

    if is_first then
        print_outline(COL_WHITE, COL_BLACK_BLUE, name, x + 30, y + 20)
        print_outline(COL_WHITE, COL_BLACK_BLUE, concat("(Ply '", user_n, "')"), x + 30, y + 30)
    end

    -- print_outline(ternary(Input:action_down(user_n, "left"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("left"), "✅", "❎"), x+30, y+60)
    -- print_outline(ternary(Input:action_down(user_n, "right"), COL_GREEN, COL_WHITE), COL_BLACK_BLUE, ternary(Input:action_down_any_player("right"), "✅", "❎"), x+70, y+60)
    -- print_outline(ternary(Input:action_down(user_n, "up"), COL_GREEN, COL_WHITE),    COL_BLACK_BLUE, ternary(Input:action_down_any_player("up"), "✅", "❎"), x+50, y+40)
    -- print_outline(ternary(Input:action_down(user_n, "down"), COL_GREEN, COL_WHITE),  COL_BLACK_BLUE, ternary(Input:action_down_any_player("down"), "✅", "❎"), x+50, y+80)

    local ox = x + 60
    local oy = y + 80
    local r = 30
    love.graphics.setColor(COL_GREEN)
    circle_color({ 0, 0, 0, 0.5 }, "fill", ox, oy, r)
    circle_color(COL_WHITE, "line", ox, oy, r)
    love.graphics.line(ox, oy - r, ox, oy + r)
    love.graphics.line(ox - r, oy, ox + r, oy)

    -- love.graphics.setColor(COL_GREEN)
    -- love.graphics.line(x-AXIS_DEADZONE*r, y-r, x-AXIS_DEADZONE*r, y+r)
    -- love.graphics.line(x+AXIS_DEADZONE*r, y-r, x+AXIS_DEADZONE*r, y+r)
    -- love.graphics.line(x-r, y-AXIS_DEADZONE*r, x+r, y-AXIS_DEADZONE*r)
    -- love.graphics.line(x-r, y+AXIS_DEADZONE*r, x+r, y+AXIS_DEADZONE*r)
    -- love.graphics.setColor(COL_WHITE)
    local deadzone = Options:get("axis_deadzone_p" .. tostring(user_n)) or AXIS_DEADZONE

    love.graphics.setColor(COL_GREEN)
    love.graphics.circle("line", ox, oy, r * deadzone)
    for a = pi / 8, pi2, pi / 4 do
        local ax = math.cos(a)
        local ay = math.sin(a)
        love.graphics.line(ox + deadzone * ax * r, oy + deadzone * ay * r, ox + r * ax, oy + r * ay)
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
        circle_color(COL_RED, "fill", ox + r * j:getGamepadAxis(axis_x), oy + r * j:getGamepadAxis(axis_y), 2)

        local val_x = round(j:getGamepadAxis(axis_x), 3)
        local val_y = round(j:getGamepadAxis(axis_y), 3)
        local val_a = round(get_axis_angle(j, axis_x, axis_y), 3)
        local val_r = round(math.sqrt(get_axis_radius_sqr(j, axis_x, axis_y)), 3)
        print_outline(COL_WHITE, COL_BLACK_BLUE, "x " .. tostring(val_x), ox - 20, oy + 40)
        print_outline(COL_WHITE, COL_BLACK_BLUE, "y " .. tostring(val_y), ox - 20, oy + 50)
        print_outline(COL_WHITE, COL_BLACK_BLUE, "a " .. tostring(val_a), ox - 20, oy + 60)
        print_outline(COL_WHITE, COL_BLACK_BLUE, "r " .. tostring(val_r), ox - 20, oy + 70)
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
        print_outline(COL_WHITE, COL_BLACK_BLUE, txt, ox - 20, oy + 90 + 10 * i)
    end
    Text:pop_font(FONT_MINI)
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

        rect_color({ 0, 0, 0, 0.5 }, "fill", x, y, get_text_width(text), 10)
        print_outline(nil, nil, text, x, y)
        y = y + 12
        if y + 12 >= CANVAS_HEIGHT then
            y = 0
            x = x + max_w
            max_w = 0
        end
    end
end

local oa = 0
local sa = 0.01
local star
local function new_star()
    star = generate_star_shape({
        triangulated = true,

        ox = 100,
        oy = 100,

        start_angle = 0,
        min_angle_step = pi/9,
        max_angle_step = pi/9,
        scale = 2,
        low_radius = 20,
        high_radius = 40,
        radius_randomness = 0,

        scale_multiplier_function = function(t)
            local x = (t + 1) % 1
            local c = 0.5
            return 2 * c * abs(x-0.5)-c+1
        end
    })
end
new_star()

-- 2^(-(2 (x-0.5))^(2))

local spr = AnimatedSprite:new({
    normal = {images.bee_boss_alt, 0.05, 2}
}, "normal")
local linedottedoffset = 0.0



function Debug:draw_info_view()
    love.graphics.setFont(FONT_MINI)

    self.test_sprite_t = self.test_sprite_t + 1 / 60
    if self.test_sprite_t > 0.3 then
        self.test_sprite_t = 0.0
        self.test_sprite:set_spritesheet_tile(mod_plus_1(self.test_sprite.spritesheet_tile + 1,
            self.test_sprite.spritesheet_tile_count_x))
    end
    -- self.test_sprite:draw(200, 100)

    do
        local players_str = "players: "
        for k, player in pairs(self.game.players) do
            players_str = concat(players_str, "{", k, ":", player.n, "}, ")
        end
        players_str = players_str .. " | all_players: " 
        for k, player in pairs(self.game.all_players) do
            players_str = concat(players_str, "{", k, ":", player.n, "}, ")
        end

        local users_str = "users: "
        for k, player in pairs(Input.users) do
            users_str = concat(users_str, "{", k, ":", player.n, "(", player.input_profile_id, ")", "}, ")
        end

        local joystick_user_str = "joysticks_to_users: "
        for joy, user in pairs(Input.joystick_to_user_map) do
            joystick_user_str = concat(joystick_user_str, "{", string.sub(joy:getName(), 1, 4), "... ", ":", user.n, "}, ")
        end

        local joystick_str = "joysticks: "
        for _, joy in pairs(love.joystick.getJoysticks()) do
            joystick_str = concat(joystick_str, "{", string.sub(joy:getName(), 1, 4), "...}, ")
        end

        local wave_resp_str = "waves_until_respawn "
        for i = 1, MAX_NUMBER_OF_PLAYERS do
            wave_resp_str = concat(wave_resp_str, "{", i, ":", self.game.waves_until_respawn[i][1], "}, ")
        end

        local queued_players_str = "{"
        for k, player in pairs(game.queued_players) do
            queued_players_str = concat(queued_players_str, player.player_n, ": ", param(player.is_pressed, "nil"), ", ")
        end
        queued_players_str = queued_players_str .. "}"

        local renderer_name, renderer_version, renderer_vendor, renderer_device = love.graphics.getRendererInfo( )

        local skininfo = ""
        for _, skin_id in pairs(Metaprogression:get("skins")) do
            skininfo = skininfo .. concat(skin_id, "(", (skins[skin_id] or {}).text_key, "), ")
        end

        local upgradeinfo = ""
        for _, upgrade_name in pairs(Metaprogression:get("upgrades")) do
            upgradeinfo = upgradeinfo .. concat(upgrades[upgrade_name]:new().name, ", ")
        end

        -- Print debug info
        local txt_h = get_text_height(" ")
        local txts = {
            "",
            "",
            "",
            "",
            "",
            concat("FPS: ", love.timer.getFPS(), " / Vsync: ", Options:get("is_vsync")),
            concat("LOVE version: ", string.format("%d.%d.%d - %s", love.getVersion())),
            concat("Renderer info: ", renderer_name, " (v", renderer_version, ")"),
            concat("Renderer vendor: ", renderer_vendor, ", device ", renderer_device),
            concat("game state: ", game.game_state, " / camera pos: (", game.camera.x, ", ", game.camera.y, ")"),
            concat("nb of active audio sources: ", love.audio.getActiveSourceCount()),
            concat("nb of actors: ", #self.game.actors, " / ", self.game.actor_manager.actor_limit, " | nb of enemies: ", self.game:get_enemy_count()),
            concat("nb collision items: ", Collision.world:countItems()),
            concat("number_of_alive_players ", self.game:get_number_of_alive_players(), " / number_of_kb_users ", Input:get_number_of_users(INPUT_TYPE_KEYBOARD), " / global_user.ui_actions_enabled ", Input:get_user(GLOBAL_INPUT_USER_PLAYER_N).ui_actions_enabled),
            players_str,
            users_str,
            joystick_user_str,
            joystick_str,
            wave_resp_str,
            concat("backroom ", (game.level.backroom == nil) and "nil" or game.level.backroom.name),
            concat("queued_players ", queued_players_str),
            concat("level_speed ", game.level.level_speed),
            concat("menu_stack size: ", #game.menu_manager.menu_stack) .. " / " .. concat("cur_menu_name ", game.menu_manager.cur_menu_name),
            concat("cur_cutscene ", (game.cutscene == nil) and "[nil]" or 
                string.format("%s: [%d/%d] (%.1f s/%.1f s) '%s' / (total: %.1f s)", 
                    game.cutscene.name, 
                    game.cutscene.current_scene_i, 
                    #game.cutscene.scenes, 
                    game.cutscene.timer.duration - game.cutscene.timer.time, 
                    game.cutscene.timer.duration, 
                    game.cutscene.current_scene.description, 
                    game.cutscene.total_duration
                ), " / ",
                "has_seen_w2_transition_cutscene: ", Metaprogression:get("has_seen_w2_transition_cutscene")
            ),
            concat("score: ", game.score) .. " / ".. concat("xp: ", Metaprogression:get_xp()) .. " / " .. concat("xp_level: ", Metaprogression:get_xp_level()),
            concat("unlocked_skins: ", skininfo),
            concat("unlocked_upgrades: ", upgradeinfo),
            "",
        }

        for i = 1, #txts do print_label(txts[i], 0, 0 + txt_h * (i - 1)) end
    end 

    self.game.level.world_generator:draw()

    -- Show time taken by various functions during last frame
    if __times then
        local tab = {}
        for k, time in pairs(__buf_times) do
            if not tab[time.layer] then
                tab[time.layer] = {}
            end
            tab[time.layer][time.i] = time
        end

        local total_w = 300
        local x = 0
        local y = 0
        local h = 16
        for _, layer in pairs(tab) do
            local x = 0
            for i, time in pairs(layer) do
                local w = total_w * (time.t / (1/60))

                rect_color(time.col, "fill", x, y, w, 16)
                x = x + w
            end 
            y = y + 16
            h = h - 16
        end 

        -- Text
        local x = 0
        local y = 0
        local h = 16
        local text_oy = false
        for _, layer in pairs(tab) do
            local x = 0
            for i, time in pairs(layer) do
                local w = total_w * (time.t / (1/60))
                love.graphics.print(time.label, x, y + ternary(text_oy, 6, 0))
                x = x + w
                text_oy = not text_oy
            end 
            y = y + 16
            h = h - 16
        end 

        rect_color(COL_WHITE, "line", 0, 0, total_w, 16)
    end

    self:test_info_view_3d_renderer()

    -- local w = 255
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

    love.graphics.setFont(FONT_REGULAR)

    -- love.graphics.draw(images.removeme_bands, 0, 0)

    linedottedoffset = linedottedoffset - 0.2
end



function Debug:test_info_view_3d_renderer()
end

local test_ang = 0
local test_rect = Rect:new(
    CANVAS_CENTER[1] - 26 * 3, CANVAS_CENTER[2] - 13 * 3,
    CANVAS_CENTER[1] - 4 * 3, CANVAS_CENTER[2] + 20 * 3
)

function Debug:test_info_view_crop_line()
    -- love.graphics.clear(COL_BLACK_BLUE)

    local mx, my = love.mouse.getPosition()
    mx, my = mx / 3, my / 3
    local ax, ay, bx, by = get_vector_in_rect_from_angle(mx, my, test_ang, test_rect)
    circle_color(COL_GREEN, "fill", mx, my, 2.5)
    rect_color(COL_RED, "line", test_rect.x, test_rect.y, test_rect.w, test_rect.h)
    if ax then
        line_color(COL_GREEN, ax, ay, bx, by)
    end
    test_ang = test_ang + 0.01

    -- local mx, my = love.mouse.getPosition()
    -- local seg1 = Segment:new(50, 50, mx/3, my/3)
    -- local seg2 = Segment:new(30, 70, 10, 10)
    -- line_color(COL_RED, seg1.ax, seg1.ay, seg1.bx, seg1.by)
    -- line_color(COL_RED, seg2.ax, seg2.ay, seg2.bx, seg2.by)
    -- local pt = segment_intersect_point(seg1, seg2)
    -- if pt then
    --     circle_color(COL_CYAN, "fill", pt.x, pt.y, 4)
    -- end
end

function Debug:draw_actor_info_view()
    if not self.actor_info_view then
        return
    end 

    game.camera:push()
    Text:push_font(FONT_MINI)

    for _, e in pairs(self.game.actors) do
        print_outline(COL_WHITE, COL_BLACK_BLUE, 
            concat(math.floor(e.x), ", ", math.floor(e.y), ternary(e.is_player, concat(" [", math.floor(e.x/16), ", ", math.floor(e.y/16), "]"), "")), e.x, e.y - 10) 

        Text:push_font(FONT_MINI)
        if e.life then
            print_outline(COL_WHITE, COL_DARK_BLUE, concat(round(e.life, 1), "HP"), e.x, e.y-3)
        end
		Text:pop_font()
    end
    
    Text:pop_font()
    game.camera:pop()
end

function Debug:draw_colview()
	if not self.colview_mode then
        return
    end

    game.camera:push()
    Text:push_font(FONT_MINI)

    local items, len = Collision:get_items()
    for i, it in pairs(items) do
        local x, y, w, h = Collision:get_rect(it)
        rect_color({ 0, 1, 0, .2 }, "fill", x, y, w, h)
        rect_color({ 0, 1, 0, .5 }, "line", x, y, w, h)
        if it.type == "tile" then
            print_color(COL_WHITE, concat(it.id), x, y)
        end
    end
    local level = game.level
    if level then
        rect_color(COL_RED, "line", level.cabin_rect.x, level.cabin_rect.y, level.cabin_rect.w, level.cabin_rect.h)
        rect_color(COL_CYAN, "line", level.cabin_inner_rect.x, level.cabin_inner_rect.y, level.cabin_inner_rect.w,
            level.cabin_inner_rect.h)
        
        for _, entr in pairs(level.elevator.entrances) do
            rect_color(COL_YELLOW, "line", entr.rect.x, entr.rect.y, entr.rect.w, entr.rect.h)
        end
    end

    for _, e in pairs(self.game.actors) do
        love.graphics.points(e.x, e.y)
    end

    Text:pop_font()
    game.camera:pop()
end

function Debug:draw_layers()
    local x = 0
    local y = 0
    for i = 1, #self.game.layers do
        local layer_canvas = self.game.layers[i].canvas
        rect_color({ 0.6, 0.6, 0.6, 0.8 }, "fill", x, y, CANVAS_WIDTH, CANVAS_HEIGHT)
        for ix = 0, layer_canvas:getWidth(), 8 do
            for iy = 0, layer_canvas:getHeight(), 8 do
                if (math.floor(ix/8) + math.floor(iy/8)) % 2 == 0 then
                    rect_color({ 1/2,1/2,1/2, 0.8 }, "fill", x + ix, y + iy, math.min(8, layer_canvas:getWidth() - ix), math.min(8, layer_canvas:getHeight() - iy))
                end
            end
        end

        love.graphics.draw(layer_canvas, x, y)
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
