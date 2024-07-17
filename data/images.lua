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
	beetle_1 =           "actors/players/beetle_1",
	beetle_2 =           "actors/players/beetle_2",
	beetle_dead =        "actors/players/beetle_dead",

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
	big_bug_1 =          "actors/enemies/big_bug_1",
	boomshroom_1 =       "actors/enemies/boomshroom_1",
	boomshroom_2 =       "actors/enemies/boomshroom_2",
	boomshroom_3 =       "actors/enemies/boomshroom_3",
	boomshroom_4 =       "actors/enemies/boomshroom_4",
	boomshroom_5 =       "actors/enemies/boomshroom_5",
	boomshroom_6 =       "actors/enemies/boomshroom_6",
	boomshroom_7 =       "actors/enemies/boomshroom_7",
	boomshroom_8 =       "actors/enemies/boomshroom_8",
	bulb_buddy_1 =       "actors/enemies/bulb_buddy_1",
	bulb_buddy_2 =       "actors/enemies/bulb_buddy_2",
	chipper_1 =          "actors/enemies/chipper_1",
	chipper_2 =          "actors/enemies/chipper_2",
	chipper_3 =          "actors/enemies/chipper_3",
	chipper_attack_1 =   "actors/enemies/chipper_attack_1",
	chipper_attack_2 =   "actors/enemies/chipper_attack_2",
	chipper_attack_3 =   "actors/enemies/chipper_attack_3",
	cocoon =             "actors/enemies/cocoon",
	dummy_target =       "actors/enemies/dummy_target",
	dung =               "actors/enemies/dung",
	dung_beetle_1 =      "actors/enemies/dung_beetle_1",
	dung_beetle_2 =      "actors/enemies/dung_beetle_2",
	dung_beetle_shield = "actors/enemies/dung_beetle_shield",
	dung_beetle_shield_shine = "actors/enemies/dung_beetle_shield_shine",
	dung_flying =        "actors/enemies/dung_flying",
	shovel_bee =         "actors/enemies/shovel_bee",
	shovel_bee_buried =  "actors/enemies/shovel_bee_buried",
	fly1 =               "actors/enemies/fly1",
	fly2 =               "actors/enemies/fly2",
	grasshopper =        "actors/enemies/grasshopper",
	honeypot_ant1 =      "actors/enemies/honeypot_ant1",
	honeypot_ant2 =      "actors/enemies/honeypot_ant2",
	honeypot_liquid =    "actors/enemies/honeypot_liquid",
	larva =              "actors/enemies/larva",
	larva1 =             "actors/enemies/larva1",
	larva2 =             "actors/enemies/larva2",
	metal_mosquito_1 =   "actors/enemies/metal_mosquito_1",
	metal_mosquito_2 =   "actors/enemies/metal_mosquito_2",
	mosquito1 =          "actors/enemies/mosquito1",
	mosquito2 =          "actors/enemies/mosquito2",
	slug1 =              "actors/enemies/slug1",
	slug2 =              "actors/enemies/slug2",
	snail_open =         "actors/enemies/snail_open",
	snail_shell =        "actors/enemies/snail_shell",
	snail_shell_bouncy = "actors/enemies/snail_shell_bouncy",
	spider1 =            "actors/enemies/spider1",
	spider2 =            "actors/enemies/spider2",
	spiked_fly =         "actors/enemies/spiked_fly",
	stink_bug_1 =        "actors/enemies/stink_bug_1",
	mushroom_ant1 =      "actors/enemies/mushroom_ant1",
	mushroom_ant2 =      "actors/enemies/mushroom_ant2",
	woodlouse_1 =        "actors/enemies/woodlouse_1",
	woodlouse_2 =        "actors/enemies/woodlouse_2",

	poison_cloud =       "actors/enemies/poison_cloud_1",

	upgrade_jar =            "actors/enemies/upgrade_jar",
	big_red_button_crack0 =  "actors/enemies/big_red_button_crack0",
	big_red_button_crack1 =  "actors/enemies/big_red_button_crack1",
	big_red_button_crack2 =  "actors/enemies/big_red_button_crack2",
	big_red_button_crack3 =  "actors/enemies/big_red_button_crack3",
	big_red_button =         "actors/enemies/big_red_button",
	big_red_button_pressed = "actors/enemies/big_red_button_pressed",
	small_button_crack0 =    "actors/enemies/small_button_crack0",
	small_button_crack1 =    "actors/enemies/small_button_crack1",
	small_button_crack2 =    "actors/enemies/small_button_crack2",
	small_button =           "actors/enemies/small_button",
	small_button_pressed =   "actors/enemies/small_button_pressed",
	exit_sign =              "actors/enemies/exit_sign",
	exit_sign_front =        "actors/enemies/exit_sign_front",
	punching_glove =         "actors/enemies/punching_glove",
	spring =                 "actors/enemies/spring",

	machine_coffee =         "actors/enemies/machine_coffee",
	machine_coffee_pressed = "actors/enemies/machine_coffee_pressed",
	machine_snacks =         "actors/enemies/machine_snacks",
	machine_toys =           "actors/enemies/machine_toys",

	loot_ammo =     "actors/loot/loot_ammo",
	loot_ammo_big = "actors/loot/loot_ammo_big",
	loot_life =     "actors/loot/loot_life",
	loot_life_big = "actors/loot/loot_life_big",
	
	bullet =          "actors/bullets/bullet",
	bullet_pea =      "actors/bullets/bullet_pea",
	bullet_red =      "actors/bullets/bullet_red",
	bullet_blue =     "actors/bullets/bullet_blue",
	bullet_ring =     "actors/bullets/bullet_ring",
	mushroom =        "actors/bullets/mushroom",
	mushroom_yellow = "actors/bullets/mushroom_yellow",
	mushroom_spike =  "actors/bullets/mushroom_spike",

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

	-----------------------------------------------------
	
	-- level
	metal =     "level/metal",
	chain =     "level/chain",
	semisolid = "level/semisolid",
	bg_plate =  "level/bg_plate",

	cabin_bg =                "level/cabin_bg",
	cabin_bg_ambient_occlusion = "level/cabin_bg_ambient_occlusion",
	cabin_walls =             "level/cabin_walls",
	cabin_door_left_far =     "level/cabin_door_left_far", 
	cabin_door_left_center =  "level/cabin_door_left_center",
	cabin_door_right_center = "level/cabin_door_right_center",
	cabin_door_right_far =    "level/cabin_door_right_far",
	cabin_rubble =            "level/cabin_rubble",
	cabin_grid =              "level/cabin_grid",
	cabin_grid_platform =     "level/cabin_grid_platform",

	cafeteria =               "level/cafeteria",

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

	-----------------------------------------------------
	
	-- misc
	rays = "ui/rays",
	offscreen_indicator = "ui/offscreen_indicator",
	stomp_arrow = "ui/stomp_arrow",
	yanis = "yanis",
	test = "test",

	_test_fly_big_1 = "_test_fly_big_1",
	_test_fly_big_2 = "_test_fly_big_2",

	_test_bg_image_1 = "_test_bg_image_1",
	_test_bg_image_2 = "_test_bg_image_2",

	_tuto_arrow = "_tuto_arrow",

}
for id, path in pairs(img_names) do
	images[id] = load_image(path..".png")
end

images.button_fragments = {
	images.button_fragment_1,
	images.button_fragment_2,
	images.button_fragment_3,
	images.button_fragment_4,
	images.button_fragment_5,
}

images._test_anim_explosion = load_image_table("_test_explosion_", 14)

-----------------------------------------------------
-- Input buttons

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

-----------------------------------------------------

return images