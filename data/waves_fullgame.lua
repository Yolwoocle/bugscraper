
new_wave({
    -- Woodlouse intro
    min = 4,
    max = 6,
    enemies = {
        {E.Woodlouse, 2},
    },
}),

new_wave({
    min = 4,
    max = 6,
    enemies = {
        {E.Larva, 2},
        {E.Fly, 3},
        {E.Woodlouse, 2},
    },
}),

new_wave({
    -- Slug intro
    min = 4,
    max = 6,
    enemies = {
        {E.Larva, 2},
        {E.Fly, 2},
        {E.Slug, 4},
    },
}),


new_wave({
    min = 3,
    max = 5,
    enemies = {
        -- Shelled Snail intro
        {E.SnailShelled, 3},
    },
}),

new_wave({
    min = 6,
    max = 8,
    enemies = {
        -- 
        {E.Larva, 4},
        {E.Fly, 4},
        {E.Woodlouse, 2},
        {E.SnailShelled, 3},
        {E.Slug, 2},
    },
}),

new_wave({ 
    min = 7,
    max = 9,
    enemies = {
        {E.SnailShelled, 4},
        {E.SpikedFly, 3},
        {E.Fly, 3},
    },
}),

new_wave({
    -- Mushroom ant intro
    roll_type = WAVE_ROLL_TYPE_FIXED,
    enemies = {
        {E.Fly, 2},
        {E.Boomshroom, 4},
    },
}),

new_wave({
    min = 8,
    max = 10,
    enemies = {
        {E.Fly, 5},
        {E.Slug, 2},
        {E.SpikedFly, 4},
        {E.Woodlouse, 4},
        {E.SnailShelled, 4},
    },
}),

new_cafeteria(),

new_wave({ 
    -- Spiked Fly intro
    min = 6,
    max = 8,
    music = "w1",

    enemies = {
        {E.Larva, 1},
        {E.Fly, 2},
        {E.SpikedFly, 4},
    },
}),

new_wave({
    min = 6,
    max = 8,
    enemies = {
        {E.Larva, 1},
        {E.Fly, 2},
        {E.SpikedFly, 2},
        {E.Boomshroom, 4},
        {E.Slug, 2},
        {E.SnailShelled, 2},
    },
}),

new_wave({
    -- Spider intro
    min = 6,
    max = 8,
    enemies = {
        {E.Larva, 1},
        {E.Slug, 2},
        {E.Spider, 4},
    },
}),

new_wave({
    min = 6,
    max = 8,
    enemies = {
        {E.Fly, 2},
        {E.SnailShelled, 2},
        {E.Spider, 4},
    },
}),

new_wave({
    min = 8,
    max = 9,
    enemies = {
        {E.Fly, 2},
        {E.SpikedFly, 2},
        {E.SnailShelled, 2},
        {E.Slug, 2},
        {E.Spider, 4},
    },
}),

new_wave({ 
    -- Stink bug intro
    min = 5,
    max = 6,
    enemies = {
        {E.StinkBug, 3},
    },
}),

new_wave({ 
    min = 7,
    max = 9,
    enemies = {
        {E.Larva, 1},
        {E.SpikedFly, 2},
        {E.Boomshroom, 2},
        {E.SnailShelled, 2},
        {E.Spider, 2},
        {E.StinkBug, 4},
    },
}),

new_wave({ 
    min = 8,
    max = 10,
    enemies = {
        {E.Fly, 2},
        {E.Slug, 2},
        {E.Woodlouse, 2},
        {E.SpikedFly, 2},
        {E.Boomshroom, 2},
        {E.SnailShelled, 2},
        {E.Spider, 2},
        {E.StinkBug, 2},
    },
}),

new_wave({
    -- roll_type = WAVE_ROLL_TYPE_FIXED,
    min = 1,
    max = 1,
    enemies = {	
        {E.Dung, 1, position = {240, 200}},			
    },
    music = "miniboss",
}),

new_cafeteria(),



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--- W2: beehive
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


new_wave({
    min = 6,
    max = 7,

    enemies = {
        {E.Larva, 2},
        {E.Mosquito, 2},
    },

    background = backgrounds.BackgroundBeehive:new(),
    music = "w2",

    title = get_world_name("2"),
    title_color = COL_YELLOW_ORANGE,
}),

new_wave({
    min = 5,
    max = 7,

    enemies = {
        {E.Larva, 2},
        {E.Mosquito, 2},
        {E.ShovelBee, 4},
    },
}),

