require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"
local key_constant_to_image = require "data.buttons.images_buttons_keyboard"
local controller_buttons = require "data.buttons.controller_buttons"

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
	dummy_target =    "actors/enemies/dummy_target",
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
	mushroom_ant1 =   "actors/enemies/mushroom_ant1",
	mushroom_ant2 =   "actors/enemies/mushroom_ant2",

	big_red_button_crack0 =  "actors/enemies/big_red_button_crack0",
	big_red_button_crack1 =  "actors/enemies/big_red_button_crack1",
	big_red_button_crack2 =  "actors/enemies/big_red_button_crack2",
	big_red_button_crack3 =  "actors/enemies/big_red_button_crack3",
	big_red_button =         "actors/enemies/big_red_button",
	big_red_button_pressed = "actors/enemies/big_red_button_pressed",
	small_button_crack0 =  "actors/enemies/small_button_crack0",
	small_button_crack1 =  "actors/enemies/small_button_crack1",
	small_button_crack2 =  "actors/enemies/small_button_crack2",
	small_button =         "actors/enemies/small_button",
	small_button_pressed = "actors/enemies/small_button_pressed",

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
	heart =       "ui/hud/heart",
	heart_half =  "ui/hud/heart_half",
	heart_empty = "ui/hud/heart_empty",
	ammo =        "ui/hud/ammo",

	-- logo
	logo =        "ui/logo/logo",
	logo_noshad = "ui/logo/logo_noshad",
	logo_shad =   "ui/logo/logo_shad",

	controls_jetpack = "ui/controls_jetpack",

	-----------------------------------------------------
	
	-- effects
	honey_blob = "effects/honey_blob",

	-----------------------------------------------------

	-- upgrades
	upgrade_coffee = "upgrades/upgrade_coffee"
	
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

for key_constant, button_image_name in pairs(key_constant_to_image) do
	images[button_image_name] = load_image("buttons/keyboard/"..button_image_name..".png")
end

for _, brand in pairs(CONTROLLER_BRANDS) do
	for button, __ in pairs(controller_buttons) do
		local name = string.format("btn_c_%s_%s", brand, button)
		local path = string.format("buttons/controller/%s/%s.png", brand, name)
		images[name] = load_image(path)
	end
end
images.btn_c_unknown = load_image("buttons/controller/btn_c_unknown.png")

return images