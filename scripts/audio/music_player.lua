require "scripts.util"
local Class = require "scripts.meta.class"
local MusicDisk = require "scripts.audio.music_disk"
local sounds = require "data.sounds"

local MusicPlayer = Class:inherit()

function MusicPlayer:init()
	self.disks = {
		["intro"] = MusicDisk:new(self, sounds.music_intro_unpaused[1], sounds.music_intro_paused[1]),
		["w1"] =    MusicDisk:new(self, sounds.music_w1_unpaused[1], sounds.music_w1_paused[1]),
	}

	-- self.music_source    = sounds.music_galaxy_trip[1]
	-- self.sfx_elevator_bg = sounds.elevator_bg[1]
	-- self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	-- self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	
	self.music_mode = MUSIC_MODE_INGAME
	self.current_disk = self.disks["intro"]
	self.current_disk:set_mode(self.music_mode)

	self.volume = Options:get("music_volume")

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
	self:play()
end

function MusicPlayer:on_menu()
	self:set_music_mode(MUSIC_MODE_PAUSE)

	if Options:get("play_music_on_pause_menu") then
		if self.current_disk ~= nil then
			self.current_disk:play()
		end	
	else 
		self:pause()
	end
end

function MusicPlayer:on_unmenu()
	self:set_music_mode(MUSIC_MODE_INGAME)

	if Options:get("play_music_on_pause_menu") then
		if self.current_disk ~= nil then
			self.current_disk:play()
		end
	else
		self:play()
	end
end

function MusicPlayer:set_music_mode(mode)
	self.music_mode = mode
	if self.current_disk ~= nil then
		self.current_disk:set_mode(mode)
	end
end

function MusicPlayer:pause()
	if self.current_disk ~= nil then
		self.current_disk:pause()
	end
end

function MusicPlayer:play()
	if self.current_disk ~= nil then
		self.current_disk:play()
	end
end

function MusicPlayer:stop()
	if self.current_disk ~= nil then
		self.current_disk:stop()
	end
end

function MusicPlayer:set_volume(vol)
	self.volume = vol
end

function MusicPlayer:update(dt)
	if self.current_disk ~= nil then
		self.current_disk:set_volume(self.volume)
		
		if not Options:get("play_music_on_pause_menu") and self.music_mode == MUSIC_MODE_PAUSE then
			self.current_disk:set_volume(0)
		end
	end
end

return MusicPlayer