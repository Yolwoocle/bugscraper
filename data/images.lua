require "scripts.util"
local Class = require "scripts.class"
local key_constant_to_image = require "data.buttons.images_buttons_keyboard"
local controller_brands = require "data.buttons.controller_brands"
local controller_buttons = require "data.buttons.controller_buttons"

function load_image(name)
	local im = love.graphics.newImage("images/"..name)
	im:setFilter("nearest", "nearest")
	return im 
end
function load_image_table(name, n, w, h)
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
	"empty",
	
	"grass",
	"dirt",
	"snowball",

	"heart",
	"heart_half",
	"heart_empty",
	"ammo",

	"ant1",
	"ant2",
	"ant_dead",
	"bee",
	"caterpillar_1",
	"caterpillar_2",
	"caterpillar_dead",
	"duck",
	"fly1",
	"fly2",
	"grasshopper",
	"larva",
	"larva1",
	"larva2",
	"slug1",
	"slug2",
	"snail_open",
	"snail_shell",
	"spider1",
	"spider2",
	"spiked_fly",
	
	"bullet",
	"bullet_pea",
	"bullet_red",
	"bullet_blue",
	"bullet_ring",

	"gun_machinegun",
	"gun_triple",
	"gun_burst",
	"gun_shotgun",
	"gun_minigun",
	"gun_mushroom_cannon",
	"gun_ring",

	"metal",
	"chain",
	"bg_plate",
	"cabin_bg",
	"cabin_bg_2",
	"cabin_bg_amboccl",
	"cabin_walls",
	"cabin_door_left", "cabin_door_right",
	"cabin_rubble",

	"logo",
	"logo_noshad",
	"logo_shad",

	"loot_ammo",
	"loot_ammo_big",
	"loot_life",
	"loot_life_big",

	"lever_on",
	"lever_off",

	"big_red_button_crack0",
	"big_red_button_crack1",
	"big_red_button_crack2",
	"big_red_button_crack3",
	"big_red_button",
	"big_red_button_pressed",

	"small_button_crack0",
	"small_button_crack1",
	"small_button_crack2",
	"small_button_crack3",
	"small_button",
	"small_button_pressed",

	"ptc_glass_shard",
	"snail_shell_fragment",

	"dummy_target",

	"controls",
	"controls_jetpack",

	"mushroom_ant1",
	"mushroom_ant2",
	"mushroom",
	"mushroom_yellow",
	"mushroom_spike",

	"dummy_target_ptc1",
	"dummy_target_ptc2",

	"ptc_bullet_casing",

	"btnfrag_1",
	"btnfrag_2",
	"btnfrag_3",
	"btnfrag_4",
	"btnfrag_5",
}

for i=1,#img_names do   images[img_names[i]] = load_image(img_names[i]..".png")   end

for key_constant, button_image_name in pairs(key_constant_to_image) do
	images[button_image_name] = load_image("buttons/keyboard/"..button_image_name..".png")
end

for _, brand in pairs(controller_brands) do
	for button, __ in pairs(controller_buttons) do
		local name = string.format("btn_c_%s_%s", brand, button)
		local path = string.format("buttons/controller/%s/%s.png", brand, name)
		images[name] = load_image(path)
	end
end
images.btn_c_unknown = load_image("buttons/controller/btn_c_unknown.png")

return images