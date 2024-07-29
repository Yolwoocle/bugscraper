require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"
local images = require "data.images"
local utf8 = require "utf8"

local OptionsManager = Class:inherit()

function OptionsManager:init(game)
	self.game = game
	self.is_first_time = false
	self.default_options = {
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
	self:update_options_file()
end

function OptionsManager:toggle(name)
	self.options[name] = not self.options[name]
	self:update_options_file()
end

-----------------------------------------------------

function OptionsManager:toggle_fullscreen()
	-- local success = love.graphics.toggleFullscreen( )
	self:toggle("is_fullscreen")
	local is_fullscreen = self:get("is_fullscreen")
	game:update_fullscreen(is_fullscreen)
end

function OptionsManager:set_pixel_scale(scale)
	if not game then  return  end
	self:set("pixel_scale", scale)
	game:update_screen()
end

function OptionsManager:toggle_vsync()
	self:toggle("is_vsync")
	love.window.setVSync(self:get("is_vsync"))
end


function OptionsManager:toggle_sound()
	-- TODO: move from bool to a number (0-1), customisable in settings
	self:toggle("sound_on")
	self:update_sound_on()
end

function OptionsManager:update_sound_on()
	if self:get("sound_on") then
		self:set_volume(self:get("volume"))
	else
		love.audio.setVolume(0)
	end
end

function OptionsManager:set_screenshake(n)
	self:set("screenshake", n)
end

function OptionsManager:set_volume(n)
	self:set("volume", n)
	love.audio.setVolume( self:get("volume") )
end

function OptionsManager:set_music_volume(n)
	self:set("music_volume", n)
	game:set_music_volume( self:get("music_volume") )
end

function OptionsManager:toggle_timer()
	self:toggle("timer_on")
end

function OptionsManager:toggle_mouse_visible()
	self:toggle("mouse_visible")
end

function OptionsManager:toggle_pause_on_unfocus()
	self:toggle("pause_on_unfocus")
end

function OptionsManager:toggle_screenshake()
	self:toggle("screenshake_on")
end

function OptionsManager:toggle_background_noise()
	self:toggle("disable_background_noise")
end

function OptionsManager:toggle_play_music_on_pause_menu()
	self:toggle("play_music_on_pause_menu")
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