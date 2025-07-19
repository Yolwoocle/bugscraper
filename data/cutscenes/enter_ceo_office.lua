local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"
local images = require "data.images"

return Cutscene:new("enter_ceo_office", {
    CutsceneScene:new({
        description = "Setup scene",
        duration = 1.0,
        enter = function(cutscene, data)
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
        enter = function(cutscene, data)
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
            end
        end
    }),
    CutsceneScene:new({
        description = "Set level walls",

        duration = 1.0,
        enter = function(cutscene, data)
            game.level.world_generator:write_rect(Rect:new(78, 10, 78, 14), TILE_METAL)
            game:screenshake(6)
        end,
    }),
    CutsceneScene:new({
        description = "Give back controls to players",

        duration = 1.0,
        enter = function(cutscene, data)
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
        enter = function(cutscene, data)
            for _, actor in pairs(game.actors) do
                if actor.name == "final_boss" then
                    actor.state_machine:set_state("standby")
                end
            end
        end,
    }),
})
