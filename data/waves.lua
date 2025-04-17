require "scripts.util"
local backgrounds        = require "data.backgrounds"
local enemies            = require "data.enemies"
local cutscenes          = require "data.cutscenes"
local images             = require "data.images"

local Rect               = require "scripts.math.rect"
local LevelGeometry      = require "scripts.level.level_geometry"
local Wave               = require "scripts.level.wave"
local BackroomCafeteria  = require "scripts.level.backrooms.backroom_cafeteria"
local BackroomCEOOffice = require "scripts.level.backrooms.backroom_ceo_office"
local E                  = require "data.enemies"

local utf8 = require "utf8"

RECT_ELEVATOR            = Rect:new(unpack(RECT_ELEVATOR_PARAMS))
RECT_CAFETERIA           = Rect:new(unpack(RECT_CAFETERIA_PARAMS))
RECT_CEO_OFFICE          = Rect:new(unpack(RECT_CEO_OFFICE_PARAMS))

local function new_cafeteria(run_func)
	run_func = run_func or function(...) end
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
			
			run_func(self, level)
		end,

		min = 1,
		max = 1,
		bounds = RECT_CAFETERIA,
		enemies = {
			{ E.UpgradeDisplay, 1, position = { 474+16, 181 } },
			{ E.UpgradeDisplay, 1, position = { 530+16, 181 } },
			{ E.UpgradeDisplay, 1, position = { 586+16, 181 } },
		},

		backroom = BackroomCafeteria
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

