require "util"
local Class = require "class"
local images = require "data.images"
local sounds = require "data.sounds"

local AudioManager = Class:inherit()

function AudioManager:init()
end

function AudioManager:update()
	
end

function AudioManager:play(snd, volume, pitch, object)
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
		if object then self:set_source_position_relative_to_object(source, object) end
		source:play()
	end
end

function AudioManager:play_pitch(snd, pitch, object)
	if not snd then      return   end
	if pitch <= 0 then   return   end

	local sfx = sounds[snd]
	if not sfx then   return   end
	sfx:setPitch(pitch)
	if object then self:set_source_position_relative_to_object(sfx, object) end
	self:play(sfx)
	--snd:setPitch(1)
end

function AudioManager:play_random_pitch(snd, var, object)
	var = var or 0.2
	local pitch = random_range(1/var, var)
	self:play_pitch(snd, pitch, object)
end

function AudioManager:play_var(snd, vol_var, pitch_var, parms)
	parms = parms or {}
	var = var or 0.2
	local def_vol = parms.volume or 1
	local volume = random_range(def_vol-vol_var, def_vol)
	local pitch = random_range(1/pitch_var, pitch_var) * (parms.pitch or 1)
	self:play(snd, volume, pitch, parms.object)
end

function AudioManager:set_music(name)
	-- Unused
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

function AudioManager:set_source_position_relative_to_object(source, obj)
	if not source then print("AudioManager:set_source_position_relative_to_object : No source defined!") return end
	if not obj then print("AudioManager:set_source_position_relative_to_object : No object defined!") return end
	local mult = 0.05
	source:setPosition(
		mult * (obj.x - CANVAS_WIDTH*.5) / (CANVAS_WIDTH),
		mult * (obj.y - CANVAS_HEIGHT*.5) / (CANVAS_HEIGHT)
	)
end

return AudioManager