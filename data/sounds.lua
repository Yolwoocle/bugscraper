require "scripts.util"
local Sound = require "scripts.audio.sound"

local function new_source(path, type, args)
	local source = love.audio.newSource("sounds/" .. path, type)
	if not args then return source end

	if args.looping then
		source:setLooping(true)
	end
	return source
end

local sounds = {}

local sfxnames = {
	["empty"] =                             { "empty.ogg", "static" },

	["music_ground_floor_players_paused"] = { "music/music_ground_floor_players_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_ingame"] =   { "music/music_ground_floor_empty_ingame.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_paused"] =   { "music/music_ground_floor_empty_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_players_ingame"] = { "music/music_ground_floor_players_ingame.ogg", "stream", { looping = true } },
	["music_w1_ingame"] =                   { "music/music_w1_ingame.ogg", "stream", { looping = true } },
	["music_w1_paused"] =                   { "music/music_w1_paused.ogg", "stream", { looping = true } },
	["music_w2_ingame"] =                   { "music/music_w2_ingame.mp3", "stream", { looping = true } },
	["music_w3_ingame"] =                   { "music/music_w3_ingame.mp3", "stream", { looping = true } },
	["music_w3_paused"] =                   { "music/music_w3_paused.mp3", "stream", { looping = true } },
	["music_game_over"] =                   { "music/music_game_over.ogg", "stream", { looping = true } },
	["music_cafeteria_ingame"] =            { "music/music_cafeteria_ingame.ogg", "stream", { looping = true } },
	["music_cafeteria_paused"] =            { "music/music_cafeteria_paused.ogg", "stream", { looping = true } },
	["music_cafeteria_empty_ingame"] =      { "music/music_cafeteria_empty_ingame.ogg", "stream", { looping = true } },
	["music_boss_w1_ingame"] =              { "music/music_boss_w1_ingame.ogg", "stream", { looping = true } },
	["music_boss_w1_paused"] =              { "music/music_boss_w1_paused.ogg", "stream", { looping = true } },

	-- Player
	["sfx_player_footstep_metal_{01-10}"] =  {"sfx/actor/player/walk/metal/sfx_player_footstep_metal_{}.ogg", "static"},
	["sfx_player_footstep_carpet_{01-10}"] = {"sfx/actor/player/walk/carpet/sfx_player_footstep_carpet_{}.ogg", "static"},
	["sfx_player_footstep_sand_{01-10}"] =   {"sfx/actor/player/walk/sand/sfx_player_footstep_sand_{}.ogg", "static"},
	["sfx_player_footstep_stone_{01-10}"] =  {"sfx/actor/player/walk/stone/sfx_player_footstep_stone_{}.ogg", "static"},
	["sfx_player_footstep_wood_{01-06}"] =   {"sfx/actor/player/walk/wood/sfx_player_footstep_wood_{}.ogg", "static"},
	["sfx_player_footstep_glass_{01-06}"] =  {"sfx/actor/player/walk/glass/sfx_player_footstep_glass_{}.ogg", "static"},

	["sfx_player_wall_slide_metal_{01-02}"] = {"sfx/actor/player/slide/metal/sfx_player_wall_slide_metal_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stone_{01-02}"] = {"sfx/actor/player/slide/stone/sfx_player_wall_slide_stone_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_glass_{01-02}"] = {"sfx/actor/player/slide/glass/sfx_player_wall_slide_glass_{}.ogg", "static", { looping = true }},

	["sfx_player_wall_slide_stamina_low"] =      {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_low.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stamina_very_low"] = {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_very_low.ogg", "static", { looping = true }},

	["sfx_player_damage_normal"] =         {"sfx/actor/player/sfx_player_damage_normal.ogg", "static"},
	["sfx_player_damage_poison"] =         {"sfx/actor/player/sfx_player_damage_poison.ogg", "static"},
	["sfx_player_death"] =                 {"sfx/actor/player/sfx_player_death.ogg", "static"},
	["sfx_player_leave_game"] =            {"sfx/actor/player/sfx_player_leave_game.ogg", "static"},
	["sfx_player_leave_game_easter_egg"] = {"sfx/actor/player/sfx_player_leave_game_easter_egg.mp3", "static"},
	
	["sfx_player_jumplong"] = {"sfx/actor/player/jump/sfx_player_jumplong.ogg", "static"},

	-- ACTORS
	-- Jumping props
	["sfx_actor_jumping_prop_paper_stack_{01-04}"] = {"sfx/actor/jumping_prop/sfx_actor_jumping_prop_paper_stack_{}.ogg", "static"},
	["sfx_actor_jumping_prop_mug_{01-02}"] =         {"sfx/actor/jumping_prop/sfx_actor_jumping_prop_mug_{}.ogg", "static"},
	["sfx_actor_jumping_prop_plant_small_{01-03}"] = {"sfx/actor/jumping_prop/sfx_actor_jumping_prop_plant_small_{}.ogg", "static"},
	["sfx_actor_jumping_prop_screen_{01-04}"] =      {"sfx/actor/jumping_prop/sfx_actor_jumping_prop_screen_{}.ogg", "static"},

	-- Cocoon
	["sfx_actor_cocoon_damage_{01-07}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_damage_{}.ogg", "static"},
	["sfx_actor_cocoon_break_{01-02}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_break_{}.ogg", "static"},

	-- Upgrade display 
	["sfx_actor_upgrade_display_break_{01-04}"] = {"sfx/upgrades/sfx_actor_upgrade_display_break_{}.ogg", "static"},

	-- Health pickup
	["sfx_loot_health_collect"] = {"sfx/sfx_loot_health_collect.ogg", "static"},

	-- ENEMIES 
	-- Snail
	["sfx_enemy_snail_bounce_{01-06}"] = {"sfx/enemy/snail/sfx_enemy_snail_bounce_{}.ogg", "static"},

	-- Boomshroom
	["sfx_enemy_boomshroom_explosion_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_explosion_{}.ogg", "static"},
	["sfx_enemy_boomshroom_flashing"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_flashing.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_{01-07}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_{}.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_instant_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_instant_{}.ogg", "static"},

	-- Stink bug
	["sfx_enemy_poison_cloud_spawn_{01-04}"] = {"sfx/enemy/poison/sfx_enemy_poison_cloud_spawn_{}.ogg", "static"},

	-- Boss W1    
	["sfx_boss_mrdung_boss_activate"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_boss_activate.ogg", "static"},
	["sfx_boss_mrdung_death"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_death.ogg", "static"},
	["sfx_boss_mrdung_dying"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_dying.ogg", "static"},
	["sfx_boss_mrdung_land_in_dung"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_land_in_dung.ogg", "static"},
	["sfx_boss_mrdung_roll"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_roll.ogg", "static", { looping = true }},
	["sfx_boss_mrdung_ball_hit_{01-08}"] = {"sfx/enemy/mrdung/ball/sfx_boss_mrdung_ball_hit_{}.ogg", "static"},

	["fly_buzz"] = {"empty.ogg", "static"}, -- TODO change to actual sound
}

for key, params in pairs(sfxnames) do
	local start_s, end_s = key:match("{(.-)%-(.-)}")
	
	assert(params and #params > 0, "Empty table given for "..tostring(key))
	local path = params[1]
	local r = path:match("{}")
    if start_s and end_s and r then
        local len = math.max(#start_s, #end_s)
        local a = tonumber(start_s)
        local b = tonumber(end_s)
        assert(a and b, "Invalid number range in pattern")

        for i = a, b do
            local formatted = string.format("%0"..len.."d", i)
            local new_key = key:gsub("{(.-)%-(.-)}", formatted)
			local new_path = path:gsub("{}", formatted)
			sounds[new_key] = new_source(new_path, params[2], params[3])
        end
    else
        -- If no pattern, just apply the function directly
		sounds[key] = new_source(unpack(params))
    end
end

-- All sources are tables to support multiple sounds playing at once without using Source:clone()
for k, snd in pairs(sounds) do
	sounds[k] = Sound:new(
		snd,
		snd:getPitch(),
		snd:getVolume(),
		{
			looping = snd:isLooping(),
		}
	)
end

return sounds
