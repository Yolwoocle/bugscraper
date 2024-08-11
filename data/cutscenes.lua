local Cutscene = require "scripts.game.cutscene"
local Scene    = require "scripts.game.scene"
local Light = require "scripts.graphics.light"

local cutscenes = {}

cutscenes.boss_enter = Cutscene:new {
    Scene:new({
        duration = 1.5,
        enter = function(scene)
            game.light_world.darkness_intensity = 0.85

            game.level.slowdown_timer_override = 3.0
            game.level.opened_door_timer_override = 6.0
            game.is_light_on = false
        end,
    }),
    Scene:new({
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
    Scene:new({
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
    Scene:new({
        duration = 2.3,
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
    Scene:new({
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
        end,
    }),
    Scene:new({
        update = function(scene, dt)
            game.light_world.darkness_intensity = move_toward(game.light_world.darkness_intensity, 0.4, 0.3*dt)
        end
    }),
}

return cutscenes