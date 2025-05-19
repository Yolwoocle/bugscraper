require "scripts.util"
local Sound = require "scripts.audio.sound"

local function new_source(path, type, args)
	local source = love.audio.newSource("sounds/"..path, type)
	if not args then   return source   end

	if args.looping then
		source:setLooping(true)
	end
	return source
end

local sounds = {}

--music_level_1 = new_source("music/level_1.ogg", "stream", {looping = true})
local sfxnames = {
	char_walk_metal_001 = "actor/player/footstep/char_walk_metal_001.ogg",
	char_walk_metal_002 = "actor/player/footstep/char_walk_metal_002.ogg",
	char_walk_metal_003 = "actor/player/footstep/char_walk_metal_003.ogg",
	char_walk_metal_004 = "actor/player/footstep/char_walk_metal_004.ogg",
	char_walk_metal_005 = "actor/player/footstep/char_walk_metal_005.ogg",
	char_walk_metal_006 = "actor/player/footstep/char_walk_metal_006.ogg",
	char_walk_metal_007 = "actor/player/footstep/char_walk_metal_007.ogg",
	char_walk_metal_008 = "actor/player/footstep/char_walk_metal_008.ogg",
	char_walk_metal_009 = "actor/player/footstep/char_walk_metal_009.ogg",
	char_walk_metal_010 = "actor/player/footstep/char_walk_metal_010.ogg",

	char_walk_stone_001 = "actor/player/footstep/char_walk_stone_001.ogg",
	char_walk_stone_002 = "actor/player/footstep/char_walk_stone_002.ogg",
	char_walk_stone_003 = "actor/player/footstep/char_walk_stone_003.ogg",
	char_walk_stone_004 = "actor/player/footstep/char_walk_stone_004.ogg",
	char_walk_stone_005 = "actor/player/footstep/char_walk_stone_005.ogg",
	char_walk_stone_006 = "actor/player/footstep/char_walk_stone_006.ogg",
	char_walk_stone_007 = "actor/player/footstep/char_walk_stone_007.ogg",
	char_walk_stone_008 = "actor/player/footstep/char_walk_stone_008.ogg",
	char_walk_stone_009 = "actor/player/footstep/char_walk_stone_009.ogg",
	char_walk_stone_010 = "actor/player/footstep/char_walk_stone_010.ogg",

	sfx_enemies_stomp_break_01 =  "actor/enemies/sfx_enemies_stomp_break_01.ogg",
	sfx_enemies_stomp_break_02 =  "actor/enemies/sfx_enemies_stomp_break_02.ogg",
	sfx_enemies_stomp_break_03 =  "actor/enemies/sfx_enemies_stomp_break_03.ogg",
	sfx_enemies_stomp_break_04 =  "actor/enemies/sfx_enemies_stomp_break_04.ogg",
	sfx_enemies_stomp_glitch_01 = "actor/enemies/sfx_enemies_stomp_glitch_01.ogg",
	sfx_enemies_stomp_glitch_02 = "actor/enemies/sfx_enemies_stomp_glitch_02.ogg",
	sfx_enemies_stomp_glitch_03 = "actor/enemies/sfx_enemies_stomp_glitch_03.ogg",
	sfx_enemies_stomp_glitch_04 = "actor/enemies/sfx_enemies_stomp_glitch_04.ogg",
	sfx_enemies_stomp_gore_01 =   "actor/enemies/sfx_enemies_stomp_gore_01.ogg",
	sfx_enemies_stomp_gore_02 =   "actor/enemies/sfx_enemies_stomp_gore_02.ogg",
	sfx_enemies_stomp_gore_03 =   "actor/enemies/sfx_enemies_stomp_gore_03.ogg",
	sfx_enemies_stomp_gore_04 =   "actor/enemies/sfx_enemies_stomp_gore_04.ogg",

	sfx_upgrades_glassbreak_01 =  "actor/sfx_upgrades_glassbreak_01.ogg", 
	sfx_upgrades_glassbreak_02 =  "actor/sfx_upgrades_glassbreak_02.ogg",
	sfx_upgrades_glassbreak_03 =  "actor/sfx_upgrades_glassbreak_03.ogg",
	
	sfx_upgrades_glassbreak_04 = "actor/sfx_upgrades_glassbreak_04.ogg", 
	sfx_weapon_bulletbounce_01 = "actor/sfx_weapon_bulletbounce_01.ogg", 
	sfx_weapon_bulletbounce_02 = "actor/sfx_weapon_bulletbounce_02.ogg", 
	sfx_weapon_bulletbounce_03 = "actor/sfx_weapon_bulletbounce_03.ogg", 
	sfx_weapon_bulletbounce_04 = "actor/sfx_weapon_bulletbounce_04.ogg", 
	sfx_weapon_bulletbounce_05 = "actor/sfx_weapon_bulletbounce_05.ogg", 
	sfx_weapon_bulletbounce_06 = "actor/sfx_weapon_bulletbounce_06.ogg", 
	sfx_weapon_glassbreak =      "actor/sfx_weapon_glassbreak.ogg", 
	sfx_weapon_glassjump_01 =    "actor/sfx_weapon_glassjump_01.ogg", 
	sfx_weapon_glassjump_02 =    "actor/sfx_weapon_glassjump_02.ogg", 
	sfx_weapon_glassjump_03 =    "actor/sfx_weapon_glassjump_03.ogg", 
	sfx_weapon_glassjump_04 =    "actor/sfx_weapon_glassjump_04.ogg", 
	sfx_weapon_glassjump_05 =    "actor/sfx_weapon_glassjump_05.ogg", 
	sfx_weapon_glassjump_06 =    "actor/sfx_weapon_glassjump_06.ogg",

	jump = "jump1.ogg",
	shot1 = "shot1.ogg", -- these are pico 8 sfx from birds with guns
	shot2 = "shot2.ogg",
	shot3 = "shot3.ogg",
	gunshot1 = "gunshot1.ogg",
	gunshot_machinegun = "gunshot_machinegun.ogg",
	gunshot_shotgun = "gunshot_shotgun.ogg",
	gunshot_ring_1 = "gunshot_ring_1.ogg",
	gunshot_ring_2 = "gunshot_ring_2.ogg",
	gunshot_ring_3 = "gunshot_ring_3.ogg",
	pop_ring = "pop_ring.ogg",
	bullet_bounce_1 = "bullet_bounce_1.ogg",
	bullet_bounce_2 = "bullet_bounce_2.ogg",

	hurt =  "hurt.ogg",
	land =  "land.ogg",
	item_collect = "item_collect.ogg",

	menu_hover_old =  "menu_hover.ogg",

	ui_menu_hover_01 =      "ui/ui_menu_hover_01.ogg",
	ui_menu_hover_02 =      "ui/ui_menu_hover_02.ogg",
	ui_menu_hover_03 =      "ui/ui_menu_hover_03.ogg",
	ui_menu_hover_04 =      "ui/ui_menu_hover_04.ogg",
	ui_menu_select_01 =      "ui/ui_menu_select_01.ogg",
	ui_menu_select_02 =      "ui/ui_menu_select_02.ogg",
	ui_menu_select_03 =      "ui/ui_menu_select_03.ogg",
	ui_menu_select_04 =      "ui/ui_menu_select_04.ogg",
	ui_menu_pause =      "ui/ui_menu_pause.ogg",
	ui_menu_unpause =    "ui/ui_menu_unpause.ogg",

	stabee_land_1 = "actor/enemy/stabee_land_1.ogg",
	stabee_land_2 = "actor/enemy/stabee_land_2.ogg",
	stabee_land_3 = "actor/enemy/stabee_land_3.ogg",
	stabee_attack = "actor/enemy/stabee_attack.ogg",

	beelet_inflate_1 = "actor/enemy/beelet_inflate_1.ogg",
	beelet_inflate_2 = "actor/enemy/beelet_inflate_2.ogg",
	beelet_inflate_3 = "actor/enemy/beelet_inflate_3.ogg",
	beelet_inflate_4 = "actor/enemy/beelet_inflate_4.ogg",
	
	wall_slide = "wall_slide.ogg",
	death = "death.ogg",

	explosion = "explosion.ogg",

	sliding_wall_metal = "sliding_wall_metal.ogg",

	footstep00 = "footstep00.ogg", -- CC0 https://kenney.nl/
	footstep01 = "footstep01.ogg",
	footstep02 = "footstep02.ogg",
	footstep03 = "footstep03.ogg",
	footstep04 = "footstep04.ogg",
	footstep05 = "footstep05.ogg",
	footstep06 = "footstep06.ogg",
	footstep07 = "footstep07.ogg",
	footstep08 = "footstep08.ogg",
	footstep09 = "footstep09.ogg",

	metalfootstep_00 = "footstep/metalfootstep_000.ogg", -- CC0 https://kenney.nl/
	metalfootstep_01 = "footstep/metalfootstep_001.ogg",
	metalfootstep_02 = "footstep/metalfootstep_002.ogg",
	metalfootstep_03 = "footstep/metalfootstep_003.ogg",
	metalfootstep_04 = "footstep/metalfootstep_004.ogg",

	impactglass_heavy_000 = "impactglass_heavy_000.ogg", -- CC0 https://kenney.nl/
	impactglass_heavy_001 = "impactglass_heavy_001.ogg",
	impactglass_heavy_002 = "impactglass_heavy_002.ogg",
	impactglass_heavy_003 = "impactglass_heavy_003.ogg",
	impactglass_heavy_004 = "impactglass_heavy_004.ogg",

	impactglass_light_000 = "impactglass_light_000.ogg",
	impactglass_light_001 = "impactglass_light_001.ogg",
	impactglass_light_002 = "impactglass_light_002.ogg",
	impactglass_light_003 = "impactglass_light_003.ogg",
	impactglass_light_004 = "impactglass_light_004.ogg",

	metal_impact = "metal_impact.ogg",

	glass_fracture = "glass_fracture.ogg", -- CC BY https://freesound.org/people/cmusounddesign/sounds/85168/
	glass_break_weak = "glass_break_weak.ogg", -- CC BY https://freesound.org/people/cmusounddesign/sounds/85168/
	glass_break = "glass_break.ogg", 
	-- CC0  window shatter https://freesound.org/people/avrahamy/sounds/141563/
	-- + combined & deeper CCBY   glass shatter https://freesound.org/people/cmusounddesign/sounds/85168/
	-- + combined & fade out CCBY sprinkle texture https://freesound.org/people/el-bee/sounds/636238/

	button_press = "button_press.ogg",
	-- CCBY RICHERlandTV Buzz https://freesound.org/people/RICHERlandTV/sounds/216090/
	-- CCBY keypress slowed down https://freesound.org/people/MattRuthSound/sounds/561661/
	-- CC0 Impact Sound https://kenney.nl/

	cloth1 = "cloth1.ogg", -- CC0 Kenney
	cloth2 = "cloth2.ogg",
	cloth3 = "cloth3.ogg",
	cloth_drop = "cloth_drop.ogg", -- CC0 Kenney + CC0 https://freesound.org/people/RossBell/sounds/389442/

	larva_damage1 = "larva_damage1.ogg",
	larva_damage2 = "larva_damage2.ogg",
	larva_damage3 = "larva_damage3.ogg",
	larva_death = "larva_death.ogg",

	flying_dung_death = "flying_dung_death.ogg",

	fly_buzz = "fly_buzz.ogg",

	elevator_bg = "elevator_bg.ogg",
	elev_door_open = "elev_door_open.ogg",
	elev_door_close = "elev_door_close.ogg",
	elev_burning = "elev_burning.ogg",
	elev_ding = "elev_ding.ogg",

	gravel_footstep_1 = "gravel_footstep_1.ogg",
	gravel_footstep_2 = "gravel_footstep_2.ogg",
	gravel_footstep_3 = "gravel_footstep_3.ogg",
	gravel_footstep_4 = "gravel_footstep_4.ogg",
	gravel_footstep_5 = "gravel_footstep_5.ogg",
	gravel_footstep_6 = "gravel_footstep_6.ogg",

	elev_crash = "elev_crash.ogg",
	elev_siren = "elev_siren.ogg",
	mushroom_ant_pop = "mushroom_ant_pop.ogg",

	enemy_damage = "enemy_damage.ogg",
	enemy_death_1 = "enemy_death_1.ogg",
	enemy_death_2 = "enemy_death_2.ogg",
	enemy_stomp_2 = "enemy_stomp_2.ogg",
	enemy_stomp_3 = "enemy_stomp_3.ogg",

	ball_roll = "ball_roll.ogg",

	snail_shell_crack = "snail_shell_crack.ogg",
	triple_pop = "triple_pop.ogg",

	crush_bug_1 = "crush_bug_1.ogg",
	crush_bug_2 = "crush_bug_2.ogg",
	crush_bug_3 = "crush_bug_3.ogg",
	crush_bug_4 = "crush_bug_4.ogg",

	stink_bug_death = "stink_bug_death.ogg",

	chipper_telegraph = "chipper_telegraph.ogg",

	spotlight_1 = "spotlight_1.ogg",
	spotlight_2 = "spotlight_2.ogg",
	spotlight_3 = "spotlight_3.ogg",

	xp_tick = "xp_tick.wav",

	---------
	stomp2 = "stomp2.ogg", --removeme todo rename this

	jump_short = "jump_short.ogg",

	exit_sign_activate = "exit_sign_activate.ogg",
	smash_easter_egg = "smash_easter_egg.mp3",

	empty = "empty.ogg",
}

