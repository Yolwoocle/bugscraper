require "util"
local Class = require "class"
local images = require "data.images"
local utf8 = require "utf8"

local OptionsManager = Class:inherit()

function OptionsManager:init(game)
	self.game = game
	self.options = {
		volume = 1,
		sound_on = true,

		is_vsync = true,
		is_fullscreen = true,
		pixel_scale = "auto",
	}

	self:load_options()
end

function OptionsManager:load_options()
	local options_file_exists = love.filesystem.getInfo("options.txt")
	if not options_file_exists then
		print("options.txt does not exist, so creating it")
		self:update_options_file()
		return
	end

	local file = love.filesystem.newFile("options.txt")
	file:open("r")
	
	local text, size = file:read()
	if not text then    print("Error reading options.txt file: "..size)    end
	local contents = split_str(text, "\n")

	for i = 1, #contents do
		local line = contents[i]
		local tab = split_str(line, ":")
		local key, value = tab[1], tab[2]
		print("file(key, val):", key, value)

		if self.options[key] then
			local typ = type(self.options[key])
			print("type(self.options[key])", type(self.options[key]))
			local val
			if typ == "string" then   val = value    end
			if typ == "number" then   val = tonumber(value)   end
			if typ == "boolean" then   val = strtobool(value)   end
			if typ == "table" then   val = split_str(value, ",")   end
			print(val, type(val))

			self.options[key] = val
		else
			print(concat("Error: option '",key,"' does not exist"))
		end
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

function OptionsManager:get(name)
	return self.options[name]
end

function OptionsManager:set(name, val)
	self.options[name] = val
end

function OptionsManager:toggle(name)
	self.options[name] = not self.options[name]
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

	self:update_options_file()
end

function OptionsManager:set_volume(n)
	self:set("volume", n)
	love.audio.setVolume( self:get("volume") )

	self:update_options_file()
end

return OptionsManager