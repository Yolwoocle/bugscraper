local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"
local images = require "data.images"

return Cutscene:new("bee_boss_enter", {
    CutsceneScene:new({
        duration = 1.5,
        enter = function(cutscene, data)
            game.light_world.darkness_intensity = 0.85

            game.level.slowdown_timer_override = 3.0
            game.level.opened_door_timer_override = 1.0
            game.is_light_on = false

            -- game.level.elevator:set_layer("door_background", false)
        end,
    }),
    CutsceneScene:new({
        duration = 0.3,
        enter = function(cutscene, data)
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
        enter = function(cutscene, data)
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
        duration = 0.3,
        enter = function(cutscene, data)
            game.light_world:new_light("right", Light:new(CANVAS_WIDTH - 500, -32, {
                angle = pi*0.3, 
                spread = pi*0.05, 
                range = 800, 
                is_active = true,
            }))
            Audio:play_var("spotlight_3", nil, 1.05)
        end,
    }),
    CutsceneScene:new({
        duration = 1.1,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
            -- Particles:falling_cabin_back(game.level.cabin_rect.ax, game.level.cabin_rect.by)
        end
    }),
    CutsceneScene:new({
        duration = 0,
        enter = function(cutscene, data)
            if not Options:get("skip_boss_intros") then
                game.menu_manager:set_menu("w2_boss_intro")
            end
        end,
    }),
    CutsceneScene:new({
        enter = function(cutscene, data)
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
        update = function(cutscene, data, dt)
            game.light_world.darkness_intensity = move_toward(game.light_world.darkness_intensity, 0.4, 0.3*dt)
        end
    }),
})