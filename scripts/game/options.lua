require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"
local images = require "data.images"
local utf8 = require "utf8"

local OptionsManager = Class:inherit()

function OptionsManager:init()
	self.is_first_time = false
	self.default_options = {
		language = "en",

		volume = 1.0,
		music_volume = 0.5,
		screenshake = 1.0,
		sound_on = true,
		disable_background_noise = false,
		play_music_on_pause_menu = true,

		is_vsync = true,
		is_fullscreen = true,
		pixel_scale = "auto",
		windowed_width = CANVAS_WIDTH,
		windowed_height = CANVAS_HEIGHT,
		is_window_maximized = true,
		menu_blur = true,
		background_speed = 1.0,

		timer_on = false,
		mouse_visible = false,
		pause_on_unfocus = ternary(love.system.getOS() == "Web", false, true),
		screenshake_on = true,
		show_fps_warning = true,

		button_style_p1 = BUTTON_STYLE_DETECT,
		button_style_p2 = BUTTON_STYLE_DETECT,
		button_style_p3 = BUTTON_STYLE_DETECT,
		button_style_p4 = BUTTON_STYLE_DETECT,

		axis_deadzone_p1 = AXIS_DEADZONE,
		axis_deadzone_p2 = AXIS_DEADZONE,
		axis_deadzone_p3 = AXIS_DEADZONE,
		axis_deadzone_p4 = AXIS_DEADZONE,

		vibration_p1 = 1.0,
		vibration_p2 = 1.0,
		vibration_p3 = 1.0,
		vibration_p4 = 1.0,

		has_seen_stomp_tutorial = false,

		removeme_test_option = 0.5,
	}
	self.setters = {
		sound_on = function(value) 
			if value then
				love.audio.setVolume(self:get("volume"))
			else
				love.audio.setVolume(0)
			end
		end,
		volume = function(value) 
			love.audio.setVolume(value)
		end,
		music_volume = function(value)
			game:set_music_volume(value)
		end,
		play_music_on_pause_menu = function(value)
			if value then
                game.music_player:play() --TODO test this
            end
		end,

		is_fullscreen = function(value)
			game:update_fullscreen(value)
		end,
		pixel_scale = function(value)		
			if not game then 
				return	
			end
			game:update_screen()
		end,
		is_vsync = function(value)
			love.window.setVSync(value)
		end,
		mouse_visible = function(value)
            love.mouse.setVisible(value)
		end,
	}
	self.options = copy_table(self.default_options)

	self:load_options()
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

function OptionsManager:get(name)
	return self.options[name]
end

function OptionsManager:set(name, val)
	self.options[name] = val
	if self.setters[name] then
		self.setters[name](val)
	end
	self:update_options_file()
end

function OptionsManager:toggle(name)
	self:set(name, not self.options[name])
end

function OptionsManager:update_volume()
	love.audio.setVolume(self:get("sound_on") and self:get("volume") or 0.0)
end


-----------------------------------------------------

-- DEPRACATED

function OptionsManager:toggle_screenshake()
	self:toggle("screenshake_on")
end

function OptionsManager:toggle_background_noise()
	self:toggle("disable_background_noise")
end

function OptionsManager:on_quit()
	self:update_options_file()
end

function OptionsManager:set_button_style(player_n, style)
	self:set("button_style_p"..tostring(player_n), style)
end

function OptionsManager:set_axis_deadzone(player_n, style)
	self:set("axis_deadzone_p"..tostring(player_n), style)
end

return OptionsManager