new_wave({
    min = 4,
    max = 4,

    enemies = {
        {E.Beelet, 2},
    },
}),

new_wave({
    min = 8,
    max = 8,

    enemies = {
        {E.Larva, 4},
        {E.Mosquito, 4},
        {E.Boomshroom, 4},
        {E.Beelet, 2},
    },
}),
    
new_wave({
    min = 6,
    max = 6,

    enemies = {
        {E.Mosquito, 4},
        {E.HoneypotAnt, 4},
    },
}), 

new_wave({
    min = 6,
    max = 6,

    enemies = {
        {E.Mosquito, 4},
        {E.Beelet, 3},
    },
}), 

new_wave({
    min = 6,
    max = 6,

    enemies = {
        {E.Mosquito, 3},
        {E.HoneypotAnt, 4},
        {E.ShovelBee, 3},
    },
    fixed_enemies = {
        {E.LarvaSpawner, 1},
    }
}), 

new_wave({
    min = 10,
    max = 10,

    enemies = {
        {E.SnailShelled, 1},
        {E.Mosquito, 3},
        {E.HoneypotAnt, 1},
        {E.ShovelBee, 2},
        {E.Larva, 2},
    },
}),

    
new_wave({
    min = 1,
    max = 1,

    enemies = {
        {E.HoneycombFootball, 2},
    },
}), 

---------------------------------------------
new_cafeteria(),
---------------------------------------------
    
new_wave({
    min = 5,
    max = 5,

    enemies = {
        {E.Mosquito, 3},
        {E.Larva, 3},
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
        {E.Mosquito, 3},
        {E.Larva, 3},
        {E.HoneypotAnt, 2},
        {E.Fly, 2},
    },		
}), 
    
new_wave({
    min = 7,
    max = 7,

    enemies = {
        {E.Mosquito, 3},
        {E.Larva, 3},
        {E.HoneypotAnt, 2},
        {E.Fly, 2},
    },
    fixed_enemies = {
        {E.LarvaSpawner, 1},
    },
}), 
    
new_wave({
    min = 4,
    max = 4,

    enemies = {
        {E.DrillBee, 3},
    },
}), 
    
new_wave({
    min = 6,
    max = 6,

    enemies = {
        {E.Mosquito, 20},
        {E.ShovelBee, 10},
        {E.Boomshroom, 20},
        {E.DrillBee, 30},
    },
}), 
    
new_wave({
    min = 8,
    max = 8,

    enemies = {
        {E.Larva, 3},
        {E.Mosquito, 3},
        {E.HoneypotAnt, 3},
    },
    fixed_enemies = {
        {E.LarvaSpawner, 1},
    },
}), 


new_wave({
    min = 7,
    max = 7,

    enemies = {
        {E.Mosquito, 3},
        {E.ShovelBee, 3},
        {E.DrillBee, 3},
    },
}), 


new_wave({
    min = 9,
    max = 9,

    enemies = {
        {E.Larva, 3},
        {E.Mosquito, 3},
        {E.ShovelBee, 3},
        {E.DrillBee, 3},
        {E.HoneypotAnt, 3},
        {E.Boomshroom, 3},
    },
}), 

new_wave({
    -- roll_type = WAVE_ROLL_TYPE_FIXED,
    min = 1,
    max = 1,
    enemies = {	
        {E.BeeBoss, 1, position = {240, 200}},
    },
    music = "miniboss",

    run = function(self, level)
        for _, actor in pairs(level.game.actors) do
            if actor.name == "timed_spikes" then
                actor:remove()
            end
        end
    end,

    cutscene = cutscenes.boss_enter,
}),

new_cafeteria(function()
    game:kill_actors_with_name("timed_spikes") 

    game.is_light_on = true
end),

------

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--- W3: server room
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

-- Floor 20
new_wave({
    min = 6,
    max = 6, 
    enemies = {
        {E.Chipper, 1},
    },
    background = backgrounds.BackgroundServers:new(),
    music = "w3",

    title = get_world_name("3"),
    title_color = COL_MID_GREEN,
}),

new_wave({
    min = 5,
    max = 5,
    enemies = {
        {E.Woodlouse, 2},
        {E.Fly, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1},
    },
}),

new_wave({
    min = 5,
    max = 7,
    enemies = {
        {E.Slug, 2},
        {E.StinkBug, 2},
        {E.Chipper, 2},
        {E.BulbBuddy, 1},
    },
}),

