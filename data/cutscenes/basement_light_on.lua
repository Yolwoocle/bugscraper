local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light.light_spotlight"
local Rect = require "scripts.math.rect"
local images = require "data.images"
local guns = require "data.guns"
local BackroomBasement = require "scripts.level.backroom.backroom_basement"
local LightPoint      = require "scripts.graphics.light.light_point"

local function on(opacity)
    game.light_world.darkness_intensity = opacity
	game:set_actor_draw_color(nil)
    game.level.backroom.show_basement_bg = true
end

local function off()
    game.light_world.darkness_intensity = 1.0
	game:set_actor_draw_color(COL_BLACK_BLUE)
    game.level.backroom.show_basement_bg = false
end

return Cutscene:new("enter_ceo_office", {
    CutsceneScene:new({
        description = "Wait",
        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        description = "ON",
        duration = 0.05,
        enter = function(cutscene, data)
            on(0.7)
        end,
    }),
    CutsceneScene:new({
        description = "OFF",
        duration = 0.07,
        enter = function(cutscene, data)
            off()
        end,
    }),
    CutsceneScene:new({
        description = "ON",
        duration = 0.05,
        enter = function(cutscene, data)
            on(0.7)
        end,
    }),
    
    CutsceneScene:new({
        description = "OFF",
        duration = 0.07,
        enter = function(cutscene, data)
            off()
        end,
    }),
    
    CutsceneScene:new({
        description = "ON",
        duration = 0.5,
        enter = function(cutscene, data)
            on(0.3)
        end,
    }),
    
    CutsceneScene:new({
        description = "OFF",
        duration = 0.07,
        enter = function(cutscene, data)
            game.is_light_on = true
            game.light_world:reset_lights()
        end,
    }),

    CutsceneScene:new({
        description = "Wait",
        duration = 7.0,
        enter = function(cutscene, data)
        	game.level.world_generator:write_rect(Rect:new(2, 0, 68, 0), TILE_AIR) -- Wall
        end,
    }),

    CutsceneScene:new({
        description = "Wait",
        duration = 0,
        enter = function(cutscene, data)
            game.game_ui:enable_floating_text("🈶 {input.prompts.jetpack}")
        end,
    }),
})
