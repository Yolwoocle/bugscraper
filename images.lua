local Class = require "class"
require "util"

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

local img_names = {
	"magnet",
	"grass",
	"dirt",
	"snowball",

	"heart",
	"heart_half",
	"heart_empty",
	"ammo",

	"ant1",
	"ant2",
	"bee",
	"caterpillar",
	"duck",
	"fly",
	"grasshopper",
	"larva",
	"slug",
	"snail_open",
	"snail_shell",
	
	"bullet",

	"gun_machinegun",
	"gun_triple",
	"gun_burst",
	"gun_shotgun",

	"metal",
	"chain",
	"bg_plate",
	"cabin_bg",
	"cabin_bg_amboccl",
	"cabin_walls",
	"cabin_door_left", "cabin_door_right",

	"logo",
}

local images = {}
for i=1,#img_names do   images[img_names[i]] = load_image(img_names[i]..".png")   end
return images