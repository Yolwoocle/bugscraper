require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"

DEBUG_IMAGE_TO_COL = {}
local function debug_set_image_col(im, name)
	local image_data = love.image.newImageData("images/"..name)
	local col = {image_data:getPixel(im:getWidth()/2, im:getHeight()/2)}
	DEBUG_IMAGE_TO_COL[im] = col
end

local function load_image(name)
	local im = love.graphics.newImage("images/"..name)
	im:setFilter("nearest", "nearest")
	debug_set_image_col(im, name)
	return im 
end

local function load_spritesheet(name, number)
	local image = load_image(name)
	local sheet = {
		type = "spritesheet",
		image = image,
		quads = {},
	}
	local width = math.floor(image:getWidth()/number)

	for x = 0, image:getWidth(), width do
		table.insert(sheet.quads, love.graphics.newQuad(x, 0, width, image:getHeight(), image:getDimensions()))
	end

    return sheet
end

local function load_image_table(name, n, w, h)
	if not n then  error("number of images `n` not defined")  end
	local t = {}
	for i=1,n do 
		t[i] = load_image(name..tostring(i)..".png")
	end
	t.w = w
	t.h = h
	return t
end

-----------------------------------------------------

local images = {}

local img_names = {
	empty = "empty",

	-----------------------------------------------------

	-- test
	_test_window = "_test_window",
	_test_shine = "_test_shine",

	-----------------------------------------------------

	-- players
	beetle_1 =         "actors/players/beetle_1",
	beetle_2 =         "actors/players/beetle_2",
	beetle_dead =      "actors/players/beetle_dead",

	leo =              "actors/players/leo",

	ant1 =             "actors/players/ant1",
	ant2 =             "actors/players/ant2",
	ant_wall_slide =   "actors/players/ant_wall_slide",
	ant_dead =         "actors/players/ant_dead",
	ant_head =         "actors/players/ant_head",

	bee_1 =            "actors/players/bee_1",
	bee_2 =            "actors/players/bee_2",
	bee_dead =         "actors/players/bee_dead",

	rabbit_1 =         "actors/players/rabbit_1",
	rabbit_2 =         "actors/players/rabbit_2",
	rabbit_dead =      "actors/players/rabbit_dead",
	
	caterpillar_1 =    "actors/players/caterpillar_1",
	caterpillar_2 =    "actors/players/caterpillar_2",
	caterpillar_dead = "actors/players/caterpillar_dead",
	caterpillar_head = "actors/players/caterpillar_head",

	duck =             "actors/players/duck",

	-- enemies
	bee_boss_1 =               "actors/enemies/bee_boss_1",
	bee_boss_2 =               "actors/enemies/bee_boss_2",
	big_bug_1 =                "actors/enemies/big_bug_1",
	boomshroom_1 =             "actors/enemies/boomshroom_1",
	boomshroom_2 =             "actors/enemies/boomshroom_2",
	boomshroom_3 =             "actors/enemies/boomshroom_3",
	boomshroom_4 =             "actors/enemies/boomshroom_4",
	boomshroom_5 =             "actors/enemies/boomshroom_5",
	boomshroom_6 =             "actors/enemies/boomshroom_6",
	boomshroom_7 =             "actors/enemies/boomshroom_7",
	boomshroom_8 =             "actors/enemies/boomshroom_8",
	bulb_buddy_1 =             "actors/enemies/bulb_buddy_1",
	bulb_buddy_2 =             "actors/enemies/bulb_buddy_2",
	chipper_1 =                "actors/enemies/chipper_1",
	chipper_2 =                "actors/enemies/chipper_2",
	chipper_3 =                "actors/enemies/chipper_3",
	cloud_enemy_size1 =        "actors/enemies/cloud_enemy_size1",
	cloud_enemy_size2 =        "actors/enemies/cloud_enemy_size2",
	cloud_enemy_size3 =        "actors/enemies/cloud_enemy_size3",
	cloud_storm =              "actors/enemies/cloud_storm",
	cloud_storm_angry =        "actors/enemies/cloud_storm_angry",
	cloud_storm_angry_attack = "actors/enemies/cloud_storm_angry_attack",
	beelet_1 =                 "actors/enemies/beelet_1",
	beelet_activated_1 =       "actors/enemies/beelet_activated_1",
	beelet_activated_2 =       "actors/enemies/beelet_activated_2",
	chipper_attack_1 =         "actors/enemies/chipper_attack_1",
	chipper_attack_2 =         "actors/enemies/chipper_attack_2",
	chipper_attack_3 =         "actors/enemies/chipper_attack_3",
	cocoon =                   "actors/enemies/cocoon",
	dummy_target =             "actors/enemies/dummy_target",
	dung =                     "actors/enemies/dung",
	dung_beetle_1 =            "actors/enemies/dung_beetle_1",
	dung_beetle_2 =            "actors/enemies/dung_beetle_2",
	dung_beetle_shield =       "actors/enemies/dung_beetle_shield",
	dung_beetle_shield_shine = "actors/enemies/dung_beetle_shield_shine",
	dung_flying =              "actors/enemies/dung_flying",
	dung_flying_spiked =       "actors/enemies/dung_flying_spiked",
	dung_projectile =          "actors/enemies/dung_projectile",
	drill_bee =                "actors/enemies/drill_bee",
	fly1 =                     "actors/enemies/fly1",
	fly2 =                     "actors/enemies/fly2",
	grasshopper =              "actors/enemies/grasshopper",
	grasshopper_fall =         "actors/enemies/grasshopper_fall",
	honeypot_ant1 =            "actors/enemies/honeypot_ant1",
	honeypot_ant2 =            "actors/enemies/honeypot_ant2",
	honeypot_liquid =          "actors/enemies/honeypot_liquid",
	larva =                    "actors/enemies/larva",
	larva1 =                   "actors/enemies/larva1",
	larva2 =                   "actors/enemies/larva2",
	larva_spawner =            "actors/enemies/larva_spawner",
	flying_spawner_1 =         "actors/enemies/flying_spawner_1",
	flying_spawner_2 =         "actors/enemies/flying_spawner_2",
	larva_projectile =         "actors/enemies/larva_projectile",
	metal_mosquito_1 =         "actors/enemies/metal_mosquito_1",
	metal_mosquito_2 =         "actors/enemies/metal_mosquito_2",
	mole_digging_1 =           "actors/enemies/mole_digging_1",
	mosquito1 =                "actors/enemies/mosquito1",
	mosquito2 =                "actors/enemies/mosquito2",
	motherboard =              "actors/enemies/motherboard",
	motherboard_button =       "actors/enemies/motherboard_button",
	mushroom_ant1 =            "actors/enemies/mushroom_ant1",
	mushroom_ant2 =            "actors/enemies/mushroom_ant2",
	shovel_bee =               "actors/enemies/shovel_bee",
	shovel_bee_buried =        "actors/enemies/shovel_bee_buried",
	slug1 =                    "actors/enemies/slug1",
	slug2 =                    "actors/enemies/slug2",
	snail_open =               "actors/enemies/snail_open",
	snail_shell =              "actors/enemies/snail_shell",
	snail_shell_bouncy =       "actors/enemies/snail_shell_bouncy",
	spider1 =                  "actors/enemies/spider1",
	spider2 =                  "actors/enemies/spider2",
	spiked_fly =               "actors/enemies/spiked_fly",
	stink_bug_1 =              "actors/enemies/stink_bug_1",
	timed_spikes_base =        "actors/enemies/timed_spikes_base",
	timed_spikes_spikes =      "actors/enemies/timed_spikes_spikes",
	woodlouse_1 =              "actors/enemies/woodlouse_1",
	woodlouse_2 =              "actors/enemies/woodlouse_2",

	motherboard_bullet_cannon = "actors/enemies/motherboard_bullet_cannon",
	motherboard_led_on =       "actors/enemies/motherboard_led_on",
	motherboard_led_off =      "actors/enemies/motherboard_led_off",
	motherboard_plug_rays_1 =  "actors/enemies/motherboard_plug_rays_1",
	motherboard_plug_rays_2 =  "actors/enemies/motherboard_plug_rays_2",
	motherboard_plug_bullets = "actors/enemies/motherboard_plug_bullets",
	motherboard_shield =       "actors/enemies/motherboard_shield",
	poison_cloud =             "actors/enemies/poison_cloud_1",

	upgrade_jar =              "actors/enemies/upgrade_jar",
	gun_display =              "actors/enemies/gun_display",
	big_red_button_crack0 =    "actors/enemies/big_red_button_crack0",
	big_red_button_crack1 =    "actors/enemies/big_red_button_crack1",
	big_red_button_crack2 =    "actors/enemies/big_red_button_crack2",
	big_red_button_crack3 =    "actors/enemies/big_red_button_crack3",
	big_red_button =           "actors/enemies/big_red_button",
	big_red_button_pressed =   "actors/enemies/big_red_button_pressed",
	small_button_crack0 =      "actors/enemies/small_button_crack0",
	small_button_crack1 =      "actors/enemies/small_button_crack1",
	small_button_crack2 =      "actors/enemies/small_button_crack2",
	small_button =             "actors/enemies/small_button",
	small_button_pressed =     "actors/enemies/small_button_pressed",
	exit_sign =                "actors/enemies/exit_sign",
	exit_sign_front =          "actors/enemies/exit_sign_front",
	punching_glove =           "actors/enemies/punching_glove",
	spring =                   "actors/enemies/spring",

	machine_coffee =           "actors/enemies/machine_coffee",
	machine_coffee_pressed =   "actors/enemies/machine_coffee_pressed",
	machine_snacks =           "actors/enemies/machine_snacks",
	machine_toys =             "actors/enemies/machine_toys",

	loot_ammo =                "actors/loot/loot_ammo",
	loot_ammo_big =            "actors/loot/loot_ammo_big",
	loot_life =                "actors/loot/loot_life",
	loot_life_big =            "actors/loot/loot_life_big",
	
	bullet =                   "actors/bullets/bullet",
	bullet_pea =               "actors/bullets/bullet_pea",
	bullet_red =               "actors/bullets/bullet_red",
	bullet_blue =              "actors/bullets/bullet_blue",
	bullet_ring =              "actors/bullets/bullet_ring",
	mushroom =                 "actors/bullets/mushroom",
	mushroom_yellow =          "actors/bullets/mushroom_yellow",
	mushroom_spike =           "actors/bullets/mushroom_spike",

	-----------------------------------------------------
	
	-- guns
	gun_machinegun =      "guns/gun_machinegun",
	gun_triple =          "guns/gun_triple",
	gun_burst =           "guns/gun_burst",
	gun_shotgun =         "guns/gun_shotgun",
	gun_minigun =         "guns/gun_minigun",
	gun_mushroom_cannon = "guns/gun_mushroom_cannon",
	gun_ring =            "guns/gun_ring",
	
	-----------------------------------------------------
	
	-- particles
	cocoon_fragment_1 =    "particles/cocoon_fragment_1",
	cocoon_fragment_2 =    "particles/cocoon_fragment_2",
	honey_fragment_1 =     "particles/honey_fragment_1",
	honey_fragment_2 =     "particles/honey_fragment_2",
	dummy_fragment_1 =     "particles/dummy_fragment_1",
	dummy_fragment_2 =     "particles/dummy_fragment_2",
	explosion_flash =      "particles/explosion_flash",
	glass_shard =          "particles/glass_shard",
	snail_shell_fragment = "particles/snail_shell_fragment",
	snail_shell_bouncy_fragment = "particles/snail_shell_bouncy_fragment",
	bullet_casing =        "particles/bullet_casing",
	button_fragment_1 =    "particles/button_fragment_1",
	button_fragment_2 =    "particles/button_fragment_2",
	button_fragment_3 =    "particles/button_fragment_3",
	button_fragment_4 =    "particles/button_fragment_4",
	button_fragment_5 =    "particles/button_fragment_5",
	smash_flash =          "particles/smash_flash",
	particle_leaf =        "particles/particle_leaf",
	white_dust =           "particles/white_dust",
	particle_bit_zero =    "particles/particle_bit_zero",
	particle_bit_one =     "particles/particle_bit_one",

	bullet_vanish_1 =      "particles/bullet_vanish_1",
	bullet_vanish_2 =      "particles/bullet_vanish_2",
	bullet_vanish_3 =      "particles/bullet_vanish_3",
	bullet_vanish_4 =      "particles/bullet_vanish_4",
	bullet_vanish_5 =      "particles/bullet_vanish_5",

	star_splash_1 =        "particles/star_splash_1",
	star_splash_2 =        "particles/star_splash_2",
	star_splash_3 =        "particles/star_splash_3",
	star_splash_4 =        "particles/star_splash_4",
	star_splash_5 =        "particles/star_splash_5",

	star_splash_small_1 =  "particles/star_splash_small_1",
	star_splash_small_2 =  "particles/star_splash_small_2",
	star_splash_small_3 =  "particles/star_splash_small_3",

	jump_dust_kick_1 =     "particles/jump_dust_kick_1",
	jump_dust_kick_2 =     "particles/jump_dust_kick_2",
	jump_dust_kick_3 =     "particles/jump_dust_kick_3",
	jump_dust_kick_4 =     "particles/jump_dust_kick_4",
	jump_dust_kick_5 =     "particles/jump_dust_kick_5",

	-----------------------------------------------------
	
	-- level
	metal =                   "level/metal",
	chain =                   "level/chain",
	semisolid =               "level/semisolid",
	bg_plate =                "level/bg_plate",

	cabin_bg =                       "level/cabin_bg",
	cabin_bg_brown =                 "level/cabin_bg_brown",
	cabin_bg_ambient_occlusion =     "level/cabin_bg_ambient_occlusion",
	cabin_walls =                    "level/cabin_walls",
	cabin_walls_brown =              "level/cabin_walls_brown",

	cabin_door_left_far =            "level/cabin_door_left_far", 
	cabin_door_left_center =         "level/cabin_door_left_center",
	cabin_door_right_center =        "level/cabin_door_right_center",
	cabin_door_light_left_far =      "level/cabin_door_light_left_far", 

	cabin_door_right_far =           "level/cabin_door_right_far",
	cabin_door_light_left_center =   "level/cabin_door_light_left_center",
	cabin_door_light_right_far =     "level/cabin_door_light_right_far",
	cabin_door_light_right_center =  "level/cabin_door_light_right_center",

	cabin_door_brown_left_far =      "level/cabin_door_brown_left_far", 
	cabin_door_brown_left_center =   "level/cabin_door_brown_left_center",
	cabin_door_brown_right_far =     "level/cabin_door_brown_right_far",
	cabin_door_brown_right_center =  "level/cabin_door_brown_right_center",
	
	cabin_rubble =                   "level/cabin_rubble",
	cabin_grid =                     "level/cabin_grid",
	cabin_grid_brown =               "level/cabin_grid_brown",
	cabin_grid_platform =            "level/cabin_grid_platform",

	cafeteria =                      "level/cafeteria",
	elevator_through_door =          "level/elevator_through_door",
	ground_floor =                   "level/ground_floor",
	ground_floor_front =             "level/ground_floor_front",

	ground_floor_lamp =              "level/props/ground_floor_lamp",
	ground_floor_cactus =            "level/props/ground_floor_cactus",
	ground_floor_computer_left =     "level/props/ground_floor_computer_left",
	ground_floor_computer_right =    "level/props/ground_floor_computer_right",
	ground_floor_mug =               "level/props/ground_floor_mug",
	ground_floor_potted_tree =       "level/props/ground_floor_potted_tree",
	ground_floor_potted_plant =      "level/props/ground_floor_potted_plant",
	ground_floor_stack_papers_big =  "level/props/ground_floor_stack_papers_big",
	ground_floor_stack_papers_medium = "level/props/ground_floor_stack_papers_medium",
	ground_floor_stack_papers_medium_b = "level/props/ground_floor_stack_papers_medium_b",
	ground_floor_stack_papers_small = "level/props/ground_floor_stack_papers_small",

	tv_slideshow_001 = "level/tv_slideshow/tv_slideshow_001",
	tv_slideshow_002 = "level/tv_slideshow/tv_slideshow_002",
	tv_slideshow_003 = "level/tv_slideshow/tv_slideshow_003",
	tv_slideshow_004 = "level/tv_slideshow/tv_slideshow_004",
	tv_slideshow_005 = "level/tv_slideshow/tv_slideshow_005",
	tv_slideshow_006 = "level/tv_slideshow/tv_slideshow_006",
	tv_slideshow_007 = "level/tv_slideshow/tv_slideshow_007",
	tv_slideshow_008 = "level/tv_slideshow/tv_slideshow_008",
	tv_slideshow_009 = "level/tv_slideshow/tv_slideshow_009",
	tv_slideshow_010 = "level/tv_slideshow/tv_slideshow_010",
	tv_slideshow_011 = "level/tv_slideshow/tv_slideshow_011",
	tv_slideshow_012 = "level/tv_slideshow/tv_slideshow_012",
	tv_slideshow_013 = "level/tv_slideshow/tv_slideshow_013",
	tv_slideshow_014 = "level/tv_slideshow/tv_slideshow_014",
	tv_slideshow_999 = "level/tv_slideshow/tv_slideshow_999",
	tv_bluescreen = "level/tv_slideshow/tv_bluescreen",

	-----------------------------------------------------

	-- hud
	heart =           "ui/hud/heart",
	heart_half =      "ui/hud/heart_half",
	heart_empty =     "ui/hud/heart_empty",
	heart_temporary = "ui/hud/heart_temporary",
	ammo =            "ui/hud/ammo",

	-- logo
	logo =        "ui/logo/logo",
	logo_noshad = "ui/logo/logo_noshad",
	logo_shad =   "ui/logo/logo_shad",

	controls_jetpack = "ui/controls_jetpack",

	selection_left =  "ui/selection_left",
	selection_mid =   "ui/selection_mid",
	selection_right = "ui/selection_right",
	bubble_tip =      "ui/bubble_tip",

	-- ui
	rays = "ui/rays",
	offscreen_indicator = "ui/offscreen_indicator",
	stomp_arrow = "ui/stomp_arrow",

	sawtooth_separator = "ui/sawtooth_separator",

	boss_intro_dung_layer0 = "ui/boss_intro/boss_intro_dung_layer0",
	boss_intro_dung_layer1 = "ui/boss_intro/boss_intro_dung_layer1",
	boss_intro_dung_layer2 = "ui/boss_intro/boss_intro_dung_layer2",
	boss_intro_dung_layer3 = "ui/boss_intro/boss_intro_dung_layer3",
	boss_intro_dung_layer4 = "ui/boss_intro/boss_intro_dung_layer4",
	boss_intro_dung_layer5 = "ui/boss_intro/boss_intro_dung_layer5",

	-----------------------------------------------------
	
	-- effects
	honey_blob = "effects/honey_blob",

	-----------------------------------------------------
	
	-- upgrades
	upgrade_coffee =       "upgrades/upgrade_coffee",
	upgrade_tea =          "upgrades/upgrade_tea",
	upgrade_chocolate =    "upgrades/upgrade_chocolate",
	upgrade_milk =         "upgrades/upgrade_milk",
	upgrade_peanut =       "upgrades/upgrade_peanut",
	upgrade_energy_drink = "upgrades/upgrade_energy_drink",
	upgrade_soda =         "upgrades/upgrade_soda",
	
	-----------------------------------------------------

	-- background
	bg_city_0 =     "level/city_0",
	bg_city_1 =     "level/city_1",
	bg_city_2 =     "level/city_2",
	bg_city_3 =     "level/city_3",
	bg_city_shine = "level/city_shine",

	bg_element_w1_01 = "level/background/bg_element_w1_01",
	bg_element_w1_02 = "level/background/bg_element_w1_02",
	bg_element_w1_03 = "level/background/bg_element_w1_03",
	bg_element_w1_04 = "level/background/bg_element_w1_04",
	bg_element_w1_05 = "level/background/bg_element_w1_05",
	bg_element_w1_06 = "level/background/bg_element_w1_06",
	bg_element_w1_07 = "level/background/bg_element_w1_07",

	-----------------------------------------------------
	
	-- misc
	yanis = "yanis",

	_test_gaysquare = "_test_gaysquare",
	_test_hexagon = "_test_hexagon",
	_test_hexagon_small = "_test_hexagon_small",
}

