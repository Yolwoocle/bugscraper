local Class = require "class"
local Game = require "game"
require "util"

game = nil

function love.load(arg)
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
		if options then   options:toggle_fullscreen()    end

	elseif key == "m" then
		options:toggle_sound()
		
	elseif key == "g" then
		game.players[1]:kill()

	elseif key == "e" then
		if not game then return end
		for i,e in pairs(game.actors) do
			if e.is_enemy then
				e:kill()
			end
		end
		game.floor = 40
	
	elseif key == "b" then
		if not game then return end
		local Enemies = require "data.enemies"
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
	if not game then     return     end
	if game.resize then   game:resize(w,h)   end
	game:update_screen()
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
	print("Quitting game")
	if options then    options:update_options_file()    end
	love.event.quit()
end
