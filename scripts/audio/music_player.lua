require "scripts.util"
local Class = require "scripts.meta.class"
local MusicDisk = require "scripts.audio.music_disk"
local MusicDiskWeb = require "scripts.audio.music_disk_web"
local Timer = require "scripts.timer"

local sounds = require "data.sounds"

local MusicPlayer = Class:inherit()

function MusicPlayer:init(disks, default_disk, params)
	params = params or {}
	-- local disk_class = MusicDiskWeb
	self.disks = disks or {}
	for name, disk in pairs(self.disks) do
		disk:set_name(name)
	end

	self.volume = params.volume or 1.0 

	self.music_mode = MUSIC_MODE_INGAME
	self.current_disk = self.disks[default_disk]
	self.current_disk:set_mode(self.music_mode)
	self.pause_volume = 0.5

	self.fadeout_timer = Timer:new(1.0)
	self.fadeout_volume = 1.0
	self.queued_disk = nil

	self.processes_pause = param(params.processes_pause, false)

	self.buffer_playback_position = nil
	self.load_buffer_playback_position_after_fadeout = false

	self:reset()
	self:update()
end

function MusicPlayer:reset()
	self:stop()
end

function MusicPlayer:update(dt)
	if self.current_disk ~= nil then
		self:update_current_disk(dt)
	end

	self:update_fadeout(dt)
end

function MusicPlayer:update_current_disk(dt)
	self.current_disk:set_volume(self:get_total_volume())
	self.current_disk:update(dt)
	
	if self.processes_pause and (not Options:get("play_music_on_pause_menu") and self.music_mode == MUSIC_MODE_PAUSE) then
		self.current_disk:set_volume(0)
	end
end

function MusicPlayer:update_fadeout(dt)
	if self.fadeout_timer.is_active then
		self:set_fadeout_volume(self.fadeout_timer:get_time() / self.fadeout_timer:get_duration())
	end
	
	if self.fadeout_timer:update(dt) then
		self:set_disk(self.queued_disk)
		self:set_fadeout_volume(1.0)
		if self.load_buffer_playback_position_after_fadeout and self.buffer_playback_position then
			self.current_disk.current_source:seek(self.buffer_playback_position)
			self.load_buffer_playback_position_after_fadeout = false
			self.buffer_playback_position = nil
		end
	end
end

function MusicPlayer:set_disk(disk_name, flags)
	flags = flags or {}
	if disk_name == "off" then
		self:stop()
		self.current_disk = nil
		return
	end
	
	local disk = self.disks[disk_name]
	if disk == nil then
		error("MusicPlayer:set_disk: the disk '"..tostring(disk_name).."' doesn't exist")
	end
	if self.current_disk and disk_name == self.current_disk.name then 
		return 
	end
	
	local previous_disk_time = 0.0
	if flags.continue_previous_pos and self.current_disk then
		if self.current_disk.current_source then
			local current_source = self.current_disk.current_source
			previous_disk_time = current_source:tell()
		end
	end
	
	if self.current_disk then
		self.current_disk:stop()
	end

	self.current_disk = disk
	if self.current_disk then
		self:set_music_mode(self.music_mode)
	end
	self:play()
	self:update_current_disk()

	if flags.continue_previous_pos and self.current_disk and self.current_disk.current_source then
		local source = self.current_disk.current_source
		source:seek(previous_disk_time)
	end
end

function MusicPlayer:fade_out(new_disk, duration, params)
	params = params or {}
	if self.current_disk and new_disk == self.current_disk.name then 
		return 
	end

	if params.push_playback_position and self.current_disk then
		self.buffer_playback_position = self.current_disk.current_source:tell()
	end
	if params.pull_playback_position and self.current_disk then
		self.load_buffer_playback_position_after_fadeout = true
	end

	self.fadeout_timer:set_duration(duration)
	self.fadeout_timer:start()
	self.queued_disk = new_disk
end

function MusicPlayer:on_menu()
	if game.menu_manager.cur_menu and game.menu_manager.cur_menu.do_pause_music_mode then
		self:set_music_mode(MUSIC_MODE_PAUSE)
	end

	if self.processes_pause and Options:get("play_music_on_pause_menu") then
		if self.current_disk ~= nil then
			self.current_disk:play()
		end	
	else 
		self:pause()
	end
end

function MusicPlayer:on_unmenu()
	self:set_music_mode(MUSIC_MODE_INGAME)

	if self.processes_pause and Options:get("play_music_on_pause_menu") then
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
	if self.current_disk then
		volume = volume * self.current_disk.volume
	end
	return volume
end


return MusicPlayer