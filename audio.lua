require "util"
local Class = require "class"
local images = require "data.images"
local sounds = require "data.sounds"

local AudioManager = Class:inherit()

function AudioManager:init()
end

function AudioManager:update()
	
end

function AudioManager:play(snd, volume, pitch)
	-- Formalise inputs
	if type(snd) == "string" then
		snd = sounds[snd]
	end
	if type(snd) == "table" then
		snd = random_sample(snd)
	end
	volume = volume or 1
	pitch = pitch or 1
	
	if options:get("sound_on") and snd then
		local source = snd:clone()
		source:setVolume(volume * source:getVolume())
		source:setPitch(pitch   * source:getPitch())
		source:play()
	end
end

function AudioManager:play_pitch(snd, pitch)
	if not snd then      return   end
	if pitch <= 0 then   return   end

	local sfx = sounds[snd]
	if not sfx then   return   end
	sfx:setPitch(pitch)
	self:play(sfx)
	--snd:setPitch(1)
end

function AudioManager:play_random_pitch(snd, var)
	var = var or 0.2
	local pitch = random_range(1/var, var)
	self:play_pitch(snd, pitch)
end


function AudioManager:play_var(snd, vol_var, pitch_var)
	var = var or 0.2
	local volume = random_range(1-vol_var, 1)
	local pitch = random_range(1/pitch_var, pitch_var)
	self:play(snd, volume, pitch)
end

function AudioManager:set_music(name)
	local track = self.music_tracks[name]
	if track then
		self.curmusic_name = name
		self.curmusic = track
	end
end

function AudioManager:play_music()
	if game.music_on then
		self.curmusic:play()
	end
end

function AudioManager:pause_music()
	self.curmusic:pause()
end

function AudioManager:on_leave_start_area()
	self:play_music()
end

function AudioManager:on_pause()
	self:pause_music()
end

function AudioManager:on_unpause()
	self:play_music()
end

return AudioManager