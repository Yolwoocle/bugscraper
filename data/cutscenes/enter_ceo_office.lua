local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light.light_spotlight"
local Rect = require "scripts.math.rect"
local images = require "data.images"
local guns = require "data.guns"
local BackroomBasement = require "scripts.level.backroom.backroom_basement"
local LightPoint      = require "scripts.graphics.light.light_point"

return Cutscene:new("enter_ceo_office", {
    -- [[
    CutsceneScene:new({
        description = "Setup scene",
        duration = 0.0,
        enter = function(cutscene, data)
            -- Init players
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()

                player.do_fury_trail = false
                player.show_hud = false
            end

            game.game_ui.cinematic_bars_enabled = true
            game.game_ui.show_fury = false
            game.game_ui.offscreen_indicators_enabled = false

            -- Find resigning player
            data.resigning_player = nil
            for _, player in pairs(game.players) do
                if player.gun.name == "resignation_letter" then
                    data.resigning_player = player
                end
            end
            if not data.resigning_player then
                data.resigning_player = game.players[1] or game.players[2] or game.players[3] or game.players[4] or game.players[5] or game.players[6] or game.players[7] or game.players[8]
                data.resigning_player:equip_gun(guns.unlootable.ResignationLetter:new(data.resigning_player))
            end

            -- Teleport faraway players
            for _, player in pairs(game.players) do
                if player.x < 79*16 - CANVAS_WIDTH then
                   player.x = 79*16 - CANVAS_WIDTH
                   Particles:smoke_big(player.mid_x, player.mid_y, COL_WHITE)
                end
            end

            -- Find CEO
            for _, actor in pairs(game.actors) do
                if actor.name == "npc" and actor.npc_name == "ceo" then
                    data.ceo = actor
                end
                if actor.name == "npc" and actor.npc_name == "button" then
                    data.button = actor
                end
                if actor.name == "npc" and actor.npc_name == "big_glove" then
                    data.big_glove = actor
                end
            end
        end,
    }),
    CutsceneScene:new({
        description = "Wait a bit",
        duration = 2.0,
        enter = function(cutscene, data)
            
        end,
    }),
    CutsceneScene:new({
        description = "Wait for all players walk into position",
        duration = 4.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(84*16 + 8 + MAX_NUMBER_OF_PLAYERS*24)

            -- Put players to code input mode
            local n = 1
            for _, player in pairs(game.players) do
                if player ~= data.resigning_player then
                    local target_x = 84*16 + 8 + (MAX_NUMBER_OF_PLAYERS-n) * 24
                    player:set_code_input_mode_target_x(target_x)
                    n = n + 1
                end
            end
        end,
        update = function(cutscene, data, dt)
            local ok_players = 0
            for _, player in pairs(game.players) do
                if player:is_near_code_input_mode_target_x() then
                    ok_players = ok_players + 1
                end
            end

            -- the scene is finished early
            if ok_players == game:get_number_of_alive_players() then
                return true 
            end
        end,
        exit = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x()
                player:reset_virtual_controller()
            end
        end
    }),

    
    CutsceneScene:new({
        description = "Wait",
        duration = 1.0,
    }),


    CutsceneScene:new({
        description = "Shocked",
        
        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("shocked")
            data.shake = 3.0

            Particles:static_image(images.surprise_effect, data.ceo.x - 16, data.ceo.y - 30, 0, 0.3)
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(data.shake), random_neighbor(data.shake))
            data.shake = math.max(0, data.shake - dt*6)
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),

    CutsceneScene:new({
        description = "Wait",
        duration = 1.0,
    }),

    CutsceneScene:new({
        description = "Wait",
        duration = 1.0,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("normal")
        end
    }),

    CutsceneScene:new({
        description = "Clap",

        duration = (0.02 * 3),
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("clap")
        end,
    }),
    CutsceneScene:new({
        description = "Clap after shake",

        duration = 1.0,
        enter = function(cutscene, data)
            Particles:static_image(images.clap_effect, math.floor(data.ceo.x), math.floor(data.ceo.y - 32), 0, 0.3)

            data.shake = 3.0
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(data.shake), random_neighbor(data.shake))
            data.shake = math.max(0, data.shake - dt * 6)
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),
    
    CutsceneScene:new({
        description = "",
        
        duration = (0.02 * 3),
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("clap")
        end,
    }),

    CutsceneScene:new({
        description = "Show button",

        duration = 1.0,
        enter = function(cutscene, data)
            data.btn_t = 0
            data.button.is_visible = true
            game:screenshake(4)
        end,
        update = function(cutscene, data, dt)
            data.btn_t = clamp(data.btn_t + dt*3, 0, 1)
            data.button.y = (15*16 - 5) - (ease_out_overshoot(data.btn_t) * 20)
        end,
        exit = function(cutscene, data)
        end
    }),

    CutsceneScene:new({
        description = "Jump on button",

        duration = 0.55,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("airborne")
            data.ceo.gravity = data.ceo.default_gravity
            data.ceo.friction_x = 1.0
            data.ceo.vx = -16
            data.ceo.vy = -400
        end,
        update = function(cutscene, data, dt)
        end,
        exit = function(cutscene, data)
            data.ceo.gravity = 0
            data.ceo.friction_x = 1.0
            data.ceo.vx = 0
            data.ceo.vy = 0

            game:screenshake(4)
        end
    }),
    

    CutsceneScene:new({
        description = "Wait",

        duration = 0.7,
    }),

    CutsceneScene:new({
        description = "Shake button",

        duration = 0.7,

        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(1), random_neighbor(1))
            data.button.spr:update_offset(random_neighbor(1), random_neighbor(1))
        end,
        exit = function(cutscene, data)
        end
    }),

    CutsceneScene:new({
        description = "Shake button",

        duration = 0.7,

        enter = function(cutscene, data)
            Audio:play("sfx_actor_button_small_glass_damage_{01-06}")
            Particles:image(data.button.mid_x, data.button.mid_y, 40, images.glass_shard, 8, 400, 0.3)
            data.button.spr:set_animation("cracked")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(2), random_neighbor(2))
            data.button.spr:update_offset(random_neighbor(2), random_neighbor(2))
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
            data.button.spr:update_offset(0, 0)
        end
    }),

    CutsceneScene:new({
        description = "Press button",

        duration = 0.04,

        enter = function(cutscene, data)
            Audio:play("sfx_actor_button_small_glass_break")
            Particles:image(data.button.mid_x, data.button.mid_y, 60, images.glass_shard, 8, 400, 0.3)
            data.button.spr:set_animation("pressed")
            data.t = 0
            data.ceo_y_start = data.ceo.y
        end,
        update = function(cutscene, data, dt)
            data.t = clamp(data.t + dt*(1/0.04), 0, 1)
            data.ceo.y = lerp(data.ceo_y_start, data.ceo_y_start + 8, data.t)
        end,
        exit = function(cutscene, data)
            Audio:play("sfx_actor_button_small_pressed")
            game:screenshake(5)
        end
    }),

    CutsceneScene:new({
        description = "Wait",

        duration = 1.0,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 1.0,

        update = function(cutscene, data, dt)
            game:screenshake(1)
        end,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 1.0,

        update = function(cutscene, data, dt)
            game:screenshake(2)
        end,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 1.0,

        update = function(cutscene, data, dt)
            game:screenshake(4)
        end,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 2.0,

        update = function(cutscene, data, dt)
            game:screenshake(6)
        end,
    }),

    CutsceneScene:new({
        description = "Big glove",

        duration = 2.0,

        enter = function(cutscene, data)
            data.big_glove_init_y = data.big_glove.y 
            data.t = 0

            data.has_shot_players = false

            game:frameskip(5)
            game:screenshake(15)

            Input:vibrate_all(0.5, 1.0)

            for ix = data.big_glove.x - 5*16, data.big_glove.x + 5*16, 16 do
                Particles:image(ix, 3*16, 5,
                    { images.cabin_fragment_1, images.cabin_fragment_2, images.cabin_fragment_3 }, 4, nil, nil, nil,
                    {
                        vx1 = -50,
                        vx2 = 50,

                        vy1 = 80,
                        vy2 = 200,
                    })
            end

        end,
        update = function(cutscene, data, dt)
            data.t = clamp(data.t + 2*dt, 0, 1)

            -- Update glove
            local target = 14.5*16
            data.big_glove.y = xerp(ease_out_overshoot, data.big_glove_init_y, target, data.t) 

            -- KICK PLAYERS
            if data.big_glove.y > target and not data.has_shot_players then
                -- Effects
                game:frameskip(25)
                game:screenshake(15)

                -- Star effect
                Particles:push_layer(PARTICLE_LAYER_BACK)
                for _, player in pairs(game.players) do
                    local a = random_range(0, pi2)
                    Particles:static_image(images.star_big, player.mid_x, player.mid_y, a, 0.05, 0.8, {
                        color = player.color_palette[1]
                    })
                end
                Particles:pop_layer()

                -- Do stuff to players
                for _, player in pairs(game.players) do
                    player.is_affected_by_bounds = false
                    player.is_affected_by_walls = false
                    player.is_vulnerable_to_kill_zone = false
                    player.vy = 400
                    player.spr:set_animation("dead")
                end

                data.has_shot_players = true
            end

            -- Smoke trail effect
            if data.has_shot_players then
                for _, player in pairs(game.players) do
                	Particles:dust(player.mid_x, player.mid_y, COL_WHITE, nil, nil, nil)
                end
            end
        end,
        exit = function(cutscene, data)
            data.big_glove.y = 14.5*16
        end,
    }),
    
    CutsceneScene:new({
        description = "Pan camera down",

        duration = 1.6,
        enter = function(cutscene, data)
            game.camera.follows_players = false
        	game.camera.max_y = CANVAS_HEIGHT
            data.cam_speed = 0.0  

            for _, player in pairs(game.players) do
                player.is_visible = false
                player:set_position(nil, -100000)
                player.gravity_mult = 0
                player.show_gun = false
            end
        end,
        update = function(cutscene, data, dt)
            data.big_glove.y = 14.5*16

            data.cam_speed = data.cam_speed + dt*600
            game.camera.y = game.camera.y + data.cam_speed * dt
        end,
        exit = function(cutscene, data)
        end,
    }),
    
    CutsceneScene:new({
        description = "Reset background & camera",

        duration = 5.0,
        enter = function(cutscene, data)
            game.level.backroom.background_state = "void"
            game.level.world_generator:reset()

            game.camera.max_x = 0
            game.camera.max_y = 0
            game.camera.is_x_locked = true
            game.camera.is_y_locked = true
            game.camera:set_position(0, 0)

            local num_players = game:get_number_of_alive_players()
            for _, player in pairs(game.players) do
                local r = 0
                local sp = 32
                if num_players > 1 then
                    r = (player.n - 1) / (num_players - 1)
                end
                player:set_position(CANVAS_WIDTH/2 - sp*(num_players-1)*0.5 + r*sp, CANVAS_HEIGHT)
				player.gravity_mult = 0
                player.is_visible = true
                player.friction_x = 0.0
                
				player.vx = 0
				player.vy = 0

                player.spr:set_rotation(random_range_int(0, 3) * pi/2)

                player:reset_virtual_controller()
            end

            data.update_fall = function(dt, update_fake_counter)
                Particles:speed_line(random_range(0, CANVAS_WIDTH), CANVAS_HEIGHT + 64)
    
                for _, player in pairs(game.players) do
                    player.spr:update_offset(random_neighbor(2), random_neighbor(2))
                    player.spr:set_animation("dead")
                    player:set_position(nil, player.y - clamp(player.y - CANVAS_HEIGHT/2, 0, 64)*dt)
                end

                if update_fake_counter then
                    data.fake_counter = max(-20, data.fake_counter - dt*10)
                    game.game_ui.ending_counter_text = elevator_counter_format(data.fake_counter)
                end
            end
        end,
        update = function(cutscene, data, dt)
            data.update_fall(dt)
        end,
    }),
    
    CutsceneScene:new({
        description = "W4",

        duration = 2.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w4"
            data.fake_counter = 80
        end,
        update = function(cutscene, data, dt)
            game.level.backroom.bg_w4.offset_y = 160
            game.level.backroom.bg_w4.speed = -1000
            game.level.backroom.bg_w4:update(dt)
            data.update_fall(dt, true)
        end,
    }),

    
    CutsceneScene:new({
        description = "W3",

        duration = 2.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w3"
        end,
        update = function(cutscene, data, dt)
            game.level.backroom.bg_w3.speed = -1000
            game.level.backroom.bg_w3:update(dt)
            data.update_fall(dt, true)
        end,
    }),
    
    CutsceneScene:new({
        description = "W2",

        duration = 2.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w2"
        end,
        update = function(cutscene, data, dt)
            game.level.backroom.bg_w2.speed = -1000
            game.level.backroom.bg_w2:update(dt)
            data.update_fall(dt, true)
        end,
    }),

    CutsceneScene:new({
        description = "W1",

        duration = 2.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w1"
        end,
        update = function(cutscene, data, dt)
            game.level.backroom.bg_w1.speed = -1000
            game.level.backroom.bg_w1:update(dt)
            data.update_fall(dt, true)
        end,
    }),

    CutsceneScene:new({
        description = "W0",

        duration = 2.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w0"
            data.spd = 0
        end,
        update = function(cutscene, data, dt)
            game.level.backroom.bg_w0.speed = -1000
            game.level.backroom.bg_w0:update(dt)

            data.update_fall(dt, true)
            if data.fake_counter < 10 then
                data.spd = data.spd + dt*200
                for _, player in pairs(game.players) do
                    player.y = min(player.y + data.spd*dt, CANVAS_HEIGHT+32)
                end
            end
        end,
    }),
    

    CutsceneScene:new({
        description = "Wait for particles to settle",

        duration = 0.5,

        enter = function(cutscene, data)
        end
    }),

    CutsceneScene:new({
        description = "Crash",

        duration = 3.0,

        enter = function(cutscene, data)
            game.level.backroom.background_state = "w0"
            data.spd = 0

            for ix = CANVAS_WIDTH/2 - 4*16, CANVAS_WIDTH/2 + 4*16, 16 do
                Particles:image(CANVAS_WIDTH/2, CANVAS_HEIGHT, 5,
                    { images.cabin_fragment_1, images.cabin_fragment_2, images.cabin_fragment_3 }, 4, nil, nil, nil,
                    {
                        vx1 = -50,
                        vx2 = 50,

                        vy1 = -100,
                        vy2 = -200,
                    }
                )
            end
            game:screenshake(8)
        end,
        update = function(cutscene, data, dt)
        end,
    }),

    CutsceneScene:new({
        description = "Wait b4 fadeout",

        duration = 1.0,

        enter = function(cutscene, data)
            game.game_ui.ending_counter_text = nil
        end,
        update = function(cutscene, data, dt)
        end,
    }),
    --]]

    CutsceneScene:new({
        description = "Set to basement",

        duration = 2.0,
        enter = function(cutscene, data)
            for _, a in pairs(game.actors) do
                if not a.is_player then
                    a:remove()
                end
            end

            game.level:begin_backroom(BackroomBasement:new())
            game.level:set_backroom_on()

            game.light_world:reset_lights()

            local px = 960
            data.py = 220
            local avg = 0
            local nbplayer = 0
            for _, player in pairs(game.players) do
                player.is_visible = true
                player.spr:set_rotation(0)

                player.is_affected_by_bounds = true
                player.is_affected_by_walls = true

                player:reset_virtual_controller()
				player.gravity_mult = 1
				player.friction_x = player.default_friction
				player.vx = 0
                player.is_vulnerable_to_kill_zone = true
                player.show_gun = true
                player.show_hud = true
                player.do_fury_trail = true

                local x = px + (player.n-1)*16
                player:set_position(x, data.py)
                avg = avg + player.mid_x
                nbplayer = nbplayer + 1
                
                game.game_ui.ending_counter_text = nil

                game.light_world:new_light(tostring(player.n), LightPoint:new(0, 0, {
                    radius = 48,
                    is_active = true,
                    target = player,
                }))
            end
            data.px = avg / nbplayer

            game.music_player:set_disk("off")
            game.game_ui.cinematic_bars_enabled = false

            game.camera:set_position(math.huge, 0)
            game.camera.follow_speed = DEFAULT_CAMERA_FOLLOW_SPEED
            game.camera.max_y = 0

            game.game_ui.dark_overlay_alpha_target = 0.0
            game.game_ui.dark_overlay_alpha = 0.0
            game.game_ui:start_iris_transition(data.px - game.camera.x, data.py + 8, 1.0, 0, CANVAS_WIDTH)

            game.is_light_on = false
            game.light_world.darkness_intensity = 1.0
            game.light_world.custom_fill_color = COL_BLACK_BLUE
        end,
    }),

    
    CutsceneScene:new({
        description = "Give back controls to players",

        duration = 1.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_USER)            
            end

            game.camera:set_x_locked(false)
            game.camera:set_y_locked(true)
            game.camera.follows_players = true
            game.camera.target_ox = 0.0

            game.game_ui.show_fury = true
            game.game_ui.offscreen_indicators_enabled = true
            game.game_ui.dark_overlay_color_override = nil

            game.draw_shadows = false

            -- game.is_light_on = true --REMOVEME
        end
    })
})
