require "util"
local Class = require "class"
local images = require "data.images"
local utf8 = require "utf8"

local OptionsManager = Class:inherit()

function OptionsManager:init(game)
	self.game = game
	self.is_first_time = false
	self.options = {
		volume = 1,
		music_volume = 1,
		sound_on = true,

		is_vsync = true,
		is_fullscreen = true,
		pixel_scale = "auto",
		timer_on = false,
		mouse_visible = false,
		pause_on_unfocus = ternary(love.system.getOS()=="Web", false, true),
		screenshake_on = true,
		disable_background_noise = false,
	}

	local add_keyboard_ui_buttons = function(scheme)
		scheme.ui_left = {"a", "left"}
		scheme.ui_right = {"d", "right"}
		scheme.ui_up = {"w", "up"}
		scheme.ui_down = {"s", "down"}
	end

	-- igl scotch
	self.solo_keyboard_scheme = {
		left = {"a", "left"},
		right = {"d", "right"},
		up = {"w", "up"},
		down = {"s", "down"},
		jump = {"z", "c", "b"},
		shoot = {"x", "v", "n"},
		select = {"return"},
		pause = {"escape", "p"},
		get_icon = function(n, joystick) 
			local imgs = {
				[1] = images.controls_solo_keyboard,
				[2] = images.controls_p2_keyboard,
			}
			return imgs[n] or images.controls_p2_keyboard
		end
	}
	add_keyboard_ui_buttons(self.solo_keyboard_scheme)

	self.solo_ui_keyboard_scheme = {
		left = {},
		right = {},
		up = {},
		down = {},
		jump = {},
		shoot = {},
		select = {"return", "x", "v", "n", "z", "c", "b"},
		pause = {"escape", "p"},
		get_icon = function(n, joystick) return images.controls_solo_keyboard end
	}
	add_keyboard_ui_buttons(self.solo_ui_keyboard_scheme)

	self.p1_split_keyboard_scheme = {
		left = {"a"},
		right = {"d"},
		up = {"w"},
		down = {"s"},
		jump = {"f", "c"},
		shoot = {"g", "x"},
		select = {"return"},
		pause = {"escape", "p"},
		get_icon = function(n, joystick) return images.controls_p1_split end
	}
	add_keyboard_ui_buttons(self.p1_split_keyboard_scheme)

	self.p2_split_keyboard_scheme = {
		left = {"left"},
		right = {"right"},
		up = {"up"},
		down = {"down"},
		jump = {"l", ","},
		shoot = {"k", "m"},
		select = {"return"},
		pause = {"escape", "p"},
		get_icon = function(n, joystick) return images.controls_p2_split end
	}
	add_keyboard_ui_buttons(self.p2_split_keyboard_scheme)

	self.controller_scheme = {
		left = {"stick_xneg", "dpleft"},
		right = {"stick_xpos", "dpright"},
		up = {"stick_yneg", "dpup"},
		down = {"stick_ypos", "dpdown"},
		ui_left = {"stick_xneg", "dpleft"},
		ui_right = {"stick_xpos", "dpright"},
		ui_up = {"stick_yneg", "dpup"},
		ui_down = {"stick_ypos", "dpdown"},

		jump = {"a", "b"},
		shoot = {"x", "y"},
		select = {"a"},
		pause = {"start", "back"},
		get_icon = function(n, joystick)
			if joystick == nil then return images.controls_p1_stadia end

			local imgs = {
				[1] = {
					P = images.controls_p1_ps,
					G = images.controls_p1_stadia,
				},
				[2] = {
					P = images.controls_p2_ps,
					G = images.controls_p2_stadia,
				},
			}
			local name = joystick:getName()
			return imgs[n][name:sub(1, 1)] or images.controls_p1_stadia
		end
	}

	self.default_control_schemes = {
		["solo"] = {
			keyboard = self.solo_keyboard_scheme,
			controller = self.controller_scheme
		},
		[1] = {
			keyboard = self.p1_split_keyboard_scheme,
			controller = self.controller_scheme
		},
		[2] = {
			keyboard = self.solo_keyboard_scheme,
			controller = self.controller_scheme
		}
	}

	self.control_schemes = copy_table(self.default_control_schemes)

	self:load_options()
	-- self:load_controls()
end

function OptionsManager:load_options()
	if love.filesystem.getInfo == nil then
		print("/!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading options.txt aborted, so custom options will not be loaded.")
		return
	end
	local options_file_exists = love.filesystem.getInfo("options.txt")
	if not options_file_exists then
		print("options.txt does not exist, so creating it")
		self.is_first_time = true
		self:update_options_file()
		return
	end

	-- Read options.txt file
	local file = love.filesystem.newFile("options.txt")
	file:open("r")
	
	local text, size = file:read()
	if not text then    print("Error reading options.txt file: "..size)    end
	local lines = split_str(text, "\n") -- Split lines

	for i = 1, #lines do
		local line = lines[i]
		local tab = split_str(line, ":")
		local key, value = tab[1], tab[2]

		if self.options[key] ~= nil then
			local typ = type(self.options[key])
			local val
			if typ == "string" then   val = value    end
			if typ == "number" then   val = tonumber(value)   end
			if typ == "boolean" then   val = strtobool(value)   end
			if typ == "table" then   val = split_str(value, ",")   end

			self.options[key] = val
		else
			print(concat("Error: option '",key,"' does not exist"))
		end
	end
end

