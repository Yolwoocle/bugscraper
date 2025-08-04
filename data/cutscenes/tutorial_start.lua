local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"
local images = require "data.images"

return Cutscene:new("tutorial_start", {
    CutsceneScene:new({
        description = "",

        duration = 3.0,
        enter = function(cutscene, data)
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

        duration = 4.2,
        enter = function(cutscene, data)
            game.game_ui:start_title("Léo Bernard", "🦋 @yolwoocle.com", "{menu.credits.game_by}", 0.5, 3.2, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 4.2,
        enter = function(cutscene, data)
            game.game_ui:start_title("Alexandre Mercier", "OLX", "{menu.credits.music}", 0.5, 3.2, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 4.2,
        enter = function(cutscene, data)
            game.game_ui:start_title("Martin Domergue", "Verbaudet", "{menu.credits.sound_design}", 0.5, 3.2, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 4.2,
        enter = function(cutscene, data)
            game.game_ui:start_title("Noam Goldfarb", "𝕏 @SSlime7", "{menu.credits.additional_art}", 0.5, 3.2, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 4.2,
        enter = function(cutscene, data)
            game.game_ui:start_title("Ninesliced", "🦋 @ninesliced.com", "{menu.credits.game_by}", 0.5, 3.2, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 0.1,
        enter = function(cutscene, data)
	        game.logo_y_target = 0

            game.camera.follows_players = true
            game.camera.min_y = 0    
            game.camera.max_speed = DEFAULT_CAMERA_MAX_SPEED
            game.can_join_game = true 

            Metaprogression:set("has_seen_intro_credits", true)
        end,
    }),
})