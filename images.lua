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

	"ant",
	"caterpillar",
	"bee",
	"duck",
	"larva",
	"fly",
	"grasshopper",
	
	"bullet",

	"metal",
	"chain",
	"bg_plate",
	"cabin_bg",
	"cabin_bg_amboccl",
	"cabin_walls",
	"cabin_door_left", "cabin_door_right",
	
}

local images = {}
for i=1,#img_names do   images[img_names[i]] = load_image(img_names[i]..".png")   end
return images