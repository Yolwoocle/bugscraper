local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light.light_spotlight"
local Rect = require "scripts.math.rect"
local images = require "data.images"
local guns = require "data.guns"
local BackroomBasement = require "scripts.level.backroom.backroom_basement"
local LightPoint      = require "scripts.graphics.light.light_point"

return Cutscene:new("basement_zoom_into_rocket", {
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
        	local cx, cy = math.floor(game.camera:get_real_position())
            local x = game.level.backroom:get_rocket_x() + images.basement_rocket_small:getWidth()/2
            local y = game.level.backroom.rocket_y + 32
            game.game_ui:start_iris_transition(x - cx, y, 1.0, CANVAS_WIDTH, 42)
        end,
    }),
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:start_iris_transition(nil, nil, 1.0, nil, 0)           
        end,
    }),
    CutsceneScene:new({
        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),

    CutsceneScene:new({
        duration = 0.0,
        enter = function(cutscene, data)
        end,
    }),
})
