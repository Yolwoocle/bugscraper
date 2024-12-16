-- Splash screen
local init = require "scripts.meta.init"
init()
----------

require "scripts.util"
require "lib.please_work_error_explorer.error_explorer" {
	source_font = love.graphics.newFont("fonts/FiraCode-Regular.ttf", 12)
}
local Game = require "scripts.game.game"
local Measure = require "scripts.debug.measure"

game = nil

function love.load(arg)
	game = Game:new()
end

local fixed_dt = 1/60 -- fixed frame delta time
_G_t = 0
_G_frame = 0
_G_fixed_frame = 0
_G_frame_by_frame_mode = false
local max_frame_buffer_duration = fixed_dt * 2
local _frame_by_frame_mode_advance_flag = false

local measure_update = Measure:new(10000)
local function fixed_update()
	if _G_frame_by_frame_mode and not _frame_by_frame_mode_advance_flag then
		return
	else
		_frame_by_frame_mode_advance_flag = false
	end

	_G_fixed_frame = _G_fixed_frame + 1

	game:update(fixed_dt)
end

_G_do_fixed_framerate = true

function love.update(dt)
	_G_t = math.min(_G_t + dt, max_frame_buffer_duration)
	local cap = 1 
	local i = 0
	local update_fixed_dt = fixed_dt
	while (not _G_do_fixed_framerate or _G_t > update_fixed_dt) and cap > 0 do
		_G_t = _G_t - update_fixed_dt
		fixed_update()
		cap = cap - 1
		i=i+1
	end

	if game then   game.frame_repeat = i end
	_G_frame = _G_frame + 1
end

function love.draw()
	game:draw()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			love.event.quit("restart")
		end

	elseif key == "f4" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			love.event.quit()
		end

	elseif key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
		if Options then
			Options:toggle("is_fullscreen")
		end
	
	elseif scancode == "f9" then
		if _G_frame_by_frame_mode then
			_frame_by_frame_mode_advance_flag = true
		end

	end

	if game.keypressed then  game:keypressed(key, scancode, isrepeat)  end
end

function love.keyreleased(key, scancode)
	if game.keyreleased then  game:keyreleased(key, scancode)  end
end

function love.mousepressed(x, y, button, istouch, presses)
	if game.mousepressed then   game:mousepressed(x, y, button, istouch, presses)   end
end

function love.mousereleased(x, y, button, istouch, presses)
	if game.mousereleased then   game:mousereleased(x, y, button, istouch, presses)   end
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
	-- table.insert(msg_log, text)
	-- print_log_file:write(concat(os.date("%c", os.time())," | ",text,"\n"))
	
	if #msg_log > max_msg_log then
		table.remove(msg_log, 1)
	end

	-- print_log_file:close()
end

--- Quits the game and saves settings.
---@param restart boolean Whether the game should restart
function quit_game(restart)
	print("Quitting game")
	if Options then   Options:on_quit()   end
	if Input then     Input:on_quit()   end
	love.event.quit(ternary(restart, "restart", nil))
end