function OptionsManager:load_controls_file(filename, current_controls)
	-- Check if file exists
	local file_exists = love.filesystem.getInfo(filename)
	if not file_exists then
		print(filename, "does not exist, so creating it")
		self:update_controls_file()
		return
	end

	local file = love.filesystem.newFile(filename)
	file:open("r")

	-- Read file contents
	local text, size = file:read()
	if not text then    print(concat("Error reading ",filename,": ",size))    end
	local lines = split_str(text, "\n") -- Split lines

	local control_scheme = {}

	for iline = 1, #lines do
		local line = lines[iline]
		local tab = split_str(line, ":")
		local key, value = tab[1], tab[2]

		if current_controls[key] ~= nil then
			local typ = type(current_controls[key])
			local val
			if typ == "string" then   val = value    end
			if typ == "number" then   val = tonumber(value)   end
			if typ == "boolean" then   val = strtobool(value)   end
			if typ == "table" then   val = split_str(value, ",")   end

			if value ~= nil then
				control_scheme[key] = val
			else
				print(concat("Invalid reading of button ",key," (nil found) in ",filename))
			end
		else
			print(concat("Error: option '",key,"' does not exist"))
		end
	end

	file:close()

	return control_scheme
end

function OptionsManager:load_controls()
	if love.filesystem.getInfo == nil then
		print("/!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading controls for players aborted, so custom keybinds will not be loaded.")
		return
	end

	self.control_schemes["solo"] = self:load_controls_file("controls_solo.txt", self.control_schemes["solo"])
	for n=1, #self.control_schemes do
		local filename = concat("controls_p",n,".txt")
		self.control_schemes[n] = self:load_controls_file(filename, self.control_schemes[n])
	end
end

function OptionsManager:update_options_file()
	print("Creating or updating options.txt file")
	local file = love.filesystem.newFile("options.txt")
	file:open("w")
	
	for k, v in pairs(self.options) do
		local val = v
		local success, errmsg = file:write(concat(k, ":", val, "\n"))
	end
	
	file:close()
end

function OptionsManager:update_controls_file()
	for i=1, #self.control_schemes do
		print("Creating or updating options.txt file")
		local controlsfile = love.filesystem.newFile(concat("controls_p",i,".txt"))
		controlsfile:open("w")
		
		for btn, scancodes in pairs(self.control_schemes[i]) do
			local value
			if type(scancodes) == "table" then
				value = concatsep(scancodes,",")
			else
				value = tostring(scancodes)
			end
			controlsfile:write(concat(btn,":",value,"\n"))
		end

		controlsfile:close()
	end
end

function OptionsManager:get(name)
	return self.options[name]
end

function OptionsManager:set(name, val)
	self.options[name] = val
	self:update_options_file()
end

function OptionsManager:toggle(name)
	self.options[name] = not self.options[name]
	self:update_options_file()
end



function OptionsManager:toggle_fullscreen()
	-- local success = love.graphics.toggleFullscreen( )
	self:toggle("is_fullscreen")
	love.window.setFullscreen(self:get("is_fullscreen"))

	self:update_options_file()
end

function OptionsManager:set_pixel_scale(scale)
	if not game then  return  end
	self:set("pixel_scale", scale)
	game:update_screen(scale)

	self:update_options_file()
end

function OptionsManager:toggle_vsync()
	self:toggle("is_vsync")
	love.window.setVSync(self:get("is_vsync"))

	self:update_options_file()
end


function OptionsManager:toggle_sound()
	-- TODO: move from bool to a number (0-1), customisable in settings
	self:toggle("sound_on")
	self:update_sound_on()

	self:update_options_file()
end

function OptionsManager:update_sound_on()
	if self:get("sound_on") then
		self:set_volume(self:get("volume"))
	else
		love.audio.setVolume(0)
	end
end

function OptionsManager:set_volume(n)
	self:set("volume", n)
	love.audio.setVolume( self:get("volume") )

	self:update_options_file()
end
function OptionsManager:set_music_volume(n)
	self:set("music_volume", n)
	game:set_music_volume( self:get("music_volume") )

	self:update_options_file()
end

function OptionsManager:toggle_timer()
	self:toggle("timer_on")

	self:update_options_file()
end

function OptionsManager:toggle_mouse_visible()
	self:toggle("mouse_visible")

	self:update_options_file()
end

function OptionsManager:toggle_pause_on_unfocus()
	self:toggle("pause_on_unfocus")

	self:update_options_file()
end

function OptionsManager:toggle_screenshake()
	self:toggle("screenshake_on")

	self:update_options_file()
end
function OptionsManager:toggle_background_noise()
	self:toggle("disable_background_noise")

	self:update_options_file()
end

function OptionsManager:get_controls(n, btn)
	if not btn then
		return self.control_schemes[n]
	end
	
	return self.control_schemes[n][btn]
end

function OptionsManager:set_button_bind(n, btn, scancodes)
	if type(scancodes) ~= table then
		scancodes = {scancodes}
	end
	
	self.control_schemes[n][btn] = scancodes
	local player = game.players[n]
	if player == nil then  print("set_btn_bind: player",n,"doesn't exist") return end

	-- D-pad controls will always be assigned to L/R/U/D
	if is_in_table({"left", "right", "up", "down"}, btn) then
		table.insert(scancodes, btn)
	end

	player:set_controls(btn, scancodes)

	self:update_controls_file()
end

function OptionsManager:check_if_key_in_use(scancode)
	if true then
		return true
	end
	for i=1, #self.control_schemes do
		for k,v in pairs(self.control_schemes[i]) do
			if type(v) == "table" then
				for _,code in pairs(v) do
					if code == scancode then
						return true
					end
				end
			end
		end
	end
	return false
end

function OptionsManager:on_quit()
	self:update_options_file()
	self:update_controls_file()
end

function OptionsManager:reset_controls()
	self.control_schemes = copy_table(self.default_control_schemes)
	self:update_controls_file()
end

return OptionsManager