local waves = {
	-- debug_wave(),

	
	-- new_wave({
	-- 	-- roll_type = WAVE_ROLL_TYPE_FIXED,
	-- 	min = 1,
	-- 	max = 1,
	-- 	enemies = {
	-- 		{ E.BeeBoss, 1, position = { 240, 200 } },
	-- 	},
	-- 	music = "miniboss",

	-- 	run = function(self, level)
	-- 		for _, actor in pairs(level.game.actors) do
	-- 			if actor.name == "timed_spikes" then
	-- 				actor:remove()
	-- 			end
	-- 		end
	-- 	end,

	-- 	-- cutscene = cutscenes.bee_boss_enter,
	-- }),

	-- new_cafeteria(),
	-- [[

	new_wave({
		min = 5,
		max = 5,
		enemies = {
			{ E.Larva, 3 },
			-- { E.Fly,   3 },
		},
		music = "w1",

		over_title = get_world_prefix(1),
		title = get_world_name(1),
		title_color = COL_LIGHTEST_GRAY,
		title_outline_color = COL_BLACK_BLUE,
	}),


	new_wave({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enemies = {
			{ E.Woodlouse, 2 },
		},
	}),

	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{ E.Larva,     2 },
			{ E.Fly,       3 },
			{ E.Woodlouse, 2 },
		},
	}),

	new_wave({
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{ E.Larva, 2 },
			{ E.Fly,   2 },
			{ E.Slug,  4 },
		},
	}),


	new_wave({
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{ E.SnailShelled, 3 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
		min = 7,
		max = 9,
		enemies = {
			{ E.SnailShelled, 4 },
			{ E.SpikedFly,    3 },
			{ E.Fly,          3 },
		},
	}),

	new_wave({
		-- Mushroom ant intro
		roll_type = WAVE_ROLL_TYPE_FIXED,
		enemies = {
			{ E.Fly,        2 },
			{ E.Boomshroom, 4 },
		},
	}),

	new_wave({
		min = 8,
		max = 10,
		enemies = {
			{ E.Fly,          5 },
			{ E.Slug,         2 },
			{ E.SpikedFly,    4 },
			{ E.Woodlouse,    4 },
			{ E.SnailShelled, 4 },
		},
	}),

	new_cafeteria(),

	new_wave({
		-- Spiked Fly intro
		min = 6,
		max = 8,
		music = "w1",

		enemies = {
			{ E.Larva,     1 },
			{ E.Fly,       2 },
			{ E.SpikedFly, 4 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
		-- Spider intro
		min = 6,
		max = 8,
		enemies = {
			{ E.Larva,  1 },
			{ E.Slug,   2 },
			{ E.Spider, 4 },
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{ E.Fly,          2 },
			{ E.SnailShelled, 2 },
			{ E.Spider,       4 },
		},
	}),

	new_wave({
		min = 8,
		max = 9,
		enemies = {
			{ E.Fly,          2 },
			{ E.SpikedFly,    2 },
			{ E.SnailShelled, 2 },
			{ E.Slug,         2 },
			{ E.Spider,       4 },
		},
	}),

	new_wave({
		-- Stink bug intro
		min = 5,
		max = 6,
		enemies = {
			{ E.StinkBug, 3 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
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
	}),

	new_wave({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enemies = {
			{ E.Dung, 1, position = { CANVAS_WIDTH / 2 - 24 / 2, 200 } },
		},
		music = "miniboss",
		cutscene = cutscenes.dung_boss_enter,
	}),

	new_cafeteria(),



	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	--- W2: beehive / factory
	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------


	new_wave({
		min = 6,
		max = 7,

		enemies = {
			{ E.Larva, 2 },
			{ E.Bee,   2 },
		},

		background = backgrounds.BackgroundFactory:new(),
		music = "w2",

		elevator_layers = {
			["cabin_bg"] = images.cabin_bg_w2,
			["walls"] = images.cabin_walls_w2,
			
			["bg_fan"] = true,
			["bg_grid"] = false,
		},
		door_images = {
			images.cabin_door_bee_left_far,
			images.cabin_door_bee_left_center,
			images.cabin_door_bee_right_far,
			images.cabin_door_bee_right_center,
		},

		over_title = get_world_prefix(2),
		title = get_world_name(2),
		title_color = COL_LIGHT_YELLOW,
		title_outline_color = COL_BLACK_BLUE,
	}),

	new_wave({
		min = 5,
		max = 7,

		enemies = {
			{ E.Larva,     2 },
			{ E.Bee,       2 },
			{ E.ShovelBee, 4 },
		},
	}),

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.Beelet, 2 },
		},
	}),

	new_wave({
		min = 8,
		max = 8,

		enemies = {
			{ E.Larva,      4 },
			{ E.Bee,        4 },
			{ E.Boomshroom, 4 },
			{ E.Beelet,     2 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Bee,         4 },
			{ E.HoneypotAnt, 4 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Bee,    4 },
			{ E.Beelet, 3 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Bee,         3 },
			{ E.HoneypotAnt, 4 },
			{ E.ShovelBee,   3 },
		},
		fixed_enemies = {
			{ E.FlyingSpawner, 1 },
		}
	}),

	new_wave({
		min = 10,
		max = 10,

		enemies = {
			{ E.SnailShelled, 1 },
			{ E.Bee,          3 },
			{ E.HoneypotAnt,  1 },
			{ E.ShovelBee,    2 },
			{ E.Larva,        2 },
		},
	}),


	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Beelet, 8 },
		},
		fixed_enemies = {
			{ E.HoneycombFootball, 1 },
		},
	}),

	---------------------------------------------
	new_cafeteria(),
	---------------------------------------------

	new_wave({
		min = 5,
		max = 5,

		enemies = {
			{ E.Bee,   3 },
			{ E.Larva, 3 },
		},

		music = "w2",

		run = function(self, level)
			spawn_timed_spikes()
		end,
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Bee,         3 },
			{ E.Larva,       3 },
			{ E.HoneypotAnt, 2 },
			{ E.Fly,         2 },
		},
	}),

	new_wave({
		min = 7,
		max = 7,

		enemies = {
			{ E.Bee,         3 },
			{ E.Larva,       3 },
			{ E.HoneypotAnt, 2 },
			{ E.Fly,         2 },
		},
		fixed_enemies = {
			{ E.FlyingSpawner, 1 },
		},
	}),

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.DrillBee, 3 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Bee,        20 },
			{ E.ShovelBee,  10 },
			{ E.Boomshroom, 20 },
			{ E.DrillBee,   30 },
		},
	}),

	new_wave({
		min = 8,
		max = 8,

		enemies = {
			{ E.Larva,       3 },
			{ E.Bee,         3 },
			{ E.HoneypotAnt, 3 },
		},
		fixed_enemies = {
			{ E.FlyingSpawner, 1 },
		},
	}),


	new_wave({
		min = 7,
		max = 7,

		enemies = {
			{ E.Bee,       3 },
			{ E.ShovelBee, 3 },
			{ E.DrillBee,  3 },
		},
	}),


	new_wave({
		min = 9,
		max = 9,

		enemies = {
			{ E.Larva,       3 },
			{ E.Bee,         3 },
			{ E.ShovelBee,   3 },
			{ E.DrillBee,    3 },
			{ E.HoneypotAnt, 3 },
			{ E.Boomshroom,  3 },
		},
	}),

	new_wave({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enemies = {
			{ E.BeeBoss, 1, position = { 240-16, 200 } },
		},
		music = "miniboss",

		run = function(self, level)
			for _, actor in pairs(level.game.actors) do
				if actor.name == "timed_spikes" then
					actor:remove()
				end
			end
		end,

		cutscene = cutscenes.bee_boss_enter,
	}),

	new_cafeteria(function()
		for _, a in pairs(game.actors) do
			if a.name == "timed_spikes" then
				a:remove()
			end
		end

		game.is_light_on = true
	end),

	------

	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	--- W3: server room
	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------

	-- Floor 
	new_wave({
		min = 6,
		max = 6,
		enemies = {
			{ E.Chipper, 1 },
		},
		background = backgrounds.BackgroundServers:new(),
		music = "w3",

		elevator_layers = {
			["cabin_bg"] = images.cabin_bg_w3,
			["walls"] = images.cabin_walls_w3,

			["bg_fan"] = false,
			["bg_grid"] = true,
			["w3_cabin"] = true,

			["door_background"] = true,
            ["cabin"] = true,
            ["counter"] = true,
		},

		door_images = {
			images.cabin_door_empty,
			images.cabin_door_w3_left_center,
			images.cabin_door_empty,
			images.cabin_door_w3_right_center,
		},

		over_title = get_world_prefix(3),
		title = get_world_name(3),
		title_color = COL_LIGHT_GREEN,
		title_outline_color = COL_BLACK_BLUE,
	}),

	new_wave({
		min = 5,
		max = 5,
		enemies = {
			{ E.Woodlouse, 2 },
			{ E.Fly,       2 },
		},
		fixed_enemies = {
			{ E.BulbBuddy, 1 },
		},
	}),

	new_wave({
		min = 5,
		max = 7,
		enemies = {
			{ E.Slug,      2 },
			{ E.StinkBug,  2 },
			{ E.Chipper,   2 },
			{ E.BulbBuddy, 1 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,
		enemies = {
			{ E.Grasshopper,  2 },
			{ E.SnailShelled, 2 },
			{ E.Woodlouse,    2 },
		},
	}),

	new_wave({
		level_geometry = LevelGeometry:new({
			{ rect = Rect:new(3, 8, 8, 8),   tile = TILE_SEMISOLID },
			{ rect = Rect:new(21, 8, 26, 8), tile = TILE_SEMISOLID },
		}),
		elevator_layers = {
			["bg_grid"] = false,
		},
		run = function(self, level)
			local cabin_rect = game.level.cabin_rect
			Particles:falling_grid(cabin_rect.ax + 16, cabin_rect.ay + 6 * 16)
			Particles:falling_grid(cabin_rect.bx - 7 * 16, cabin_rect.ay + 6 * 16)
			level.elevator:start_grid_timer(2.5)
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
	}),

	new_wave({
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
	}),

	new_wave({
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
	}),

	new_wave({
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
	}),

	new_wave({
		min = 5,
		max = 6,
		enemies = {
			{ E.SpikedFly, 2 },
			{ E.StinkBug,  2 },
		},
		fixed_enemies = {
			{ E.BulbBuddy, 1 },
		}
	}),

	------------------------------------------------
	-- Cafeteria
	new_cafeteria(function()
		game:kill_actors_with_name("electric_rays")
	end),
	------------------------------------------------

	new_wave({
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
	}),

	new_wave({
		min = 5,
		max = 6,
		enemies = {
			{ E.Grasshopper,        2 },
			{ E.StinkBug,           2 },
			{ E.SnailShelledBouncy, 2 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
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
	}),

	new_wave({
		min = 4,
		max = 5,
		enemies = {
			{ E.Chipper,  2 },
			{ E.StinkBug, 2 },
		},

		-- run = function(self, level)
		-- 	for _, player in pairs(game.players) do
		-- 		local arc = enemies.ElectricArc:new(CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5)
		-- 		arc:set_arc_target(player)
		-- 		arc.arc_damage = 2.5
		-- 		game:new_actor(arc)
		-- 	end
		-- end,
	}),

	new_wave({
		min = 6,
		max = 7,

		enemies = {
			{ E.SnailShelled, 2 },
			{ E.Fly,          2 },
			{ E.SpikedFly,    2 },
		},
	}),

	new_wave({
		min = 7,
		max = 9,

		enemies = {
			{ E.Spider,    20 },
			{ E.MetalFly,  20 },
			{ E.BulbBuddy, 5 }
		},
	}),

	new_wave({
		min = 6,
		max = 7,

		enemies = {
			{ E.Spider,    2 },
			{ E.Fly,       2 },
			{ E.SpikedFly, 2 },
			{ E.Chipper,   2 },
			{ E.StinkBug,  2 },
		},
	}),


	new_wave({
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
	}),

	------
	-- Cafeteria
	new_cafeteria(function()
		-- for _, actor in pairs(game.actors) do
		-- 	if actor.name == "electric_rays" then
		-- 		actor:kill()
		-- 	end
		-- end
	end),


	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	--- W4: the gardens
	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.CloudEnemy, 20 },
		},

		elevator_layers = {
			["bg_grid"] = false,
			["w3_cabin"] = false,

			["cabin_bg"] = images.cabin_bg_w4,
			["walls"] = images.cabin_walls_w3,
			-- ["walls_brown"] = false,
			-- ["bg_grid_brown"] = false,
			-- ["walls"] = false,
		},

		background = backgrounds.BackgroundGreenhouse:new(),
		music = "w4",

		over_title = get_world_prefix(4),
		title = get_world_name(4),
		title_color = COL_LIGHT_BLUE,
		title_outline_color = COL_BLACK_BLUE,
	}),


	new_wave({
		min = 7,
		max = 7,

		enemies = {
			{ E.CloudStorm, 30 },
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.Shooter, 1 },
		},
		fixed_enemies = {
			{ E.CloudEnemy, 2 },
		}
	}),

	new_wave({
		min = 7,
		max = 9,

		enemies = {
			{ E.CloudStorm,  2 },
			{ E.MushroomAnt, 1 },
		},
	}),

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.Mole, 2 },
		},
	}),

	new_wave({
		min = 7,
		max = 7,

		enemies = {
			{ E.MushroomAnt, 2 },
			{ E.Mole,        2 },
			{ E.Shooter,     1 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Shooter, 1 },
			{ E.Mole,    2 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.CloudStorm,  2 },
			{ E.Shooter,     1 },
			{ E.MushroomAnt, 2 },
		},
	}),

	new_wave({
		min = 1,
		max = 1,

		enemies = {
			{ E.Centipede, 1, args = { 15 } },
		},
	}),

	---------------------------------------------
	new_cafeteria(),
	---------------------------------------------

	new_wave({
		min = 5,
		max = 5,

		enemies = {
			{ E.CloudStorm, 20 },
			{ E.CloudEnemy, 20 },
		},
		
		fixed_enemies = {
			{ 
				E.Pendulum, 1, 
				args = {pi/3, 200, 1}, 
				position = {CANVAS_WIDTH/2, 3*16} 
			},
		},

		music = "w4",
	}),


	new_wave({
		min = 5,
		max = 5,

		enemies = {
			{ E.Shooter, 40 },
		},
	}),

	new_wave({
		min = 8,
		max = 8,

		enemies = {
			{ E.CloudEnemy, 20 },
			{ E.CloudStorm, 40 },
			{ E.Shooter,    40 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Chipper, 20 },
		},
		fixed_enemies = {
			{ E.BulbBuddy, 1 },
		}
	}),

	new_wave({
		min = 1,
		max = 1,

		enemies = {
			{ E.Centipede, 1 },
		},
	}),

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.Bee,       2 },
			{ E.ShovelBee, 2 },
		},
	}),

	new_wave({
		min = 5,
		max = 5,

		enemies = {
			{ E.DrillBee, 2 },
		},
	}),

	new_wave({
		min = 7,
		max = 7,

		enemies = {
			{ E.StinkBug, 1 },
			{ E.Spider,   1 },
		},
	}),

	new_wave({
		min = 6,
		max = 6,

		enemies = {
			{ E.Beelet, 1 },
		},
		fixed_enemies = {
			{ E.HoneycombFootball, 1 },
		},
	}),
	
	---------------------------------------------
	new_cafeteria(),
	---------------------------------------------

	
	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	--- W5: executive
	----------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------

	new_wave({
		min = 4,
		max = 4,

		enemies = {
			{ E.CloudEnemy, 20 },
		},

		elevator_layers = {
			["bg_grid"] = false,
			["w3_cabin"] = false,

			["cabin_bg"] = images.cabin_bg_w4,
			["walls"] = images.cabin_walls_w3,
			-- ["walls_brown"] = false,
			-- ["bg_grid_brown"] = false,
			-- ["walls"] = false,
		},

		background = backgrounds.BackgroundGreenhouse:new(),
		music = "w5",

		over_title = get_world_prefix(5),
		title = get_world_name(5),
		title_color = COL_LIGHT_BLUE,
		title_outline_color = COL_BLACK_BLUE,
	}),


	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),

	---------------------------------------------
	new_cafeteria(),
	---------------------------------------------

	new_wave({
		min = 5,
		max = 5,

		enemies = {
			{ E.CloudEnemy, 20 },
		},

		music = "w5",
	}),

	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),
	
	new_wave({
		min = 3,
		max = 3,

		enemies = {
			{ E.CloudEnemy, 10 },
		},
	}),


	--]]

	-----------------------------------------------------
	--- Last wave
	-----------------------------------------------------

	new_wave({
		floor_type = FLOOR_TYPE_CAFETERIA,
		roll_type = WAVE_ROLL_TYPE_FIXED,
		music = "off",

		run = function(self, level) 
			for _, actor in pairs(game.actors) do
				if actor.name == "poison_cloud" then
					actor.lifespan = 1
				end
				if actor.name == "floor_hole_spawner" then
					actor:remove()
				end
			end
		end,

		min = 1,
		max = 1,
		enemies = {},

		bounds = RECT_CEO_OFFICE,

		backroom = BackroomCEOOffice
	}),

	
	new_wave({
		roll_type = WAVE_ROLL_TYPE_FIXED,

		min = 1,
		max = 1,
		enemies = {
			{E.FinalBoss, 1, position = {87*16, 14*16}}
		},

		run = function(self, level)
			for _, actor in pairs(game.actors) do
				if actor.name == "final_boss" then
					actor.state_machine:set_state("standby")
				end
			end
		end
	}),

	-- Last wave
	-- new_wave({
	-- 	min = 1,
	-- 	max = 1,
	-- 	enemies = {
	-- 		{ E.ButtonBigGlass, 1, position = { 211, 194 } }
	-- 	},
	-- 	music = "off",
	-- })
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