for key, name in pairs(sfxnames) do
	sounds[key] = new_source(name, "static")
end

sounds.shot1:setVolume(0.9)
sounds.shot2:setPitch(0.8)

sounds.sliding_wall_metal:setLooping(true)
sounds.sliding_wall_metal:setVolume(0.1)
sounds.elevator_bg:setVolume(0.5)
sounds.elevator_bg:setLooping(true)
sounds.elev_door_open:setVolume(0.3)
sounds.elev_door_close:setVolume(0.3)

sounds.elev_burning:setLooping(true)

sounds.fly_buzz:setLooping(true)
sounds.ball_roll:setLooping(true)

for i=0,9 do
	sounds["footstep0"..tostring(i)]:setVolume(0.2)
end
 
-- sounds.music_galaxy_trip = new_source("music/v2_teelopes.ogg", "static", {looping = true})
sounds.music_intro_ingame =     new_source("music/music_intro_ingame.ogg",     "stream", {looping = true})
sounds.music_intro_paused =     new_source("music/music_intro_paused.ogg",     "stream", {looping = true})
sounds.music_ground_floor_players_paused =    new_source("music/music_ground_floor_players_paused.ogg", "stream", {looping=true}) 
sounds.music_ground_floor_empty_ingame =      new_source("music/music_ground_floor_empty_ingame.ogg",   "stream", {looping=true}) 
sounds.music_ground_floor_empty_paused =      new_source("music/music_ground_floor_empty_paused.ogg",   "stream", {looping=true})
sounds.music_ground_floor_players_ingame =    new_source("music/music_ground_floor_players_ingame.ogg", "stream", {looping=true})