new_wave({
    min = 6,
    max = 6,
    enemies = {
        {E.Grasshopper, 2},
        {E.SnailShelled, 2},
        {E.Woodlouse, 2},
    },
}),

new_wave({
    level_geometry = LevelGeometry:new({
        {rect = Rect:new(3, 8, 8, 8), tile = TILE_SEMISOLID}, 
        {rect = Rect:new(21, 8, 26, 8), tile = TILE_SEMISOLID}, 
    }),
    elevator_layers = {
        ["bg_grid"] = false,
    },
    run = function(self, level)
        game:screenshake(10)

        local cabin_rect = game.level.cabin_rect
        Particles:falling_grid(cabin_rect.ax +   16, cabin_rect.ay + 6*16)
        Particles:falling_grid(cabin_rect.bx - 7*16, cabin_rect.ay + 6*16)
        level.elevator:start_grid_timer(2.5)
    end,
    
    fixed_enemies = {
        {E.ElectricRays, 1, position = {CANVAS_WIDTH/2, CANVAS_HEIGHT/2 + 8}, args = {{
                n_rays = 1, 
                activation_delay = 2, 
                init_angle = pi/2,
                angle_speed = 0,
            }}
        },
    },
    floating_text = "🎓 "..string.upper(Text:text("input.prompts.jetpack")),

    min = 4,
    max = 6,
    enemies = {
        {E.Fly, 2},
        {E.Chipper, 2},
    },
}),

new_wave({
    min = 3,
    max = 4,
    enemies = {
        {E.MetalFly, 4},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1},
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
        {E.Slug, 4},
        {E.StinkBug, 4},
        {E.Chipper, 4},
        {E.Grasshopper, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1},
    }
}),

new_wave({
    min = 6,
    max = 7,
    enemies = {
        {E.Fly, 2},
        {E.MetalFly, 4},
        {E.Chipper, 4},
        {E.Grasshopper, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1},
    }
}),
    
new_wave({
    min = 5,
    max = 6,
    enemies = {
        {E.SpikedFly, 2},
        {E.StinkBug, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1},
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
        {E.SnailShelledBouncy, 2},
    },
    elevator_layers = {
        ["bg_grid"] = false,
        ["fg_grid"] = false,
    },
    
    fixed_enemies = {
        {E.ElectricRays, 1, position = {CANVAS_WIDTH/2, CANVAS_HEIGHT/2 + 8}, args = {
            {
                n_rays = 1, 
                activation_delay = 2,
                angle_speed = 0.3,
            }
        }},
    },
    music = "w3",

    floating_text = "🎓 "..string.upper(Text:text("input.prompts.jetpack")),
}),

new_wave({
    min = 5,
    max = 6,
    enemies = {
        {E.Grasshopper, 2},
        {E.StinkBug, 2},
        {E.SnailShelledBouncy, 2},
    },
}),

new_wave({
    min = 5,
    max = 6,
    enemies = {
        {E.SnailShelledBouncy, 2},
        {E.Fly, 2},
        {E.Boomshroom, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 2}
    }
}),

new_wave({
    min = 5,
    max = 6,
        {E.SnailShelledBouncy, 2},
    enemies = {
        {E.Boomshroom, 2},
        {E.Grasshopper, 2},
    },
    fixed_enemies = {
        {E.BulbBuddy, 1}
    }
}),

new_wave({
    min = 4,
    max = 5,
    enemies = {
        {E.Chipper, 2},
        {E.StinkBug, 2},
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
        {E.SnailShelled, 2},
        {E.Fly, 2},
        {E.SpikedFly, 2},
    },
}),

new_wave({
    min = 7,
    max = 9,

    enemies = {
        {E.Spider, 20},
        {E.MetalFly, 20},
        {E.BulbBuddy, 5}
    },
}),

new_wave({
    min = 6,
    max = 7,

    enemies = {
        {E.Spider, 2},
        {E.Fly, 2},
        {E.SpikedFly, 2},
        {E.Chipper, 2},
        {E.StinkBug, 2},
    },

}),


