require "scripts.util"
local backgrounds       = require "data.backgrounds"
local enemies           = require "data.enemies"
local cutscenes         = require "data.cutscenes"
local images            = require "data.images"

local Rect              = require "scripts.math.rect"
local LevelGeometry     = require "scripts.level.level_geometry"
local Wave              = require "scripts.level.wave"
local BackroomCafeteria = require "scripts.level.backroom.backroom_cafeteria"
local BackroomCEOOffice = require "scripts.level.backroom.backroom_ceo_office"
local E                 = require "data.enemies"

local ElevatorW1        = require "scripts.level.elevator.elevator_w1"
local ElevatorW2        = require "scripts.level.elevator.elevator_w2"
local ElevatorW3        = require "scripts.level.elevator.elevator_w3"

local utf8              = require "utf8"

RECT_ELEVATOR           = Rect:new(unpack(RECT_ELEVATOR_PARAMS))
RECT_CAFETERIA          = Rect:new(unpack(RECT_CAFETERIA_PARAMS))
RECT_CEO_OFFICE         = Rect:new(unpack(RECT_CEO_OFFICE_PARAMS))

local function new_cafeteria(params)
    params = params or {}

    local run_func = params.run_func or function(...) end
    local wave_enemies = {
        { E.UpgradeDisplay, 1, position = { 474 + 16, 181 }, ignore_position_clamp = true },
        { E.UpgradeDisplay, 1, position = { 530 + 16, 181 }, ignore_position_clamp = true },
        { E.UpgradeDisplay, 1, position = { 586 + 16, 181 }, ignore_position_clamp = true },
    }
    if params.empty_cafeteria then
        wave_enemies = {}
    end

    return Wave:new({
        floor_type = FLOOR_TYPE_CAFETERIA,
        roll_type = WAVE_ROLL_TYPE_FIXED,
        music = "cafeteria",
        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end
            end

            for i=1, MAX_NUMBER_OF_PLAYERS do
                if game.waves_until_respawn[i][2] then
                    game.waves_until_respawn[i][1] = -1
                end
            end

            run_func(self, level)
        end,

        min = 1,
        max = 1,
        enemies = wave_enemies,

        backroom = BackroomCafeteria,
        backroom_params = {
            ceo_info = params.ceo_info,
            empty_cafeteria = param(params.empty_cafeteria, false)
        },
    })
end

local function new_wave(params)
    params.bounds = params.bounds or RECT_ELEVATOR
    return Wave:new(params)
end

local function get_world_prefix(n)
    return Text:text("level.world_prefix", tostring(n))
end

local function get_world_name(n)
    return Text:text("level.world_" .. tostring(n))
end

local function spawn_timed_spikes()
    local j = 0
    for ix = 3, CANVAS_WIDTH / 16 - 4 do
        local spikes = enemies.TimedSpikes:new(ix * BW, CANVAS_HEIGHT * 0.85, 4, 1, 0.5, j * 0.2)
        spikes.z = 3 - j / 100
        game:new_actor(spikes)
        j = j + 1
    end
end

local function debug_wave()
    return new_wave({
        min = 1,
        max = 1,

        enemies = {
            { E.Motherboard, 1, position = { 3 * 16, 3 * 16 + 4 } },
        },
        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "electric_arc" then
                    actor:start_disable_timer(1)
                end
            end
        end,

        music = "miniboss",
    })
end

local function get_w4_vines_points_func_1(x_offset)
    return function()
        local pts = {}
        local center = (game.level.cabin_inner_rect.ax + game.level.cabin_inner_rect.bx) / 2

        local iy = 0
        while iy < game.level.cabin_rect.by + 32 do
            table.insert(pts, { center - x_offset + random_neighbor(8), iy })
            iy = iy + random_range(10, 40)
        end
        table.insert(pts, { center - x_offset + random_neighbor(8), game.level.cabin_rect.by + 32 })

        return pts
    end
end

local function get_w4_vines_points_func_2()
    return function()
        local pts = {}
        local center = (game.level.cabin_inner_rect.ax + game.level.cabin_inner_rect.bx) / 2

        local ix = 0
        for ix = 0, CANVAS_WIDTH, 16 do
            table.insert(pts, { ix, game.level.cabin_inner_rect.by + math.cos((ix-CANVAS_WIDTH/2)/32) * 32 })
        end

        return pts
    end