sounds.music_intro_ingame =     new_source("music/music_intro_ingame.ogg",     "stream", {looping = true})
sounds.music_intro_paused =     new_source("music/music_intro_paused.ogg",     "stream", {looping = true})
sounds.music_w1_ingame =        new_source("music/music_w1_ingame.ogg",        "stream", {looping = true})
sounds.music_w1_paused =        new_source("music/music_w1_paused.ogg",        "stream", {looping = true})
sounds.music_w2_ingame =        new_source("music/music_w2_ingame.mp3",        "stream", {looping = true})
sounds.music_w3_ingame =        new_source("music/music_w3_ingame.mp3",        "stream", {looping = true})
sounds.music_w3_paused =        new_source("music/music_w3_paused.mp3",        "stream", {looping = true})
sounds.music_game_over =        new_source("music/music_game_over.ogg",        "stream", {looping = true})
sounds.music_cafeteria_ingame = new_source("music/music_cafeteria_ingame.ogg", "stream", {looping = true})
sounds.music_cafeteria_paused = new_source("music/music_cafeteria_paused.ogg", "stream", {looping = true})
sounds.music_cafeteria_empty_ingame = new_source("music/music_cafeteria_empty_ingame.ogg", "stream", {looping = true})
sounds.music_miniboss_ingame =  new_source("music/music_miniboss_ingame.ogg",  "stream", {looping = true})
sounds.music_miniboss_paused =  new_source("music/music_miniboss_paused.ogg",  "stream", {looping = true})

-- Static sounds are sounds that are played without the use of the audio:play function
-- local static_sfx_names = {
-- 	"music1",
-- 	"elevator_bg",
-- 	"elev_door_open",
-- 	"elev_door_close",
-- 	"elev_burning",
-- 	"elev_siren",
-- 	"sliding_wall_metal",
-- 	"fly_buzz"
-- }
-- local static_sounds = {}
-- for _,v in pairs(static_sfx_names) do
-- 	table.insert(static_sounds, sounds[v])
-- end

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