for id, path in pairs(img_names) do
	if type(path) == "string" then
		images[id] = load_image(path..".png")

	elseif type(path) == "table" then
		if path[1] == "spritesheet" then
			images[id] = load_spritesheet(path[2]..".png", path[3])
		end

	else
		error("Invalid type for image: "..type(path))
	end
end

images.button_fragments = {
	images.button_fragment_1,
	images.button_fragment_2,
	images.button_fragment_3,
	images.button_fragment_4,
	images.button_fragment_5,
}

-----------------------------------------------------
-- Input buttons

local start = love.timer.getTime()
print_debug("Loading images...")

-- TV big animation
for i=1,35 do
	local name = "tv_slideshow_003_"..string.sub("0000"..tostring(i), -3, -1)
	images[name] = load_image("level/tv_slideshow/mio_rotate/"..name..".png")
end

-- Keyboard
for key_constant, button_image_name in pairs(KEY_CONSTANT_TO_IMAGE_NAME) do
	images[button_image_name] = load_image("buttons/keyboard/"..button_image_name..".png")
end

-- Controller
local function get_button_name(brand, button)
	return string.format("btn_c_%s_%s", brand, button)
end
local function load_button_icon(brand, button)
	local name = get_button_name(brand, button)
	local path = string.format("buttons/controller/%s/%s.png", brand, name)
	images[name] = load_image(path)
