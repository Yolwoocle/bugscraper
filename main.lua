local Class = require "scripts.meta.class"
local Game = require "scripts.game.game"
require "scripts.util"

-- LÖVE uses Luajit 2.1 which is based on Lua 5.1 but has some additions (like goto)

game = nil

local removeme_measure_n = 1000
local removeme_measure_i = removeme_measure_n
local function removeme_time_diff(func)
	if removeme_measure_i <= 0 then
		func()
		return 0
	end
	removeme_measure_i = removeme_measure_i - 1
	local start = love.timer.getTime( )
	func()
	local result = love.timer.getTime() - start
	-- print_debug(string.format("Measure '%s': %.4f ms", name, result * 1000 ))
	return result
end
local removeme_update_t = 0
local removeme_draw_t = 0

function love.load(arg)
	frame = 0

	game = Game:new()
end

local t = 0
local fixed_dt = 1/60 -- fixed frame delta time
local frame = 0
local function fixed_update()
	--update that happens at the fixed fdt interval
	frame = frame + 1

	removeme_update_t = removeme_update_t + removeme_time_diff(function()
		game:update(fixed_dt)
	end)
end

function love.update(dt)
	t = t + dt
	local cap = 1 --If there's lag spike, repeat up to how many frames?
	local i = 0
	while t > fixed_dt and cap > 0 do
		t = t - fixed_dt
		fixed_update()
		cap = cap - 1
		i=i+1
	end

	if game then   game.frame_repeat = i end
	frame = frame + 1
end

function love.draw()
	removeme_draw_t = removeme_draw_t + removeme_time_diff(function()
		game:draw()
	end)

	love.graphics.print(concat("update ", removeme_update_t*1000/removeme_measure_n, " ms"), 0, 0, 0, 3, 3)
	love.graphics.print(concat("draw ", removeme_draw_t*1000/removeme_measure_n, " ms"), 0, 42, 0, 3, 3)
end

-- CAPTURING_GIF = false
-- gif_n = 0
function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		if love.keyboard.isDown("lshift") then
			love.event.quit("restart")
		end

	elseif key == "f4" then
		if love.keyboard.isDown("lshift") then
			love.event.quit()
		end
	-- elseif key == "f7" then
	-- 	love.graphics.captureScreenshot(os.time() .. ".png")
	-- elseif key == "f8" then
	-- 	CAPTURING_GIF = not CAPTURING_GIF
	-- 	gif_n = gif_n + 1

	elseif key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
		if Options then   Options:toggle_fullscreen()    end
	end

	if game.keypressed then  game:keypressed(key, scancode, isrepeat)  end
end

function love.keyreleased(key, scancode)
	if game.keyreleased then  game:keyreleased(key, scancode)  end
end

function love.mousepressed(x, y, button, istouch, presses)
	if game.mousepressed then   game:mousepressed(x, y, button)   end
end

function love.joystickadded(joystick)
	if game.joystickadded then   game:joystickadded(joystick)   end
end

function love.joystickremoved(joystick)
	if game.joystickremoved then   game:joystickremoved(joystick)   end
end

function love.gamepadpressed(joystick, buttoncode)
	if game.gamepadpressed then   game:gamepadpressed(joystick, buttoncode)   end
end

function love.gamepadreleased(joystick, buttoncode)
	if game.gamepadreleased then   game:gamepadreleased(joystick, buttoncode)   end
end

function love.gamepadaxis(joystick, axis, value)
	if game.gamepadaxis then   game:gamepadaxis(joystick, axis, value)   end
end

function love.quit()
	if game.quit then   game:quit()   end
end

function love.resize(w, h)
	if not game then   return   end
	if game.on_resize then   game:on_resize(w,h)   end
end

function love.textinput(text)
	if game.textinput then  game:textinput(text)  end
end

function love.focus(f)
	if game.focus then  game:focus(f)  end
end

print_log_file = love.filesystem.newFile("consolelog.txt")
print_log_file:open("w")
print_log_file:write("")
print_log_file:close()

max_msg_log = 20
old_print = print
msg_log = {}
function print(...)
	-- print_log_file:open("a")

	old_print(...)
	
	local text = concatsep({...}, " ")
	table.insert(msg_log, text)
	-- print_log_file:write(concat(os.date("%c", os.time())," | ",text,"\n"))
	
	if #msg_log > max_msg_log then
		table.remove(msg_log, 1)
	end

	-- print_log_file:close()
end

function quit_game()
	print("Quitting game")
	if Options then   Options:on_quit()   end
	if Input then     Input:on_quit()   end
	love.event.quit()
end