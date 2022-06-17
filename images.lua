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

local images = {}
images.magnet = load_image("magnet.png")
images.grass = load_image("grass.png")
images.dirt = load_image("dirt.png")
images.snowball = load_image("snowball.png")

images.heart = load_image("heart.png")

images.ant = load_image("ant.png")
images.caterpillar = load_image("caterpillar.png")
images.bee = load_image("bee.png")
images.duck = load_image("duck1.png")
images.larva = load_image("larva.png")

return images