end

local function parse_waves_table(waves)
    local parsed_waves = {}

    local current_world = nil
    local current_background = nil
    local current_elevator = nil
    local current_music = nil
    for i = 1, #waves do
        local wave_params = waves[i]

        current_world = wave_params.world or current_world
        current_background = wave_params.background or current_background
        current_elevator = wave_params.elevator or current_elevator
        current_music = wave_params.music or current_music

        wave_params.world = current_world
        wave_params.background = current_background
        wave_params.elevator = current_elevator
        wave_params.music = current_music

        parsed_waves[i] = new_wave(wave_params)
    end
    return parsed_waves
end

local thorns_arc_params = {
    lightning_params = {
        style = LIGHTNING_STYLE_THORNS, 
        min_step_size = 10,
        max_step_size = 10,
        min_line_width = 0,
        max_line_width = 0,
        jitter_width = 0,
    }
}

local waves = parse_waves_table {
    
    -- Cafeteria
    -- new_cafeteria({ 
    --     run_func = function()
    --         game.actor_manager:kill_actors_with_name("electric_rays")
    --     end, 
    --     ceo_info = 3,
    --     empty_cafeteria = true
    -- }),


    -- {
    --     min = 1,
    --     max = 1,
    --     enemies = {{ E.Larva, 3 }},
    --     elevator = ElevatorW1,

    -- },
    -- {
    --     floor_type = FLOOR_TYPE_CAFETERIA,
    --     roll_type = WAVE_ROLL_TYPE_FIXED,
    --     music = "off",

    --     run = function(self, level)
    --         for _, actor in pairs(game.actors) do
    --             if actor.name == "poison_cloud" then
    --                 actor.lifespan = 1
    --             end
    --             if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
    --                 actor:remove()
    --             end
    --         end
    --     end,

    --     min = 1,
    --     max = 1,
    --     enemies = {},

    --     bounds = RECT_CEO_OFFICE,

    --     backroom = BackroomCEOOffice
    -- },

    -------------------------------------------


    {
        min = 5,
        max = 5,
        enemies = {
            { E.Larva, 3, entrances = { "main" } },
            -- { E.Fly,   3 },
        },
        music = "w1",

        over_title = get_world_prefix(1),
        title = get_world_name(1),
        title_color = COL_LIGHTEST_GRAY,
        title_outline_color = COL_BLACK_BLUE,

        elevator = ElevatorW1,
    },


    {
        -- Woodlouse intro
        min = 4,
        max = 6,
        enemies = {
            { E.Woodlouse, 2, entrances = { "main" } },
        },
    },

    {
        min = 4,
        max = 6,
        enemies = {
            { E.Larva,     2, entrances = { "main" } },
            { E.Fly,       3, entrances = { "main" } },
            { E.Woodlouse, 2, entrances = { "main" } },
        },
    },

    {
        -- Slug intro
        min = 4,
        max = 6,
        enemies = {
            { E.Larva, 2 },
            { E.Fly,   2 },
            { E.Slug,  4 },
        },
    },


    {
        min = 3,
        max = 5,
        enemies = {
            -- Shelled Snail intro
            { E.SnailShelled, 3 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            --
            { E.Larva,        4 },
            { E.Fly,          4 },
            { E.Woodlouse,    2 },
            { E.SnailShelled, 3 },
            { E.Slug,         2 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.SnailShelled, 4 },
            { E.SpikedFly,    3 },
            { E.Fly,          3 },
        },
    },

    {
        -- Mushroom ant intro
        roll_type = WAVE_ROLL_TYPE_FIXED,
        enemies = {
            { E.Fly,        2 },
            { E.Boomshroom, 4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          5 },
            { E.Slug,         2 },
            { E.SpikedFly,    4 },
            { E.Woodlouse,    4 },
            { E.SnailShelled, 4 },
        },
    },

    new_cafeteria(),

    {
        -- Spiked Fly intro
        min = 6,
        max = 8,
        music = "w1",

        enemies = {
            { E.Larva,     1 },
            { E.Fly,       2 },
            { E.SpikedFly, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,        1 },
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   4 },
            { E.Slug,         2 },
            { E.SnailShelled, 2 },
        },
    },

    {
        -- Spider intro
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,  1 },
            { E.Slug,   2 },
            { E.Spider, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Fly,          2 },
            { E.SnailShelled, 2 },
            { E.Spider,       4 },
        },
    },

    {
        min = 8,
        max = 9,
        enemies = {
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.SnailShelled, 2 },
            { E.Slug,         2 },
            { E.Spider,       4 },
        },
    },

    {
        -- Stink bug intro
        min = 5,
        max = 6,
        enemies = {
            { E.StinkBug, 3 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.Larva,        1 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          2 },
            { E.Slug,         2 },
            { E.Woodlouse,    2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     2 },
        },
    },

    {
        -- roll_type = WAVE_ROLL_TYPE_FIXED,
        min = 1,
        max = 1,
        enemies = {
            { E.Dung, 1, position = { CANVAS_WIDTH / 2 - 24 / 2, 200 } },
        },
        music = "miniboss",
        cutscene = "dung_boss_enter",
    },

    new_cafeteria({ ceo_info = 1 }),



    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W2: beehive / factory
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------


    {
        min = 6,
        max = 7,

        enemies = {
            { E.Larva, 2 },
            { E.Bee,   2 },
        },

        background = backgrounds.BackgroundFactory:new(),
        music = "w2",

        elevator = ElevatorW2,

        over_title = get_world_prefix(2),
        title = get_world_name(2),
        title_color = COL_LIGHT_YELLOW,
        title_outline_color = COL_BLACK_BLUE,
    },

    {
        min = 5,
        max = 7,

        enemies = {
            { E.Larva,  2 },
            { E.Bee,    2 },
            { E.Stabee, 4 },
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.Beelet, 2 },
        },
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.Larva,      4 },
            { E.Bee,        4 },
            { E.Boomshroom, 4 },
            { E.Beelet,     2 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         4 },
            { E.HoneypotAnt, 4 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,    4 },
            { E.Beelet, 3 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         3 },
            { E.HoneypotAnt, 4 },
            { E.Stabee,      3 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        }
    },

    {
        min = 10,
        max = 10,

        enemies = {
            { E.SnailShelled, 1 },
            { E.Bee,          3 },
            { E.HoneypotAnt,  1 },
            { E.Stabee,       2 },
            { E.Larva,        2 },
        },
    },


    {
        min = 6,
        max = 6,

        enemies = {
            { E.Beelet, 8 },
        },
        fixed_enemies = {
            { E.HoneycombFootball, 1 },
        },
    },

    ---------------------------------------------
    new_cafeteria(),
    ---------------------------------------------

    {
        min = 4,
        max = 4,

        enemies = {
            { E.DrillBee, 3 },
        },

        music = "w2",
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.Bee,   3 },
            { E.Larva, 3 },
        },

        run = function(self, level)
            spawn_timed_spikes()
        end,
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         3 },
            { E.Larva,       3 },
            { E.HoneypotAnt, 2 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.Stabee,      10 },
            { E.HoneypotAnt, 2 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,        20 },
            { E.Stabee,     10 },
            { E.Boomshroom, 20 },
            { E.DrillBee,   30 },
        },
        fixed_enemies = {
            { E.DrillBee, 1 },
        }
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.Bee,         3 },
            { E.HoneypotAnt, 3 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        },
    },


    {
        min = 7,
        max = 7,

        enemies = {
            { E.Bee,      3 },
            { E.DrillBee, 3 },
        },
    },


    {
        min = 9,
        max = 9,

        enemies = {
            { E.Larva,       3 },
            { E.Bee,         3 },
            { E.Stabee,      3 },
            { E.DrillBee,    3 },
            { E.HoneypotAnt, 3 },
            { E.Boomshroom,  3 },
        },
    },

    {
        -- roll_type = WAVE_ROLL_TYPE_FIXED,
        min = 1,
        max = 1,
        enemies = {
            { E.BeeBoss, 1, position = { 240 - 16, 200 } },
        },
        music = "miniboss",

        run = function(self, level)
            for _, actor in pairs(level.game.actors) do
                if actor.name == "timed_spikes" then
                    actor:remove()
                end
            end
        end,

        cutscene = "bee_boss_enter",
    },

    new_cafeteria({ run_func = function()
        for _, a in pairs(game.actors) do
            if a.name == "timed_spikes" then
                a:remove()
            end
        end

        game.is_light_on = true
    end,
        ceo_info = 2,
    }),

    ------

    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W3: server room
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    -- Floor
    {
        min = 6,
        max = 6,
        enemies = {
            { E.Chipper, 1 },
        },
        background = backgrounds.BackgroundServers:new(),
        music = "w3",

        elevator = ElevatorW3,

        elevator_layers = {
            ["bg_grid"] = true,
            ["fg_grid"] = false,
        },

        over_title = get_world_prefix(3),
        title = get_world_name(3),
        title_color = COL_LIGHT_GREEN,
        title_outline_color = COL_BLACK_BLUE,
    },

    {
        min = 5,
        max = 5,
        enemies = {
            { E.Woodlouse, 2 },
            { E.Fly,       2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        },
    },

    {
        min = 5,
        max = 7,
        enemies = {
            { E.Slug,      2 },
            { E.StinkBug,  2 },
            { E.Chipper,   2 },
            { E.BulbBuddy, 1 },
        },
    },

    {
        min = 6,
        max = 6,
        enemies = {
            { E.Grasshopper,  2 },
            { E.SnailShelled, 2 },
            { E.Woodlouse,    2 },
        },
    },

    {
        level_geometry = LevelGeometry:new({
            { rect = Rect:new(3, 8, 8, 8),   tile = TILE_METAL_SEMISOLID },
            { rect = Rect:new(21, 8, 26, 8), tile = TILE_METAL_SEMISOLID },
        }),
        elevator_layers = {
            ["bg_grid"] = false,
        },
        run = function(self, level)
            local cabin_rect = game.level.cabin_rect
            Particles:falling_grid(cabin_rect.ax + 16, cabin_rect.ay + 6 * 16)
            Particles:falling_grid(cabin_rect.bx - 7 * 16, cabin_rect.ay + 6 * 16)
            if level.elevator.start_grid_timer then
                level.elevator:start_grid_timer(2.5)
            end
        end,

        fixed_enemies = {
            {
                E.ElectricRays,
                1,
                position = { CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 8 },
                args = { {
                    n_rays = 1,
                    activation_delay = 2,
                    init_angle = pi / 2,
                    angle_speed = 0,
                } }
            },
        },

        min = 4,
        max = 6,
        enemies = {
            { E.Fly,     2 },
            { E.Chipper, 2 },
        },
    },

    {
        min = 3,
        max = 4,
        enemies = {
            { E.MetalFly, 4 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        },

        run = function(self, level)
            for _, enemy in pairs(game.actors) do
                if enemy.name == "electric_rays" then
                    enemy.angle_speed = 0.3
                end
            end
        end,
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.Slug,        4 },
            { E.StinkBug,    4 },
            { E.Chipper,     4 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    {
        min = 6,
        max = 7,
        enemies = {
            { E.Fly,         2 },
            { E.MetalFly,    4 },
            { E.Chipper,     4 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.SpikedFly, 2 },
            { E.StinkBug,  2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    ------------------------------------------------
    -- Cafeteria
    new_cafeteria({ run_func = function()
        game.actor_manager:kill_actors_with_name("electric_rays")
    end }),
    ------------------------------------------------

    {
        min = 4,
        max = 5,
        enemies = {
            { E.SnailShelledBouncy, 2 },
        },
        elevator_layers = {
            ["bg_grid"] = false,
            ["fg_grid"] = false,
        },

        fixed_enemies = {
            {
                E.ElectricRays,
                1,
                position = { CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 8 },
                args = {
                    {
                        n_rays = 1,
                        activation_delay = 2,
                        angle_speed = 0.3,
                    }
                }
            },
        },
        music = "w3",
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.Grasshopper,        2 },
            { E.StinkBug,           2 },
            { E.SnailShelledBouncy, 2 },
        },
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.SnailShelledBouncy, 2 },
            { E.Fly,                2 },
            { E.Boomshroom,         2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 2 }
        }
    },

    {
        min = 5,
        max = 6,
        { E.SnailShelledBouncy, 2 },
        enemies = {
            { E.Boomshroom,  2 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 }
        }
    },

    {
        min = 4,
        max = 5,
        enemies = {
            { E.Chipper,  2 },
            { E.StinkBug, 2 },
        },

        -- run = function(self, level)
        --     for _, player in pairs(game.players) do
        --         local arc = enemies.ElectricArc:new(CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5)
        --         arc:set_arc_target(player)
        --         arc.arc_damage = 2.5
        --         game:new_actor(arc)
        --     end
        -- end,
    },

    {
        min = 6,
        max = 7,

        enemies = {
            { E.SnailShelled, 2 },
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
        },
    },

    {
        min = 7,
        max = 9,

        enemies = {
            { E.Spider,    20 },
            { E.MetalFly,  20 },
            { E.BulbBuddy, 5 }
        },
    },

    {
        min = 6,
        max = 7,

        enemies = {
            { E.Spider,    2 },
            { E.Fly,       2 },
            { E.SpikedFly, 2 },
            { E.Chipper,   2 },
            { E.StinkBug,  2 },
        },
    },


    {
        min = 1,
        max = 1,

        enemies = {
            { E.Motherboard, 1, position = { 3 * 16, -40 } },
        },
        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "electric_arc" then
                    actor:start_disable_timer(1)
                end
            end
        end,

        music = "miniboss",
    },

    ------
    -- Cafeteria
    new_cafeteria({ 
        run_func = function()
            game.actor_manager:kill_actors_with_name("electric_rays")
        end, 
        -- ceo_info = 3,
    }),

    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W4: the gardens
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    {
        min = 4,
        max = 4,

        enemies = {
            { E.CloudEnemy, 20 },
        },

        elevator_layers = {
            ["bg_grid"] = false,
            ["w3_cabin"] = false,

            ["cabin_bg"] = images.cabin_bg_w4_test,
            ["walls"] = images.empty,
        },

        background = backgrounds.BackgroundGreenhouse:new(),
        music = "w4",

        over_title = get_world_prefix(4),
        title = get_world_name(4),
        title_color = COL_LIGHT_BLUE,
        title_outline_color = COL_BLACK_BLUE,
    },


    {
        min = 7,
        max = 7,

        enemies = {
            { E.CloudStorm, 30 },
            { E.CloudEnemy, 10 },
        },
    },

    {
        min = 3,
        max = 3,

        enemies = {
            { E.Rollopod, 1 },
        },
        fixed_enemies = {
            { E.CloudEnemy, 2 },
        }
    },

    {
        min = 7,
        max = 9,

        enemies = {
            { E.CloudEnemy,  5 },
            { E.CloudStorm,  5 },
            { E.Rollopod, 3 },
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.CloudEnemy, 2 },
        },

        fixed_enemies = {
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_1(-64),
                interval_size = 150,
                progress_speed = 80,
                arc_params = thorns_arc_params
            }}},
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_1(64),
                interval_size = 150,
                progress_speed = -80,
                arc_params = thorns_arc_params
            }}},
        }
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.MushroomAnt, 2 },
        },
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.Rollopod, 1 },
            { E.CloudStorm, 1 },
        },
        fixed_enemies = {
            { E.MushroomAnt, 2 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.CloudStorm,  2 },
            { E.Rollopod,     1 },
            { E.MushroomAnt, 2 },
        },
    },

    {
        min = 1,
        max = 1,

        enemies = {
            { E.Centipede, 1, args = { 15 } },
        },

        run = function()
            game.actor_manager:kill_actors_with_name("progressing_arc")
        end, 
    },

    ---------------------------------------------
    new_cafeteria(),
    ---------------------------------------------

    {
        min = 3,
        max = 3,

        enemies = {
            { E.Shooter, 20 },
        },

        music = "w4",
    },


    {
        min = 5,
        max = 5,

        enemies = {
            { E.Rollopod, 40 },
            { E.Shooter, 40 },
        },
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.CloudEnemy, 20 },
            { E.CloudStorm, 40 },
            { E.Rollopod,    40 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.MushroomAnt, 20 },
            { E.Shooter, 20 },
        },
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.CloudEnemy, 1 },
            { E.CloudStorm, 1 },
        },
        
        fixed_enemies = {
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_2(),
                interval_size = 150,
                progress_speed = 80,
                arc_params = thorns_arc_params
            }}},
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.Shooter, 2 },
        },
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.Rollopod, 2 },
            { E.CloudEnemy, 2 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.Shooter, 1 },
            { E.MushroomAnt, 1 },
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.Shooter, 3 },
        },

        fixed_enemies = {
            { E.HoneycombFootball, 3 },
        },

        cutscene = cutscenes.arum_titan_enter,
        run = function(self, level)
        end,
    },

    
    {
        floor_type = FLOOR_TYPE_CAFETERIA,
        roll_type = WAVE_ROLL_TYPE_FIXED,
        music = "off",

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end
            end
        end,

        min = 1,
        max = 1,
        enemies = {},

        bounds = RECT_CEO_OFFICE,

        backroom = BackroomCEOOffice
    },

    --]]
    --[[

    ---------------------------------------------
    new_cafeteria(),
    ---------------------------------------------


    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W5: executive
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    {
        min = 4,
        max = 4,

        enemies = {
            { E.GoldenBeetle, 20 },
        },

        elevator_layers = {
            ["cabin_bg"] = images.cabin_bg_w2,
            ["walls"] = images.cabin_walls_w2,

            ["bg_fan"] = true,
            ["bg_grid"] = false,
        },

        background = backgrounds.BackgroundGreenhouse:new(),
        music = "w5",

        over_title = get_world_prefix(5),
        title = get_world_name(5),
        title_color = COL_LIGHT_BLUE,
        title_outline_color = COL_BLACK_BLUE,
    },


    {
        min = 4,
        max = 5,

        enemies = {
            { E.GoldenBeetle, 20 },
            { E.Rollopod, 20 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.CloudEnemy, 10 },
            { E.GoldenBeetle, 10 },
            { E.Rollopod, 10 },
        },
    },

    {
        min = 3,
        max = 4,

        enemies = {
            { E.GoldenBeetle, 2 },
        },
        fixed_enemies = {
            { E.WalkingSlotMachine, 2 },
        },
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.CloudEnemy, 10 },
            { E.Rollopod, 10 },
        },

        fixed_enemies = {
            {
                E.Pendulum, 1,
                args = {pi/3, 200, 1},
                position = {CANVAS_WIDTH/2, 3*16}
            },
        },
    },

    {
        min = 5,
        max = 6,

        enemies = {
            { E.StinkBug, 10 },
            { E.GoldenBeetle, 10 },
        },
    },

    {
        min = 3,
        max = 3,

        enemies = {
            { E.CloudEnemy, 10 },
            { E.StinkBug, 10 },
        },
        fixed_enemies = {
            { E.Shooter, 2 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.GoldenBeetle, 10 },
            { E.WalkingSlotMachine, 5 },
            { E.Shooter, 10 },
            { E.Rollopod, 10 },

        },
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.GoldenBeetle, 10 },
            { E.WalkingSlotMachine, 5 },
            { E.Shooter, 10 },
            { E.Rollopod, 10 },

        },
    },

    ---------------------------------------------
    -- new_cafeteria(),
    ---------------------------------------------

    -- {
    --     min = 5,
    --     max = 5,

    --     enemies = {
    --         { E.CloudEnemy, 20 },
    --     },

    --     music = "w5",
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },

    -- {
    --     min = 3,
    --     max = 3,

    --     enemies = {
    --         { E.CloudEnemy, 10 },
    --     },
    -- },


    -----------------------------------------------------
    --- Last wave
    -----------------------------------------------------

    {
        floor_type = FLOOR_TYPE_CAFETERIA,
        roll_type = WAVE_ROLL_TYPE_FIXED,
        music = "off",

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end
            end
        end,

        min = 1,
        max = 1,
        enemies = {},

        bounds = RECT_CEO_OFFICE,

        backroom = BackroomCEOOffice
    },


    {
        roll_type = WAVE_ROLL_TYPE_FIXED,

        min = 1,
        max = 1,
        enemies = {
            { E.FinalBoss, 1, position = { 87 * 16, 14 * 16 } }
        },

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "final_boss" then
                    actor.state_machine:set_state("standby")
                end
            end
        end
    },

    -- Last wave
    -- {
    --     min = 1,
    --     max = 1,
    --     enemies = {
    --         { E.ButtonBigGlass, 1, position = { 211, 194 } }
    --     },
    --     music = "off",
    -- })
    --]]
}


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------


