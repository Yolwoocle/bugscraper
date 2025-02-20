local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"

local cutscenes = {}

cutscenes.tutorial_start = Cutscene:new("tutorial_end", {
    CutsceneScene:new({
        description = "",

        duration = 3.0,
        enter = function(scene)
            game.can_join_game = false 
            game.logo_y = -5000
            game.logo_y_target = -5000

            game.camera.follows_players = false
            game.camera.min_y = -999999    
            game.camera:set_position(0, -2200)    
            game.camera.max_speed = 100
            
            local cx, cy = DEFAULT_CAMERA_X, DEFAULT_CAMERA_Y
            if game.level.backroom and game.level.backroom.get_default_camera_position then
                cx, cy = game.level.backroom:get_default_camera_position()
            end
            game.camera.target_y = cy
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 5.0,
        enter = function(scene)
            game.game_ui:start_title("Léo Bernard", "Yolwoocle", "{menu.credits.game_by}", 0.5, 4.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 5.0,
        enter = function(scene)
            game.game_ui:start_title("OLX", "Alexandre Mercier", "{menu.credits.music}", 0.5, 4.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 5.0,
        enter = function(scene)
            game.game_ui:start_title("Martin Domergue", "Verbaudet", "{menu.credits.sound_design}", 0.5, 4.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(scene)
            game.game_ui:start_title("Ninesliced", "", "{menu.credits.published_by}", 0.5, 4.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 0.1,
        enter = function(scene)
	        game.logo_y_target = 0

            game.camera.follows_players = true
            game.camera.min_y = 0    
            game.camera.max_speed = DEFAULT_CAMERA_MAX_SPEED
            game.can_join_game = true 

            Metaprogression:set("has_seen_intro_credits", true)
        end,
    }),
})


cutscenes.tutorial_end = Cutscene:new("tutorial_end", {
    CutsceneScene:new({
        description = "Start",
        duration = 1.0,
        enter = function(scene)
            game.menu_manager:set_can_pause(false)

            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end

            game.can_join_game = false 
            game.logo_y_target = -70
        end,
    }),
    CutsceneScene:new({
        description = "All players walk into position",
        duration = 3.0,
        enter = function(scene)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(88*16 + player.n*16)
            end
        end,
    }),
    CutsceneScene:new({
        description = "Players walk into the building",
        duration = 2.0,
        enter = function(scene)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(9999999)
            end
        end,
    }),
    CutsceneScene:new({
        description = "Pan camera up",

        duration = 7.0,
        enter = function(scene)
            game.camera.follows_players = false
            game.camera.min_y = -2000000    
            game.camera.target_y = -1000
        end,
    }),
    CutsceneScene:new({
        description = "Pan camera up",

        duration = 2.0,
        enter = function(scene)
            Metaprogression:set("has_played_tutorial", true)
            game.game_ui.dark_overlay_alpha_target = 1.0
        end,
    }),
    CutsceneScene:new({
        description = "Pan camera up",
        duration = 0.1,

        enter = function(scene)
            game.menu_manager:set_can_pause(true)
            game.game_ui.dark_overlay_alpha = 0.0
            game.game_ui.dark_overlay_alpha_target = 0.0
            game:new_game({
                dark_overlay_alpha = 1.0,
                dark_overlay_alpha_target = 0.0,
            })
        end

    })
})


cutscenes.enter_ceo_office = Cutscene:new("enter_ceo_office", {
    CutsceneScene:new({
        description = "Setup scene",
        duration = 1.0,
        enter = function(scene)
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end

            game.game_ui.cinematic_bars_enabled = true
        end,
    }),
    CutsceneScene:new({
        description = "All players walk into position",
        duration = 4.0,
        enter = function(scene)
            for _, player in pairs(game.players) do
                if player.x < 79*16 - CANVAS_WIDTH then
                   player.x = 79*16 - CANVAS_WIDTH
                   Particles:smoke_big(player.mid_x, player.mid_y, COL_WHITE)
                end
            end
            -- boss min x = 79*16
            
            for _, player in pairs(game.players) do
                local target_x = 79*16 + 8 + (4-player.n) * 24 
                player:set_code_input_mode_target_x(target_x)
            end
        end,
        update = function(scene, dt)
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
        exit = function(scene)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x()
            end
        end
    }),
    CutsceneScene:new({
        description = "Set level walls",

        duration = 1.0,
        enter = function(scene)
            game.level.world_generator:write_rect(Rect:new(78, 10, 78, 14), TILE_METAL)
            game:screenshake(6)
        end,
    }),
    CutsceneScene:new({
        description = "Give back controls to players",

        duration = 1.0,
        enter = function(scene)
            for _, p in pairs(game.players) do
                p:set_input_mode(PLAYER_INPUT_MODE_USER)
            end

            game.music_player:set_disk("miniboss")
            game.game_ui.cinematic_bars_enabled = false
        end,
    }),
    CutsceneScene:new({
        description = "Give back control to boss",

        duration = 1.0,
        enter = function(scene)
            for _, actor in pairs(game.actors) do
                if actor.name == "final_boss" then
                    actor.state_machine:set_state("standby")
                end
            end
        end,
    }),
})


cutscenes.dung_boss_enter = Cutscene:new("dung_boss_enter", {
    CutsceneScene:new({
        duration = 1.9,
    }),
    CutsceneScene:new({
        duration = 1.5,
        enter = function(scene)
            if not Options:get("skip_boss_intros") then
                game.menu_manager:set_menu("w1_boss_intro")
            end
        end,
    }),
})


cutscenes.bee_boss_enter = Cutscene:new("bee_boss_enter", {
    CutsceneScene:new({
        duration = 1.5,
        enter = function(scene)
            game.light_world.darkness_intensity = 0.85

            game.level.slowdown_timer_override = 3.0
            game.level.opened_door_timer_override = 6.0
            game.is_light_on = false
        end,
    }),
    CutsceneScene:new({
        duration = 0.3,
        enter = function(scene)
            game.light_world:new_light("center", Light:new(CANVAS_WIDTH/2, -32, {
                angle = pi*0.5,
                spread = pi*0.1,
                range = 800,
                is_active = true,
            }))
            Audio:play_var("spotlight_1", nil, 1.05)
        end,
    }),
    CutsceneScene:new({
        duration = 0.3,
        enter = function(scene)
            game.light_world:new_light("left", Light:new(500, -32, {
                angle = pi*0.7, 
                spread = pi*0.05, 
                range = 800, 
                is_active = true,
            }))
            Audio:play_var("spotlight_2", nil, 1.05)
        end,
    }),
    CutsceneScene:new({
        duration = 2.0,
        enter = function(scene)
            game.light_world:new_light("right", Light:new(CANVAS_WIDTH - 500, -32, {
                angle = pi*0.3, 
                spread = pi*0.05, 
                range = 800, 
                is_active = true,
            }))
            Audio:play_var("spotlight_3", nil, 1.05)
        end,
    }),
    -- Scene:new({
    --     duration = 1.5,
    --     enter = function(scene)
    --         game.menu_manager:set_menu("w2_boss_intro")
    --     end,
    -- }),
    CutsceneScene:new({
        enter = function(scene)
            game.level.slowdown_timer_override = nil
            game.level.opening_door_timer_override = nil
            game.level.opened_door_timer_override = nil
            
            local light_settings = {
                ["left"] = {1, pi/12},
                ["right"] = {0.7, pi/12},
                ["center"] = {1.23, pi/12},
            }

            for name, light in pairs(game.light_world.lights) do
                light.oscillation_enabled = true
                light.oscillation_speed = light_settings[name][1]
                light.oscillation_amplitude = light_settings[name][2]
            end

            local boss
            for _, actor in pairs(game.actors) do
                if actor.name == "bee_boss" then
                    boss = actor
                    break
                end
            end
            if boss then
                game.light_world.lights.center.target = boss
            end
        end,
    }),
    CutsceneScene:new({
        update = function(scene, dt)
            game.light_world.darkness_intensity = move_toward(game.light_world.darkness_intensity, 0.4, 0.3*dt)
        end
    }),
})

return cutscenes