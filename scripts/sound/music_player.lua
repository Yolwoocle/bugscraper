require "scripts.util"
local Class = require "scripts.class"
local MusicDisk = require "scripts.sound.music_disk"
local sounds = require "data.sounds"

local MusicPlayer = Class:inherit()

function MusicPlayer:init()
	self.disks = {
		["w1"] = MusicDisk:new(sounds.music_w1_unpaused[1], sounds.music_w1_paused[1])
	}

	-- self.music_source    = sounds.music_galaxy_trip[1]
	-- self.sfx_elevator_bg = sounds.elevator_bg[1]
	-- self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	-- self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	
	self.current_disk = self.disks["w1"]
	self.current_disk:set_mode(MUSIC_MODE_INGAME)

	self:reset()
end

function MusicPlayer:reset()
	self:stop()
end

function MusicPlayer:set_disk(disk_name)
	local disk = self.disks[disk_name]
	if disk == nil then   error("set_disk: the disk'"..tostring(disk_name).."' doesn't exist")   end

	self.current_disk:stop()
	self.current_disk = disk
end

function MusicPlayer:on_menu()
	self:pause()
end

function MusicPlayer:on_unmenu()
	self:play()
end

function MusicPlayer:pause()
	if self.current_disk ~= nil then
		self.current_disk:set_mode(MUSIC_MODE_PAUSE)
		-- self.current_disk:pause()
	end
end

function MusicPlayer:play()
	self.current_disk:play()
	if self.current_disk ~= nil then
		self.current_disk:set_mode(MUSIC_MODE_INGAME)
		-- self.current_disk:play()
	end
end

function MusicPlayer:stop()
	if self.current_disk ~= nil then
		self.current_disk:stop()
	end
end

function MusicPlayer:set_volume(vol)
	-- TODO
	-- self.source:setVolume(vol*0.7)
end

function MusicPlayer:update(dt)
	
end

return MusicPlayer