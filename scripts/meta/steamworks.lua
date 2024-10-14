require "scripts.util"
local creq = require "lib.creq.creq"
local Class = require "scripts.meta.class"
local Steam
local import_success
if pcall(function()
	Steam = require "luasteam"
end) then
	import_success = true
else
	print("Steamworks: error during import")
	import_success = false
end

-- Thanks to https://github.com/uspgamedev/luasteam

local Steamworks = Class:inherit()

function Steamworks:init()
	self.is_enabled = false
	self.import_success = import_success

	if not self.import_success then
		self.is_enabled = false
		print("Steamworks: error during import")
		return
	end

	self:enable()
end

function Steamworks:enable()
	Steam.init()
end

function Steamworks:disable()
	Steam.shutdown()
end

function Steamworks:update(dt)
	if not self.is_enabled then
		return
	end

	Steam.runCallbacks()
end

function Steamworks:quit()
	if not self.is_enabled then
		return
	end

	self:disable()
end

local steam_instance = Steamworks:new()

if not import_success then

	return steam_instance
end

return steam_instance