local demo_waves = {
	new_wave({
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
	}),


	new_wave({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enemies = {
			{ E.Woodlouse, 2 },
		},
	}),

	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{ E.Larva,     2 },
			{ E.Fly,       3 },
			{ E.Woodlouse, 2 },
		},
	}),

	new_wave({
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{ E.Larva, 2 },
			{ E.Fly,   2 },
			{ E.Slug,  4 },
		},
	}),


	new_wave({
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{ E.SnailShelled, 3 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
		min = 7,
		max = 9,
		enemies = {
			{ E.SnailShelled, 4 },
			{ E.SpikedFly,    3 },
			{ E.Fly,          3 },
		},
	}),

	new_wave({
		-- Mushroom ant intro
		roll_type = WAVE_ROLL_TYPE_FIXED,
		enemies = {
			{ E.Fly,        2 },
			{ E.Boomshroom, 4 },
		},
	}),

	new_wave({
		min = 8,
		max = 10,
		enemies = {
			{ E.Fly,          5 },
			{ E.Slug,         2 },
			{ E.SpikedFly,    4 },
			{ E.Woodlouse,    4 },
			{ E.SnailShelled, 4 },
		},
	}),

	new_cafeteria(),

	new_wave({
		-- Spiked Fly intro
		min = 6,
		max = 8,
		music = "w1",

		enemies = {
			{ E.Larva,     1 },
			{ E.Fly,       2 },
			{ E.SpikedFly, 4 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
		-- Spider intro
		min = 6,
		max = 8,
		enemies = {
			{ E.Larva,  1 },
			{ E.Slug,   2 },
			{ E.Spider, 4 },
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{ E.Fly,          2 },
			{ E.SnailShelled, 2 },
			{ E.Spider,       4 },
		},
	}),

	new_wave({
		min = 8,
		max = 9,
		enemies = {
			{ E.Fly,          2 },
			{ E.SpikedFly,    2 },
			{ E.SnailShelled, 2 },
			{ E.Slug,         2 },
			{ E.Spider,       4 },
		},
	}),

	new_wave({
		-- Stink bug intro
		min = 5,
		max = 6,
		enemies = {
			{ E.StinkBug, 3 },
		},
	}),

	new_wave({
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
	}),

	new_wave({
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
	}),

	new_wave({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enemies = {
			{ E.Dung, 1, position = { CANVAS_WIDTH / 2 - 24 / 2, 200 } },
		},
		music = "miniboss",
	}),


	-- Last wave
	new_wave({
		min = 1,
		max = 1,
		enemies = {
			{ E.ButtonBigGlass, 1, position = { 211, 194 } }
		},
		music = "off",
	})
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
