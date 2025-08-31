local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"
local images = require "data.images"

return Cutscene:new("tutorial_end_short", {
    CutsceneScene:new({
        description = "Start",
        duration = 1.0,
        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(false)

            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end

            game.can_join_game = false 
            game.game_ui.logo_y_target = -70
            game.game_ui.cinematic_bars_enabled = true
        end,
    }),
    CutsceneScene:new({
        description = "All players walk into position",
        duration = 3.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(88*16 + player.n*16)
            end
        end,
    }),
    CutsceneScene:new({
        description = "Players walk into the building",
        duration = 2.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(9999999)
            end
        end,
    }),
    CutsceneScene:new({
        description = "Start dark fadeout",

        duration = 2.0,
        enter = function(cutscene, data)
            Metaprogression:set("has_played_tutorial", true)
            game.game_ui.dark_overlay_alpha_target = 1.0
        end,
    }),
    CutsceneScene:new({
        description = "End dark fadeout",
        duration = 0.1,

        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(true)
            game.game_ui.dark_overlay_alpha = 0.0
            game.game_ui.dark_overlay_alpha_target = 0.0
            game:new_game({
                dark_overlay_alpha = 1.0,
                dark_overlay_alpha_target = 0.0,
            })
            game.game_ui.cinematic_bars_enabled = false
        end
    })
})
