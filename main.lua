local Class = require "class"
local Game = require "game"
require "util"

game = nil

function update_screen(scale)
	-- When scale is (-1), it will find the maximum whole number
	if scale == "auto" then   scale = nil    end
	if scale == "max whole" then   scale = -1    end
	if type(scale) ~= "number" then    scale = nil    end
 
	WINDOW_WIDTH, WINDOW_HEIGHT = gfx.getDimensions()
	CANVAS_WIDTH = 480
	CANVAS_HEIGHT = 270

	screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	CANVAS_SCALE = min(screen_sx, screen_sy)

	if scale then
		if scale == -1 then
			CANVAS_SCALE = floor(CANVAS_SCALE)
		else
			CANVAS_SCALE = scale
		end
	end

	CANVAS_OX = max(0, (WINDOW_WIDTH  - CANVAS_WIDTH  * CANVAS_SCALE)/2)
	CANVAS_OY = max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * CANVAS_SCALE)/2)
end

function love.load(arg)
	-- GLOBALS
	is_fullscreen = true
	is_vsync = true
	pixel_scale = "auto"

	love.window.setMode(0, 0, {
		fullscreen = is_fullscreen,
		resizable = true,
		vsync = true,
		minwidth = 400,
		minheight = 300,
	})
	SCREEN_WIDTH, SCREEN_HEIGHT = gfx.getDimensions()
	gfx.setDefaultFilter("nearest", "nearest")
	
	update_screen()

	canvas = gfx.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	love.window.setTitle("Elevator game")

	-- Load fonts
	FONT_REGULAR = gfx.newFont("fonts/HopeGold.ttf", 16)
	FONT_7SEG = gfx.newImageFont("fonts/7seg_font.png", " 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	FONT_MINI = gfx.newFont("fonts/Kenney Mini.ttf", 8)
	gfx.setFont(FONT_REGULAR)

	frame = 0

	game = Game:new()
end

t = 0
fdt = 1/60 -- fixed frame delta time
local function fixed_update()
	--update that happens at the fixed fdt interval
	game:update(fdt)
end

function love.update(dt)
	t = t + dt
	local cap = 2 --If theres lag spike, repeat up to how many frames?
	local i = 0
	while t > fdt and cap > 0 do
		t = t - fdt
		fixed_update()
		cap = cap - 1
		i=i+1
	end

	-- if t > 0 then    t = 0    end
	if game then   game.frame_repeat = i end
	frame = frame + 1
end

function love.draw()
	gfx.setCanvas(canvas)
    gfx.clear(0,0,0)
    gfx.translate(0, 0)

	game:draw()
	
    -- Canvas for that sweet pixel art
    gfx.setCanvas()
    gfx.origin()
    gfx.scale(1, 1)
    gfx.draw(canvas, CANVAS_OX, CANVAS_OY, 0, CANVAS_SCALE, CANVAS_SCALE)

end

function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		if love.keyboard.isDown("lshift") then
			love.event.quit("restart")
		end

	elseif key == "f4" then
		if love.keyboard.isDown("lshift") then
			love.event.quit()
		end
	
	elseif key == "f11" then
		toggle_fullscreen()

	elseif key == "m" then
		game.sound_on = not game.sound_on
		
	elseif key == "g" then
		game.players[1]:kill()
	
	elseif key == "b" then
		if not game then return end
		local Enemies = require "stats.enemies"
		local nx = CANVAS_WIDTH/2
		local ny = game.world_generator.box_by * BLOCK_WIDTH
		local l = create_actor_centered(Enemies.ButtonGlass, nx, ny)
		game:new_actor(l)

	elseif key == "k" then
		if not game then return end
		for i,e in pairs(game.actors) do
			if e.is_enemy then
				e:kill()
			end
		end

	end

	if game.keypressed then  game:keypressed(key, scancode, isrepeat)  end
end

function toggle_fullscreen()
	-- local success = love.graphics.toggleFullscreen( )
	is_fullscreen = not is_fullscreen
	love.window.setFullscreen(is_fullscreen)
end

function set_pixel_scale(scale)
	update_screen(scale)
end

function love.keyreleased(key, scancode)
	if game.keyreleased then  game:keyreleased(key, scancode)  end
end

function love.mousepressed(x, y, button, istouch, presses)
	if game.mousepressed then   game:mousepressed(x, y, button)   end
end

--function love.quit()
--	game:quit()
--end

function love.resize(w, h)
	if game.resize then   game:resize(w,h)   end
	update_screen()
end

function love.textinput(text)
	if game.textinput then  game:textinput(text)  end
end

max_msg_log = 20
old_print = print
msg_log = {}
function print(...)
	old_print(...)
	
	table.insert(msg_log, concatsep({...}, " "))

	if #msg_log > max_msg_log then
		table.remove(msg_log, 1)
	end
end

function quit_game()
	love.event.quit()
end

function toggle_vsync()
	is_vsync = not is_vsync
	love.window.setVSync(is_vsync)
end