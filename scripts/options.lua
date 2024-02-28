require "scripts.util"
local Class = require "scripts.class"
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

	self.control_presets = {
		[1] = {
			left =  {"k_a", "k_left",     "c_dpleft",  "c_leftstickxneg", "c_rightstickxneg"},
			right = {"k_d", "k_right",    "c_dpright", "c_leftstickxpos", "c_rightstickxpos"},
			up =    {"k_w", "k_up",       "c_dpup",    "c_leftstickyneg", "c_rightstickyneg"},
			down =  {"k_s", "k_down",     "c_dpdown",  "c_leftstickypos", "c_rightstickypos"},
			jump =  {"k_z", "k_c", "k_b", "c_a", "c_b"},
			shoot = {"k_x", "k_v", "k_n", "c_x", "c_y", "c_righttrigger"},
			pause = {"k_escape", "k_p",   "c_start"},

			ui_select = {"k_return", "k_z", "k_c", "k_b", "k_x", "k_v", "k_n", "c_a"},
			ui_back =   {"k_escape",       "c_b"},
			ui_left =   {"k_a", "k_left",  "c_dpleft"},
			ui_right =  {"k_d", "k_right", "c_dpright"},
			ui_up =     {"k_w", "k_up",    "c_dpup"},
			ui_down =   {"k_s", "k_down",  "c_dpdown"},
		},
	}

	self.control_schemes = copy_table(self.control_presets)

	self:load_options()
	self:load_controls()
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

function OptionsManager:load_controls()
	if love.filesystem.getInfo == nil then
		print("/!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading controls for players aborted, so custom keybinds will not be loaded.")
		return
	end
	for n=1, #self.control_schemes do
		local filename = concat("controls_p",n,".txt")

		-- Check if file exists
		local file_exists = love.filesystem.getInfo(filename)
		if not file_exists then
			print(filename, "does not exist, so creating it")
			self:update_controls_file()
			break
		end

		local file = love.filesystem.newFile(filename)
		file:open("r")

		-- Read file contents
		local text, size = file:read()
		if not text then    print(concat("Error reading ",filename,": ",size))    end
		local lines = split_str(text, "\n") -- Split lines
	
		for iline = 1, #lines do
			local line = lines[iline]
			local tab = split_str(line, ":")
			local key, value = tab[1], tab[2]
	
			if self.control_schemes[n][key] ~= nil then
				local typ = type(self.control_schemes[n][key])
				local val
				if typ == "string" then   val = value    end
				if typ == "number" then   val = tonumber(value)   end
				if typ == "boolean" then   val = strtobool(value)   end
				if typ == "table" then   val = split_str(value, ",")   end

				if value ~= nil then
					self.control_schemes[n][key] = val
				else
					print(concat("Invalid reading of p",n," button ",key," (nil found)"))
				end
			else
				print(concat("Error: option '",key,"' does not exist"))
			end
		end

		file:close()
	end
end

function OptionsManager:update_options_file()
	-- print("Creating or updating options.txt file")
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
	local is_fullscreen = self:get("is_fullscreen")
	love.window.setFullscreen(is_fullscreen)

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

function OptionsManager:on_quit()
	self:update_options_file()
	self:update_controls_file()
end

function OptionsManager:reset_controls()
	self.control_schemes = copy_table(self.control_presets)
	self:update_controls_file()
end

return OptionsManager