local demo_waves = parse_waves_table {
    {
        min = 5,
        max = 5,
        enemies = {
            { E.Larva, 3 },
            { E.Fly,   3 },
        },
        music = "w1",

        title = get_world_name("1"),
        title_color = COL_MID_BLUE,
        title_outline_color = COL_BLACK_BLUE,
    },


    {
        -- Woodlouse intro
        min = 4,
        max = 6,
        enemies = {
            { E.Woodlouse, 2 },
        },
    },

    {
        min = 4,
        max = 6,
        enemies = {
            { E.Larva,     2 },
            { E.Fly,       3 },
            { E.Woodlouse, 2 },
        },
    },

    {
        -- Slug intro
        min = 4,
        max = 6,
        enemies = {
            { E.Larva, 2 },
            { E.Fly,   2 },
            { E.Slug,  4 },
        },
    },


    {
        min = 3,
        max = 5,
        enemies = {
            -- Shelled Snail intro
            { E.SnailShelled, 3 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            --
            { E.Larva,        4 },
            { E.Fly,          4 },
            { E.Woodlouse,    2 },
            { E.SnailShelled, 3 },
            { E.Slug,         2 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.SnailShelled, 4 },
            { E.SpikedFly,    3 },
            { E.Fly,          3 },
        },
    },

    {
        -- Mushroom ant intro
        roll_type = WAVE_ROLL_TYPE_FIXED,
        enemies = {
            { E.Fly,        2 },
            { E.Boomshroom, 4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          5 },
            { E.Slug,         2 },
            { E.SpikedFly,    4 },
            { E.Woodlouse,    4 },
            { E.SnailShelled, 4 },
        },
    },

    new_cafeteria(),

    {
        -- Spiked Fly intro
        min = 6,
        max = 8,
        music = "w1",

        enemies = {
            { E.Larva,     1 },
            { E.Fly,       2 },
            { E.SpikedFly, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,        1 },
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   4 },
            { E.Slug,         2 },
            { E.SnailShelled, 2 },
        },
    },

    {
        -- Spider intro
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,  1 },
            { E.Slug,   2 },
            { E.Spider, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Fly,          2 },
            { E.SnailShelled, 2 },
            { E.Spider,       4 },
        },
    },

    {
        min = 8,
        max = 9,
        enemies = {
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.SnailShelled, 2 },
            { E.Slug,         2 },
            { E.Spider,       4 },
        },
    },

    {
        -- Stink bug intro
        min = 5,
        max = 6,
        enemies = {
            { E.StinkBug, 3 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.Larva,        1 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          2 },
            { E.Slug,         2 },
            { E.Woodlouse,    2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     2 },
        },
    },

    {
        -- roll_type = WAVE_ROLL_TYPE_FIXED,
        min = 1,
        max = 1,
        enemies = {
            { E.Dung, 1, position = { CANVAS_WIDTH / 2 - 24 / 2, 200 } },
        },
        music = "miniboss",
    },


    -- Last wave
    {
        min = 1,
        max = 1,
        enemies = {
            { E.ButtonBigGlass, 1, position = { 211, 194 } }
        },
        music = "off",
    }
}

local function sanity_check_waves()
    for i, wave in ipairs(waves) do
        assert((wave.min <= wave.max), "max > min for wave " .. tostring(i))

        for j, enemy_pair in ipairs(wave.enemies) do
            local enemy_class = enemy_pair[1]
            local weight = enemy_pair[2]

            assert(enemy_class ~= nil, "enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " doesn't exist")
            assert(type(weight) == "number",
                "weight for enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " isn't a number")
            assert(weight >= 0, "weight for enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " is negative")
        end
    end
end

sanity_check_waves()

for i, wave in pairs(waves) do
    table.sort(wave.enemies, function(a, b) return a[2] > b[2] end)
end

return ternary(DEMO_BUILD, demo_waves, waves)
