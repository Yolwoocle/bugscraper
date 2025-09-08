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

	-- MUSIC
	["music_ground_floor_players_paused"] = { "music/music_ground_floor_players_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_ingame"] =   { "music/music_ground_floor_empty_ingame.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_paused"] =   { "music/music_ground_floor_empty_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_players_ingame"] = { "music/music_ground_floor_players_ingame.ogg", "stream", { looping = true } },
	["music_w1_ingame"] =                   { "music/music_w1_ingame.ogg", "stream", { looping = true } },
	["music_w1_paused"] =                   { "music/music_w1_paused.ogg", "stream", { looping = true } },
	["music_w2_ingame"] =                   { "music/music_w2_ingame.ogg", "stream", { looping = true } },
	["music_w3_ingame"] =                   { "music/music_w3_ingame.mp3", "stream", { looping = true } },
	["music_w3_paused"] =                   { "music/music_w3_paused.mp3", "stream", { looping = true } },
	["music_game_over"] =                   { "music/music_game_over.ogg", "stream", { looping = true } },
	["music_cafeteria_ingame"] =            { "music/music_cafeteria_ingame.ogg", "stream", { looping = true } },
	["music_cafeteria_paused"] =            { "music/music_cafeteria_paused.ogg", "stream", { looping = true } },
	["music_cafeteria_empty_ingame"] =      { "music/music_cafeteria_empty_ingame.ogg", "stream", { looping = true } },
	["music_boss_w1_ingame"] =              { "music/music_boss_w1_ingame.ogg", "stream", { looping = true } },
	["music_boss_w1_paused"] =              { "music/music_boss_w1_paused.ogg", "stream", { looping = true } },

	-- GUNS
	["sfx_weapon_peagun_shoot_{01-08}"] =           {"sfx/weapons/peagun/sfx_weapon_peagun_shoot_{}.ogg", "static"},
	["sfx_weapon_pollenburst_shoot_{01-06}"] =      {"sfx/weapons/pollenburst/sfx_weapon_pollenburst_shoot_{}.ogg", "static"},
	["sfx_weapon_seedminigun_shoot_{01-10}"] =      {"sfx/weapons/seedminigun/sfx_weapon_seedminigun_shoot_{}.ogg", "static"},
	["sfx_weapon_mushroomcannon_shoot_{01-04}"] =   {"sfx/weapons/mushroomcannon/sfx_weapon_mushroomcannon_shoot_{}.ogg", "static"},
	["sfx_weapon_bigberry_shoot_{01-04}"] =         {"sfx/weapons/bigberry/sfx_weapon_bigberry_shoot_{}.ogg", "static"},
	["sfx_weapon_raspberryshotgun_shoot_{01-10}"] = {"sfx/weapons/raspberryshotgun/sfx_weapon_raspberryshotgun_shoot_{}.ogg", "static"},
	["sfx_weapon_triplepepper_shoot_{01-08}"] =     {"sfx/weapons/triplepepper/sfx_weapon_triplepepper_shoot_{}.ogg", "static"},

	-- PLAYER
	["sfx_player_footstep_metal_{01-10}"] =  {"sfx/actor/player/walk/metal/sfx_player_footstep_metal_{}.ogg", "static"},
	["sfx_player_footstep_carpet_{01-10}"] = {"sfx/actor/player/walk/carpet/sfx_player_footstep_carpet_{}.ogg", "static"},
	["sfx_player_footstep_sand_{01-10}"] =   {"sfx/actor/player/walk/sand/sfx_player_footstep_sand_{}.ogg", "static"},
	["sfx_player_footstep_stone_{01-10}"] =  {"sfx/actor/player/walk/stone/sfx_player_footstep_stone_{}.ogg", "static"},
	["sfx_player_footstep_wood_{01-06}"] =   {"sfx/actor/player/walk/wood/sfx_player_footstep_wood_{}.ogg", "static"},
	["sfx_player_footstep_glass_{01-06}"] =  {"sfx/actor/player/walk/glass/sfx_player_footstep_glass_{}.ogg", "static"},

	["sfx_player_footstep_land_metal_{01-04}"] = {"sfx/actor/player/land/metal/sfx_player_footstep_land_metal_{}.ogg", "static"},
	["sfx_player_footstep_land_carpet_{01-04}"] = {"sfx/actor/player/land/carpet/sfx_player_footstep_land_carpet_{}.ogg", "static"},
	["sfx_player_footstep_land_sand_{01-04}"] = {"sfx/actor/player/land/sand/sfx_player_footstep_land_sand_{}.ogg", "static"},
	["sfx_player_footstep_land_stone_{01-04}"] = {"sfx/actor/player/land/stone/sfx_player_footstep_land_stone_{}.ogg", "static"},
	["sfx_player_footstep_land_wood_{01-04}"] = {"sfx/actor/player/land/wood/sfx_player_footstep_land_wood_{}.ogg", "static"},
	["sfx_player_footstep_land_glass_{01-04}"] = {"sfx/actor/player/land/glass/sfx_player_footstep_land_glass_{}.ogg", "static"},

	["sfx_player_wall_slide_metal_{01-02}"] = {"sfx/actor/player/slide/metal/sfx_player_wall_slide_metal_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stone_{01-02}"] = {"sfx/actor/player/slide/stone/sfx_player_wall_slide_stone_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_glass_{01-02}"] = {"sfx/actor/player/slide/glass/sfx_player_wall_slide_glass_{}.ogg", "static", { looping = true }},

	["sfx_player_wall_slide_stamina_low"] =      {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_low.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stamina_very_low"] = {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_very_low.ogg", "static", { looping = true }},

	["sfx_player_damage_normal"] =         {"sfx/actor/player/sfx_player_damage_normal.ogg", "static"},
	["sfx_player_damage_poison"] =         {"sfx/actor/player/sfx_player_damage_poison.ogg", "static"},
	["sfx_player_death"] =                 {"sfx/actor/player/sfx_player_death.ogg", "static"},
	["sfx_player_leave_game"] =            {"sfx/actor/player/sfx_player_leave_game.ogg", "static"},
	["sfx_player_leave_game_easter_egg"] = {"sfx/actor/player/sfx_player_leave_game_easter_egg.ogg", "static"},
	
	["sfx_player_jumplong"] = {"sfx/actor/player/jump/sfx_player_jumplong.ogg", "static"},

	-- ACTORS
	-- Jumping props
	["sfx_actor_jumping_prop_paper_stack_{01-06}"] = {"sfx/actor/jumping_prop/paper_stack/sfx_actor_jumping_prop_paper_stack_{}.ogg", "static"},
	["sfx_actor_jumping_prop_mug_{01-06}"] =         {"sfx/actor/jumping_prop/mug/sfx_actor_jumping_prop_mug_{}.ogg", "static"},
	-- ["sfx_actor_jumping_prop_plant_small_{01-03}"] = {"sfx/actor/jumping_prop/plant_small/sfx_actor_jumping_prop_plant_small_{}.ogg", "static"},
	["sfx_actor_jumping_prop_screen_{01-06}"] =      {"sfx/actor/jumping_prop/screen/sfx_actor_jumping_prop_screen_{}.ogg", "static"},
	["sfx_actor_jumping_prop_boba_{01-06}"] =        {"sfx/actor/jumping_prop/boba/sfx_actor_jumping_prop_boba_{}.ogg", "static"},

	-- Cocoon
	["sfx_actor_cocoon_damage_{01-07}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_damage_{}.ogg", "static"},
	["sfx_actor_cocoon_break_{01-02}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_break_{}.ogg", "static"},

	-- Upgrade display 
	["sfx_actor_upgrade_display_break_{01-04}"] = {"sfx/upgrades/display_break/sfx_actor_upgrade_display_break_{}.ogg", "static"},

	-- Health pickup
	["sfx_loot_health_collect"] = {"sfx/sfx_loot_health_collect.ogg", "static"},

	-- Button small
	["sfx_actor_button_small_glass_damage_{01-06}"] = {"sfx/actor/button/glass/sfx_actor_button_small_glass_damage_{}.ogg", "static"},
	["sfx_actor_button_small_glass_break"] = {"sfx/actor/button/glass/sfx_actor_button_small_glass_break.ogg", "static"},
	["sfx_actor_button_small_pressed"] = {"sfx/actor/button/sfx_actor_button_small_pressed.ogg", "static"},

	-- ENEMIES 
	["sfx_enemy_kill_general_crush_{01-10}"] = {"sfx/enemy/death_temp/crush/sfx_enemy_kill_general_crush_{}.ogg", "static"},
	["sfx_enemy_kill_general_glitch_{01-10}"] = {"sfx/enemy/death_temp/glitch/sfx_enemy_kill_general_glitch_{}.ogg", "static"},
	["sfx_enemy_kill_general_gore_{01-10}"] = {"sfx/enemy/death_temp/gore/sfx_enemy_kill_general_gore_{}.ogg", "static"},

	-- Snail
	["sfx_enemy_snail_bounce_{01-06}"] = {"sfx/enemy/snail/sfx_enemy_snail_bounce_{}.ogg", "static"},

	-- Boomshroom
	["sfx_enemy_boomshroom_explosion_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_explosion_{}.ogg", "static"},
	["sfx_enemy_boomshroom_flashing"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_flashing.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_{01-07}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_{}.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_instant_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_instant_{}.ogg", "static"},

	-- Stink bug
	["sfx_enemy_poison_cloud_spawn_{01-04}"] = {"sfx/enemy/poison/sfx_enemy_poison_cloud_spawn_{}.ogg", "static"},

	-- Fly 
	["sfx_enemy_fly_ambient_{01-02}"] = {"sfx/enemy/fly/sfx_enemy_fly_ambient_{}.ogg", "static", { looping = true }},

	-- Boss W1    
	["sfx_boss_intro_mrdung"] = {"sfx/enemy/mrdung/sfx_boss_intro_mrdung.ogg", "static"},
	["sfx_boss_mrdung_boss_activate"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_boss_activate.ogg", "static"},
	["sfx_boss_mrdung_death"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_death.ogg", "static"},
	["sfx_boss_mrdung_dying"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_dying.ogg", "static"},
	["sfx_boss_mrdung_land_in_dung"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_land_in_dung.ogg", "static"},
	["sfx_boss_mrdung_roll"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_roll.ogg", "static", { looping = true }},
	["sfx_boss_mrdung_jump_{01-06}"] = {"sfx/enemy/mrdung/jump/sfx_boss_mrdung_jump_{}.ogg", "static"},
	["sfx_boss_mrdung_ball_hit_{01-06}"] = {"sfx/enemy/mrdung/ball/sfx_boss_mrdung_ball_hit_{}.ogg", "static"},

	-- W2	
	-- Timed spikes
	["sfx_enemy_timed_spikes_hit_{01-04}"] = {"sfx/enemy/timed_spikes/sfx_enemy_timed_spikes_hit_{}.ogg", "static"},

	-- Bee
	["sfx_enemy_bee_attack_{01-05}"] = {"sfx/enemy/bee/sfx_enemy_bee_attack_{}.ogg", "static"},

	-- Stabee
	["sfx_enemy_stabee_land_{01-04}"] = {"sfx/enemy/stabee/sfx_enemy_stabee_land_{}.ogg", "static"},
	["sfx_enemy_stabee_unstuck_{01-04}"] = {"sfx/enemy/stabee/sfx_enemy_stabee_unstuck_{}.ogg", "static"},

	-- Drill bee
	["sfx_enemy_drill_bee_attack_{01-04}"] = {"sfx/enemy/drill_bee/sfx_enemy_drill_bee_attack_{}.ogg", "static"},
	["sfx_enemy_drill_bee_explosion_{01-03}"] = {"sfx/enemy/drill_bee/sfx_enemy_drill_bee_explosion_{}.ogg", "static"},
	
	-- Beelet
	["sfx_enemy_beelet_telegraph_{01-04}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_telegraph_{}.ogg", "static"},
	["sfx_enemy_beelet_attack_{01-04}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_attack_{}.ogg", "static"},
	["sfx_enemy_beelet_bounce_{01-04}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_bounce_{}.ogg", "static"},

	-- Flying nest 
	["sfx_enemy_flying_nest_ambient_lp"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_ambient_lp.ogg", "static", { looping = true }},
	["sfx_enemy_flying_nest_death"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_death.ogg", "static"},
	["sfx_enemy_flying_nest_shoot_larva_{01-03}"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_shoot_larva_{}.ogg", "static"},
	
	-- Comball
	["sfx_enemy_comball_bounce_{01-06}"] = {"sfx/enemy/comball/sfx_enemy_comball_bounce_{}.ogg", "static"},
	["sfx_enemy_comball_flash_{01-06}"] = {"sfx/enemy/comball/sfx_enemy_comball_flash_{}.ogg", "static"},
	["sfx_enemy_comball_death"] = {"sfx/enemy/comball/sfx_enemy_comball_death.ogg", "static"},

	["fly_buzz"] = {"empty.ogg", "static"}, -- TODO change to actual sound

	-- UPGRADES
	["sfx_upgrades_apple_juice_pickedup"] = {"sfx/upgrades/sfx_upgrades_apple_juice_pickedup.ogg", "static"},
	["sfx_upgrades_boba_pickedup"] = {"sfx/upgrades/sfx_upgrades_boba_pickedup.ogg", "static"},
	["sfx_upgrades_energydrink_pickedup"] = {"sfx/upgrades/sfx_upgrades_energydrink_pickedup.ogg", "static"},
	["sfx_upgrades_espresso_pickedup"] = {"sfx/upgrades/sfx_upgrades_espresso_pickedup.ogg", "static"},
	["sfx_upgrades_milk_pickedup"] = {"sfx/upgrades/sfx_upgrades_milk_pickedup.ogg", "static"},
	["sfx_upgrades_peanut_pickedup"] = {"sfx/upgrades/sfx_upgrades_peanut_pickedup.ogg", "static"},
	["sfx_upgrades_soda_pickedup"] = {"sfx/upgrades/sfx_upgrades_soda_pickedup.ogg", "static"},
	["sfx_upgrades_tea_pickedup"] = {"sfx/upgrades/sfx_upgrades_tea_pickedup.ogg", "static"},
	["sfx_upgrades_water_pickedup"] = {"sfx/upgrades/sfx_upgrades_water_pickedup.ogg", "static"},

	["sfx_upgrades_general_hover"] = {"sfx/upgrades/sfx_upgrades_general_hover.ogg", "static"},
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
