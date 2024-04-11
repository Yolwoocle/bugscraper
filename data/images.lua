require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"

REMOVEME_image_to_col = {}
local function removeme_set_image_col(im, name)
	local image_data = love.image.newImageData("images/"..name)
	local col = {image_data:getPixel(im:getWidth()/2, im:getHeight()/2)}
	REMOVEME_image_to_col[im] = col
end

local function load_image(name)
	local im = love.graphics.newImage("images/"..name)
	im:setFilter("nearest", "nearest")
	removeme_set_image_col(im, name)
	return im 
end
local function load_image_table(name, n, w, h)
	if not n then  error("number of images `n` not defined")  end
	local t = {}
	for i=1,n do 
		t[i] = load_image(name..tostr(i))
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
	_test_layer0 = "_test_layer0",
	_test_layer1 = "_test_layer1",
	_test_layer2 = "_test_layer2",
	_test_layer3 = "_test_layer3",
	_test_window = "_test_window",
	_test_shine = "_test_shine",

	-----------------------------------------------------

	-- players
	ant2_1 =           "actors/players/ant2_1",
	ant2_2 =           "actors/players/ant2_2",
	ant2_dead =        "actors/players/ant2_dead",
	ant1 =             "actors/players/ant1",
	ant2 =             "actors/players/ant2",
	ant_dead =         "actors/players/ant_dead",
	bee_1 =            "actors/players/bee_1",
	bee_2 =            "actors/players/bee_2",
	bee_dead =         "actors/players/bee_dead",
	caterpillar_1 =    "actors/players/caterpillar_1",
	caterpillar_2 =    "actors/players/caterpillar_2",
	caterpillar_dead = "actors/players/caterpillar_dead",
	duck =             "actors/players/duck",

	-- enemies
	cocoon =          "actors/enemies/cocoon",
	dummy_target =    "actors/enemies/dummy_target",
	dung_beetle_1 =   "actors/enemies/dung_beetle_1",
	dung_1 =          "actors/enemies/dung_1",
	fly1 =            "actors/enemies/fly1",
	fly2 =            "actors/enemies/fly2",
	grasshopper =     "actors/enemies/grasshopper",
	honeypot_ant1 =   "actors/enemies/honeypot_ant1",
	honeypot_ant2 =   "actors/enemies/honeypot_ant2",
	honeypot_liquid = "actors/enemies/honeypot_liquid",
	larva =           "actors/enemies/larva",
	larva1 =          "actors/enemies/larva1",
	larva2 =          "actors/enemies/larva2",
	mosquito1 =       "actors/enemies/mosquito1",
	mosquito2 =       "actors/enemies/mosquito2",
	slug1 =           "actors/enemies/slug1",
	slug2 =           "actors/enemies/slug2",
	snail_open =      "actors/enemies/snail_open",
	snail_shell =     "actors/enemies/snail_shell",
	spider1 =         "actors/enemies/spider1",
	spider2 =         "actors/enemies/spider2",
	spiked_fly =      "actors/enemies/spiked_fly",
	stink_bug_1 =     "actors/enemies/stink_bug_1",
	mushroom_ant1 =   "actors/enemies/mushroom_ant1",
	mushroom_ant2 =   "actors/enemies/mushroom_ant2",
	woodlouse_1 =     "actors/enemies/woodlouse_1",
	woodlouse_2 =     "actors/enemies/woodlouse_2",

	poison_cloud =    "actors/enemies/poison_cloud_1",

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
	dummy_target_ptc1 =    "particles/dummy_target_ptc1",
	dummy_target_ptc2 =    "particles/dummy_target_ptc2",
	ptc_glass_shard =      "particles/ptc_glass_shard",
	snail_shell_fragment = "particles/snail_shell_fragment",
	ptc_bullet_casing =    "particles/ptc_bullet_casing",
	btnfrag_1 =            "particles/btnfrag_1",
	btnfrag_2 =            "particles/btnfrag_2",
	btnfrag_3 =            "particles/btnfrag_3",
	btnfrag_4 =            "particles/btnfrag_4",
	btnfrag_5 =            "particles/btnfrag_5",
	smash_flash =          "particles/smash_flash",

	-----------------------------------------------------
	
	-- level
	metal =    "level/metal",
	chain =    "level/chain",
	bg_plate = "level/bg_plate",

	cabin_bg =         "level/cabin_bg",
	cabin_bg_2 =       "level/cabin_bg_2",
	cabin_bg_amboccl = "level/cabin_bg_amboccl",
	cabin_walls =      "level/cabin_walls",
	cabin_door_left =  "level/cabin_door_left", 
	cabin_door_right = "level/cabin_door_right",
	cabin_rubble =     "level/cabin_rubble",

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

	selection_left = "ui/selection_left",
	selection_mid = "ui/selection_mid",
	selection_right = "ui/selection_right",

	-----------------------------------------------------
	
	-- effects
	honey_blob = "effects/honey_blob",

	-----------------------------------------------------
	
	-- upgrades
	upgrade_coffee =    "upgrades/upgrade_coffee",
	upgrade_tea =       "upgrades/upgrade_tea",
	upgrade_chocolate = "upgrades/upgrade_chocolate",
	upgrade_milk =      "upgrades/upgrade_milk",
	
	-----------------------------------------------------

	-- misc
	rays = "ui/rays"

}
for id, path in pairs(img_names) do
	images[id] = load_image(path..".png")
end

images.button_fragments = {
	images.btnfrag_1,
	images.btnfrag_2,
	images.btnfrag_3,
	images.btnfrag_4,
	images.btnfrag_5,
}

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