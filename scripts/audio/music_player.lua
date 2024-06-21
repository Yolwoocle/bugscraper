require "scripts.util"
local Class = require "scripts.meta.class"
local MusicDisk = require "scripts.audio.music_disk"
local MusicDiskWeb = require "scripts.audio.music_disk_web"
local Timer = require "scripts.timer"

local sounds = require "data.sounds"

local MusicPlayer = Class:inherit()

function MusicPlayer:init()
	local disk_class = ternary(OPERATING_SYSTEM == "Web", MusicDiskWeb, MusicDisk)
	-- local disk_class = MusicDiskWeb
	self.disks = {
		["intro"] =           disk_class:new(self, sounds.music_intro_ingame.source, sounds.music_intro_paused.source),
		["w1"] =              disk_class:new(self, sounds.music_w1_ingame.source, sounds.music_w1_paused.source),
		["w2"] =              disk_class:new(self, sounds.music_w1_ingame.source, sounds.music_w1_paused.source),
		
		["game_over"] =       disk_class:new(self, sounds.music_game_over.source, sounds.music_game_over.source),
		["cafeteria"] =       disk_class:new(self, sounds.music_cafeteria_ingame.source, sounds.music_cafeteria_paused.source),
		["cafeteria_empty"] = disk_class:new(self, sounds.music_cafeteria_empty_ingame.source, sounds.music_cafeteria_paused.source),
		["miniboss"] =        disk_class:new(self, sounds.music_miniboss_ingame.source, sounds.music_miniboss_paused.source),
	}
	for name, disk in pairs(self.disks) do
		disk:set_name(name)
	end

	-- self.music_source    = sounds.music_galaxy_trip[1] 
	-- self.sfx_elevator_bg = sounds.elevator_bg[1]
	-- self.sfx_elevator_bg_volume     = self.sfx_elevator_bg:getVolume()
	-- self.sfx_elevator_bg_def_volume = self.sfx_elevator_bg:getVolume()
	
	self.volume = Options:get("music_volume")

	self.music_mode = MUSIC_MODE_INGAME
	self.current_disk = self.disks["intro"]
	self.current_disk:set_mode(self.music_mode)
	self.pause_volume = 0.5

	self.fadeout_timer = Timer:new(1.0)
	self.fadeout_volume = 1.0
	self.queued_disk = nil

	self:reset()
	self:update()
end

function MusicPlayer:reset()
	self:stop()
end

function MusicPlayer:update(dt)
	if self.current_disk ~= nil then
		self.current_disk:set_volume(self:get_total_volume())
		self.current_disk:update(dt)
		
		if not Options:get("play_music_on_pause_menu") and self.music_mode == MUSIC_MODE_PAUSE then
			self.current_disk:set_volume(0)
		end
	end

	self:update_fadeout(dt)
end

function MusicPlayer:update_fadeout(dt)
	if self.fadeout_timer.is_active then
		self:set_fadeout_volume(self.fadeout_timer:get_time() / self.fadeout_timer:get_duration())
	end
	
	if self.fadeout_timer:update(dt) then
		self:set_disk(self.queued_disk)
		self:set_fadeout_volume(1.0)
	end
end

function MusicPlayer:set_disk(disk_name)
	if disk_name == "off" then
		self.current_disk = nil
		self:stop()
		return
	end
	
	local disk = self.disks[disk_name]
	if disk == nil then
		error("MusicPlayer:set_disk: the disk'"..tostring(disk_name).."' doesn't exist")
	end
	if self.current_disk and disk_name == self.current_disk.name then 
		return 
	end
	
	if self.current_disk then
		self.current_disk:stop()
	end
	
	self.current_disk = disk
	if self.current_disk then
		self:set_music_mode(self.music_mode)
	end
	self:play()
end

function MusicPlayer:fade_out(new_disk, duration)
	if self.current_disk and new_disk == self.current_disk.name then 
		return 
	end

	self.fadeout_timer:set_duration(duration)
	self.fadeout_timer:start()
	self.queued_disk = new_disk
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

function MusicPlayer:set_fadeout_volume(vol)
	self.fadeout_volume = vol
end

function MusicPlayer:get_total_volume()
	local volume = self.volume * self.fadeout_volume
	if self.music_mode == MUSIC_MODE_PAUSE then
		volume = volume * self.pause_volume
	end
	return volume
end


return MusicPlayer