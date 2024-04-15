
function Game:removeme_bg_test()
	-- love.graphics.setColor(COL_BLACK_BLUE)
	-- love.graphics.clear()
	love.graphics.setColor(COL_WHITE)
	local ox, oy = CANVAS_WIDTH/2, CANVAS_HEIGHT/2
	local padding = CANVAS_WIDTH/2
	local z = 9
	local fov = 1
	local interval = 42
	for iy = -CANVAS_HEIGHT*5, 5*CANVAS_HEIGHT, interval do
		local y = iy + ((self.t*100) % interval)
		love.graphics.line(math.floor(fov *  padding + ox), math.floor(fov * y + oy), math.floor(fov *  padding/z + ox), math.floor(fov * y/z + oy))
		love.graphics.line(math.floor(fov * -padding + ox), math.floor(fov * y + oy), math.floor(fov * -padding/z + ox), math.floor(fov * y/z + oy))
	end
end

local function new_bg_line()
	return {
		x = random_range(0, 480), 
		y = -80,
		dy = random_range(8, 16),
		h = random_range(30, 60),
	}
end
local removeme_parallax_y = 0
local bglines = {}
for i=1, 30 do 
	table.insert(bglines, new_bg_line())
end
function Game:removeme_bg_test2()
	love.graphics.clear(COL_LIGHT_BLUE)
	love.graphics.setColor(COL_WHITE)

	removeme_parallax_y = self.t * 60
	love.graphics.draw(images._test_layer0, 0, 0)
	love.graphics.draw(images._test_layer1, 0, removeme_parallax_y * 0.01)
	love.graphics.draw(images._test_layer2, 0, removeme_parallax_y * 0.05)
	love.graphics.draw(images._test_layer3, 0, removeme_parallax_y * 0.1)

	love.graphics.draw(images._test_shine, 0, 0)

	exec_using_shader(shaders.lighten, function()
		love.graphics.draw(self.object_canvas, -4, -12)
	end)
	local y0 = (removeme_parallax_y * 5) % (96*2)
	local i_line = 1
	for iy=y0-(96*2), CANVAS_HEIGHT+100, 96 do
		local x0 = ternary(i_line % 2 == 0, -16, -16 - 32)
		for ix=x0, CANVAS_WIDTH, 64 do
			love.graphics.draw(images._test_window, ix, iy)
		end
		i_line = i_line + 1
	end

	for i=1, #bglines do
		bglines[i].y = bglines[i].y + bglines[i].dy
		love.graphics.line(bglines[i].x, bglines[i].y, bglines[i].x, bglines[i].y + bglines[i].h)
		if bglines[i].y > CANVAS_HEIGHT then
			bglines[i] = new_bg_line()
		end
	end
end