new_wave({
    min = 1,
    max = 1,

    enemies = {
        {E.Motherboard, 1, position = {3*16, 3*16 + 4}},
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
--- W4: the final climb
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

new_wave({
    min = 8,
    max = 8,

    enemies = {
        {E.Larva, 2},
        {E.Fly, 2},
        {E.Slug, 2},
    },

    background = backgrounds.BackgroundFinal:new(),
    music = "w4",

    title = get_world_name("4"),
    title_color = COL_LIGHT_BLUE,
    title_outline_color = COL_DARK_BLUE,

    elevator_layers = {
        ["cabin"] = false,
        ["bg_grid"] = false,
    },
    run = function(self, level)
    end,
}),


new_wave({
    min = 9,
    max = 9,

    enemies = {
        {E.Fly, 2},
        {E.SpikedFly, 2},
        {E.Woodlouse, 2},
    },
}),


new_wave({
    min = 11,
    max = 11,

    enemies = {
        {E.Woodlouse, 20},
        {E.SpikedFly, 20},
        {E.SnailShelled, 20},
        {E.Boomshroom, 15},
    },
}),


new_wave({
    min = 12,
    max = 13,

    enemies = {
        {E.StinkBug, 2},
        {E.Spider, 2},
        {E.SnailShelled, 2},
        {E.Boomshroom, 2},
    },
}),

new_wave({
    min = 13,
    max = 14,

    enemies = {
        {E.Larva, 2},
        {E.Fly, 2},
        {E.Woodlouse, 2},
        {E.SpikedFly, 2},
        {E.Boomshroom, 2},
        {E.SnailShelled, 2},
        {E.Spider, 2},
    },
}),

-- W2 recap

new_wave({
    min = 8,
    max = 9,

    enemies = {
        {E.Larva, 2},
        {E.Mosquito, 2},
        {E.ShovelBee, 2},
    },

    run = function(wave, level)
        spawn_timed_spikes()
    end,
}),

new_wave({
    min = 9,
    max = 10,

    enemies = {
        {E.Larva, 2},
        {E.Mosquito, 2},
        {E.Beelet, 2},
    },
}),

new_wave({
    min = 11,
    max = 12,

    enemies = {
        {E.Mosquito, 2},
        {E.HoneypotAnt, 2},
        {E.DrillBee, 2},
    },
    fixed_enemies = {
        {E.LarvaSpawner, 1},
    }
}),

new_wave({
    min = 11,
    max = 12,

    enemies = {
        {E.HoneypotAnt, 2},
        {E.DrillBee, 2},
        {E.ShovelBee, 2},
        {E.Beelet, 2},
        {E.Mosquito, 2},
    },
}),

new_wave({
    min = 11,
    max = 12,

    enemies = {
        {E.Larva, 2},
        {E.Mosquito, 2},
        {E.ShovelBee, 2},
        {E.HoneypotAnt, 2},
        {E.DrillBee, 2},
        {E.Beelet, 2},
    },
    
    fixed_enemies = {
        {E.HoneycombFootball, 1},
        {E.LarvaSpawner, 1},
    }
}),

-- W3 recap

new_wave({
    min = 12,
    max = 12,
    
    enemies = {
        {E.Chipper, 2},
    },

    fixed_enemies = {
        {E.ElectricRays, 1, position = {CANVAS_WIDTH/2, CANVAS_HEIGHT/2 + 8}, args = {
            {
                n_rays = 1, 
                activation_delay = 2,
                angle_speed = 0.3,
            }
        }},
    },
    
    run = function(wave, level)
        game:kill_actors_with_name("timed_spikes") 
    end
}),

new_wave({
    min = 14,
    max = 14,
    
    enemies = {
        {E.Chipper, 2},
        {E.StinkBug, 2},
    },

    fixed_enemies = {
        {E.BulbBuddy, 1},
    }
}),

new_wave({
    min = 14,
    max = 14,
    
    enemies = {
        {E.Chipper, 2},
        {E.StinkBug, 2},
        {E.Grasshopper, 2},
        {E.Fly, 2},
    },

    fixed_enemies = {
        {E.BulbBuddy, 1},
    },
}),

new_wave({
    min = 16,
    max = 16,
    
    enemies = {
        {E.SnailShelledBouncy, 2},
        {E.Fly, 2},
        {E.Spider, 2},
    },
}),

new_wave({
    min = 16,
    max = 16,
    
    enemies = {
        {E.Chipper, 2},
        {E.BulbBuddy, 2},
        {E.StinkBug, 2},
        {E.SnailShelledBouncy, 2},
        {E.MetalFly, 2},
        {E.Grasshopper, 2},
        {E.Spider, 2},
    },
}),

--]]

-----------------------------------------------------
--- Last wave
-----------------------------------------------------

-- Last wave
new_wave({ 
    min = 1,
    max = 1,
    enemies = {
        {E.ButtonBigGlass, 1, position = {211, 194}}
    },
    music = "off",
})