end

local brands = copy_table(CONTROLLER_BRANDS)
local ps5_index = 0
for i = 1, #brands do 
	if brands[i] == BUTTON_STYLE_PLAYSTATION5 then
		ps5_index = i
		break
	end
end
assert(ps5_index ~= 0, "no PS5 button scheme found")
table.remove(brands, ps5_index)
for _, brand in pairs(brands) do
	for button, __ in pairs(CONTROLLER_BUTTONS) do
		load_button_icon(brand, button)
	end
end

-- PS5 buttons
local ps5_buttons = {
    ["back"] = true,
    ["start"] = true,
    ["misc1"] = true,
    ["touchpad"] = true,
}
for button, _ in pairs(CONTROLLER_BUTTONS) do
	if ps5_buttons[button] then
		load_button_icon(BUTTON_STYLE_PLAYSTATION5, button)
	else
		images[get_button_name(BUTTON_STYLE_PLAYSTATION5, button)] = images[get_button_name(BUTTON_STYLE_PLAYSTATION4, button)]
	end
end
images.btn_c_unknown = load_image("buttons/controller/btn_c_unknown.png")

print_debug("Finished loading", table_key_count(images), "images. (", (love.timer.getTime() - start) * 1000 ,"ms)")

-----------------------------------------------------

return images