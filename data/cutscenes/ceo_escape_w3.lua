local Cutscene      = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light         = require "scripts.graphics.light"
local Rect          = require "scripts.math.rect"
local images        = require "data.images"
local guns          = require "data.guns"

local function dust_particles(data)
    -- local vx = random_range(40, 60)
    -- Particles:dust(data.ceo.x, data.ceo.y, COL_WHITE, 8, nil, 0, {
    --     vx1 = -vx, vx2 = -vx, vy1 = 0, vy2 = 0
    -- })
    -- Particles:dust(data.ceo.x, data.ceo.y, COL_WHITE, 8, nil, 0, {
    --     vx1 = vx, vx2 = vx, vy1 = 0, vy2 = 0
    -- })

	Particles:smoke(data.ceo.x, data.ceo.y)
end

return Cutscene:new("ceo_escape_w2", {
    CutsceneScene:new({
        description = "",

        duration = 0.01,
        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(false)
            game.game_ui.cinematic_bars_enabled = true
            game.game_ui.cinematic_bar_color = COL_VERY_DARK_GRAY
            game.game_ui.offscreen_indicators_enabled = false
            game.camera:set_target_offset(10000, 0)

            data.resigning_player = nil
            for _, player in pairs(game.players) do
                if player.gun.name == "resignation_letter" then
                    data.resigning_player = player
                end
            end
            assert(data.resigning_player ~= nil)
            data.resigning_player:set_code_input_mode_target_x(47 * 16)

            local n = 1
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
                if player ~= data.resigning_player then
                    player:set_code_input_mode_target_x(47 * 16 - n * 16)
                end
            end

            for _, actor in pairs(game.actors) do
                if actor.name == "npc" and actor.npc_name == "ceo" then
                    data.ceo = actor
                end
            end
        end,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
    }),
    CutsceneScene:new({
        description = "Shocked",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires_shocked")
            data.shake = 3.0

            Particles:static_image(images.surprise_effect, data.ceo.x - 16, data.ceo.y - 30, 0, 0.3)
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
        description = "Wait for a bit",

        duration = 1.5,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 1.0,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires")
            data.shake = 3.0
			Particles:sweat(data.ceo.x - 15, data.ceo.y - 30, true)
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(data.shake), 0)
            data.shake = math.max(0, data.shake - dt * 6)
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),

    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires_shocked")
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(48 * 16)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 1.0,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(49 * 16)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(51 * 16)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(53 * 16)
        end,
    }),

    CutsceneScene:new({
        description = "Big ass slap in the face (jump)",

        duration = 0.35,
        enter = function(cutscene, data)
            data.resigning_player.virtual_controller.actions["jump"] = true
            data.frames = 0
        end,
        update = function(cutscene, data, dt)
            data.frames = data.frames + 1
            if data.frames > 3 then
                data.resigning_player.virtual_controller.actions["jump"] = false
            end
        end,
        exit = function(cutscene, data)
            data.resigning_player.virtual_controller.actions["jump"] = false
        end,
    }),
    CutsceneScene:new({
        description = "Big ass slap in the face (bammm)",

        duration = 0.3,
        enter = function(cutscene, data)
            Particles:push_layer(PARTICLE_LAYER_BACK)
            Particles:static_image(
                images.star_big, 
                (data.resigning_player.mid_x + data.ceo.mid_x)/2, 
                data.resigning_player.mid_y, 
                0, 1.0, 0.8, {
                color = COL_WHITE
            })
            Particles:pop_layer()

            data.ceo.spr:set_animation("tangled_wires")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(3), random_neighbor(3))
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),
    CutsceneScene:new({
        description = "Image of the big ass slap in the face",

        duration = 0.5,
        enter = function(cutscene, data)
            game.menu_manager:set_menu("ceo_slap")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(3), random_neighbor(3))
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),

    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),

    CutsceneScene:new({
        description = "Blink (closed)",

        duration = 0.05,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (open)",

        duration = 0.2,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires_shocked")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (closed)",

        duration = 0.05,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (open)",

        duration = 0.2,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("tangled_wires_shocked")
        end,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
        enter = function(cutscene, data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player goes away",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:equip_gun(guns.unlootable.EmptyGun:new(data.resigning_player))
            data.resigning_player:set_code_input_mode_target_x(420) -- Nice.
        end,
    }),
    CutsceneScene:new({
        description = "Remaining players go away",

        duration = 3.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                if player ~= data.resigning_player then
                    player:set_code_input_mode_target_x(420)
                end
            end
        end,
    }),

    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Iris phase 1",

        duration = 0.8,
        enter = function(cutscene, data)
            local x = data.ceo.x - game.camera.x
            local y = data.ceo.y - game.camera.y - 16
            game.game_ui:start_iris_transition(x, y, 0.8, CANVAS_WIDTH, 50)
        end,
    }),

    
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Iris end",

        duration = 1.0,
        enter = function(cutscene, data)
            local x = data.ceo.x - game.camera.x
            local y = data.ceo.y - game.camera.y - 16
            game.game_ui:start_iris_transition(x, y, 0.5, 50, 0)
        end,
    }),
    
    CutsceneScene:new({
        description = "Wait",

        duration = 1.5,
        enter = function(cutscene, data)
        end,
    }),
    
    CutsceneScene:new({
        description = "Credits",

        duration = 3.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("Léo Bernard", "Yolwoocle", "{menu.credits.game_by}", 0, 3.2, 0)
        end,
    }),
})
